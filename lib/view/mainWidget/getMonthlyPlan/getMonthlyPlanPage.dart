import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/monthlyPlanCubit/monthlyPlanState.dart';


import '../../../model_view/cubits/mainCubitofWidget/monthlyPlanCubit/monthlyPlanCubit.dart';

class MonthlyPlanPage extends StatelessWidget {
  const MonthlyPlanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Plans'),
      ),
      body: BlocProvider(
        create: (context) => MonthlyPlanCubit()..fetchMonthlyPlans(),
        child: BlocBuilder<MonthlyPlanCubit, MonthlyPlanState>(
          builder: (context, state) {
            if (state is MonthlyPlanLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is MonthlyPlanLoaded) {
              return ListView.builder(
                itemCount: state.monthlyPlans.length,
                itemBuilder: (context, index) {
                  final plan = state.monthlyPlans[index];
                  return ListTile(
                    title: Text(plan.title),
                    subtitle: Text('User: ${plan.user}\nStart Date: ${plan.startDate}\nEnd Date: ${plan.endDate}\nState: ${plan.state}'),
                    leading: Icon(Icons.calendar_today), // Use an appropriate icon or placeholder
                    onTap: () {
                      // Handle item tap if needed
                    },
                  );
                },
              );
            } else if (state is MonthlyPlanError) {
              return Center(child: Text('No Data Found'));
            }
            return Center(child: Text('No Data'));
          },
        ),
      ),
    );
  }
}
