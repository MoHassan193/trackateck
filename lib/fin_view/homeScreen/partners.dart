import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visit_man/model/commonWidget/networkImageCustom/networkImageCustom.dart';
import 'package:visit_man/model/utils/move.dart';
import 'package:visit_man/model/utils/sizes.dart';
import '../../model/dialToast.dart';
import '../../model_view/cubits/mainCubitofWidget/partnerInfoCubit/partnerInfoCubit.dart';
import '../../model_view/cubits/mainCubitofWidget/partnerInfoCubit/partnerInfoState.dart';
import '../partnerSubWidgets/createPartner.dart';
import '../partnerwidget/partnerWidget.dart';

class FnPatnersScreen extends StatefulWidget {
  const FnPatnersScreen({super.key});

  @override
  State<FnPatnersScreen> createState() => _FnPatnersScreenState();
}

class _FnPatnersScreenState extends State<FnPatnersScreen> with RouteAware {
  String searchText = '';
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  @override
  void initState() {
    super.initState();
    _fetchData(); // استدعاء التحديث عند الدخول الأول للصفحة
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void didPopNext() {
    _fetchData(); // استدعاء التحديث عند العودة إلى الصفحة
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // استدعاء البيانات من API
  Future<void> _fetchData() async {
    final cubit = BlocProvider.of<PartnerInfoCubit>(context);
    cubit.AllfetchPartnerInfo();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       Move.move(context, CreatePartnerPlan());
        //     },
        //     icon: Icon(Icons.add, color: Colors.white),
        //   ),
        //   SizedBox(height: 10)
        // ],
        centerTitle: true,
        title: Text("Contacts", style: TextStyle(color: Colors.white)),
      ),
      body: BlocProvider(
        create: (context) => PartnerInfoCubit()..AllfetchPartnerInfo(),
        child: BlocBuilder<PartnerInfoCubit, PartnerInfoState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                final cubit = BlocProvider.of<PartnerInfoCubit>(context);
                await cubit.AllfetchPartnerInfo(); // استدعاء إعادة تحميل البيانات عند السحب
              },
              child: Builder(
                builder: (context) {
                  if (state is AllPartnerInfoLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is AllPartnerInfoLoadedRaw) {
                    // بيانات الشركاء من الـ API
                    final partnerData = state.partnerData;
                    return _buildPartnerList(context, height, partnerData);
                  } else if (state is AllPartnerInfoError) {
                    return Center(child: Text("No Data Available"));
                  } else {
                    return const Center(child: Text('No data available.'));
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // دالة لبناء قائمة الشركاء
  Widget _buildPartnerList(BuildContext context, double height, List<dynamic> partnerData) {
    // تصفية البيانات بناءً على النص المدخل في حقل البحث
    final filteredPartnerData = partnerData.where((partner) {
      return (partner['name'] ?? '').toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search...',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                searchText = value; // تحديث النص المدخل
              });
            },
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, index) {
              final partner = filteredPartnerData[index];
              return Padding(
                padding: EdgeInsets.all(MoSizes.md(context) / 1.5),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(MoSizes.md(context) / 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.cyan, width: 2),
                      ),
                      child: ListTile(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FnPartnerDetails(partnerData: partner),
                          ),
                        ),
                        leading: NetworkImageCustom(
                          imageUrl: partner['image'],
                          size: 30,
                        ),
                        title: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.grey, size: 15),
                                SizedBox(width: 3),
                                Text(
                                  partner['name'] ?? 'No Name',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.email, color: Colors.grey, size: 15),
                                SizedBox(width: 3),
                                Text(
                                  partner['street2'].toString(),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            GestureDetector(
                              onTap: () => showCallDialog(context, partner['mobile'] ?? ''),
                              child: Row(
                                children: [
                                  Icon(Icons.phone, color: Colors.grey, size: 15),
                                  SizedBox(width: 3),
                                  Text(
                                    partner['mobile'].toString(),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "Latitude : ${partner['partner_latitude'].toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Longitude : ${partner['partner_longitude'].toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 6),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => Column(
              children: [
                SizedBox(height: height * 0.02),
                Divider(height: 2, color: Colors.grey, indent: 50, endIndent: 50),
                SizedBox(height: height * 0.02),
              ],
            ),
            itemCount: filteredPartnerData.length, // استخدم البيانات المصفاة
          ),
        ),
      ],
    );
  }


  void showCallDialog(BuildContext context, String mobile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Calling', style: TextStyle(color: Colors.black)),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mobile,
                style: TextStyle(color: Colors.black),
              ),
              IconButton(
                onPressed: () async {
                  Clipboard.setData(ClipboardData(text: mobile));
                  DialToast.showToast("Phone Number added to ClipBoard", Colors.green);
                },
                icon: Icon(Icons.copy, color: Colors.grey.shade800),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final Uri url = Uri(scheme: 'tel', path: mobile);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                throw 'Could not launch $mobile';
              }
            },
            child: Text('Call', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
