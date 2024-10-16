import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart'; // إضافة SharedPreferences
import 'package:visit_man/model_view/cubits/mainCubitofWidget/visitObjectiveCubit/visitObjectiveCubit.dart';

import '../../../model_view/cubits/mainCubitofWidget/visitObjectiveCubit/visitObjectiveState.dart';

class VisitObjectivePage extends StatelessWidget {
  const VisitObjectivePage({Key? key}) : super(key: key);

  Future<void> saveObjectives(List<Map<String, dynamic>> objectives) async {
    final prefs = await SharedPreferences.getInstance();

    // تحويل الأهداف إلى قائمة من السلاسل النصية
    List<String> objectivesString = objectives.map((objective) {
      return '${objective['id']},${objective['name']},${objective['type']}';
    }).toList();

    // حفظ الأهداف في SharedPreferences
    await prefs.setStringList('selectedObjectives', objectivesString);
  }

  Future<void> saveAllObjectives(BuildContext context) async {
    final state = BlocProvider.of<VisitObjectiveCubit>(context).state;

    if (state is VisitObjectiveLoaded && state.visitObjectives.isNotEmpty) {
      // تحويل قائمة الأهداف إلى قائمة من القواميس
      List<Map<String, dynamic>> objectives = state.visitObjectives.map((objective) {
        return {
          'id': objective.id,
          'name': objective.name,
          'type': objective.type,
        };
      }).toList();

      // استخراج الأسماء
      List<String> names = objectives.map((objective) => '"${objective['name']}"').toList();
      String objectiveNames = names.join(', ');

      // استخراج المعرفات
      List<String> objectiveIdList = objectives.map((objective) => objective['id'].toString()).toList();
      List<int> objectiveIds = objectiveIdList.map((id) => int.parse(id)).toList();

      final prefs = await SharedPreferences.getInstance();
      // حفظ الأسماء والمعرفات في SharedPreferences
      await prefs.setString('objective', objectiveNames);
      await prefs.setStringList('objectiveIds', objectiveIdList); // حفظ المعرفات كقائمة

      // حفظ الأهداف
      await saveObjectives(objectives);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All objectives saved automatically')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visit Objectives'),
      ),
      body: BlocProvider(
        create: (context) => VisitObjectiveCubit()..fetchVisitObjectives(),
        child: BlocBuilder<VisitObjectiveCubit, VisitObjectiveState>(
          builder: (context, state) {
            if (state is VisitObjectiveLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is VisitObjectiveLoaded) {
              // حفظ أول objectiveId عند تحميل الأهداف
              saveAllObjectives(context);

              return ListView.builder(
                itemCount: state.visitObjectives.length,
                itemBuilder: (context, index) {
                  final objective = state.visitObjectives[index];
                  return ListTile(
                    title: Text(objective.name),
                    subtitle: Text('Type: ${objective.type}'),
                    leading: Icon(Icons.assignment), // استخدام أيقونة مناسبة
                  );
                },
              );
            } else if (state is VisitObjectiveError) {
              return Center(child: Text('No Data Found'));
            }
            return Center(child: Text('No Data'));
          },
        ),
      ),
    );
  }
}
