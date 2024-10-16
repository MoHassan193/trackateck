import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:visit_man/model/utils/move.dart';
import 'package:visit_man/view/visitCard/%20models/partnerModel.dart';

import '../../../../../model/utils/sizes.dart';

class AllPartnerInfo{
  static void showPartnerInfo(BuildContext context,List<PartnerInfo> partnerinfo) {
    showDialog(
        context: context,
        builder: (context) => Scaffold(
          body: ListView.separated(
            separatorBuilder: (context, index) => SizedBox(height: MoSizes.xs(context) / 2,),
            itemCount: 6,
            itemBuilder: (context, index) => PartnerMember(
                widget: partnerinfo[index].widget,
                trailing: partnerinfo[index].trailingIcon,
                leading: partnerinfo[index].leadingIcon,
                title: partnerinfo[index].title
            ),
          ),
        ),
    );
  }

}

class PartnerMember extends StatelessWidget {
  const PartnerMember({
    super.key, required this.widget, required this.trailing, required this.leading, required this.title,
  });

final Widget widget;
final IconData trailing;
final IconData leading;
final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MoSizes.md(context) / 2),
      child: Container(
        padding: EdgeInsets.all(MoSizes.md(context) / 4),
        height: MediaQuery.of(context).size.height * 0.1,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white),
        ),
        child: Center(
          child: ListTile(
            onTap: () => showModalBottomSheet(
              builder: (context) => widget, context: context,
            ),
            leading: Icon(
              leading,size: 25,color: Colors.grey.shade800,
            ),
            title: Text(
              title,
              style: TextStyle(color: Colors.black,fontSize: 15),
            ),
            subtitle: Text(
              "Tab To Show",
              style: TextStyle(color: Colors.grey.shade600,fontSize: 12),
            ),
            trailing: Icon(
              Icons.open_in_new,size: 20,color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}