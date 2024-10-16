abstract class StatesState {}

class StatesInitial extends StatesState {}

class StatesLoading extends StatesState {}

class StatesLoaded extends StatesState {
  final List<dynamic> states;

  StatesLoaded(this.states);
}

class StatesError extends StatesState {
  final String message;

  StatesError(this.message);
}

