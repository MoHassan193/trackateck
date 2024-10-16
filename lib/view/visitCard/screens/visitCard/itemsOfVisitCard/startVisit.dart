import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/userModel/userModel.dart';
import 'dart:math';
import 'package:intl/intl.dart';


import 'package:visit_man/model_view/cubits/postCubit/endVisitCubit/end_visit_cubit.dart';

import '../../../../../model/dialToast.dart';
import '../reschudleAndCancelWidget/ReschudleAndCancelWidget.dart';

class StartTimer extends StatefulWidget {
  const StartTimer({
    Key? key, required this.partnerData, required this.visitId,required this.state
  }) : super(key: key);
  final Map<String, dynamic> partnerData;
  final int visitId;
  final String state;




  @override
  State<StartTimer> createState() => _StartTimerState();
}

class _StartTimerState extends State<StartTimer> {
  bool _canStartVisit = false;

  bool _checkedIn = false;
  bool _visitEnded = false;
  DateTime? _checkInTime;
  DateTime? _checkOutTime;
  Timer? _timer;
  int _seconds = 0;
  late UserModel userModel;
  DateTime now = DateTime.now();
  bool visitCompleted = false; // متغير للتحكم في إظهار الأزرار

  Future<void> _refreshData() async {
    // Perform your data refresh actions
    await _checkLocationMatch();
    await loadUserModel();
    await _checkVisitCompletion();

    // This will update the UI with the new data
    setState(() {
      // Here you could also modify other variables if needed
      // e.g., _canStartVisit, visitCompleted, etc.
    });
  }

  @override
  void initState() {
    super.initState();
    _checkLocationMatch();
    loadUserModel();
    _checkVisitCompletion();  // Add this check
    _canStartVisit = widget.partnerData['check_location'] == false ? true : false;
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000; // Earth's radius in meters
    double dLat = _degreeToRadian(lat2 - lat1);
    double dLon = _degreeToRadian(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreeToRadian(lat1)) * cos(_degreeToRadian(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance in meters
  }

  double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }

  Future<void> _checkLocationMatch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // استرجاع إحداثيات الشريك والموقع الحالي من SharedPreferences
    double? partnerLatitude = widget.partnerData['partner_latitude'];
    double? partnerLongitude = widget.partnerData['partner_longitude'];
    double? currentLatitude = prefs.getDouble('latitude');
    double? currentLongitude = prefs.getDouble('longitude');

    // إذا كان check_location = false، اجعل canStartVisit = true مباشرة
    if (widget.partnerData['check_location'] == false) {
      setState(() {
        _canStartVisit = true;
      });
      return;
    }

    // إذا كان check_location = true، تحقق من المسافة
    if (partnerLatitude != null &&
        partnerLongitude != null &&
        currentLatitude != null &&
        currentLongitude != null) {
      double distance = _calculateDistance(
          partnerLatitude, partnerLongitude, currentLatitude, currentLongitude);

      if (distance < 500) {
        setState(() {
          _canStartVisit = true;
        });
      } else {
        setState(() {
          _canStartVisit = false;
        });
      }
    } else {
      setState(() {
        _canStartVisit = false;
      });
    }
  }
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatTime() {
    int minutes = _seconds ~/ 60;
    int seconds = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _checkIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String visitKey = 'visit_${widget.visitId}_checkInTime';

    // تحقق إذا كان هناك Check-In تم مسبقًا لهذه الزيارة
    if (prefs.containsKey(visitKey)) {
      DialToast.showToast("You have already checked in for this visit", Colors.red);
      return; // الخروج إذا كان Check-In موجود مسبقًا
    }

    setState(() {
      _checkedIn = true;
      _checkInTime = DateTime.now(); // استخدام الوقت الحالي كوقت Check-In

      _seconds = 0; // إعادة ضبط التايمر
    });

    // بدء التايمر
    _startTimer();

    // حفظ البيانات في SharedPreferences
    await prefs.setString('inDoom', 'True');
    await prefs.setString('state', 'done');
    await prefs.setString(visitKey, _checkInTime.toString());
  }


  void _checkOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String checkOutKey = 'visit_${widget.visitId}_checkOutTime';

    // تحقق إذا كان هناك Check-Out تم مسبقًا لهذه الزيارة
    if (prefs.containsKey(checkOutKey)) {
      DialToast.showToast("You have already checked out for this visit", Colors.red);
      return; // الخروج إذا كان Check-Out موجود مسبقًا
    }
    setState(() {
      _checkOutTime = DateTime.now(); // استخدام الوقت الحالي كوقت Check-Out
      _checkedIn = false;
    });

    // إيقاف التايمر
    _stopTimer();

    // حساب مدة الزيارة
    Duration visitDuration = _checkOutTime!.difference(_checkInTime!);
    String formattedDuration = '${visitDuration.inMinutes.toString().padLeft(2, '0')}:${(visitDuration.inSeconds % 60).toString().padLeft(2, '0')}';

    // حفظ وقت Check-Out ومدة الزيارة في SharedPreferences باستخدام visitId
    await prefs.setString(checkOutKey, _checkOutTime.toString());
    await prefs.setString('visit_${widget.visitId}_duration', formattedDuration);

    // إظهار زر End Visit
    setState(() {
      _visitEnded = true;
    });

    // عرض رسالة توست تحتوي على وقت Check-In وCheck-Out والمدة
    DialToast.showToast(
        "Check In At: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(_checkInTime!)} \n"
            "Check Out At: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(_checkOutTime!)} \n"
            "Duration: $formattedDuration",
        Colors.green
    );
  }




  Future<void> loadUserModel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = prefs.getString('sessionData');
      if (sessionData != null) {
        userModel = UserModel.fromJson(jsonDecode(sessionData));
      } else {
        throw Exception('No user data found');
      }
    } catch (e) {
      print(e);
    }
  }



  Future<void> endAndUpdateVisit() async {

    await loadUserModel();
    print(userModel.accessToken);
    final prefs = await SharedPreferences.getInstance();

    // Read stored values from SharedPreferences
    String? inDoom = prefs.getString('inDoom');
    String? state = prefs.getString('state');




    // Ensure values were retrieved successfully

      final dio = Dio();
      final String? url = prefs.getString('storedUrl'); // Get the API URL

      if (url == null || url.isEmpty) {
        print('Error: URL not found in SharedPreferences');
        DialToast.showToast('Failed to end visit', Colors.red);
        return;
      }


      // Send visit data to the API
      final request = {
        'in_doom': '"$inDoom"',
        'check_in': DateFormat('yyyy-MM-dd HH:mm:ss').format(_checkInTime!),
        'check_out': DateFormat('yyyy-MM-dd HH:mm:ss').format(_checkOutTime!),
        'state': state,
        'rank_id': widget.partnerData['rank_id'] is int ? widget.partnerData['rank_id'] : 0,
        'behave_style_id': widget.partnerData['behave_style_id'] is int ? widget.partnerData['behave_style_id'] : 0,
        'segment_id': widget.partnerData['segment_id'] is int ? widget.partnerData['segment_id'] : 0,
        'classification_id': widget.partnerData['classification_id'] is int ? widget.partnerData['classification_id'] : 0,
        'no_patient': widget.partnerData['no_patient'] is int ? widget.partnerData['no_patient'] : 0,
        'survey_id': widget.partnerData['survey'] is int ? widget.partnerData['survey'] : 0,
        'client_attitude': widget.partnerData['client_attitude'] ?? 'excellent',
      };

      final response = await dio.post(
        '$url/api/${widget.visitId}/update_visit',
        options: Options(
           contentType: Headers.formUrlEncodedContentType,
          headers: {
            'token': userModel.accessToken
          },
        ),
        data: request,
      );

      // Check the response status
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final inDoom = data['in_doom'];
        final checkIn = data['check_in'];
        final checkOut = data['check_out'];
        final state = data['state'];
        final clientAttitude = data['client_attitude'];


        DialToast.showToast(
            "Visit updated successfully\n\n"
            "Check In At : $checkIn \nCheck Out At : $checkOut"
            "In Doom : $inDoom \nState : $state \nClient Attitude : $clientAttitude",
            Colors.green);
        Navigator.pop(context);
        // Resetting the state of the page
        setState(() {
          _canStartVisit = false;
          _checkedIn = false;
          _visitEnded = false;
          visitCompleted = true;

        });
      } else {
        DialToast.showToast("Failed to update visit", Colors.red);
      }
  }

  Future<void> _checkVisitCompletion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String checkOutKey = 'visit_${widget.visitId}_checkOutTime';

    // Check if the Check-Out key exists in SharedPreferences
    if (!prefs.containsKey(checkOutKey)) {
      setState(() {
        visitCompleted = true;  // No Check-Out exists, set visitCompleted to true
      });
    } else {
      setState(() {
        visitCompleted = false;  // Check-Out exists, keep visit in progress
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _refreshData,  // This function will be called on pull-to-refresh
        child: visitCompleted
            ? Column(
      children: [
        ReschudleAndCancelWidget(
          visitId: widget.visitId.toString(),
          state: widget.state,
        ),
        SizedBox(height:   15,),
        if (_canStartVisit)
          _checkedIn
              ? Container(
            decoration: BoxDecoration(
              color: Colors.white, // لون الخلفية
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.cyan, width: 2),
            ),
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.all(15),
            child: Column(
              children: [
                Text(
                  'Check-In Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(_checkInTime!)}',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                Text(
                  'Elapsed Time: ${_formatTime()}',
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: OutlinedButton(
                    onPressed: _checkOut, // Stop the timer and register check-out
                    child: const Text(
                      "Check-Out",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                if (_checkOutTime != null)
                  Text(
                    'Check-Out Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(_checkOutTime!)}',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
              ],
            ),
          ) : Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton(
                  onPressed: _checkIn, // Register check-in and start the timer
                  child: const Text(
                    "Check-In",
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10),
              if (_visitEnded)
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: OutlinedButton(
                    onPressed: () async {
                      await endAndUpdateVisit();
                    },
                    child: const Text(
                      "End Visit",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
            ],
          )
        else
          Column(
            children: [
              SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: OutlinedButton(
                  onPressed: () {
                    DialToast.showToast(
                      "You are not in Location,\nplease check your location",
                      Colors.red,
                    );
                  },
                  child: Text(
                    "Check In",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
      ],
    ) : SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: OutlinedButton(onPressed: () {
            DialToast.showToast(
              "Visit Completed",Colors.green
            );
          } , child: Text("Visit Done")))
    );
  }
}
