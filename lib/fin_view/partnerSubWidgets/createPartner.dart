import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getClassificationCubit/getClassificationCubit.dart';

import '../../model/dialToast.dart';
import '../../model/userModel/userModel.dart';
import '../../model/utils/sizes.dart';
import '../../model_view/cubits/mainCubitofWidget/behaviorStyleCubit/behaviorStyleCubit.dart';
import '../../model_view/cubits/mainCubitofWidget/behaviorStyleCubit/behaviorStyleState.dart';
import '../../model_view/cubits/mainCubitofWidget/getClassificationCubit/getClassificationState.dart';
import '../../model_view/cubits/mainCubitofWidget/getSegmantaionCubit/getSegmantationCubit.dart';
import '../../model_view/cubits/mainCubitofWidget/getSegmantaionCubit/getSegmantationState.dart';
import '../../model_view/cubits/mainCubitofWidget/getSpecialityCubit/getSpecialityCubit.dart';
import '../../model_view/cubits/mainCubitofWidget/getSpecialityCubit/getSpecialityState.dart';
import '../../model_view/cubits/mainCubitofWidget/getTerritoryCubit/getTerritoryCubit.dart';
import '../../model_view/cubits/mainCubitofWidget/getTerritoryCubit/getTerritoryState.dart';

class CreatePartnerPlan extends StatefulWidget {
  const CreatePartnerPlan({super.key, this.onTap});
final void Function()? onTap;
  @override
  State<CreatePartnerPlan> createState() => _CreatePartnerPlanState();
}

class _CreatePartnerPlanState extends State<CreatePartnerPlan> {
  late UserModel _userModel;

  final TextEditingController partnerNameController = TextEditingController();
  final TextEditingController territoryIdController = TextEditingController();
  final TextEditingController _segmentationIdController = TextEditingController();
  final TextEditingController _specialityIdController = TextEditingController();
  final TextEditingController _classificationIdController = TextEditingController();
  final TextEditingController _behavioralStyleIdController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController clientAttitudeController = TextEditingController();
  final TextEditingController clientKindController = TextEditingController();
  final TextEditingController clientTypeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController targetVisit = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController street2Controller = TextEditingController();
  final TextEditingController suitableDayController = TextEditingController();
  final TextEditingController suitableTimeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nopotential = TextEditingController();
  final TextEditingController functionController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  bool isCountry = false;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool draft = false;

  DateTime? selectedDate;
  TimeOfDay? selectedTimof;
  String? selectedDayName;
  int? selectedTime;

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
        selectedDayName = DateFormat('EEEE').format(selectedDate!);
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

  Future<void> createPartner() async {
    await loadUserModel();
    final prefs = await SharedPreferences.getInstance();
    final String? url = prefs.getString('storedUrl');

    if (url == null || url.isEmpty) {
      return;
    }

    final request = {
      'name': partnerNameController.text,
      'territory_id': int.tryParse(territoryIdController.text),
      'file_path': null,
      'city': cityController.text,
      'rank' : null,
      'behave_style_id': int.tryParse(_behavioralStyleIdController.text),
      'classification': int.tryParse(_classificationIdController.text),
      'speciality': int.tryParse(_specialityIdController.text),
      'segment_id': int.tryParse(_segmentationIdController.text),
      'state_id': int.tryParse(_specialityIdController.text),
      'target_visit': int.tryParse(targetVisit.text) ?? 0,
      'no_potential': int.tryParse(nopotential.text) ?? 0,
      'country_id' : int.tryParse(countryController.text) ?? 1 ,
      'client_attitude': selectedAttitude ?? null,
      'client_kind': selectedClientKind ?? null,
      'client_type': selectedClientType ?? null,
      'phone': phoneController.text,
      'mobile': mobileController.text,
      'zip': zipController.text,
      'website': websiteController.text,
      'street': streetController.text,
      'street2': street2Controller.text,
      'email': emailController.text,
      'is_company': isCountry ? "True" : "False",
      'function': functionController.text,
      'suitable_day': selectedDayName,
      'suitable_time': selectedTime,
    };

    final dio = Dio();
    final response = await dio.put('$url/api/create_partner',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'token': _userModel.accessToken,
          },
        ),
        data: request);
    if (response.statusCode == 200) {
      final data = response.data['data'];
      Navigator.pop(context);
      DialToast.showToast("Contact Created Successfully", Colors.green);
    } else {
      print(response.data);
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
  @override
  void initState() {
    super.initState();
    loadUserModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Create Contact')),
      body: Padding(
        padding: EdgeInsets.all(MoSizes.md(context)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 15),
              // if (_selectedImage == null)
              //   OutlinedButton(
              //     onPressed: pickImage,
              //     child: Text("  Pick Image  "),
              //   ),
              // if (_selectedImage != null)
              //   CircleAvatar(
              //     backgroundImage: FileImage(_selectedImage!),
              //     radius: 40,
              //   ),
              // SizedBox(height: 10),
          
              // Text fields for user input
              TextFormField(
                controller: partnerNameController,
                decoration: InputDecoration(hintText: "Enter Contact Name"),
              ),
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
              _buildSpecialityDropdown(),
              SizedBox(height: 10),
              _buildTerritoryDropdown(),
              SizedBox(height: 10,),
              TextFormField(
                controller: cityController,
                decoration: InputDecoration(hintText: "Enter City"),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: zipController,
                decoration: InputDecoration(hintText: "Enter Zip Code"),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(hintText: "Enter Phone Number"),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: mobileController,
                decoration: InputDecoration(hintText: "Enter Mobile Number"),
                keyboardType: TextInputType.phone,
              ),

              SizedBox(height: 10),
              TextFormField(
                controller: websiteController,
                decoration: InputDecoration(hintText: "Enter Website"),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: streetController,
                decoration: InputDecoration(hintText: "Enter Street"),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: street2Controller,
                decoration: InputDecoration(hintText: "Enter Street 2"),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(hintText: "Enter Email"),
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: 20,),

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
              _buildSegmentationDropdown(),
              SizedBox(height: 10,),
              _buildBehavioralStylesDropdown(),
              SizedBox(height: 10,),
              _buildClassificationDropdown(),
              SizedBox(height: 10,),
              _buildDoubleVisitSwitch(),
              SizedBox(height: 10,),
              TextFormField(
                controller: targetVisit,
                decoration: InputDecoration(hintText: "Enter Target Visit"),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: nopotential,
                decoration: InputDecoration(hintText: "Enter No Potential"),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: functionController,
                decoration: InputDecoration(hintText: "Enter Function"),
              ),

              // Date and Time Picker
              ListTile(
                title: Text(selectedDayName ?? "Select Suitable Day"),
                trailing: Icon(Icons.calendar_month),
                onTap: () => selectDate(context),
              ),
              ListTile(
                title: DropdownButton<int>(
                  hint: Text("Select Suitable Time"),
                  value: selectedTime,
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedTime = newValue;
                    });
                  },
                  items: timeOptions.map<DropdownMenuItem<int>>((Map<String, dynamic> option) {
                    return DropdownMenuItem<int>(
                      value: option['value'],
                      child: Text(option['label']),
                    );
                  }).toList(),
                ),
                trailing: Icon(Icons.access_time),
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: (){
                    if(_specialityIdController.text.isNotEmpty && territoryIdController.text.isNotEmpty){
                      createPartner();
                    }else {
                      draft = true;
                      DialToast.showToast("please Select Speciality and Territory.", Colors.red);
                    }
                  },
                  child: Text("Create Contact"),
                ),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
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
              decoration: InputDecoration(
                  border: draft ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(color: Colors.red),
                  ) : OutlineInputBorder(),
                  labelText: 'Select Territory'),
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
              decoration: InputDecoration(
                  border: draft ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(color: Colors.red),
                  ) : OutlineInputBorder(),
                  labelText: 'Select Speciality'),
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

  Widget _buildSegmentationDropdown() {
    return BlocProvider(
      create: (context) => SegmentationCubit()..fetchSegmentations(),
      child: BlocBuilder<SegmentationCubit, SegmentationState>(
        builder: (context, state) {
          if (state is SegmentationLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is SegmentationLoaded) {
            // تصفية الفئات لإظهار فقط ما يتطابق مع IdSegmentation
            final filteredSegmentations = state.segmentations;

            if (filteredSegmentations.isEmpty) {
              return Center(child: Text('No matching data found'));
            }

            return DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Select Segmentation'),
              value: int.tryParse(_segmentationIdController.text), // Assuming you have a controller
              onChanged: (int? newValue) {
                setState(() {
                  _segmentationIdController.text = newValue.toString();
                });
              },
              items: filteredSegmentations.map((segmentation) {
                return DropdownMenuItem<int>(
                  value: segmentation.id,
                  child: Text(segmentation.name),
                );
              }).toList(),
            );
          } else if (state is SegmentationError) {
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

  Widget _buildDoubleVisitSwitch() {
    return SwitchListTile(
      title: Text('Is Company'),
      value: isCountry,
      onChanged: (bool value) {
        setState(() {
          isCountry = value;
        });
      },
    );
  }

}
