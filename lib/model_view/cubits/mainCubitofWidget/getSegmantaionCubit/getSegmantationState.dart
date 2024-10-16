
import '../../../../model/userModel/segmentationModel.dart';

abstract class SegmentationState {}

class SegmentationInitial extends SegmentationState {}

class SegmentationLoading extends SegmentationState {}

class SegmentationLoaded extends SegmentationState {
  final List<SegmentationModel> segmentations;

  SegmentationLoaded(this.segmentations);
}

class SegmentationError extends SegmentationState {
  final String message;

  SegmentationError(this.message);
}
