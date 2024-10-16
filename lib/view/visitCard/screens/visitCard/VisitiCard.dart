import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/commonWidget/networkImageCustom/networkImageCustom.dart';
import 'package:visit_man/model/dialToast.dart';
import 'package:visit_man/model/utils/sizes.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getActivityOnly/getActivityCubitOnly.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getActivityOnly/getActivityStateOnly.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getTodayVisitCubit/get_today_visit_cubit.dart';
import 'package:visit_man/model_view/cubits/postCubit/mapCubit/mapCubit.dart';
import 'package:visit_man/view/visitCard/screens/visitCard/itemsOfVisitCard/startVisit.dart';
import 'package:visit_man/view/visitCard/widgets/mapPartner/mapPartner.dart';
import 'package:visit_man/view/visitCard/widgets/partnerInfo/partnerInfoPage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../model/userModel/userModel.dart';
import '../../../../model/utils/move.dart';
import '../../../../model_view/cubits/mainCubitofWidget/getSurveyCubit/getSurveyCubit.dart';
import '../../../../model_view/cubits/mainCubitofWidget/getSurveyCubit/getSurveyState.dart';
import '../../../../model_view/cubits/mainCubitofWidget/partnerInfoCubit/partnerInfoCubit.dart';
import '../../widgets/getUsers/cubit/getUsersCubit.dart';
import '../../widgets/getUsers/cubit/getUsersState.dart';
import 'getActivityOnly/getActivityPage.dart';



class VisitCardPage extends StatefulWidget {
  const VisitCardPage({Key? key, required this.partnerid, required this.visitId, required this.state,required this.visitData, required this.isSale}) : super(key: key);
  final int partnerid;
  final int visitId;
  final String state;
  final bool isSale;
  final Map<String, dynamic> visitData; // Make it nullable to handle null cases

  @override
  State<VisitCardPage> createState() => _VisitCardPageState();
}

class _VisitCardPageState extends State<VisitCardPage> with SingleTickerProviderStateMixin {
  String userImage = '';
  String userName = '';
final TextEditingController _surveyIdController = TextEditingController();
final TextEditingController _userIdController = TextEditingController();
  bool _isDoubleVisit = false;
  String _doubleVisitType = 'audit';
  // استدعاء الدالة مباشرةً عند بناء الشاشة
  @override
  void initState() {
    final mapCubit = MapCubit.get(context);

    mapCubit.loadAndSendCoordinates();
    super.initState();
    _loadVisitData();
    loadUserModel();
    tabController = TabController(length: 4, vsync: this); // 3 tabs in this case
  }


  late UserModel _userModel; // إضافة UserModel

  // وظيفة لتحميل بيانات المستخدم من SharedPreferences
  Future<void> loadUserModel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = prefs.getString('sessionData');
      if (sessionData != null) {
        _userModel = UserModel.fromJson(jsonDecode(sessionData));

        final cubit = BlocProvider.of<GetTodayVisitCubit>(context);
        cubit.fetchTodayVisits(userId: _userModel.uid.toString());
      } else {
        throw Exception('No user data found');
      }
    } catch (e) {
      print(e.toString());
    }
  }


  Future<void> updateVisitCard()async{

    await loadUserModel(); // تأكد من تحميل بيانات المستخدم قبل الجلب
    final prefs = await SharedPreferences.getInstance();
    final String? url = prefs.getString('storedUrl');

    if (url == null || url.isEmpty) {
      return;
    }

    final request = {
      'collaborative_id': int.tryParse(_userIdController.text),
      'is_double_visit': _isDoubleVisit ? "True" : "False",
      'survey_id': int.tryParse(_surveyIdController.text),
      'double_visit_type' : _doubleVisitType ?? 'audit',
    };

    final dio = Dio();
    final response = await dio.post('$url/api/${widget.visitId}/visit_update_nocheckout',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'token': _userModel.accessToken, // استخدام رمز التحقق
          },
        ),
        data: request
    );

    if(response.statusCode == 200){
      final data = response.data['data'];
      DialToast.showToast("Visit Card Updated Successfuly", Colors.green);
      tabController.animateTo(0);

    }else {
      DialToast.showToast("No Product for this Visit", Colors.red);
      print(response.data);
    }
  }

  String? checkInFormated;
  String? checkOutFormated;
  String? visitDuration;
  Future<void> _loadVisitData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // استرجاع القيم المخزنة
    String? checkInTimeString = prefs.getString('visit_${widget.visitId}_checkInTime');
    String? checkOutTimeString = prefs.getString('visit_${widget.visitId}_checkOutTime');
    visitDuration = prefs.getString('visit_${widget.visitId}_duration');

    // تحويل القيم المسترجعة إلى DateTime إذا كانت غير null
    DateTime? checkInTime = checkInTimeString != null ? DateTime.parse(checkInTimeString) : null;
    DateTime? checkOutTime = checkOutTimeString != null ? DateTime.parse(checkOutTimeString) : null;

    setState(() {
      // حفظ القيم المحدثة في المتغيرات
      checkInFormated = checkInTime != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(checkInTime) : null;
      checkOutFormated = checkOutTime != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(checkOutTime) : null;
    });


  }

  late TabController tabController;


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.blue, size: 25),
          ),
          title: Text(
            "Visit Card",
            style: TextStyle(color: Colors.blue),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(450), // تحديد الارتفاع المطلوب
            child: Padding(
              padding: EdgeInsets.only(
                right: MoSizes.md(context),
                left: MoSizes.md(context),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // لون الخلفية
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.cyan, width: 2),
                    ),
                    padding: EdgeInsets.all(8),
                    child: ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PartnerDetailPage(
                            visitDetails: widget.visitData,
                          ),
                        ),
                      ),
                      leading: NetworkImageCustom(
                        size: 35,
                        imageUrl: widget.visitData['partner_image'].toString() ?? '',
                      ),
                      title: Text(
                        widget.visitData['partner_id'].toString() ?? 'No Name',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      subtitle: widget.visitData['client_type'].toString() == 'doctor'
                          ? Text(
                        widget.visitData['speciality_name'].toString() ?? 'No Name',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                      )
                          : SizedBox(),
                    ),
                  ),
                  SizedBox(height: MoSizes.spaceBtwItems(context)),
                  StartTimer(
                    partnerData: widget.visitData,
                    visitId: widget.visitId,
                    state: widget.state,
                  ),
                  SizedBox(height: MoSizes.spaceBtwItems(context) * 0.5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: OutlinedButton.icon(
                      label: Text(
                        "Location",
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () => Move.move(
                        context,
                        MyMapPage(
                          partnerlatit: widget.visitData['partner_latitude'],
                          partnerlong: widget.visitData['partner_longitude'],
                          idPartner: widget.visitData['partner_rec_id'],
                        ),
                      ),
                      icon: Icon(Icons.location_on, color: Colors.blue),
                    ),
                  ),
                  SizedBox(height: height * 0.02,),
                  TabBar(
                    labelColor: Colors.blue,
                    indicatorColor: Colors.blue,
                    tabs: [
                      Tab(text: "Details"),
                      Tab(text: "Objectives"),
                      Tab(text: "Edit"),
                      Tab(text: "Duration"),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
            children: [
              RefreshIndicator(
                onRefresh: ()async {
                  await _loadVisitData();
                },
                child: Padding(
                  padding:  EdgeInsets.all(MoSizes.md(context)),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TitelsWidget(
                          title: "Visit Title",
                          answer: widget.visitData['title'].toString(),
                        ),
                        TitelsWidget(
                          title: "Territory",
                          answer: widget.visitData['territory_id'].toString(),
                        ),
                        if(!widget.isSale) TitelsWidget(
                          title: "Speciality",
                          answer: widget.visitData['speciality_name'].toString(),
                        ),
                        if(!widget.isSale) CenterTitleWidget(
                          title : "Products",
                        ),
                        if(!widget.isSale) widget.visitData['products'] != null  ?
                        Column(
                          children: widget.visitData['products'].map<Widget>((product) {
                            return ImageTitleWidget(
                                title: "${product['product_name'].toString()}", image: "${product['product_image_ur']}");
                          }).toList(),
                        ) : CenterTitleWidget(title: "No Products Found"),
                        CenterTitleWidget(
                          title : "Leave Behinds",
                        ),
                        widget.visitData['optional_products'] != null ?
                        Column(
                          children: widget.visitData['optional_products'].map<Widget>((product) {
                            return ImageTitleWidget(
                                title: "${product['product_name'].toString()}", image: "${product['product_image_ur']}");
                          }).toList(),
                        ) : CenterTitleWidget(title: "No Products Found"),
                      ],
                    ),
                  ),
                ),
              ),
              RefreshIndicator(
                onRefresh: ()async {
                  await _loadVisitData();
                },
                child: Padding(
                  padding:  EdgeInsets.all(MoSizes.md(context)),
                  child: SingleChildScrollView(
                      child: Column(
                        children: [
                          widget.visitData['objective_ids'] != null ?
                          Column(
                            children: widget.visitData['objective_ids'].map<Widget>((product) {
                              return CenterTitleWidget(
                                title: "${product['name'].toString()}",);
                            }).toList(),
                          ) : CenterTitleWidget(title: "No Objectives Found"),
                        ],
                      )
                  ),
                ),
              ),
              RefreshIndicator(
              onRefresh: ()async {
                await _loadVisitData();
              },
                child: Padding(
                  padding:  EdgeInsets.all(MoSizes.md(context)),
                  child: SingleChildScrollView(
                    child: widget.visitData['products'] != null ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildDoubleVisitSwitch(),
                        SizedBox(height: 10,),
                        if (_isDoubleVisit) ...[
                          _buildDoubleVisitTypeDropdown(),
                          SizedBox(height: 10,),
                          // _buildSurveyDropdown(),
                          // SizedBox(height: 10,),
                          _buildUserDropdown(),
                          SizedBox(height: 20,),
                          OutlinedButton(
                            onPressed: (){
                              updateVisitCard();
                            },
                            child: Text("Update Visit Card",style: TextStyle(color: Colors.blue),),
                          ),
                        ]



                      ],
                    ) :
                    CenterTitleWidget(title: "No Products Found For Edit"),
                  ),
                ),
              ),
              RefreshIndicator(
                onRefresh: ()async {
                  await _loadVisitData();
                },
                child: Padding(
                  padding:  EdgeInsets.all(MoSizes.md(context)),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TitelsWidget(
                          title: "Check In",
                          answer: checkInFormated != null ? checkInFormated! : "0", // عرض وقت تسجيل الدخول
                        ),
                        TitelsWidget(
                          title: "Check Out",
                          answer: checkOutFormated != null ? checkOutFormated! : "0", // عرض وقت تسجيل الخروج
                        ),
                        TitelsWidget(
                          title: "Duration",
                          answer: visitDuration ?? "0", // عرض مدة الزيارة
                        ),
                        FutureBuilder<UserModel>(
                          future: _getUserModelFromPrefs(), // جلب بيانات المستخدم من SharedPreferences
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else if (snapshot.hasData) {
                              final userModel = snapshot.data!;
                              return BlocProvider(
                                create: (context) => ActivityCubit()..fetchActivities(userid: userModel.uid.toString()),
                                child: BlocBuilder<ActivityCubit, ActivityState>(
                                  builder: (context, state) {
                                    if (state is ActivityLoading) {
                                      return Center(child: CircularProgressIndicator());
                                    } else if (state is ActivityLoaded) {
                                      final todayActivities = state.activities.where((task) => task['res_id'] == widget.visitId).toList();

                                      if(todayActivities.length == 0){
                                        return  TitelsWidget(
                                          title: "Number of Tasks: ",
                                          answer: todayActivities.length.toString(),
                                        );
                                      }
                                      return  TitelsWidget(
                                        title: "Number of Tasks: ",
                                        answer: todayActivities.length.toString(),
                                      );
                                    } else if (state is ActivityError) {
                                      print(state.message.toString());
                                      return   TitelsWidget(
                                        title: "Number of Tasks: ",
                                        answer: "0",
                                      );
                                    }
                                    return Center(child: Text('No data available', style: TextStyle(color: Colors.grey)));
                                  },
                                ),
                              );
                            }
                            return Center(child: Text('No data available'));
                          },
                        ),
                        SizedBox(height: 5,),
                        Padding(
                          padding:  EdgeInsets.all(MoSizes.defaultSpace(context)),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.blue.shade800
                              ),
                              onPressed: (){
                                Move.move(context, TaskOfVisit(id: widget.visitId,));
                              },
                              child: Text("Add Task",style: TextStyle(color: Colors.white),),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            // categories.map((category) => CategoryTab(category: category, dark: dark,)).toList()
          ),
        ),
    );
  }

  void showCallDialog(BuildContext context, String mobile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Calling', style: TextStyle(color: Colors.black)),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mobile,
                style: TextStyle(color: Colors.black),
              ),
              IconButton(
                onPressed: () async {
                  Clipboard.setData(ClipboardData(text: mobile));
                  DialToast.showToast("Phone Number added to ClipBoard", Colors.green);
                },
                icon: Icon(Icons.copy, color: Colors.grey.shade800),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final Uri url = Uri(
                  scheme: 'tel',
                  path: mobile
              );
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            },
            child: Text('Call', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyDropdown() {
    return BlocProvider(
      create: (context) => SurveyCubit()..fetchSurveys(),
      child: BlocBuilder<SurveyCubit, SurveyState>(
        builder: (context, state) {
          if (state is SurveyLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is SurveyLoaded) {
            // Filter surveys to show only the one matching IdSurvey
            final filteredSurveys = state.surveys;

            if (filteredSurveys.isEmpty) {
              return Center(child: Text('No matching survey found.'));
            }

            return DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Select Survey'),
              value: int.tryParse(_surveyIdController.text), // Assuming you have a controller
              onChanged: (int? newValue) {
                setState(() {
                  _surveyIdController.text = newValue.toString();
                });
              },
              items: filteredSurveys.map((survey) {
                return DropdownMenuItem<int>(
                  value: survey.id,
                  child: Text(survey.title),
                );
              }).toList(),
            );
          } else if (state is SurveyError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No Data'));
        },
      ),
    );
  }

  Widget _buildUserDropdown() {
    return BlocProvider(
      create: (context) => GetUsersCubit()..fetchUsers(),
      child: BlocBuilder<GetUsersCubit, GetUsersState>(
        builder: (context, state) {
          if (state is GetUsersLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is GetUsersLoaded) {
            return DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Select Collaborative'),
              value: int.tryParse(_userIdController.text),
              onChanged: (int? newValue) {
                setState(() {
                  _userIdController.text = newValue.toString();
                });
              },
              items: state.users.map((user) {
                return DropdownMenuItem<int>(
                  value: user['id'],
                  child: Text(user['name']),
                );
              }).toList(),
            );
          } else if (state is GetUsersError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No Data'));
        },
      ),
    );
  }

  Widget _buildDoubleVisitTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Select Double Visit Type'),
      value: _doubleVisitType.isNotEmpty ? _doubleVisitType : null, // تأكد من أن القيمة محدثة
      items: [
        'audit',
        'couching',
      ]
          .map((type) => DropdownMenuItem<String>(
        value: type,
        child: Text(type),
      ))
          .toList(),
      onChanged: (String? newValue) {
        setState(() {
          _doubleVisitType = newValue ?? ''; // التأكد من أن القيمة لا تكون null
        });
      },
    );
  }

  Widget _buildDoubleVisitSwitch() {
    return SwitchListTile(
      title: Text('Is Double Visit'),
      value: _isDoubleVisit,
      onChanged: (bool value) {
        setState(() {
          _isDoubleVisit = value;
        });
      },
    );
  }


  Future<UserModel> _getUserModelFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = prefs.getString('sessionData');
    if (sessionData != null) {
      return UserModel.fromJson(jsonDecode(sessionData));
    }
    throw Exception('No user data found');
  }



}

class TitelsWidget extends StatelessWidget {
  const TitelsWidget({
    super.key, required this.title, required this.answer,
  });

  final String title;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, // لون الخلفية
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.cyan, width: 2),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.cyan.withOpacity(0.7), // لون الظل
          //     spreadRadius: 3, // انتشار الظل
          //     blurRadius: 15, // ضبابية الظل
          //     offset: Offset(0, 5), // تعويض الظل
          //   ),
          // ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$title: ",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            Text(
              answer,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageTitleWidget extends StatelessWidget {
  const ImageTitleWidget({
    super.key, required this.title, required this.image,
  });

  final String title;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, // لون الخلفية
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.cyan, width: 2),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.cyan.withOpacity(0.7), // لون الظل
          //     spreadRadius: 3, // انتشار الظل
          //     blurRadius: 15, // ضبابية الظل
          //     offset: Offset(0, 5), // تعويض الظل
          //   ),
          // ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 5,),
            NetworkImageCustom(
              imageUrl: image,
              size: 20,
            ),
            SizedBox(width: 10,),
            Text(
              title,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class CenterTitleWidget extends StatelessWidget {
  const CenterTitleWidget({super.key,required this.title});
final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, // لون الخلفية
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.cyan, width: 2),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.cyan.withOpacity(0.7), // لون الظل
          //     spreadRadius: 3, // انتشار الظل
          //     blurRadius: 15, // ضبابية الظل
          //     offset: Offset(0, 5), // تعويض الظل
          //   ),
          // ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }


}



