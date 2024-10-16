import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart'; // استيراد الحزمة
import '../../../../model_view/cubits/mainCubitofWidget/getSurveyCubit/getSurveyCubit.dart';
import '../../../../model_view/cubits/mainCubitofWidget/getSurveyCubit/getSurveyState.dart';

class SurveyWidget extends StatelessWidget {
  final int IdSurvey; // Receive the ID from the second page

  const SurveyWidget({Key? key, required this.IdSurvey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SurveyCubit()..fetchSurveys(),
      child: BlocBuilder<SurveyCubit, SurveyState>(
        builder: (context, state) {
          if (state is SurveyLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is SurveyLoaded) {
            // Filter surveys to show only the one matching IdSurvey
            final filteredSurveys = state.surveys
                .where((survey) => survey.id == IdSurvey)
                .toList();

            // حفظ المعرف من البيانات المحملة إذا كان موجودًا
            if (filteredSurveys.isNotEmpty) {
              _saveSurveyId(filteredSurveys.first.id); // حفظ أول استطلاع متطابق
            }

            if (filteredSurveys.isEmpty) {
              return Center(child: Text('No matching survey found.'));
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: filteredSurveys.length,
              itemBuilder: (context, index) {
                final survey = filteredSurveys[index];
                return ListTile(
                  title: Text(survey.title),
                  subtitle: Text('Survey ID: ${survey.id}'),
                  leading: Icon(Icons.assessment),
                );
              },
            );
          } else if (state is SurveyError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No Data'));
        },
      ),
    );
  }

  Future<void> _saveSurveyId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('surveyId', id); // حفظ المعرف في SharedPreferences
  }
}
