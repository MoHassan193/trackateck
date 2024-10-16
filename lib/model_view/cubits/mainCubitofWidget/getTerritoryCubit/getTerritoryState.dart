import 'package:equatable/equatable.dart';
import '../../../../model/userModel/visitAterorityModel.dart';

// Define the state
abstract class TerritoryState extends Equatable {
  const TerritoryState();

  @override
  List<Object> get props => [];
}

class TerritoryInitial extends TerritoryState {}

class TerritoryLoading extends TerritoryState {}

class TerritoryLoaded extends TerritoryState {
  final List<Territory> territories;

  const TerritoryLoaded(this.territories);

  @override
  List<Object> get props => [territories];
}

class TerritoryError extends TerritoryState {
  final String message;

  const TerritoryError(this.message);

  @override
  List<Object> get props => [message];
}
