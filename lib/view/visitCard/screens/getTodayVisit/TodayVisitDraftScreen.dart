import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ribbon_widget/ribbon_widget.dart';
import '../../../../model/dialToast.dart';
import '../../../../model/userModel/userModel.dart';
import '../../../../model/utils/move.dart';
import '../../../../model_view/cubits/mainCubitofWidget/getTodayVisitCubit/get_today_visit_cubit.dart';
import '../../../../model_view/cubits/mainCubitofWidget/getTodayVisitCubit/get_today_visit_state.dart';
import '../../createVisitCard/createVisitCard.dart';
import '../visitCard/VisitiCard.dart';

class TodayVisitDraftScreen extends StatefulWidget {
  const TodayVisitDraftScreen({Key? key}) : super(key: key);
  @override
  State<TodayVisitDraftScreen> createState() => _TodayVisitDraftScreenState();
}

class _TodayVisitDraftScreenState extends State<TodayVisitDraftScreen> with RouteAware {
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  @override
  void initState() {
    super.initState();
    // استدعاء التحديث عند الدخول الأول للصفحة
    _fetchData();
  }

  // استدعاء البيانات من API
  void _fetchData() async {
    final userModel = await _getUserModelFromPrefs();
    if (userModel != null) {
      final cubit = BlocProvider.of<GetTodayVisitCubit>(context);
      cubit.fetchTodayVisits(userId: userModel.uid.toString());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void didPopNext() {
    // استدعاء التحديث عند العودة إلى الصفحة
    _fetchData();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => Move.move(context, CreateVisitCardPage()),
            icon: Icon(Icons.add, color: Colors.white, size: 30),
            tooltip: 'Create Visit Card',
          ),
          SizedBox(width: 10),
        ],
        title: Text('Today\'s Planned Visits', textAlign: TextAlign.center),
      ),
      body: FutureBuilder<UserModel>(
        future: _getUserModelFromPrefs(), // جلب بيانات المستخدم من SharedPreferences
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final userModel = snapshot.data!;

            return BlocProvider(
              create: (context) => GetTodayVisitCubit()
                ..fetchTodayVisits(userId: userModel.uid.toString()), // استخدام userId من الـ UserModel
              child: BlocBuilder<GetTodayVisitCubit, GetTodayVisitState>(
                builder: (context, state) {
                  if (state is GetTodayVisitLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is GetTodayVisitSuccess) {
                    // تصفية الزيارات التي حالتها "draft"
                    final draftVisits = state.visits.where((visit) => visit['state'] == "draft").toList();

                    return RefreshIndicator(
                      onRefresh: () async {
                        final cubit = BlocProvider.of<GetTodayVisitCubit>(context);
                        cubit.fetchTodayVisits(userId: userModel.uid.toString());
                      },
                      child: ListView.builder(
                        itemCount: draftVisits.length, // عدد الزيارات المصنفة كـ "draft"
                        itemBuilder: (context, index) {
                          final visit = draftVisits[index];
                          return GestureDetector(
                            onTap: () {
                              // Check if visit_id and partner_rec_id are integers
                              if (visit['visit_id'] is int && visit['partner_rec_id'] is int) {
                                // Proceed with navigation if both are integers
                                Move.move(
                                  context,
                                  VisitCardPage(
                                    visitData: visit,
                                    isSale: userModel.representativeType == 'medical' ? false : true,
                                    state: visit['state'],
                                    partnerid: visit['partner_rec_id'],
                                    visitId: visit['visit_id'],
                                  ),
                                );
                              } else {
                                // Show a toast message if data is not correct
                                DialToast.showToast("Data Not Found", Colors.red);
                              }
                            },
                            child: buildInfoCard(
                              visit['representative_image'] ?? '',
                              '${visit['partner_id'].toString()}',
                              'Territory: ${visit['territory_id'].toString()}',
                              visit['title'].toString(),
                              '${visit['state'].toString()}',
                              context,
                            ),
                          );
                        },
                      ),
                    );
                  } else if (state is GetTodayVisitError) {
                    return Center(child: Text('No Data Found'));
                  } else {
                    return Center(child: Text('No data available'));
                  }
                },
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }


  Widget buildInfoCard(String image, String title, String value, String subtitle, String additionalInfo, BuildContext context) {
    // الحصول على عرض وارتفاع الشاشة باستخدام MediaQuery
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    // تحديد لون الشريط بناءً على قيمة additionalInfo
    Color ribbonColor;
    Color textColor = Colors.white; // لون النص الافتراضي
    String state = '';
    final List<Map<String, String>> clientTypeOptions = [
      {'value': 'doctor', 'label': 'Doctor'},
      {'value': 'hospital', 'label': 'Hospital'},
      {'value': 'clinic', 'label': 'Clinic'},
    ];
    String getClientTypeLabel(String type) {

      final selectedOption = clientTypeOptions.firstWhere(
            (option) => option['value'] == type,
        orElse: () => {'label': type}, // إذا لم يوجد تطابق، استخدم الـ type نفسه كـ label
      );
      return selectedOption['label']!;
    }

    switch (additionalInfo) {
      case 'done':
        textColor = Colors.white;
        state = "Completed";
        ribbonColor = Colors.green;
        break;
      case 'draft':
        textColor = Colors.blue;
        state = "Planned";
        ribbonColor = Colors.yellow;
        break;
      default:
        ribbonColor = Colors.red;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.02, // ضبط التباعد بناءً على ارتفاع الشاشة
        horizontal: screenWidth * 0.05, // ضبط التباعد بناءً على عرض الشاشة
      ),
      child: Stack(
        children: [
          // البطاقة الأساسية
          Container(
            decoration: BoxDecoration(
              color: Colors.white, // لون الخلفية
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.cyan, width: 2),
            ),
            height: screenHeight * 0.4, // جعل الارتفاع 40% من ارتفاع الشاشة
            width: screenWidth * 0.9, // جعل العرض 90% من عرض الشاشة
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05), // ضبط المسافة الداخلية
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center, // محاذاة العناوين إلى المنتصف
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(image),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: screenHeight * 0.03, // تكبير النص بناءً على حجم الشاشة
                      fontWeight: FontWeight.bold, // جعل النص غامقًا
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01), // ضبط المسافة بين العنوان الرئيسي والعنوان الفرعي
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600], // لون النص الفرعي
                      fontSize: screenHeight * 0.02, // حجم النص الفرعي
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02), // ضبط المسافة بين النصوص
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: screenHeight * 0.016, // حجم النص الرئيسي
                      fontWeight: FontWeight.bold, // جعل النص الرئيسي غامقًا
                    ),
                  ),
                ],
              ),
            ),
          ),
          // الشريط الذي يحتوي على additionalInfo
          Positioned(
            top: 0,
            right: 0,
            child: Ribbon(
              nearLength: 120, // الطول القريب
              farLength: 100, // الطول البعيد
              title: state, // النص الذي يظهر في الشريط
              titleStyle: TextStyle(
                color: textColor, // لون النص بناءً على حالة additionalInfo
                fontSize: 18, // حجم النص
                fontWeight: FontWeight.bold, // جعل النص عريضاً
              ),
              color: ribbonColor, // لون الشريط بناءً على حالة additionalInfo
              location: RibbonLocation.topEnd, // موقع الشريط (الزاوية العلوية اليمنى)
              child: SizedBox(), // عنصر فارغ كـ child
            ),
          ),
        ],
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

//
// return Padding(
// padding: const EdgeInsets.all(12),
// child: Container(
// padding: EdgeInsets.all(2),
// decoration: BoxDecoration(
// borderRadius: BorderRadius.circular(15),
// color: Colors.blue.shade600,
// boxShadow: [
// BoxShadow(
// color: Colors.blue.withOpacity(0.5),
// spreadRadius: 2,
// blurRadius: 5,
// offset: Offset(0, 3),
// ),
// ],
// ),
// child: ListTile(
// onTap: () => Move.move(context, VisitCardPage(partnerid: visit['partner_rec_id'],
// visitId: visit['visit_id'],
// )),
// leading: Image.network(
// visit['representative_image'] ?? '',
// errorBuilder: (context, error, stackTrace) => Icon(Icons.person),
// ),
// title: Text('${visit['partner_id'] ?? 'Unknown'}', style: TextStyle(color: Colors.white)),
// subtitle: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// mainAxisSize: MainAxisSize.min,
// children: [
// Text('Territory: ${visit['territory_id'] ?? 'Unknown'}', style: TextStyle(color: Colors.white)),
// SizedBox(height: 5),
// Text(visit['title'] ?? 'No Title', style: TextStyle(color: Colors.white)),
// ],
// ),
// trailing: Text('${visit['state'] ?? 'Unknown'}', style: TextStyle(color: Colors.white)),
// ),
// ),
// );