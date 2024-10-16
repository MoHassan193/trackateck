import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../model_view/cubits/mainCubitofWidget/leaveBehindCubit/leaveBehindCubit.dart';
import '../../../../model_view/cubits/mainCubitofWidget/leaveBehindCubit/leaveBehindState.dart';

class LeaveBehindWidget extends StatelessWidget {
  final int IdLeaveBehind; // Receive the ID from the second page

  const LeaveBehindWidget({Key? key, required this.IdLeaveBehind}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LeaveBehindCubit()..fetchLeaveBehinds(),
      child: BlocBuilder<LeaveBehindCubit, LeaveBehindState>(
        builder: (context, state) {
          if (state is LeaveBehindLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is LeaveBehindLoaded) {
            // Filter leave-behinds to show only the one matching IdLeaveBehind
            final filteredLeaveBehinds = state.leaveBehinds
                .where((leaveBehind) => leaveBehind.id == IdLeaveBehind)
                .toList();

            // Save all leave behind IDs to SharedPreferences
            saveLeaveBehindIds(state.leaveBehinds);

            if (filteredLeaveBehinds.isEmpty) {
              return Center(child: Text('No matching leave-behind found.'));
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: filteredLeaveBehinds.length,
              itemBuilder: (context, index) {
                final leaveBehind = filteredLeaveBehinds[index];
                return ListTile(
                  title: Text(leaveBehind.name),
                  subtitle: Text('Leave-Behind ID: ${leaveBehind.id}'),
                  leading: Icon(Icons.folder),
                );
              },
            );
          } else if (state is LeaveBehindError) {
            return Center(child: Text('No Data Found'));
          }
          return Center(child: Text('No Data'));
        },
      ),
    );
  }

  // Function to save leave behind IDs to SharedPreferences
  Future<void> saveLeaveBehindIds(List leaveBehinds) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> leaveBehindIds = leaveBehinds.map((leaveBehind) => leaveBehind.id.toString()).toList();
    await prefs.setStringList('leaveBehindIds', leaveBehindIds);
  }
}
