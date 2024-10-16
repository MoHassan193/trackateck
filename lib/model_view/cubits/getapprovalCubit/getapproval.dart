import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/userModel/userModel.dart';
import 'package:visit_man/model_view/cubits/getapprovalCubit/approvalState.dart';


class ApprovalCubit extends Cubit<ApprovalState> {
  ApprovalCubit() : super(ApprovalInitial());

  static ApprovalCubit get(context) => BlocProvider.of<ApprovalCubit>(context);

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
      emit(ApprovalError('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> fetchApprovals({required String userId}) async {
    emit(ApprovalLoading());

    await loadUserModel();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(ApprovalError('URL not found'));
        return;
      }

      final dio = Dio();
      final response = await dio.get(
        '$url/api//$userId/get_approval_request',
        options: Options(
          headers: {
            'token': _userModel.accessToken,
          },
        ),
      );

      if (response.statusCode == 200) {
        final approvals = response.data['data'];
        emit(ApprovalLoaded(approvals));
      } else {
        emit(ApprovalError('Failed to fetch approvals: ${response.statusCode}'));
      }
    } catch (e) {
      emit(ApprovalError('Error: ${e.toString()}'));
    }
  }

}
