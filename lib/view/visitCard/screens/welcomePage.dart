import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model_view/cubits/infoCubit/myInfoCubit.dart';
import '../../../model_view/cubits/infoCubit/myInfoState.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = (hour >= 0 && hour < 12) ? 'Good Morning' : 'Good Evening';

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<MyInfoCubit, MyInfoState>(
          builder: (context, state) {
            if (state is MyInfoLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is MyInfoError) {
              return Center(child: Text(state.message));
            } else if (state is MyInfoLoaded) {
              return Text(
                '$greeting ${state.data.name}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              );
            } else {
              return Center(child: Text(greeting));
            }
          },
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // إضافة قسم الطقس والحرارة داخل Container بلون أزرق
            Container(
              color: Colors.blue, // اللون الأزرق للخلفية
              padding: const EdgeInsets.all(20.0),
              margin: const EdgeInsets.all(10.0),
              child:  ListTile(
                title: Text(
                  'الحرارة: 25°C',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                subtitle: Text(
                  'حالة الطقس: مشمس',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                leading: Icon(
                  Icons.wb_sunny, // أيقونة الطقس
                  color: Colors.white,
                  size: 40,
                ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
