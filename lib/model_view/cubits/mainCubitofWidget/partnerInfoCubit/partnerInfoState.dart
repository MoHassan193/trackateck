import '../../../../model/userModel/partnerInfoModel.dart';

abstract class PartnerInfoState {}

class PartnerInfoInitial extends PartnerInfoState {}

class PartnerInfoLoading extends PartnerInfoState {}

class PartnerInfoLoaded extends PartnerInfoState {
  final List<PartnerInfoModel> partnerInfo;

  PartnerInfoLoaded(this.partnerInfo);
}

class PartnerInfoLoadedRaw extends PartnerInfoState {
  final List<dynamic> partnerData;

  PartnerInfoLoadedRaw(this.partnerData);

  @override
  List<Object?> get props => [partnerData];
}

class PartnerInfoError extends PartnerInfoState {
  final String message;

  PartnerInfoError(this.message);
}

class AllPartnerInfoLoading extends PartnerInfoState {}

class AllPartnerInfoLoaded extends PartnerInfoState {
  final List<PartnerInfoModel> partnerInfo;

  AllPartnerInfoLoaded(this.partnerInfo);
}

class AllPartnerInfoLoadedRaw extends PartnerInfoState {
  final List<dynamic> partnerData;

  AllPartnerInfoLoadedRaw(this.partnerData);

  @override
  List<Object?> get props => [partnerData];
}

class AllPartnerInfoError extends PartnerInfoState {
  final String message;

  AllPartnerInfoError(this.message);
}