abstract class TitlesState {}

class TitlesInitial extends TitlesState {}

class TitlesLoading extends TitlesState {}

class TitlesLoaded extends TitlesState {
  final List<dynamic> titles;

  TitlesLoaded(this.titles);
}

class TitlesError extends TitlesState {
  final String message;

  TitlesError(this.message);
}
