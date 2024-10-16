import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetworkImageCustom extends StatefulWidget {
  final String imageUrl;
  final double size;

  const NetworkImageCustom({required this.imageUrl, required this.size, Key? key}) : super(key: key);

  @override
  _NetworkImageCustomState createState() => _NetworkImageCustomState();
}

class _NetworkImageCustomState extends State<NetworkImageCustom> {
  String? cookieString;

  @override
  void initState() {
    super.initState();
    _loadCookies();
  }

  Future<void> _loadCookies() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cookieString = prefs.getString('cookie');
    });
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.size,
      backgroundImage: cookieString != null
          ? CachedNetworkImageProvider(
        widget.imageUrl,
        headers: {
          'Cookie': cookieString!, // استخدام الكوكيز المحفوظة
        },
      )
          : null,
      child: cookieString == null ? CircularProgressIndicator() : null,
    );
  }
}

