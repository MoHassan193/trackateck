import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/model/commonWidget/networkImageCustom/networkImageCustom.dart';
import 'package:visit_man/view/visitCard/%20models/partnerModel.dart';
import 'package:visit_man/view/visitCard/screens/visitCard/itemsOfVisitCard/editPartnerForVisit.dart';
import '../../../../model/utils/sizes.dart';
import '../../screens/visitCard/itemsOfVisitCard/AllPartnerInfo.dart';
import '../getActivityType/getActivityType.dart';
import '../getClassificationPage/getClassificationPage.dart';
import '../getProduct/getProduct.dart';
import '../getSegmantation/getSegmantaion.dart';
import '../getSurveyPage/getSurveyPage.dart';
import '../leaveBehindPage/leaveBehindPage.dart';
import '../../../../model/utils/move.dart';



class PartnerDetailPage extends StatefulWidget {
  const PartnerDetailPage({Key? key, this.visitDetails}) : super(key: key);
  final Map<String,dynamic>? visitDetails;
  @override
  State<PartnerDetailPage> createState() => _PartnerDetailPageState();
}

class _PartnerDetailPageState extends State<PartnerDetailPage> {

  @override
  void initState() {
    super.initState();
    _savePartnerCoordinates(widget.visitDetails!['partner_latitude'], widget.visitDetails!['partner_longitude']);
  }

  Future<void> _savePartnerCoordinates(double latitude, double longitude) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('partner_latitude', latitude);
    await prefs.setDouble('partner_longitude', longitude);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.visitDetails!['partner_id'] ?? 'No Name'),
        centerTitle: true,
        // actions : [
        //   IconButton(
        //     icon:Icon(Icons.edit),
        //     onPressed:(){
        //       Move.move(context,EditPartnerForVisit(
        //         partnerId: widget.visitDetails!['partner_rec_id'],
        //           longitude:widget.visitDetails!['partner_longitude '],
        //           latitude: widget.visitDetails!['partner_latitude'],
        //           partnerData:widget.visitDetails!,
        //       ));
        //     }
        //   )
        // ]
      ),
      body: Padding(
        padding: EdgeInsets.all(MoSizes.defaultSpace(context) / 2),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              NetworkImageCustom(
                imageUrl: widget.visitDetails!['partner_image'],
                size: 35,
              ),
              SizedBox(height: MoSizes.spaceBtwItems(context) / 2),
              _buildDetailRow('Name', widget.visitDetails!['partner_id'] ?? 'No Name'),
              widget.visitDetails!['client_type'] == 'doctor'
                  ? _buildDetailRow('Client Type', widget.visitDetails!['client_type'] ?? 'No Client Type')
                  : SizedBox(height: 1),
              // _buildDetailRow(
              //   'Email',
              //   "${widget.partnerData!['email']}",
              // ),
              _buildDetailRow(
                'Specialites',
                "${widget.visitDetails!['speciality_name']}",
              ),
              _buildDetailRow(
                'Survey',
                "${widget.visitDetails!['survey_name']}",
              ),
              _buildDetailRow( " Segmant ",
              "${widget.visitDetails!['segment_name']}"
              ),
              // _buildDetailRow(
              //   'City',
              //   (widget.partnerData!['city'] is String)
              //       ? widget.partnerData!['city']
              //       : 'No City',
              // ),
              // _buildDetailRow(
              //   'Country',
              //   (widget.partnerData!['country_id'] is String)
              //       ? widget.partnerData!['country_id']
              //       : 'No Country',
              // ),
              _buildDetailRow(
                'Territory',
                (widget.visitDetails!['territory_id'] is String)
                    ? widget.visitDetails!['territory_id']
                    : 'No Territory',
              ),
              _buildDetailRow(
                'Client Attitude',
                (widget.visitDetails!['client_attitude'] is String)
                    ? widget.visitDetails!['client_attitude']
                    : 'No Attitude',
              ),
              _buildDetailRow(
                'Classification',
                (widget.visitDetails!['classification_name'] is String)
                    ? widget.visitDetails!['classification_name']
                    : 'No ',
              ),
              // _buildDetailRow(
              //   'Work Volume',
              //   (widget.partnerData!['target_visit'] is int)
              //       ? widget.partnerData!['target_visit'].toString()
              //       : 'No',
              // ),
              _buildDetailRow(
                'Behavior Style',
                (widget.visitDetails!['behave_style_name'] is String)
                    ? widget.visitDetails!['behave_style_name']
                    : 'No ',
              ),
              _buildDetailRow(
                'Check Location',
                widget.visitDetails!['check_location'].toString(),
              ),
              // _buildDetailRow(
              //   'Number of Patient',
              //   (widget.partnerData!['no_potential'] is int)
              //       ? widget.partnerData!['no_potential'].toString()
              //       : 'No Patient',
              // ),
              // _buildDetailRow(
              //   'State',
              //   getStateText(),
              // ),
              SizedBox(height: MoSizes.spaceBtwItems(context) / 2),
              // Text(
              //   'Product Tags:',
              //   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // ),
              // ...((widget.partnerData!['product_tags'] ?? []) as List)
              //     .map((tag) => Padding(
              //   padding: const EdgeInsets.only(top: 4.0),
              //   child: Text('- ${tag['name']}'),
              // )),
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
                    _buildLocationRow('Longitude', widget.visitDetails!['partner_longitude']?.toString() ?? 'No Longitude'),
                    const SizedBox(height: 10),
                    _buildLocationRow('Latitude', widget.visitDetails!['partner_latitude']?.toString() ?? 'No Latitude'),
                  ],
                ),
              ),
              SizedBox(height: MoSizes.spaceBtwItems(context) / 2),
              // Padding(
              //   padding: EdgeInsets.all(MoSizes.spaceBtwItems(context) / 1.5),
              //   child: SizedBox(
              //     width: double.infinity,
              //     child: OutlinedButton(
              //       onPressed: () => AllPartnerInfo.showPartnerInfo(context, partnerInfoList),
              //       child: const Text(
              //         " Other Details ",
              //         style: TextStyle(color: Colors.black),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow(String label, String value) {
    return Row(
      children: [
        Icon(Icons.location_on, color: Colors.teal),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.teal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: MoSizes.spaceBtwItems(context) / 2),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white, // لون الخلفية
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.cyan, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  String getStateText() {
    if (widget.visitDetails!['state'] == null || widget.visitDetails!['state'] == false) {
      return 'No State';
    } else if (widget.visitDetails!['state'] == 'done') {
      return 'Completed';
    } else if (widget.visitDetails!['state'] == 'draft') {
      return 'Planned';
    } else {
      return 'Unknown State'; // للتأكد من التعامل مع أي حالة غير متوقعة
    }
  }

}
