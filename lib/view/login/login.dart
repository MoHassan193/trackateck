import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_man/main.dart';
import 'package:visit_man/model/utils/images.dart';
import 'package:visit_man/model/utils/move.dart';
import 'package:visit_man/model/utils/sizes.dart';
import 'package:visit_man/model_view/cubits/loginCubit/login_cubit.dart';
import 'package:visit_man/view/login/resetPassword.dart';
import '../../model/dialToast.dart';
import '../visitCard/screens/NavBar.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return BlocProvider(
      create: (context) => LoginCubit(),
      child: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccessState) {
            Move.moveAndReplace(context, NavBar()); // الانتقال بعد النجاح
          } else if (state is LoginErrorState) {
            DialToast.showToast("Something Error",Colors.red);
          }
        },
        child: BlocBuilder<LoginCubit, LoginState>(
          builder: (context, state) {
            var cubit = LoginCubit.get(context);
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Login',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                centerTitle: true,
              ),
              body: Padding(
                padding: EdgeInsets.all(MoSizes.defaultSpace(context)),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: mq.height * 0.01),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Url For System',
                        ),
                        controller: cubit.urlForSystemController,
                      ),
                      SizedBox(height: mq.height * 0.01),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'DataBase Name',
                        ),
                        controller: cubit.databasetype,
                      ),
                      SizedBox(height: mq.height * 0.01),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                        ),
                        controller: cubit.emailController,
                      ),
                      SizedBox(height: mq.height * 0.01),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                        ),
                        controller: cubit.passwordController,
                        obscureText: true,
                      ),
                      SizedBox(height: mq.height * 0.05),
                      state is LoginLoadingState
                          ? CircularProgressIndicator(strokeWidth: 4)
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            cubit.loginFunction(); // استدعاء دالة تسجيل الدخول
                          },
                          child: Text(
                            'Login',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .apply(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: mq.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Switch(
                            value: cubit.keepMeSignedIn,
                            onChanged: (value) {
                              cubit.toggleKeepMeSignedIn(value);
                            },
                          ),
                          SizedBox(width: mq.width * 0.01),
                          Text(
                            'Keep me signed in',
                            style: TextStyle(
                              color: cubit.keepMeSignedIn
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: mq.height * 0.03),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Move.move(context, ResetPassword());
                          },
                          child: Text(
                            'Reset Password',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .apply(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: mq.height * 0.05),
                      Center(
                        child: Image(
                          image: AssetImage(AppImages.WelcomePic),
                          width: mq.width * 0.5,
                          height: mq.height * 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
