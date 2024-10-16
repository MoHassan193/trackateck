import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/partnerInfoCubit/partnerInfoState.dart';

import '../../../../model/userModel/partnerInfoModel.dart';
import '../../../../model/userModel/userModel.dart';


class PartnerInfoCubit extends Cubit<PartnerInfoState> {
  PartnerInfoCubit() : super(PartnerInfoInitial());

  static PartnerInfoCubit get(context) => BlocProvider.of<PartnerInfoCubit>(context);

  late UserModel userModel;

  Future<void> loadUserModel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = prefs.getString('sessionData');
      if (sessionData != null) {
        userModel = UserModel.fromJson(jsonDecode(sessionData));
      } else {
        throw Exception('No user data found');
      }
    } catch (e) {
      emit(PartnerInfoError('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> fetchPartnerInfo(String partnerId) async {
    emit(PartnerInfoLoading());

    await loadUserModel();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(PartnerInfoError('URL not found'));
        return;
      }

      final dio = Dio();
      final response = await dio.get('$url/api/partner_info', options: Options(
        headers: {
          'token': userModel.accessToken,
        },
      ));

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;

          emit(PartnerInfoLoadedRaw(data)); // إرسال بيانات الشريك

      } else {
        emit(PartnerInfoError('Failed to fetch partner info: ${response.statusCode}'));
      }
    } catch (e) {
      emit(PartnerInfoError('Error: ${e.toString()}'));
    }
  }

  Future<void> AllfetchPartnerInfo() async {
    emit(AllPartnerInfoLoading());

    await loadUserModel();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(AllPartnerInfoError('URL not found'));
        return;
      }

      final dio = Dio();
      final response = await dio.get('$url/api/partner_info', options: Options(
        headers: {
          'token': userModel.accessToken,
        },
      ));

      if (response.statusCode == 200) {
        final data = response.data['data'];
        // البحث عن بيانات الشريك بناءً على الـ ID
        emit(AllPartnerInfoLoadedRaw(data)); // إرسال بيانات الشريك

      } else {
        emit(AllPartnerInfoError('Failed to fetch partner info: ${response.statusCode}'));
      }
    } catch (e) {

    }
  }
}
