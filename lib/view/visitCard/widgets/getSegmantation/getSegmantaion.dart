import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../model_view/cubits/mainCubitofWidget/getSegmantaionCubit/getSegmantationCubit.dart';
import '../../../../model_view/cubits/mainCubitofWidget/getSegmantaionCubit/getSegmantationState.dart';

class SegmentationWidget extends StatelessWidget {
  final int IdSegmentation; // Receive the ID from the second page

  const SegmentationWidget({super.key, required this.IdSegmentation});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SegmentationCubit()..fetchSegmentations(),
      child: BlocBuilder<SegmentationCubit, SegmentationState>(
        builder: (context, state) {
          if (state is SegmentationLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is SegmentationLoaded) {
            // Filter segmentations to show only the one matching IdSegmentation
            final filteredSegmentations = state.segmentations
                .where((segmentation) => segmentation.id == IdSegmentation)
                .toList();

            if (filteredSegmentations.isEmpty) {
              return Center(child: Text('No matching data found'));
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: filteredSegmentations.length,
              itemBuilder: (context, index) {
                final segmentation = filteredSegmentations[index];
                return ListTile(
                  title: Text(
                    "Segmentation Name: ${segmentation.name}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    'Segmentation ID: ${segmentation.id}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            );
          } else if (state is SegmentationError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No data available'));
        },
      ),
    );
  }
}
