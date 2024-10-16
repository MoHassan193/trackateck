import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/userModel/productModel.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/getProductCubit/getProductState.dart';

import '../../../../model/userModel/userModel.dart';


class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(ProductInitial());

  static ProductCubit get(context) => BlocProvider.of<ProductCubit>(context);

  late UserModel _userModel; // Add UserModel property

  // Load user model from SharedPreferences
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
      emit(ProductError('Error loading user data: ${e.toString()}'));
    }
  }

  Future<void> fetchProducts() async {
    emit(ProductLoading());

    await loadUserModel(); // Ensure user model is loaded before fetching data

    try {
      // Get the stored URL from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('storedUrl');

      if (url == null || url.isEmpty) {
        emit(ProductError('URL not found'));
        return;
      }

      final dio = Dio();
      final response = await dio.get('$url/api/get_product',
        options: Options(
          headers: {
            'token': _userModel.accessToken, // Use access token
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final products = data
            .map((item) => ProductModel.fromJson(item))
            .toList();


        emit(ProductLoaded(products));
      } else {
        emit(ProductError('Failed to fetch data: ${response.statusCode}'));
      }
    } catch (e) {
      emit(ProductError('Error: ${e.toString()}'));
    }
  }
}
