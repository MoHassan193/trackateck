import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_man/model/userModel/behaviorStyleModel.dart';
import 'package:visit_man/model_view/cubits/mainCubitofWidget/behaviorStyleCubit/behaviorStyleCubit.dart';
import '../../../../model_view/cubits/mainCubitofWidget/behaviorStyleCubit/behaviorStyleState.dart';


class BehavioralStylesPage extends StatelessWidget {
  const BehavioralStylesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BehavioralStylesCubit()..fetchBehavioralStyles(),
      child: BlocBuilder<BehavioralStylesCubit, BehavioralStylesState>(
        builder: (context, state) {
          if (state is BehavioralStylesLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is BehavioralStylesLoaded) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                itemCount: state.styles.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300]),
                itemBuilder: (context, index) {
                  final style = state.styles[index];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    tileColor: Colors.grey[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    title: Text(
                      "Style Name: ${style.name}",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black87),
                    ),
                    subtitle: Text(
                      'Style ID: ${style.id}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    leading: Icon(Icons.style, color: Colors.blue),
                    onTap: () => _showStyleDetails(context, style),
                  );
                },
              ),
            );
          } else if (state is BehavioralStylesError) {
            return Center(child: Text(state.message, style: TextStyle(color: Colors.red)));
          }
          return Center(child: Text('No data available', style: TextStyle(color: Colors.grey)));
        },
      ),
    );
  }

  void _showStyleDetails(BuildContext context, BehavioralStyleModel style) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Behavior Style Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Name: ${style.name}'),
            Text('ID: ${style.id}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
