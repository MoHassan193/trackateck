import 'package:flutter/material.dart';
import 'package:visit_man/model/commonWidget/networkImageCustom/networkImageCustom.dart';
import 'package:visit_man/model/utils/sizes.dart';

import '../../../../../model/userModel/partnerInfoModel.dart';


class PartnerInfoCard extends StatelessWidget {
  const PartnerInfoCard({super.key, required this.partner});
  final PartnerInfoModel partner;


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding:  EdgeInsets.all(MoSizes.spaceBtwItems(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                NetworkImageCustom(
                  imageUrl: partner.image,
                  size: 30,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partner.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        partner.clientType,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        partner.speciality,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: Colors.grey),
            _buildDetailRow('City', partner.city),
            _buildDetailRow('Country', partner.countryId),
            _buildDetailRow('Territory', partner.territoryId),
            _buildDetailRow('Client Attitude', partner.clientAttitude.toString()),
            const SizedBox(height: 10),
            Text(
              'Product Tags:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...partner.productTags.map(
                  (tag) => Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('- ${tag.name}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            value ?? 'N/A',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
