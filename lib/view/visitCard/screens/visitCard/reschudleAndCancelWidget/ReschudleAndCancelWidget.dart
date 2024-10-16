import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:visit_man/model/utils/move.dart';
import 'package:visit_man/model_view/cubits/cancelCubit/cancel_cubit.dart';
import 'package:visit_man/model_view/cubits/cancelCubit/cancel_state.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/cancelVisitReaonCubit/getcancelVisitCubit.dart';
import 'package:visit_man/model_view/cubits/reschudleCubit/rescudle_cubit.dart';
import 'package:visit_man/model_view/cubits/reschudleCubit/rescudle_state.dart';
import 'package:visit_man/view/visitCard/screens/getTodayVisit/getTodayVisitScreen.dart';

import '../../../../../model_view/cubits/mainCubitofWidget/cancelVisitReaonCubit/getcancelVisitState.dart';

class ReschudleAndCancelWidget extends StatefulWidget {
  const ReschudleAndCancelWidget({super.key, required this.visitId,required this.state});
final String visitId;
final String state;
  @override
  State<ReschudleAndCancelWidget> createState() => _ReschudleAndCancelWidgetState();
}

class _ReschudleAndCancelWidgetState extends State<ReschudleAndCancelWidget> {
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        BlocProvider(
          create: (context) => RescudleCubit(),
          child: BlocBuilder<RescudleCubit, RescudleState>(
            builder: (context, state) {
              var cubit = RescudleCubit.get(context);
              return OutlinedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => StatefulBuilder(
                        builder:(context, setState) =>  AlertDialog(
                          title: Text("Send Reschudle"),
                          content: Column(
                            mainAxisSize:MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: cubit.reschudleReasonController,
                                decoration: InputDecoration(hintText: "Reason"),
                              ),
                              SizedBox(height: 12,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  OutlinedButton(
                                      onPressed: (){},child: Text(
                                      selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!).toString() : "Select Date",
                                      style:TextStyle(color: Colors.blue))),
                                  IconButton(
                                    onPressed: () {

                                      _selectDate(context);
                                      cubit.date = selectedDate;
                                    },
                                    icon: Icon(Icons.date_range_outlined,color: Colors.cyan,size: 30,),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: (){
                              Navigator.pop(context);
                            }, child: Text("No",style: TextStyle(color: Colors.red),)),
                            TextButton(onPressed: (){
                                cubit.sendReschudle(visitId: widget.visitId, visitState: widget.state);
                              Navigator.pop(context);
                            }, child: Text("Yes")),
                          ],
                        ),
                      ),
                  );
                },
                child: Text(
                  "Reschadule", style: TextStyle(color: Colors.blue),),
              );
            },
          ),
        ),
        BlocProvider(
          create: (context) => CancelCubit(),
          child: BlocBuilder<CancelCubit, CancelState>(
            builder: (context, state) {
              var cubit = CancelCubit.get(context);

              return OutlinedButton(
                style: OutlinedButton.styleFrom(backgroundColor: Colors.red.shade800),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder:(context, setState) =>  AlertDialog(
                          title: Text("Cancel Reason"),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                BlocProvider(
                                  create: (context) => VisitCancelReasonCubit()..fetchVisitCancelReasons(),
                                  child: BlocBuilder<VisitCancelReasonCubit, VisitCancelReasonState>(
                                    builder: (context, state) {
                                      if (state is VisitCancelReasonLoading) {
                                        return Center(child: CircularProgressIndicator());
                                      } else if (state is VisitCancelReasonLoaded) {
                                        return Column(
                                          children: [
                                            DropdownButtonFormField<int>(
                                              decoration: InputDecoration(labelText: 'Select Reason'),
                                              value: cubit.selectedId, // استخدام القيمة المخزنة في الـ Cubit
                                              items: state.reasons.map((reason) {
                                                return DropdownMenuItem<int>(
                                                  value: reason['id'],
                                                  child: Text(reason['name']),
                                                );
                                              }).toList(),
                                              onChanged: (int? newValue) {
                                                cubit.changeSelectedId(newValue); // تغيير القيمة في الـ Cubit
                                                if (newValue != null) {
                                                  cubit.cancelReasonController.text = newValue.toString();
                                                  cubit.selectedId = newValue;
                                                }
                                              },
                                            ),
                                          ],
                                        );
                                      } else if (state is VisitCancelReasonError) {
                                        return Center(child: Text(state.message));
                                      }
                                      return Center(child: Text('No Data Available'));
                                    },
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("No", style: TextStyle(color: Colors.red)),
                            ),
                            TextButton(
                              onPressed: () {

                                  cubit.sendCancel(visitId: widget.visitId, visitState: widget.state).then((value) {
                                    Navigator.pop(context);
                                  },);

                              },
                              child: Text("Yes"),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Text("Cancel", style: TextStyle(color: Colors.white)),
              );
            },
          ),
        ),
      ],
    );
  }
}
