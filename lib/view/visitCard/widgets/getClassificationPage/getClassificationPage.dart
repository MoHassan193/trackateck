import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../model_view/cubits/mainCubitofWidget/getClassificationCubit/getClassificationCubit.dart';
import '../../../../model_view/cubits/mainCubitofWidget/getClassificationCubit/getClassificationState.dart';

class GetClassificationWidget extends StatelessWidget {
  final int IdClassification; // Receive the ID from the second page

  const GetClassificationWidget({super.key, required this.IdClassification});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClassificationsCubit()..fetchClassifications(),
      child: BlocBuilder<ClassificationsCubit, ClassificationsState>(
        builder: (context, state) {
          if (state is ClassificationsLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ClassificationsLoaded) {
            // Filter classifications to show only the one matching IdClassification
            final filteredClassifications = state.classifications
                .where((classification) => classification.id == IdClassification)
                .toList();

            if (filteredClassifications.isEmpty) {
              return Center(child: Text('No matching data found'));
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: filteredClassifications.length,
              itemBuilder: (context, index) {
                final classification = filteredClassifications[index];
                return ListTile(
                  title: Text(
                    "Classification Name: ${classification.name}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    'Classification ID: ${classification.id}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            );
          } else if (state is ClassificationsError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No data available'));
        },
      ),
    );
  }
}
