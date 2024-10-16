import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getActivityType/getActivityCubit.dart';

import '../../../../model_view/cubits/mainCubitofWidget/getActivityType/getActivityState.dart';

class GetActivityTypeWidget extends StatelessWidget {
  final int IdActivity; // استلام المعرف من الصفحة الثانية

  const GetActivityTypeWidget({super.key, required this.IdActivity});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActivityTypeCubit()..fetchActivityTypes(),
      child: BlocBuilder<ActivityTypeCubit, ActivityTypeState>(
        builder: (context, state) {
          if (state is ActivityTypeLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ActivityTypeLoaded) {
            // تصفية النشاطات لتظهر فقط النشاطات التي تتطابق مع IdActivity
            final filteredActivityTypes = state.activityTypes
                .where((activityType) => activityType.id == IdActivity)
                .toList();

            if (filteredActivityTypes.isEmpty) {
              return Center(child: Text('no matching activity type found'));
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: filteredActivityTypes.length,
              itemBuilder: (context, index) {
                final activityType = filteredActivityTypes[index];
                return ListTile(
                  title: Text(activityType.name),
                  leading: Icon(Icons.list),
                );
              },
            );
          } else if (state is ActivityTypeError) {
            return Center(child: Text('خطأ: ${state.message}'));
          }
          return Center(child: Text('لا توجد بيانات'));
        },
      ),
    );
  }
}
