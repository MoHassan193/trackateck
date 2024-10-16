import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_man/model/dialToast.dart';

import '../../../model_view/cubits/postCubit/rechCubit/rechCubit.dart';
import '../../../model_view/cubits/postCubit/rechCubit/rechState.dart';


class RescheduleVisitPage extends StatelessWidget {
  const RescheduleVisitPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reschedule Visit'),
      ),
      body: BlocProvider(
        create: (context) => RescheduleVisitCubit(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: RescheduleVisitCubit.get(context).rescheduleReasonController,
                decoration: const InputDecoration(
                  labelText: 'Reschedule Reason',
                ),
              ),
              TextField(
                controller: RescheduleVisitCubit.get(context).rescheduleDateController,
                decoration: const InputDecoration(
                  labelText: 'Reschedule Date',
                ),
              ),
              const SizedBox(height: 20),
              BlocConsumer<RescheduleVisitCubit, RescheduleVisitState>(
                listener: (context, state) {
                  if (state is RescheduleVisitSuccess) {
                    DialToast.showToast("Visit Rescheduled Successfully", Colors.green);
                  } else if (state is RescheduleVisitFailure) {
                    DialToast.showToast("Error", Colors.red);
                  }
                },
                builder: (context, state) {
                  if (state is RescheduleVisitLoading) {
                    return const CircularProgressIndicator();
                  }
                  var cubit = RescheduleVisitCubit.get(context);
                  return ElevatedButton(
                    onPressed: () {
                      context.read<RescheduleVisitCubit>().rescheduleVisit(
                        rescheduleReason: cubit.rescheduleReasonController.text,
                        rescheduleDate: cubit.rescheduleDateController.text,
                        state: 'rescheduled',
                      ).then(
                        (_) => showDialog(context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Visit Rescheduled'),
                              content: const Text('Visit rescheduled successfully'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                        ),
                      );
                    },
                    child: const Text('Reschedule Visit'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}