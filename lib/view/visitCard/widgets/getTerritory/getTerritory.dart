import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../model_view/cubits/mainCubitofWidget/getTerritoryCubit/getTerritoryCubit.dart';
import '../../../../model_view/cubits/mainCubitofWidget/getTerritoryCubit/getTerritoryState.dart';


class TerritoryWidget extends StatelessWidget {
  const TerritoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => TerritoryCubit()..fetchTerritories(),
        child: BlocBuilder<TerritoryCubit, TerritoryState>(
          builder: (context, state) {
            if (state is TerritoryLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is TerritoryLoaded) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: state.territories.length,
                itemBuilder: (context, index) {
                  final territory = state.territories[index];
                  return ListTile(
                    title: Text(territory.name),
                    leading: Icon(Icons.location_city),
                  );
                },
              );
            } else if (state is TerritoryError) {
              return Center(child: Text('خطأ: ${state.message}'));
            }
            return Center(child: Text('لا توجد بيانات'));
          },
        ),
      ),
    );
  }
}
