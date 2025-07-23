import 'dart:developer';

import 'package:chit_chat/core/common/custom_button.dart';
import 'package:chit_chat/core/common/custom_text_field.dart';
import 'package:chit_chat/data/repositories/auth_repository.dart';
import 'package:chit_chat/data/services/service_locator.dart';
import 'package:chit_chat/logic/cubits/auth/auth_cubit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formkey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  final _nameFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _emailFocus = FocusNode();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    nameController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _phoneFocus.dispose();
    _usernameFocus.dispose();
    _nameFocus.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name!';
    } else
      return null;
  }

  String? _validatephone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name!';
    }
    if (value.length < 10) {
      return "Enter ur phone number correctly";
    }
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateusername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    } else
      return null;
  }

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

  Future<void> handleSignUp() async {
    FocusScope.of(context).unfocus();
    if (_formkey.currentState?.validate() ?? false) {
      try {
        getIt<AuthCubit>().signUp(
          fullname: nameController.text,
          username: usernameController.text,
          email: emailController.text,
          phoneNumber: phoneController.text,
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          //its empty because we used navigator.push() in loginScreen(for sign Up text)
          // this push operation adds pages in stack so here in empty app bar
          //automatically back button shows up to visit the last page
        ),
        body: Form(
          key: _formkey,

          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Please Fill in the details to continue',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: nameController,
                  hintText: 'Enter your Fullname',
                  focusNode: _nameFocus,
                  validator: _validateName,
                  prefixIcon: Icon(Icons.person_2_outlined),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: usernameController,
                  focusNode: _usernameFocus,
                  validator: _validateusername,
                  hintText: 'Enter your Username',
                  prefixIcon: Icon(Icons.verified_user_rounded),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: emailController,
                  focusNode: _emailFocus,
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'Enter your Email',
                  validator: _validateemail,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: phoneController,
                  focusNode: _phoneFocus,
                  validator: _validatephone,
                  hintText: 'Enter your Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: passwordController,
                  focusNode: _passwordFocus,
                  validator: _validatepassword,
                  hintText: 'Enter your Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                CustomButton(onPressed: handleSignUp, text: 'Sign Up'),
                const SizedBox(height: 10),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(color: Colors.grey[600]),
                      children: [
                        TextSpan(
                          text: 'Login',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                          recognizer: TapGestureRecognizer(),
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
  }
}
