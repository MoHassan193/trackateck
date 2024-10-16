import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_man/model/dialToast.dart';
import '../../../model/utils/sizes.dart';
import '../../../model_view/cubits/postCubit/updateVisitCubit/updateVisitCubit.dart';
import '../../../model_view/cubits/postCubit/updateVisitCubit/updateVisitState.dart';


class UpdateVisitPage extends StatelessWidget {
  const UpdateVisitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Visit No Checkout'),
      ),
      body: BlocProvider(
        create: (context) => UpdateVisitCubit(),
        child: BlocBuilder<UpdateVisitCubit, UpdateVisitState>(
          builder: (context, state) {
            var cubit = UpdateVisitCubit.get(context);
            return Padding(
              padding: EdgeInsets.all(MoSizes.defaultSpace(context)),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  TextField(
                    controller: cubit.collaborativeIdController,
                    decoration: InputDecoration(labelText: 'Collaborative ID'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: cubit.isDoubleVisit,
                    decoration: InputDecoration(labelText: 'Is Double Visit'),
                    items: [
                      DropdownMenuItem(
                        value: 'True',
                        child: Text('True'),
                      ),
                      DropdownMenuItem(
                        value: 'False',
                        child: Text('False'),
                      ),
                    ],
                    onChanged: (value) {
                      cubit.isDoubleVisit = value!;
                    },
                  ),
                  SizedBox(height: 10),

                  TextField(
                    controller: cubit.surveyIdController,
                    decoration: InputDecoration(labelText: 'Survey ID'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),

                  TextField(
                    controller: cubit.doubleVisitTypeController,
                    decoration: InputDecoration(labelText: 'Double Visit Type'),
                  ),
                  SizedBox(height: 20),
                  BlocConsumer<UpdateVisitCubit, UpdateVisitState>(
                    listener: (context, state) {
                      if (state is UpdateVisitSuccess) {
                        DialToast.showToast('Visit Updated Successfully!', Colors.green);
                      } else if (state is UpdateVisitFailure) {
                        DialToast.showToast('Error: ${state.error}', Colors.red);
                      }
                    },
                    builder: (context, state) {
                      if (state is UpdateVisitLoading) {
                        return CircularProgressIndicator();
                      }
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (cubit.collaborativeIdController.text.isEmpty) {
                              DialToast.showToast('Collaborative ID is required', Colors.red);
                              return;
                            }
                            if (cubit.surveyIdController.text.isEmpty) {
                              DialToast.showToast('Survey ID is required', Colors.red);
                              return;
                            }
                            if (cubit.doubleVisitTypeController.text.isEmpty) {
                              DialToast.showToast('Double Visit Type is required', Colors.red);
                              return;
                            }

                            context.read<UpdateVisitCubit>().updateVisitNoCheckout(
                              collaborativeId: int.parse(cubit.collaborativeIdController.text),
                              isDoubleVisit: cubit.isDoubleVisit == 'True',
                              surveyId: int.parse(cubit.surveyIdController.text),
                              doubleVisitType: cubit.doubleVisitTypeController.text,
                            );
                          },
                          child: Text('Update Visit'),
                        ),
                      );
                    },
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
