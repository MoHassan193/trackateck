// mapState.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MapState {}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final List<LatLng> shortestPath;

  MapLoaded({required this.shortestPath});
}

final class MapSuccess extends MapState {
  final List data;

  MapSuccess({required this.data});
}
class MapError extends MapState {
  final String message;

  MapError(this.message);
}
