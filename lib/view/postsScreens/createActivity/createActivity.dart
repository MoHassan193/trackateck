import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_man/model/dialToast.dart';
import 'package:visit_man/model/utils/sizes.dart';

import '../../../model_view/cubits/postCubit/createActivityCubit/createActivityCubit.dart';
import '../../../model_view/cubits/postCubit/createActivityCubit/createActivityState.dart';

class CreateActivityPage extends StatelessWidget {
  final _visitIdController = TextEditingController();
  final _summaryController = TextEditingController();
  final _dateDeadlineController = TextEditingController();
  final _activityTypeIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Activity'),
      ),
      body: BlocProvider(
        create: (context) => CreateActivityCubit(),
        child: BlocConsumer<CreateActivityCubit, CreateActivityState>(
          listener: (context, state) {
            if (state is CreateActivitySuccess) {
              DialToast.showToast(state.message, Colors.green);
            } else if (state is CreateActivityFailure) {
              DialToast.showToast(state.error, Colors.red);
            }
          },
          builder: (context, state) {
            if (state is CreateActivityLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding:  EdgeInsets.all(MoSizes.spaceBtwItems(context)),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  TextField(
                    controller: _visitIdController,
                    decoration: InputDecoration(labelText: 'Visit ID'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _summaryController,
                    decoration: InputDecoration(labelText: 'Summary'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _dateDeadlineController,
                    decoration: InputDecoration(labelText: 'Deadline Date'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _activityTypeIdController,
                    decoration: InputDecoration(labelText: 'Activity Type ID'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final visitId = int.parse(_visitIdController.text);
                        final summary = _summaryController.text;
                        final dateDeadline = _dateDeadlineController.text;
                        final activityTypeId = int.parse(_activityTypeIdController.text);

                        context.read<CreateActivityCubit>().createActivity(
                          visitId: visitId,
                          summary: summary,
                          dateDeadline: dateDeadline,
                          activityTypeId: activityTypeId,
                        );
                      },
                      child: Text('Create Activity'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
