// class Ex extends StatelessWidget {
//   const Ex ({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return       Scaffold(
//       appBar:AppBar(
//         leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back,color: Colors.white,size: 25,)),
//         actions: [
//           IconButton(
//             onPressed: () => Move.move(context,TerritoryWidget()),
//             icon: Icon(Icons.menu,color: Colors.white,size: 30,
//             ),
//           ),
//           SizedBox(height:MoSizes.sm(context)),
//           IconButton(
//             onPressed: () => Move.move(context,MyInfoPage()),
//             icon: Icon(Icons.person,color: Colors.white,size: 30,
//             ),
//           ),
//           SizedBox(height:MoSizes.sm(context)),
//         ],
//       ),
//       body:
//
//       SingleChildScrollView(
//         child: Padding(
//           padding:
//           EdgeInsets.all(MoSizes.defaultSpace(context) / 1.5),
//           child:SafeArea(
//             child: BlocProvider(
//               create: (context) => PartnerInfoCubit()..fetchPartnerInfo(widget.partnerid.toString(),), // تأكد من تمرير الـ ID
//               child: BlocBuilder<PartnerInfoCubit, PartnerInfoState>(
//                 builder: (context, state) {
//                   if (state is PartnerInfoLoading) {
//                     return Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         const Center(child: CircularProgressIndicator()),
//                         SizedBox(height: height * 0.02),
//                         Container(
//                             padding: EdgeInsets.all(8),
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               color: Colors.blue,
//                               borderRadius: BorderRadius.circular(20),
//                               border: Border.all(color: Colors.white),
//                             ),
//                             child: Text('please , wait ...\n fetching partner are loading', style: TextStyle(color: Colors.white),textAlign: TextAlign.center,)),
//                       ],
//                     );
//                   } else if (state is PartnerInfoLoadedRaw) {
//                     // عرض بيانات الشريك بناءً على الـ ID
//                     final partnerMap = {for (var partner in state.partnerData) partner['id']: partner};
//                     final partnerData = partnerMap[widget.partnerid];
//                     if (partnerData == null) {
//                       return const Center(child: Text('No partner found.'));
//                     }
//                     return Column(
//                       children: [
//
//                         BuildButtonWidget(
//                           icon: Icons.note_add_outlined,
//                           text: 'Questions',
//                           answer: 'Answer',
//                           widget: SurveyWidget(IdSurvey: partnerData['survey'] ?? 0),
//                           context: context,
//                         ),
//                         SizedBox(height: height * 0.02),
//                         BuildButtonWidget(
//                           icon: Icons.local_activity,
//                           text: 'Users',
//                           answer: 'Show',
//                           widget: GetUsersPage(),
//                           context: context,
//                         ),
//                         SizedBox(height: height * 0.02),
//                         BuildButtonWidget(
//                           icon: Icons.cancel,
//                           text: 'Cancel',
//                           answer: 'Cancel',
//                           widget: VisitCancelReasonWidget(),
//                           context: context,
//                         ),
//                         SizedBox(height: height * 0.02),
//                         BuildButtonWidget(
//                           icon: Icons.data_object_sharp,
//                           text: 'Objective',
//                           answer: 'Accept',
//                           widget: VisitObjectivePage(),
//                           context: context,
//                         ),
//                         SizedBox(height: height * 0.1),
//                       ],
//                     );
//                   } else if (state is PartnerInfoError) {
//                     return Center(child: Text(state.message));
//                   } else {
//                     return const Center(child: Text('No data available.'));
//                   }
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
