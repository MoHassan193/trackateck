import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/fin_view/partnerwidget/partnerInfo.dart';
import 'package:visit_man/fin_view/partnerwidget/partnerVisits.dart';
import 'package:visit_man/view/visitCard/%20models/partnerModel.dart';
import 'package:visit_man/view/visitCard/widgets/getActivityType/getActivityType.dart';
import '../../../../model/utils/sizes.dart';
import '../../model/commonWidget/networkImageCustom/networkImageCustom.dart';
import '../../model/utils/move.dart';
import '../../view/visitCard/screens/visitCard/itemsOfVisitCard/AllPartnerInfo.dart';
import '../../view/visitCard/widgets/getClassificationPage/getClassificationPage.dart';
import '../../view/visitCard/widgets/getProduct/getProduct.dart';
import '../../view/visitCard/widgets/getSegmantation/getSegmantaion.dart';
import '../../view/visitCard/widgets/getSpeciality/getSpecialityPage.dart';
import '../../view/visitCard/widgets/getSurveyPage/getSurveyPage.dart';
import '../../view/visitCard/widgets/leaveBehindPage/leaveBehindPage.dart';
import '../partnerSubWidgets/editPartner.dart';

class FnPartnerDetails extends StatefulWidget {
  const FnPartnerDetails({Key? key, required this.partnerData}) : super(key: key);
  final Map<String, dynamic>? partnerData; // Make it nullable to handle null cases

  @override
  State<FnPartnerDetails> createState() => _FnPartnerDetailsState();
}

class _FnPartnerDetailsState extends State<FnPartnerDetails> {
  late List<PartnerInfo> partnerInfoList;

  @override
  void initState() {
    super.initState();
    if (widget.partnerData == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    } else {
      partnerInfoList = [
        PartnerInfo(
          widget: GetActivityTypeWidget(
            IdActivity: widget.partnerData!['activity_type'] == false
                ? 0
                : int.tryParse(widget.partnerData!['activity_type'].toString()) ?? 0,
          ),
          leadingIcon: Icons.local_activity_outlined,
          trailingIcon: Icons.arrow_forward,
          title: 'Activity Type',
        ),
        PartnerInfo(
          widget: GetClassificationWidget(
            IdClassification: int.tryParse(widget.partnerData!['classification'].toString()) ?? 0,
          ),
          leadingIcon: Icons.class_outlined,
          trailingIcon: Icons.arrow_forward,
          title: 'Classification',
        ),
        PartnerInfo(
          widget: ProductWidget(),
          leadingIcon: Icons.production_quantity_limits,
          trailingIcon: Icons.arrow_forward,
          title: 'Product',
        ),
        PartnerInfo(
          widget: SegmentationWidget(
            IdSegmentation: int.tryParse(widget.partnerData!['segmentation'].toString()) ?? 0,
          ),
          leadingIcon: Icons.segment,
          trailingIcon: Icons.arrow_forward,
          title: 'Segmentation',
        ),
        PartnerInfo(
          widget: SurveyWidget(
            IdSurvey: int.tryParse(widget.partnerData!['survey'].toString()) ?? 0,
          ),
          leadingIcon: Icons.surround_sound,
          trailingIcon: Icons.arrow_forward,
          title: 'Survey',
        ),
        PartnerInfo(
          widget: LeaveBehindWidget(
            IdLeaveBehind: int.tryParse(widget.partnerData!['leave_behind'].toString()) ?? 0,
          ),
          leadingIcon: Icons.backpack,
          trailingIcon: Icons.arrow_forward,
          title: 'Leave Behind',
        ),
      ];

      if (widget.partnerData!['latitude'] != null && widget.partnerData!['longitude'] != null) {
        double partnerLatitude = widget.partnerData!['latitude'];
        double partnerLongitude = widget.partnerData!['longitude'];
        _savePartnerCoordinates(partnerLatitude, partnerLongitude);
      }
    }
  }

  Future<void> _savePartnerCoordinates(double latitude, double longitude) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('partner_latitude', latitude);
    await prefs.setDouble('partner_longitude', longitude);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.partnerData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('No Data'),
        ),
        body: Center(child: Text('No partner data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.partnerData!['name'] ?? 'No Name',style: TextStyle(color: Colors.white,fontSize: 20),),
        centerTitle: true,
        actions: [
        IconButton(
          onPressed: () => Move.move(context,EditPartnerPlan(
            partnerData: widget.partnerData!,
            latitude: widget.partnerData!['latitude'] ?? 0,
            longitude: widget.partnerData!['longitude'] ?? 0,
            partnerId: widget.partnerData!['id'],)),
          icon: Icon(Icons.edit,color: Colors.white,size: 30,),
        ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(MoSizes.defaultSpace(context) / 2),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              NetworkImageCustom(
                imageUrl: widget.partnerData!['image'] ?? '',
                size: 35,
              ),
              SizedBox(height: MoSizes.spaceBtwItems(context) / 2),
              _buildInfoCard('Name', widget.partnerData!['name'] ?? 'No Name', context),
              widget.partnerData!['client_type'] == 'doctor'
                  ? _buildInfoCard('Client Type', widget.partnerData!['client_type'] ?? 'No Client Type', context)
                  : SizedBox(height: 1),
              SizedBox(height: MoSizes.spaceBtwItems(context) / 2),
              _buildInfoCard(
                'City',
                (widget.partnerData!['city'] is String)
                    ? widget.partnerData!['city']
                    : 'No City',
                context,
              ),
              _buildInfoCard(
                'Country',
                (widget.partnerData!['country_id'] is String)
                    ? widget.partnerData!['country_id']
                    : 'No Country',
                context,
              ),
              _buildInfoCard(
                'Territory',
                (widget.partnerData!['territory_id'] is String)
                    ? widget.partnerData!['territory_id']
                    : 'No Territory',
                context,
              ),
              _buildInfoCard(
                'Client Attitude',
                (widget.partnerData!['client_attitude'] is String)
                    ? widget.partnerData!['client_attitude']
                    : 'No Attitude',
                context,
              ),
              SizedBox(height: MoSizes.spaceBtwItems(context) / 2),
              Text(
                'Product Tags:',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...((widget.partnerData!['product_tags'] ?? []) as List)
                  .map((tag) => TitleWidget('- ${tag['name']}',context)),
              SizedBox(height: MoSizes.spaceBtwItems(context) / 3),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard('Longitude', widget.partnerData!['longitude']?.toString() ?? 'No Longitude', context),
                    _buildInfoCard('Latitude', widget.partnerData!['latitude']?.toString() ?? 'No Latitude', context),
                  ],
                ),
              ),
              SizedBox(height: MoSizes.spaceBtwItems(context) / 3),
              // Padding(
              //   padding: EdgeInsets.all(MoSizes.spaceBtwItems(context)),
              //   child: SizedBox(
              //     width: double.infinity,
              //     child: ElevatedButton(
              //       onPressed: () => PartnerInfoDetails.showPartnerInfo(context, partnerInfoList),
              //       child: const Text(
              //         " Other Details ",
              //         style: TextStyle(color: Colors.black),
              //       ),
              //     ),
              //   ),
              // ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                    onPressed: (){
                      Move.move(context, PartnerVisitsScreen(
                        partnerId: widget.partnerData!['id'].toString(),
                      ));
                    },
                    child: Text("Partner Visits")
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.002,
        horizontal: screenWidth * 0.05,
      ),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.cyan, width: 2),
        ),
        height: screenHeight * 0.08,
        width: screenWidth * 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              textAlign: TextAlign.start,
              title,
              style: TextStyle(
                color: Colors.cyan,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              textAlign: TextAlign.end,
              value,
              style: TextStyle(
                color: Colors.black54,
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget TitleWidget(String title, BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.002,
        horizontal: screenWidth * 0.05,
      ),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.cyan, width: 2),
        ),
        height: screenHeight * 0.08,
        width: screenWidth * 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              textAlign: TextAlign.center,
              title,
              style: TextStyle(
                color: Colors.cyan,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
