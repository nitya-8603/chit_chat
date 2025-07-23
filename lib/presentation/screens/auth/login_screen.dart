import 'package:chit_chat/core/common/custom_button.dart';
import 'package:chit_chat/core/common/custom_text_field.dart';
import 'package:chit_chat/core/common/utils/ui_utils.dart';
import 'package:chit_chat/data/services/service_locator.dart';
import 'package:chit_chat/logic/cubits/auth/auth_cubit.dart';
import 'package:chit_chat/logic/cubits/auth/auth_state.dart';
import 'package:chit_chat/presentation/home/home_screen.dart';
import 'package:chit_chat/presentation/screens/auth/signup_screen.dart';
import 'package:chit_chat/router/app_router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _emailfocusnode = FocusNode();
  final _passwordfocusnode = FocusNode();
  bool _passwordVisible = false;

  String? _validateemail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email!';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address!';
    }
    return null;
  }

  String? _validatepassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < 6) {
      return "Password must be atleast 6 characters long!!";
    }

    return null;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    _emailfocusnode.dispose();
    _passwordfocusnode.dispose();
  }

  Future<void> handleLogin() async {
    FocusScope.of(context).unfocus();
    if (_formkey.currentState?.validate() ?? false) {
      try {
        getIt<AuthCubit>().signIn(
          email: emailController.text,
          password: passwordController.text,
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } else {
      print('form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      bloc: getIt<AuthCubit>(),
      listenWhen: (previous, current) {
        return previous.status != current.status ||
            previous.error != current.error;
      },
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated)
          getIt<AppRouter>().pushAndRemoveUntil(HomeScreen());
        else if (state.status == state.error)
          UiUtils.showSnackBar(context, message: state.error!);
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
                    Text(
                      'Welcome Back!!',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Sign In to continue',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    ),
                    SizedBox(height: 30),

                    CustomTextField(
                      controller: emailController,
                      hintText: "Enter your Email",
                      focusNode: _emailfocusnode,
                      validator: _validateemail,
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: passwordController,
                      hintText: "Enter your Password",
                      obscureText: !_passwordVisible,
                      validator: _validatepassword,
                      focusNode: _passwordfocusnode,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                        icon: _passwordVisible
                            ? Icon(Icons.visibility)
                            : Icon(Icons.visibility_off),
                      ),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    SizedBox(height: 30),
                    CustomButton(
                      onPressed: handleLogin,
                      child: state.status == AuthStatus.loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Login',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'Dont have an account? ',
                          style: TextStyle(color: Colors.grey[600]),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignupScreen(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
