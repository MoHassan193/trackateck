import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/dialToast.dart';
import 'package:visit_man/model_view/cubits/partnerVisitsCubit/partnerVisitsCubit.dart';
import 'package:visit_man/model_view/cubits/partnerVisitsCubit/partnerVisitsState.dart';
import 'package:visit_man/view/visitCard/screens/visitCard/VisitiCard.dart';
import 'dart:convert';
import 'package:ribbon_widget/ribbon_widget.dart';
import '../../../../model/userModel/userModel.dart';
import '../../../../model/utils/move.dart';
import '../../../../model_view/cubits/mainCubitofWidget/getTodayVisitCubit/get_today_visit_cubit.dart';
import '../../model/commonWidget/networkImageCustom/networkImageCustom.dart';


class PartnerVisitsScreen extends StatefulWidget {
  const PartnerVisitsScreen({Key? key, required this.partnerId}) : super(key: key);

  final String partnerId;

  @override
  State<PartnerVisitsScreen> createState() => _PartnerVisitsScreenState();
}

class _PartnerVisitsScreenState extends State<PartnerVisitsScreen> with RouteAware {
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
    return FutureBuilder<UserModel>(
      future: _getUserModelFromPrefs(), // جلب بيانات المستخدم من SharedPreferences
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Today\'s Visits'),
              centerTitle: true,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back),
              ),
            ),
            body: Center(child: CircularProgressIndicator()), // شاشة انتظار
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Today\'s Visits'),
              centerTitle: true,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back),
              ),
            ),
            body: Center(child: Text('No Data Found')), // عرض الخطأ
          );
        } else if (snapshot.hasData) {
          final userModel = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('Partner\'s Visits'),
              centerTitle: true,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back),
              ),
            ),
            body: BlocProvider(
              create: (context) => PartnerVisitCubit()
                ..fetchTodayVisits(partnerId: widget.partnerId), // استخدام partnerId من الـ widget
              child: BlocBuilder<PartnerVisitCubit, PartnerVisitState>(
                builder: (context, state) {
                  if (state is PartnerVisitLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is PartnerVisitSuccess) {
                    final visits = state.visits;
                    return RefreshIndicator(
                      onRefresh: () async {
                        final cubit = BlocProvider.of<PartnerVisitCubit>(context);
                        cubit.fetchTodayVisits(partnerId: widget.partnerId);
                      },
                      child: ListView.builder(
                        itemCount: visits.length, // عدد الزيارات
                        itemBuilder: (context, index) {
                          final visit = visits[index];
                          return GestureDetector(
                            onTap: () {
                              if (visit['visit_id'] is int && visit['partner_rec_id'] is int) {
                                Move.move(
                                  context,
                                  VisitCardPage(
                                    isSale: userModel.representativeType == 'medical' ? false : true,
                                    visitData: visit,
                                    state: visit['state'],
                                    partnerid: visit['partner_rec_id'],
                                    visitId: visit['visit_id'],
                                  ),
                                );
                              } else {
                                DialToast.showToast("Data Not Correct", Colors.red);
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
                  } else if (state is PartnerVisitError) {
                    return Center(child: Text('No Data Found'));
                  } else {
                    return Center(child: Text('No data available'));
                  }
                },
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Partner\'s Visits'),
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
            ),
          ),
          body: Center(child: Text('No data available')), // لا يوجد بيانات
        );
      },
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
                  NetworkImageCustom(
                    imageUrl: image,
                    size: 40,
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
              farLength: 100,  // الطول البعيد
              title: state,  // النص الذي يظهر في الشريط
              titleStyle: TextStyle(
                color: textColor,  // لون النص
                fontSize: 18,         // حجم النص
                fontWeight: FontWeight.bold, // جعل النص عريضاً
              ),
              color: ribbonColor,  // لون الشريط بناءً على حالة additionalInfo
              location: RibbonLocation.topEnd, child: SizedBox(), // موقع الشريط (الزاوية العلوية اليمنى)
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

// create