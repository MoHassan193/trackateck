import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model_view/cubits/getStatesCubit/getStatesCubit.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/partnerInfoCubit/partnerInfoCubit.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/partnerInfoCubit/partnerInfoState.dart';
import '../../model_view/cubits/getStatesCubit/getSatesState.dart';
import '../../model_view/cubits/getTitlesCubit/getTitlesCubit.dart';
import '../../model_view/cubits/getTitlesCubit/getTitlesState.dart';
import '../../model_view/cubits/mainCubitofWidget/behaviorStyleCubit/behaviorStyleCubit.dart';
import '../../model_view/cubits/mainCubitofWidget/behaviorStyleCubit/behaviorStyleState.dart';
import '../../model_view/cubits/mainCubitofWidget/getClassificationCubit/getClassificationCubit.dart';
import '../../model_view/cubits/mainCubitofWidget/getClassificationCubit/getClassificationState.dart';
import '../../model_view/cubits/mainCubitofWidget/getSpecialityCubit/getSpecialityCubit.dart';
import '../../model_view/cubits/mainCubitofWidget/getSpecialityCubit/getSpecialityState.dart';
import '../../model_view/cubits/mainCubitofWidget/getTerritoryCubit/getTerritoryCubit.dart';
import '../../model_view/cubits/mainCubitofWidget/getTerritoryCubit/getTerritoryState.dart';
import '../../model/dialToast.dart';
import '../../model/userModel/userModel.dart';
import '../../model/utils/sizes.dart';
import 'package:image_picker/image_picker.dart';

class EditPartnerPlan extends StatefulWidget {
  final int partnerId;// Partner ID for editing
  final double longitude;
  final double latitude;
  final Map<String, dynamic> partnerData; // Make it nullable to handle null cases


  const EditPartnerPlan({super.key, required this.partnerId, required this.longitude, required this.latitude, required this.partnerData});

  @override
  State<EditPartnerPlan> createState() => _EditPartnerPlanState();
}

class _EditPartnerPlanState extends State<EditPartnerPlan> {
  late UserModel _userModel;
  bool _isLoading1 = false;
  // Controllers for each field
  final TextEditingController partnerNameController = TextEditingController();
  final TextEditingController territoryIdController = TextEditingController();
  final TextEditingController _titleIdController = TextEditingController();
  final TextEditingController _rankIdController = TextEditingController();
  final TextEditingController _specialityIdController = TextEditingController();
  final TextEditingController _classificationIdController = TextEditingController();
  final TextEditingController _behavioralStyleIdController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController clientAttitudeController = TextEditingController();
  final TextEditingController clientKindController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController vatController = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController street2Controller = TextEditingController();
  final TextEditingController faxController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController refController = TextEditingController();
  final TextEditingController functionController = TextEditingController();
  final TextEditingController clientTypeController = TextEditingController();
  final TextEditingController _stateIdController = TextEditingController();
  final TextEditingController _countryIdController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  // Function to load the user data from shared preferences
  Future<void> loadUserModel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = prefs.getString('sessionData');
      if (sessionData != null) {
        _userModel = UserModel.fromJson(jsonDecode(sessionData));
      } else {
        throw Exception('No user data found');
      }
    } catch (e) {
      print(e.toString());
    }
  }



  // Function to update partner details
  Future<void> updatePartner() async {
    await loadUserModel();
    final prefs = await SharedPreferences.getInstance();
    final String? url = prefs.getString('storedUrl');

    if (url == null || url.isEmpty) {
      print('Error: URL is missing or invalid.');
      return;
    }

    if (_userModel.accessToken.isEmpty) {
      print('Error: Access token is missing or invalid.');
      return;
    }



    final request = {
      'partner_latitude': widget.latitude ?? 0,
      'partner_longitude': widget.longitude ?? 0,
      'website': websiteController.text.isNotEmpty ? websiteController.text : null,
      'zip': zipController.text.isNotEmpty ? zipController.text : null,
      'vat': vatController.text.isNotEmpty ? vatController.text : null,
      'type': 'contact',
      'title': _titleIdController.text.isNotEmpty ? int.tryParse(_titleIdController.text) : null,
      'territory_id': territoryIdController.text.isNotEmpty ? int.tryParse(territoryIdController.text) : null,
      'suitable_time': selectedTime ?? null,
      'suitable_day': selectedDayName ?? null,
      'street2': street2Controller.text.isNotEmpty ? street2Controller.text : null,
      'street': streetController.text.isNotEmpty ? streetController.text : null,
      'state_id': _stateIdController.text.isNotEmpty ? int.tryParse(_stateIdController.text) : null,
      'speciality': _specialityIdController.text.isNotEmpty ? int.tryParse(_specialityIdController.text) : null,
      'ref': refController.text.isNotEmpty ? refController.text : null,
      'rank': null,
      'phone': phoneController.text.isNotEmpty ? phoneController.text : null,
      'name': partnerNameController.text.isNotEmpty ? partnerNameController.text : null,
      'mobile': mobileController.text.isNotEmpty ? mobileController.text : null,
      'file_path': widget.partnerData['image'] != null ? widget.partnerData['image'] : null,
      'function': functionController.text.isNotEmpty ? functionController.text : null,
      'country_id': _countryIdController.text.isNotEmpty ? int.tryParse(_countryIdController.text) : null,
      'comment': commentController.text.isNotEmpty ? commentController.text : null,
      'client_type': selectedClientType ?? null,
      'client_kind': selectedClientKind ?? null,
      'client_attitude': selectedAttitude ?? null,
      'classification': _classificationIdController.text.isNotEmpty ? int.tryParse(_classificationIdController.text) : null,
      'city': cityController.text.isNotEmpty ? cityController.text : null,
      'behave_style_id': _behavioralStyleIdController.text.isNotEmpty ? int.tryParse(_behavioralStyleIdController.text) : null,
      'barcode': barcodeController.text.isNotEmpty ? barcodeController.text : null,
    };

    try {
      final dio = Dio();
      final response = await dio.post(
        '$url/api/${widget.partnerId}/update_partner_location',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'token': _userModel.accessToken,
          },
        ),
        data: request,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        Navigator.pop(context);
        DialToast.showToast("Partner Updated Successfully", Colors.green);
        Navigator.pop(context);
      } else {
        DialToast.showToast('Failed to update partner. Status code: ${response.statusCode}', Colors.red);
        print('Failed to update partner. Status code: ${response.statusCode}');
        print(response.data);
      }
    } catch (e) {
      print('Error during the updatePartner request: $e');
    }
  }

  String? selectedClientKind;

  final List<Map<String, String>> clientKindOptions = [
    {'value': 'doctor', 'label': 'Doctor'},
    {'value': 'pharmacy', 'label': 'Pharmacy'},
    {'value': 'dental', 'label': 'Dental'},
    {'value': 'other', 'label': 'Other'},
  ];

  String? selectedClientType;

  final List<Map<String, String>> clientTypeOptions = [
    {'value': 'doctor', 'label': 'Doctor'},
    {'value': 'hospital', 'label': 'Hospital'},
    {'value': 'clinic', 'label': 'Clinic'},
  ];

  String? selectedAttitude;

  final List<Map<String, String>> attitudeOptions = [
    {'value': 'very_bad', 'label': 'Very Bad'},
    {'value': 'bad', 'label': 'Bad'},
    {'value': 'good', 'label': 'Good'},
    {'value': 'very_good', 'label': 'Very Good'},
    {'value': 'excellent', 'label': 'Excellent'},
  ];
  DateTime? selectedDate;
  TimeOfDay? selectedTimof;
  String? selectedDayName; // Variable to store the day name

  // Function to show the date picker
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedDayName = DateFormat('EEEE').format(selectedDate!); // Get the day name
      });
    }
  }

  // Function to show the time picker
  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTimof ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTimof) {
      setState(() {
        selectedTimof = picked;
      });
    }
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserModel(); // Load partner details on initialization
  }

  int? selectedTime; // المتغير الذي سيحتوي على القيمة المختارة

  // قائمة الخيارات مع الأوقات بصيغة '8:00 AM'، ولكن القيم ستكون أرقام صحيحة
  final List<Map<String, dynamic>> timeOptions = [
    {'label': '8:00 AM', 'value': 8},
    {'label': '9:00 AM', 'value': 9},
    {'label': '10:00 AM', 'value': 10},
    {'label': '11:00 AM', 'value': 11},
    {'label': '12:00 PM', 'value': 12},
    {'label': '1:00 PM', 'value': 1},
    {'label': '2:00 PM', 'value': 2},
    {'label': '3:00 PM', 'value': 3},
    {'label': '4:00 PM', 'value': 4},
    {'label': '5:00 PM', 'value': 5},
  ];

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Update Contact')),
      body: Padding(
        padding: EdgeInsets.all(MoSizes.md(context)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SizedBox(height: 15),
              // // Add more TextFormFields for other fields as needed
              // if (_selectedImage == null) OutlinedButton(
              //   onPressed: pickImage,
              //   child: Text("  Pick Image  "),
              // ),
              // if (_selectedImage != null)
              //   CircleAvatar(
              //     backgroundImage: FileImage(_selectedImage!),
              //     radius: 40,
              //   ),
              SizedBox(height: 15),
              _buildTextField(partnerNameController, "Partner Name", (widget.partnerData['name'] != null && widget.partnerData['name'] != false) ? (widget.partnerData['name'] ?? '') : 'No Data in This Field'),
              _buildTextField(cityController, "City", (widget.partnerData['city'] != null && widget.partnerData['city'] != false) ? (widget.partnerData['city'] ?? '') : 'No Data in This Field'),
              _buildTextField(commentController, "Comment", (widget.partnerData['comment'] != null && widget.partnerData['comment'] != false) ? (widget.partnerData['comment'].toString() ?? '') : 'No Data in This Field'),
              _buildTextField(phoneController, "Phone", (widget.partnerData['phone'] != null && widget.partnerData['phone'] != false) ? (widget.partnerData['phone'].toString() ?? '') : 'No Data in This Field'),
              _buildTextField(mobileController, "Mobile", (widget.partnerData['mobile'] != null && widget.partnerData['mobile'] != false) ? (widget.partnerData['mobile'].toString() ?? '') : 'No Data in This Field'),
              _buildTextField(websiteController, "Website", (widget.partnerData['website'] != null && widget.partnerData['website'] != false) ? (widget.partnerData['website'].toString() ?? '') : 'No Data in This Field'),
              _buildTextField(streetController, "Street", (widget.partnerData['street'] != null && widget.partnerData['street'] != false) ? (widget.partnerData['street'].toString() ?? '') : 'No Data in This Field'),
              _buildTextField(street2Controller, "Street 2", (widget.partnerData['street2'] != null && widget.partnerData['street2'] != false) ? (widget.partnerData['street2'].toString() ?? '') : 'No Data in This Field'),
              _buildTextField(vatController, "VAT",''),
              _buildTextField(zipController, "ZIP",''),
              _buildTextField(barcodeController, "Barcode",''),
              _buildTextField(functionController, 'function',''),
              _buildTextField(refController, "Ref",''),
              ListTile(
                title: Text(selectedDayName ?? "Select Suitable Day"),
                trailing: Icon(Icons.calendar_month),
                onTap: () => selectDate(context),
              ),
              ListTile(
                title: DropdownButton<int>(
                  hint: Text("Select Suitable Time"),
                  value: selectedTime, // إذا كانت القيمة موجودة، قم بعرضها
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedTime = newValue; // حفظ القيمة المختارة
                    });
                    // طباعة القيمة المختارة
                    print("Time sent to API: $newValue");
                    // استدعاء API هنا مع newValue
                  },
                  items: timeOptions.map<DropdownMenuItem<int>>((Map<String, dynamic> option) {
                    return DropdownMenuItem<int>(
                      value: option['value'],
                      child: Text(option['label']), // عرض الوقت بشكل '8:00 AM'
                    );
                  }).toList(),
                ),
                trailing: Icon(Icons.access_time),
              ),
              _buildTerritoryDropdown(), // Dropdown for territories
              SizedBox(height: 10,),
              _buildStatesDropdown(),
              SizedBox(height: 10,),
              _buildTitlesDropdown(),
              SizedBox(height: 10,),
              _buildSpecialityDropdown(),
              SizedBox(height: 10,),
              _buildBehavioralStylesDropdown(),
              SizedBox(height: 10,),
              _buildClassificationDropdown(),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedClientKind,
                decoration: InputDecoration(hintText: "Select Client Kind"),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedClientKind = newValue;
                    clientKindController.text = newValue ?? '';
                  });
                },
                items: clientKindOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option['value'],
                    child: Text(option['label']!),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedClientType,
                decoration: InputDecoration(hintText: "Select Client Type"),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedClientType = newValue;
                    clientTypeController.text = newValue ?? '';
                  });
                },
                items: clientTypeOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option['value'],
                    child: Text(option['label']!),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedAttitude,
                decoration: InputDecoration(hintText: "Select Client Attitude"),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAttitude = newValue;
                    clientAttitudeController.text = newValue ?? '';
                  });
                },
                items: attitudeOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option['value'],
                    child: Text(option['label']!),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              SizedBox(height: 25),
              SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                      onPressed: () {
                        updatePartner();
                        setState(() {
                          _isLoading1 = true; // ابدأ التحميل
                        });

                        // محاكاة عملية التحميل لمدة 5 ثوانٍ
                        Future.delayed(Duration(seconds: 5), () {
                          // بعد انتهاء عملية التحميل
                          setState(() {
                            _isLoading1 = false; // إنهاء التحميل
                          });

                          // يمكنك إضافة الكود الخاص بإرسال البيانات بعد انتهاء التحميل هنا
                          print('Task created'); // مثال لطباعة رسالة في الكونسول
                        });
                      },
                      child: _isLoading1 ? CircularProgressIndicator() : Text("Update Partner"))),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,String? initialValue) {
    controller.text = initialValue ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            suffixIcon: IconButton(onPressed: (){controller.clear();}, icon: Icon(Icons.clear)),
            hintText: hint),
      ),
    );
  }

  Widget _buildTerritoryDropdown() {
    return BlocProvider(
      create: (context) => TerritoryCubit()..fetchTerritories(),
      child: BlocBuilder<TerritoryCubit, TerritoryState>(
        builder: (context, state) {
          if (state is TerritoryLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is TerritoryLoaded) {
            return DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Select Territory'),
              value: int.tryParse(territoryIdController.text),
              onChanged: (int? newValue) {
                setState(() {
                  territoryIdController.text = newValue.toString();
                });
              },
              items: state.territories.map((territory) {
                return DropdownMenuItem<int>(
                  value: territory.id,
                  child: Text(territory.name),
                );
              }).toList(),
            );
          } else if (state is TerritoryError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildPartnerDropdown(String id) {
    return BlocProvider(
      create: (context) => PartnerInfoCubit()..fetchPartnerInfo(id),
      child: BlocBuilder<PartnerInfoCubit, PartnerInfoState>(
        builder: (context, state) {
          if (state is PartnerInfoLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is PartnerInfoLoadedRaw) {
            final partnerData = state.partnerData;

            return DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Select Partner'),
              // تحقق مما إذا كان _partnerIdController فارغًا
              value: _rankIdController.text.isNotEmpty
                  ? int.tryParse(_rankIdController.text)
                  : null, // اجعل القيمة فارغة إذا كان _partnerIdController فارغًا
              onChanged: (int? newValue) {
                setState(() {
                    _rankIdController.text = newValue.toString();
                });
              },
              items: partnerData.map<DropdownMenuItem<int>>((partner) {
                return DropdownMenuItem<int>(
                  value: int.tryParse(partner['id'].toString()), // تأكد من تحويل id إلى int
                  child: Text(partner['name']),
                );
              }).toList(),
            );

          } else if (state is PartnerInfoError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildSpecialityDropdown() {
    return BlocProvider(
      create: (context) => SpecialitiesCubit()..fetchSpecialities(),
      child: BlocBuilder<SpecialitiesCubit, SpecialitiesState>(
        builder: (context, state) {
          if (state is SpecialitiesLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is SpecialitiesLoaded) {
            // تصفية التخصصات لإظهار فقط التخصصات المتاحة
            final filteredSpecialities = state.specialities;

            if (filteredSpecialities.isEmpty) {
              return Center(child: Text('No data available'));
            }

            return DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Select Speciality'),
              value: int.tryParse(_specialityIdController.text), // Assuming you have a controller
              onChanged: (int? newValue) {
                setState(() {
                  _specialityIdController.text = newValue.toString();
                });
              },
              items: filteredSpecialities.map((speciality) {
                return DropdownMenuItem<int>(
                  value: speciality.id,
                  child: Text(speciality.name),
                );
              }).toList(),
            );
          } else if (state is SpecialitiesError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildTitlesDropdown() {
    return BlocProvider(
      create: (context) => TitlesCubit()..fetchTitles(),
      child: BlocBuilder<TitlesCubit, TitlesState>(
        builder: (context, state) {
          if (state is TitlesLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is TitlesLoaded) {
            // تصفية الفئات لإظهار فقط ما يتطابق مع IdTitle
            final filteredTitles = state.titles;

            if (filteredTitles.isEmpty) {
              return Center(child: Text('No matching data found'));
            }

            return DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Select Title'),
              value: int.tryParse(_titleIdController.text), // Assuming you have a controller
              onChanged: (int? newValue) {
                setState(() {
                  _titleIdController.text = newValue.toString();
                });
              },
              items: filteredTitles.map((title) {
                return DropdownMenuItem<int>(
                  value: title['id'],
                  child: Text(title['shortcut']), // عرض اسم العنوان بدلاً من التقسيم
                );
              }).toList(),
            );
          } else if (state is TitlesError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildStatesDropdown() {
    return BlocProvider(
      create: (context) => StatesCubit()..fetchStates(),
      child: BlocBuilder<StatesCubit, StatesState>(
        builder: (context, state) {
          if (state is StatesLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is StatesLoaded) {
            // Filter states if needed
            final filteredStates = state.states;

            if (filteredStates.isEmpty) {
              return Center(child: Text('No matching data found'));
            }

            return DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Select State'),
              value: int.tryParse(_stateIdController.text), // Assuming you have a controller
              onChanged: (int? newValue) {
                setState(() {
                  _stateIdController.text = newValue.toString();
                  // Find the selected state
                  final selectedState = filteredStates.firstWhere(
                        (state) => state['id'] == newValue,
                    orElse: () => null,
                  );
                  if (selectedState != null) {
                    // Set the country_id in _countryIdController
                    _countryIdController.text = selectedState['country_id'].toString();
                  }
                });
              },
              items: filteredStates.map((state) {
                return DropdownMenuItem<int>(
                  value: state['id'],
                  child: Text(state['name']), // Display state name
                );
              }).toList(),
            );
          } else if (state is StatesError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildClassificationDropdown() {
    return BlocProvider(
      create: (context) => ClassificationsCubit()..fetchClassifications(),
      child: BlocBuilder<ClassificationsCubit, ClassificationsState>(
        builder: (context, state) {
          if (state is ClassificationsLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ClassificationsLoaded) {
            // تصفية التصنيفات لإظهار فقط التصنيف المتطابق مع IdClassification
            final filteredClassifications = state.classifications;

            if (filteredClassifications.isEmpty) {
              return Center(child: Text('No matching data found'));
            }

            return DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Select Classification'),
              value: int.tryParse(_classificationIdController.text), // Assuming you have a controller
              onChanged: (int? newValue) {
                setState(() {
                  _classificationIdController.text = newValue.toString();
                });
              },
              items: filteredClassifications.map((classification) {
                return DropdownMenuItem<int>(
                  value: classification.id,
                  child: Text(classification.name),
                );
              }).toList(),
            );
          } else if (state is ClassificationsError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildBehavioralStylesDropdown() {
    return BlocProvider(
      create: (context) => BehavioralStylesCubit()..fetchBehavioralStyles(),
      child: BlocBuilder<BehavioralStylesCubit, BehavioralStylesState>(
        builder: (context, state) {
          if (state is BehavioralStylesLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is BehavioralStylesLoaded) {
            if (state.styles.isEmpty) {
              return Center(child: Text('No styles available'));
            }

            return DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Select Behavioral Style'),
              value: int.tryParse(_behavioralStyleIdController.text), // Assuming you have a controller
              onChanged: (int? newValue) {
                setState(() {
                  _behavioralStyleIdController.text = newValue.toString();
                });
              },
              items: state.styles.map((style) {
                return DropdownMenuItem<int>(
                  value: style.id,
                  child: Text(style.name),
                );
              }).toList(),
            );
          } else if (state is BehavioralStylesError) {
            return Center(child: Text(state.message, style: TextStyle(color: Colors.red)));
          }
          return Center(child: Text('No data available', style: TextStyle(color: Colors.grey)));
        },
      ),
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
