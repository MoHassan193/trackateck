import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart'; // استيراد المكتبة
import '../../../../model_view/cubits/mainCubitofWidget/getProductCubit/getProductCubit.dart';
import '../../../../model_view/cubits/mainCubitofWidget/getProductCubit/getProductState.dart';

class ProductWidget extends StatefulWidget {
  const ProductWidget({super.key});

  @override
  _ProductWidgetState createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  List<String> selectedProductIds = []; // قائمة لتخزين الـ IDs المحددة
  List<String> allProducts = []; // قائمة لتخزين جميع المنتجات

  @override
  void initState() {
    super.initState();
    _loadSelectedProductIds(); // تحميل الـ IDs عند بدء التشغيل
  }

  // دالة لتحميل الـ selectedProductIds من SharedPreferences
  void _loadSelectedProductIds() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedProductIds = prefs.getStringList('selectedProductIds') ?? [];
    });
  }

  // دالة لحفظ الـ selectedProductIds في SharedPreferences
  void _saveSelectedProductIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedProductIds', selectedProductIds);
  }

  // دالة لحفظ جميع المنتجات في SharedPreferences
  void _saveAllProducts(List<String> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedProductIds', products);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductCubit()..fetchProducts(),
      child: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ProductLoaded) {
            // حفظ جميع المنتجات في SharedPreferences
            allProducts = state.products.map((product) => product.id.toString()).toList(); // تحويل الـ IDs إلى List<String>
            _saveAllProducts(allProducts); // حفظ جميع المنتجات

            return ListView.builder(
              shrinkWrap: true,
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];

                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(product.id.toString(), style: TextStyle(color: Colors.black)), // تغيير اللون إلى الأسود
                  leading: Icon(Icons.category),
                );
              },
            );
          } else if (state is ProductError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No Data'));
        },
      ),
    );
  }
}
