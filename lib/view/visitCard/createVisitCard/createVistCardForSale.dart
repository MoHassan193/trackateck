import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/fin_view/dailyPlans/createDailyDialog.dart';
import 'package:visit_man/fin_view/dailyPlans/createMonthlyDialog.dart';
import 'package:visit_man/fin_view/dailyPlans/createMonthlyPlan.dart';
import 'package:visit_man/fin_view/dailyPlans/createNewDailyPlan.dart';
import 'package:visit_man/fin_view/partnerSubWidgets/createPartner.dart';
import 'package:visit_man/model/dialToast.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/leaveBehindCubit/leaveBehindCubit.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/leaveBehindCubit/leaveBehindState.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/monthlyPlanCubit/monthlyPlanCubit.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/monthlyPlanCubit/monthlyPlanState.dart';
import 'package:visit_man/view/visitCard/widgets/getUsers/cubit/getUsersCubit.dart';
import 'package:visit_man/view/visitCard/widgets/getUsers/getUsersPage.dart';
import '../../../model/userModel/userModel.dart';
import '../../../model_view/cubits/mainCubitofWidget/getProductCubit/getProductCubit.dart';
import '../../../model_view/cubits/mainCubitofWidget/getProductCubit/getProductState.dart';
import '../../../model_view/cubits/mainCubitofWidget/getSurveyCubit/getSurveyCubit.dart';
import '../../../model_view/cubits/mainCubitofWidget/getSurveyCubit/getSurveyState.dart';
import '../../../model_view/cubits/mainCubitofWidget/getTodayDailyCubit/get_today_daily_cubit.dart';
import '../../../model_view/cubits/mainCubitofWidget/getTodayDailyCubit/get_today_daily_state.dart';
import '../../../model_view/cubits/mainCubitofWidget/partnerInfoCubit/partnerInfoCubit.dart';
import '../../../model_view/cubits/mainCubitofWidget/partnerInfoCubit/partnerInfoState.dart';
import '../../../model_view/cubits/mainCubitofWidget/visitObjectiveCubit/visitObjectiveCubit.dart';
import '../../../model_view/cubits/mainCubitofWidget/visitObjectiveCubit/visitObjectiveState.dart';
import '../widgets/getUsers/cubit/getUsersState.dart';


class SaleCreateVisitCard extends StatefulWidget {
  @override
  _SaleCreateVisitCardState createState() => _SaleCreateVisitCardState();
}

class _SaleCreateVisitCardState extends State<SaleCreateVisitCard> {

  // Controllers for form fields
  final TextEditingController _dailyPlanIdController = TextEditingController();
  final TextEditingController _territoryIdController = TextEditingController();
  final TextEditingController _partnerIdController = TextEditingController();
  final TextEditingController _collaborativeIdController = TextEditingController();
  final TextEditingController _surveyIdController = TextEditingController();
  final TextEditingController _objectiveController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _partnerNameController = TextEditingController();
  final TextEditingController _monthlyPlanIdController = TextEditingController();
  String? selectedTerritoryId;
  String? selectedPartnerId;

  // List to hold multiple product and objective IDs
  List<int> _productIds = [];
  List<int> _leaveBehindIds = [];
  List<int> _objectiveIds = [];
  List<String> _objectiveNames = [];

  bool _isDoubleVisit = false;
  String _doubleVisitType = 'audit';

  var getUsersPage = GetUsersPage();

  final prefs = SharedPreferences.getInstance();

  late UserModel _userModel; // إضافة UserModel

  // وظيفة لتحميل بيانات المستخدم من SharedPreferences
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

  // استرجاع الـ objectiveIds المحفوظة من SharedPreferences
  Future<List<int>> getSavedObjectiveIds() async {
    final prefs = await SharedPreferences.getInstance();
    final savedObjectiveIds = prefs.getStringList('savedObjectiveIds') ?? [];
    return savedObjectiveIds.map((id) => int.parse(id)).toList(); // تحويل القائمة إلى قائمة أعداد
  }

  Future<void> createVisitCard()async{
    await loadUserModel(); // تأكد من تحميل بيانات المستخدم قبل الجلب
    final prefs = await SharedPreferences.getInstance();
    final String? url = prefs.getString('storedUrl');

    if (url == null || url.isEmpty) {
      return;
    }

    final request = {
      'daily_plan_id': int.tryParse(_dailyPlanIdController.text),
      'territory_id': int.tryParse(_territoryIdController.text),
      'partner_id': int.tryParse(_partnerIdController.text),
      'is_double_visit': _isDoubleVisit ? 'True' : 'False',
      'collaborative_id': int.tryParse(_userIdController.text),
      'double_visit_type': _doubleVisitType ?? 'audit',
      'survey_id': null,
      'objective': _objectiveController.text ?? "",
      'user_id': _userModel.uid,
      'product_ids': '[]',
      'leave_behind_ids': '[${_leaveBehindIds.join(',')}]',
      'objective_ids': '[]',

    };
    final dio = Dio();
    final response = await dio.put('$url/api/create_visit_card',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'token': _userModel.accessToken, // استخدام رمز التحقق
          },
        ),
        data: request);
    if(response.statusCode == 200){
      final data = response.data['data'];
      final name = data['name'];
      DialToast.showToast("Visit Card Created Successfuly\n"
          "For ${name}", Colors.green);
    }else {
      print(response.data);
    }
  }
  // إنشاء بطاقة زيارة


  @override
  void initState() {
    super.initState();
    getUsersPage.checkAndStoreUserId;
    loadUserModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Create Visit Card', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () async {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: _getUserModelFromPrefs(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final userModel = snapshot.data!;
                return Column(
                  children: [
                    SizedBox(height: 10),
                    _isDoubleVisit ? _buildCollaborativeField() : SizedBox(),
                    SizedBox(height: 10),
                    _buildMonthlyPlanDropdown(userModel.uid.toString()),
                    SizedBox(height: 10),
                    SizedBox(
                        height: _monthlyPlanIdController.text.isNotEmpty ? MediaQuery.of(context).size.height * 0.17 : 5,
                        width:  MediaQuery.of(context).size.width * 0.95,
                        child: _buildDailyPlanDropdown(_monthlyPlanIdController.text.toString())),
                    SizedBox(height:10),
                    _buildPartnerDropdown(userModel.uid.toString()),
                    SizedBox(height: 10),
                    _buildDoubleVisitSwitch(),
                    SizedBox(height: 10),
                    if (_isDoubleVisit) _buildDoubleVisitTypeDropdown(),
                    SizedBox(height: 10),
                    SizedBox(height: 10),
                    _buildUserDropdown(),
                    SizedBox(height: 10,),
                    _buildLeaveBehindDropdown(),
                    SizedBox(height: 20),
                    _buildSubmitButton(),
                  ],
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCollaborativeField() {
    return TextFormField(
      controller: _objectiveController,
      decoration: InputDecoration(
        labelText: 'Note',
        border: OutlineInputBorder(),
      ),
    );
  }

// Switch for Double Visit
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

// Dropdown for Double Visit Type
  Widget _buildDoubleVisitTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Select Double Visit Type'),
      value: _doubleVisitType.isNotEmpty ? _doubleVisitType : null, // تأكد من أن القيمة محدثة
      items: [
        'audit',
        'coaching',
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



  // Dropdown for Monthly Plans
  Widget _buildMonthlyPlanDropdown(String userId) {
    return BlocProvider(
      create: (context) => MonthlyPlanCubit()..fetchMonthlyPlans(userId: userId),
      child: BlocBuilder<MonthlyPlanCubit, MonthlyPlanState>(
        builder: (context, state) {
          if (state is MonthlyPlanLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is MonthlyPlanLoaded) {
            DateTime today = DateTime.now();
            String formattedDate = DateFormat('yyyy-MM-dd').format(today);

            // التأكد من أن البيانات هي قائمة من الخرائط
            List<Map<String, dynamic>> monthlyPlans = (state.monthlyPlans as List<dynamic>)
                .cast<Map<String, dynamic>>(); // تحويل القائمة إلى النوع المطلوب

            // فلترة الخطط بناءً على تاريخ البداية والنهاية
            List<Map<String, dynamic>> filteredPlans = monthlyPlans.where((plan) {

              // التحقق من أن اليوم يقع بين start_date و end_date
              return (formattedDate.compareTo(plan['start_date']) >= 0) &&
                  (formattedDate.compareTo(plan['end_date']) <= 0);
            }).toList();
            return Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: 'Select Monthly Plan'),
                    value: filteredPlans.isNotEmpty && _monthlyPlanIdController.text.isNotEmpty
                        ? int.tryParse(_monthlyPlanIdController.text)
                        : null, // Set to null if filteredPlans is empty or no valid selection
                    items: filteredPlans.map((plan) {
                      return DropdownMenuItem<int>(
                        value: plan['id'], // Ensure unique IDs
                        child: Text(plan['title']),
                      );
                    }).toSet().toList(), // Convert to Set to ensure uniqueness, then back to List
                    onChanged: (int? newValue) {
                      setState(() {
                        if (newValue != null) {
                          _monthlyPlanIdController.text = newValue.toString();
                          _dailyPlanIdController.clear(); // Clear daily plan ID if needed
                          context.read<MonthlyPlanCubit>().fetchMonthlyPlans(userId:userId ); // تأكد من وجود دالة fetchMonthlyPlans() في MonthlyPlanCubit

                        }
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.blue),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: CreateMonthlyDialog(
                          ),
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.blue,),
                  onPressed: () {
                    // Refresh data
                    context.read<MonthlyPlanCubit>().fetchMonthlyPlans(userId: userId);
                  },
                ),

              ],
            );
          } else if (state is MonthlyPlanError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No Data'));
        },
      ),
    );
  }

  Widget _buildDailyPlanDropdown(String id) {
    return _monthlyPlanIdController.text.isNotEmpty ? BlocProvider(
      create: (context) => TodayDailyCubit()..fetchTodayDailies(userId: id),
      child: BlocBuilder<TodayDailyCubit, TodayDailyState>(
        builder: (context, state) {
          if (state is TodayDailyLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is TodayDailyLoaded) {
            DateTime today = DateTime.now();
            String formattedDate = DateFormat('yyyy-MM-dd').format(today);
            DateTime formattedDateTime = DateTime.parse(formattedDate);

            // تحويل القائمة إلى النوع المناسب
            List<Map<String, dynamic>> todayDailies = (state.todayDailies as List<dynamic>)
                .cast<Map<String, dynamic>>();

            // فلترة العناصر بناءً على أن التاريخ اليوم أو بعده
            List<Map<String, dynamic>> filteredDailies = todayDailies.where((daily) {
              DateTime dailyDate = DateTime.parse(daily['date']);
              return dailyDate.isAtSameMomentAs(formattedDateTime) || dailyDate.isAfter(formattedDateTime);
            }).toList();

            // استخراج التيريتوري الخاصة بكل خطة يومية
            List<Map<String, dynamic>> dailyTerritories = [];
            for (var daily in filteredDailies) {
              if (daily['territories'] != null) {
                dailyTerritories.addAll((daily['territories'] as List<dynamic>).cast<Map<String, dynamic>>());
              }
            }


            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(labelText: 'Select Daily Plan'),
                        value: int.tryParse(_dailyPlanIdController.text),
                        items: filteredDailies.map((daily) {
                          return DropdownMenuItem<int>(
                            value: daily['id'],
                            child: Text("${daily['title']}  / ${daily['date']}"),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            _dailyPlanIdController.text = newValue.toString();
                            context.read<TodayDailyCubit>().fetchTodayDailies(userId: id);
                            _territoryIdController.clear();
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.blue,),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: StatefulBuilder(
                                builder: (BuildContext context, StateSetter setState) {
                                  return CreateDailyDialog(monthlyPlanId: _monthlyPlanIdController.text);
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: Colors.blue,),
                      onPressed: () {
                        // Refresh data
                        context.read<TodayDailyCubit>().fetchTodayDailies(userId: _monthlyPlanIdController.text);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Select Territory'),
                  value: _isTerritorySelected ? int.tryParse(_territoryIdController.text) : null,
                  onChanged: _isTerritorySelected ? null : (int? newValue) {
                    setState(() {
                      _territoryIdController.text = newValue.toString();
                      _selectedTerritoryName = dailyTerritories
                          .firstWhere((territory) => territory['id'] == newValue)['name'];
                      _partnerIdController.clear();
                    });
                  },
                  items: dailyTerritories.map((territory) {
                    return DropdownMenuItem<int>(
                      value: territory['id'],
                      child: Text(territory['name']),
                    );
                  }).toList(),
                ),
              ],
            );
          } else if (state is TodayDailyError) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {
                                return CreateDailyDialog(
                                  monthlyPlanId: _monthlyPlanIdController.text.toString(),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }, child: Text("Create New Daily!")),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.blue),
                  onPressed: () {
                    // Refresh data
                    context.read<TodayDailyCubit>().fetchTodayDailies(userId: _monthlyPlanIdController.text);
                  },
                ),
              ],
            );
          }
          return Center(child: Text('No data available'));
        },
      ),
    ) : Container(height: 1,);
  }

  // دالة لإنشاء قائمة من Dropdown للشركاء
  Widget _buildPartnerDropdown(String id) {
    return BlocProvider(
      create: (context) => PartnerInfoCubit()..fetchPartnerInfo(id),
      child: BlocBuilder<PartnerInfoCubit, PartnerInfoState>(
        builder: (context, state) {
          if (state is PartnerInfoLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is PartnerInfoLoadedRaw) {
            final partnerData = state.partnerData
                .where((partner) => partner['territory_id'] == _selectedTerritoryName && partner['client_type'] == 'pharmacy')
                .toList(); // تصفية الشركاء بناءً على territory_id

            return Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: 'Select Partner'),
                    // تحقق مما إذا كان _partnerIdController فارغًا
                    value: _partnerIdController.text.isNotEmpty
                        ? int.tryParse(_partnerIdController.text)
                        : null, // اجعل القيمة فارغة إذا كان _partnerIdController فارغًا
                    onChanged: (int? newValue) {
                      setState(() {
                        if (newValue != null) {
                          _partnerIdController.text = newValue.toString();
                        } else {
                          _partnerIdController.clear(); // يمكنك استخدام هذا إذا أردت مسح القيمة في حالة الاختيار.
                        }
                      });
                    },
                    items: partnerData.map<DropdownMenuItem<int>>((partner) {
                      return DropdownMenuItem<int>(
                        value: int.tryParse(partner['id'].toString()), // تأكد من تحويل id إلى int
                        child: Text(partner['name']),
                      );
                    }).toList(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreatePartnerPlan(
                      )),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.blue),
                  onPressed: () {
                    // Refresh data
                    context.read<PartnerInfoCubit>().fetchPartnerInfo(id);
                  },
                ),
              ],
            );

          } else if (state is PartnerInfoError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No data available'));
        },
      ),
    );
  }
  // متغير للاحتفاظ باسم المنطقة المختارة
  String? _selectedTerritoryName;
  bool _isTerritorySelected = false;



  // Dropdown for Territory

  // Dropdown for Users
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

  Widget _buildLeaveBehindDropdown() {
    return BlocProvider(
      create: (context) => LeaveBehindCubit()..fetchLeaveBehinds(),
      child: BlocBuilder<LeaveBehindCubit, LeaveBehindState>(
        builder: (context, state) {
          if (state is LeaveBehindLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is LeaveBehindLoaded) {
            // قائمة leave-behinds
            final leaveBehinds = state.leaveBehinds;

            if (leaveBehinds.isEmpty) {
              return Center(child: Text('No matching leave-behind found.'));
            }

            return Column(
              children: [
                // Dropdown for selecting leave-behind
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Select Leave Behind'),
                  value: _leaveBehindIds.isNotEmpty ? _leaveBehindIds.first : null,
                  onChanged: (int? newValue) {
                    setState(() {
                      if (newValue != null && !_leaveBehindIds.contains(newValue)) {
                        _leaveBehindIds.add(newValue);
                      }
                    });
                  },
                  items: leaveBehinds.map((leaveBehind) {
                    return DropdownMenuItem<int>(
                      value: leaveBehind['id'],
                      child: Text(leaveBehind['name']),
                    );
                  }).toList(),
                ),
                // قائمة العناصر المحددة
                Column(
                  children: _leaveBehindIds.map((id) {
                    final leaveBehind = leaveBehinds.firstWhere((l) => l['id'] == id);
                    return ListTile(
                      title: Text(leaveBehind['name']),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: () {
                          setState(() {
                            _leaveBehindIds.remove(id); // حذف العنصر من القائمة
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          } else if (state is LeaveBehindError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No Data'));
        },
      ),
    );
  }
// Dropdown for Products
  Widget _buildProductDropdown() {
    return BlocProvider(
      create: (context) => ProductCubit()..fetchProducts(),
      child: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ProductLoaded) {
            return Column(
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Select Product'),
                  value: _productIds.isNotEmpty ? _productIds.first : null,
                  onChanged: (int? newValue) {
                    setState(() {
                      if (newValue != null && !_productIds.contains(newValue)) {
                        _productIds.add(newValue);
                      }
                    });
                  },
                  items: state.products.map((product) {
                    return DropdownMenuItem<int>(
                      value: product.id,
                      child: Text(product.name),
                    );
                  }).toList(),
                ),
                // قائمة العناصر المحددة
                Column(
                  children: _productIds.map((id) {
                    final product = state.products.firstWhere((p) => p.id == id);
                    return ListTile(
                      title: Text(product.name),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: () {
                          setState(() {
                            _productIds.remove(id);
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          } else if (state is ProductError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No Data'));
        },
      ),
    );
  }

// Dropdown for Visit Objectives
  Widget _buildVisitObjectiveDropdown() {
    return BlocProvider(
      create: (context) => VisitObjectiveCubit()..fetchVisitObjectives(),
      child: BlocBuilder<VisitObjectiveCubit, VisitObjectiveState>(
        builder: (context, state) {
          if (state is VisitObjectiveLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is VisitObjectiveLoaded) {
            return Column(
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Select Objective'),
                  value: _objectiveIds.isNotEmpty ? _objectiveIds.first : null,
                  onChanged: (int? newValue) {
                    setState(() {
                      if (newValue != null && !_objectiveIds.contains(newValue)) {
                        _objectiveIds.add(newValue);
                        // Add the corresponding name to the _objectiveNames list
                        final selectedObjective = state.visitObjectives
                            .firstWhere((o) => o.id == newValue);
                        _objectiveNames.add(selectedObjective.name);
                      }
                    });
                  },
                  items: state.visitObjectives.map((objective) {
                    return DropdownMenuItem<int>(
                      value: objective.id,
                      child: Text(objective.name),
                    );
                  }).toList(),
                ),
                // قائمة العناصر المحددة
                Column(
                  children: _objectiveIds.map((id) {
                    final objective = state.visitObjectives.firstWhere((o) => o.id == id);
                    return ListTile(
                      title: Text(objective.name),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: () {
                          setState(() {
                            _objectiveIds.remove(id);
                            // Remove the corresponding name from the _objectiveNames list
                            _objectiveNames.remove(objective.name);
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          } else if (state is VisitObjectiveError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No Data'));
        },
      ),
    );
  }


  // Submit Button
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          createVisitCard();
        },
        child: Text('Submit'),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the controllers when not needed
    _dailyPlanIdController.dispose();
    _territoryIdController.dispose();
    _partnerIdController.dispose();
    _collaborativeIdController.dispose();
    _surveyIdController.dispose();
    _objectiveController.dispose();
    _userIdController.dispose();
    _partnerNameController.dispose();
    super.dispose();
  }

// دالة لاسترجاع البيانات المطلوبة من SharedPreferences
  Future<UserModel> _getUserModelFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = prefs.getString('sessionData');
    if (sessionData != null) {
      return UserModel.fromJson(jsonDecode(sessionData));
    }
    throw Exception('No user data found');
  }
}