import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_man/view/visitCard/widgets/getUsers/cubit/getUsersCubit.dart';
import 'cubit/getUsersState.dart';

class GetUsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Users'),
      ),
      body: BlocBuilder<GetUsersCubit, GetUsersState>(
        builder: (context, state) {
          if (state is GetUsersLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is GetUsersError) {
            return Center(child: Text(state.message));
          } else if (state is GetUsersLoaded) {
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                // Check if the stored username matches the current user
                checkAndStoreUserId(user['name'], user['id']);
                return ListTile(
                  title: Text(user['name']),
                  subtitle: Text('ID: ${user['id']}'),
                );
              },
            );
          }
          return Center(child: Text('لا توجد بيانات'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GetUsersCubit.get(context).fetchUsers();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  Future<void> checkAndStoreUserId(String userName, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserName = prefs.getString('userName');

    // Check if the stored username matches the current user's name
    if (storedUserName != null && storedUserName == userName) {
      // Store the userId if they match
      await prefs.setString('userId', userId);
      print("User ID stored: $userId"); // يمكنك استخدام هذه الطباعة لتأكيد التخزين
    }
  }
}
