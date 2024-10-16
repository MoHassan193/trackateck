import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/userModel/userModel.dart';
import '../../../../model/userModel/segmentationModel.dart';
import 'getSegmantationState.dart';

class SegmentationCubit extends Cubit<SegmentationState> {
  SegmentationCubit() : super(SegmentationInitial());

  static SegmentationCubit get(context) => BlocProvider.of<SegmentationCubit>(context);

  late UserModel _userModel;

  Future<void> loadUserModel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = prefs.getString('sessionData');
      if (sessionData != null) {
        _userModel = UserModel.fromJson(jsonDecode(sessionData));
      } else {
        throw Exception('No user data found');
      }
    } catch (e) {
      emit(SegmentationError('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> fetchSegmentations() async {
    emit(SegmentationLoading());

    await loadUserModel();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(SegmentationError('URL not found'));
        return;
      }

      final dio = Dio();
      final response = await dio.get(
        '$url/api/get_segmentations',
        options: Options(
          headers: {
            'token': _userModel.accessToken,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final segmentations = data.map((item) => SegmentationModel.fromJson(item)).toList();

        // Store the segmentId in SharedPreferences
        if (segmentations.isNotEmpty) {
          await _saveSegmentId(segmentations.first.id);
        }

        emit(SegmentationLoaded(segmentations));
      } else {
        emit(SegmentationError('Failed to fetch segmentations: ${response.statusCode}'));
      }
    } catch (e) {
      emit(SegmentationError('Error: ${e.toString()}'));
    }
  }

  // Method to save segmentId in SharedPreferences
  Future<void> _saveSegmentId(int segmentId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('segment_id', segmentId);
  }
}
