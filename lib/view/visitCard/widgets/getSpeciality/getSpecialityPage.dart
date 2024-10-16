import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../model/userModel/specialityModel.dart';
import '../../../../model_view/cubits/mainCubitofWidget/getSpecialityCubit/getSpecialityCubit.dart';
import '../../../../model_view/cubits/mainCubitofWidget/getSpecialityCubit/getSpecialityState.dart';

class SpecialitiesWidget extends StatelessWidget {
  final int? specialityId; // تحويل specialityId إلى int بدلاً من String

  const SpecialitiesWidget({super.key, this.specialityId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SpecialitiesCubit()..fetchSpecialities(),
      child: BlocBuilder<SpecialitiesCubit, SpecialitiesState>(
        builder: (context, state) {
          if (state is SpecialitiesLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is SpecialitiesLoaded) {
            // تحقق مما إذا كان specialityId موجودًا في القائمة
            final speciality = state.specialities.firstWhere(
                  (speciality) => speciality.id == specialityId,
              orElse: () => SpecialityModel(id: 0, name: 'No data available'), // قيمة بديلة إذا لم يتم العثور على التخصص
            );

            if (speciality.id > 0) {
              return ListTile(
                title: Text("Speciality Name: ${speciality.name}", style: Theme.of(context).textTheme.bodyLarge),
                subtitle: Text('Speciality ID: ${speciality.id}', style: Theme.of(context).textTheme.bodySmall),
                leading: Icon(Icons.medical_services),
                trailing: Icon(Icons.arrow_forward),
              );
            } else {
              return Center(child: Text('No data available')); // إذا لم يكن هناك تخصص مطابق
            }
          } else if (state is SpecialitiesError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text('No data available'));
        },
      ),
    );
  }
}
