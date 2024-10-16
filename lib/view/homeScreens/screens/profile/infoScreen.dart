import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/dialToast.dart';
import 'package:visit_man/model/userModel/userModel.dart';
import 'package:visit_man/model_view/cubits/infoCubit/myInfoCubit.dart';
import 'package:visit_man/model_view/cubits/infoCubit/myInfoState.dart';
import 'package:visit_man/view/login/login.dart';

import '../../../../model/commonWidget/networkImageCustom/networkImageCustom.dart';
import '../../../../model/utils/sizes.dart';

class MyInfoPage extends StatefulWidget {
  @override
  State<MyInfoPage> createState() => _MyInfoPageState();
}

class _MyInfoPageState extends State<MyInfoPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Info'),
        centerTitle: true,
      ),
      body: FutureBuilder<UserModel>(
        future: _getUserModelFromPrefs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final userModel = snapshot.data!;

            return BlocProvider(
  create: (context) => MyInfoCubit()..fetchMyInfo(userId: userModel.uid.toString()),
  child: BlocBuilder<MyInfoCubit, MyInfoState>(
              builder: (context, state) {
                if (state is MyInfoLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is MyInfoError) {
                  return Center(child: Text(state.message));
                } else if (state is MyInfoLoaded) {
                  return _buildUserInfo(context, state.data);
                } else {
                  return Center(child: Text('لم يتم جلب البيانات بعد'));
                }
              },
            ),
);
          } else {
            return Center(child: Text('No user data found'));
          }
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

  // بناء واجهة المستخدم لعرض بيانات المستخدم
  Widget _buildUserInfo(BuildContext context, Map<String, dynamic> data) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final name = data['name'] ?? 'اسم غير معروف';
    final email = data['email'] ?? 'بريد غير معروف';
    final imageUrl = data['image'] ?? '';
    final phone = data['phone'] ?? 'No phone number';
    final tz = data['tz'] ?? 'No time zone';
    final representativeType = data['representative_type'] ?? 'No representative type';
    final territories = data['territory_ids'] as List<dynamic>? ?? [];

    return Padding(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              Center(
                child: NetworkImageCustom(
                  imageUrl: imageUrl,
                  size: 55,
                ),
              ),
            SizedBox(height: 16),
            _buildInfoContainer(width, height, name, 20,Icons.person),
            SizedBox(height: 10),
            _buildInfoContainer(width, height, email, 18,Icons.email,),
            SizedBox(height: 10),
            _buildInfoContainer(width, height, tz, 18,Icons.location_on),
            SizedBox(height: 10),
            _buildInfoContainer(width, height, phone, 18,Icons.phone),
            SizedBox(height: 10),
            _buildInfoContainer(width, height, representativeType, 18,representativeType == "medical" ? Icons.medical_services : Icons.sell_outlined),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _showTerritoriesModal(context, territories);
                },
                child: Text(
                  'Areas',
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 15,),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style:OutlinedButton.styleFrom(
                backgroundColor: Colors.red,
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
        
                  // الحصول على جميع المفاتيح
                  final keys = prefs.getKeys();
        
                  // إزالة جميع البيانات باستثناء المفاتيح المحددة
                  for (String key in keys) {
                    if (!['storedEmail', 'storedPassword', 'storedDatabase', 'storedUrl','isFirstLaunch'].contains(key)) {
                      await prefs.remove(key);
                    }
                  }
        
                  // إعادة توجيه المستخدم إلى صفحة تسجيل الدخول
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()), // استبدل `LoginPage` باسم صفحتك
                  );
                  DialToast.showToast("Logout Successfuly", Colors.green);
                },
                child: Text(
                  'LogOut',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }

  Widget _buildInfoContainer(double width, double height, String text, double fontSize,IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: height * 0.02,
        horizontal: width * 0.05,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.cyan, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,size: 30,color: Colors.grey.shade600,),
          SizedBox(width: 10,),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize),
          ),
        ],
      ),
    );
  }

  void _showTerritoriesModal(BuildContext context, List<dynamic> territories) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.separated(
        separatorBuilder: (context, index) => SizedBox(height: 8),
        itemCount: territories.length,
        itemBuilder: (context, index) {
          final territory = territories[index];
          return Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.cyan, width: 2),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.cyan.withOpacity(0.7),
                //     spreadRadius: 3,
                //     blurRadius: 15,
                //     offset: Offset(0, 5),
                //   ),
                // ],
              ),
              child: ListTile(
                leading: Icon(Icons.location_city),
                title: Text(
                  territory['display_name'] ?? 'منطقة غير معروفة',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
