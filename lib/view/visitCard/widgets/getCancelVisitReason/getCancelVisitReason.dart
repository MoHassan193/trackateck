import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../model_view/cubits/mainCubitofWidget/cancelVisitReaonCubit/getcancelVisitCubit.dart';
import '../../../../model_view/cubits/mainCubitofWidget/cancelVisitReaonCubit/getcancelVisitState.dart';


class VisitCancelReasonWidget extends StatelessWidget {
  const VisitCancelReasonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VisitCancelReasonCubit()..fetchVisitCancelReasons(),
      child: BlocBuilder<VisitCancelReasonCubit, VisitCancelReasonState>(
        builder: (context, state) {
          if (state is VisitCancelReasonLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is VisitCancelReasonLoaded) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: state.reasons.length,
              itemBuilder: (context, index) {
                final reason = state.reasons[index];
                return ListTile(
                  title: Text("Reason: ${reason['name']}", style: Theme.of(context).textTheme.bodyLarge),
                  onTap: () {
                    Navigator.of(context).pop(reason);
                  },
                );
              },
            );
          } else if (state is VisitCancelReasonError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}
