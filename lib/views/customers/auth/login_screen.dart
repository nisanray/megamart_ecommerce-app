import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:megamart/controllers/auth_controller.dart';
import 'package:megamart/utils/colors.dart';
import 'package:megamart/utils/custom_button.dart';
import 'package:megamart/utils/custom_text_form_fields.dart';
import 'package:megamart/views/customers/auth/register_screen.dart';
import 'package:megamart/views/customers/main_screen.dart';
import 'package:megamart/views/customers/nav_screens/home_screen.dart';
import 'package:megamart/utils/show_snackbar.dart';

import '../../../utils/circular_progress_indicator.dart';

class LogInScreen extends StatefulWidget {
  LogInScreen({Key? key}) : super(key: key);

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();

  late String email;
  late String password;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Form(
              key: _formKey,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/logo/logo7.png',
                          color: Colors.deepPurpleAccent.shade700,
                          width: 250,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Customer Login.",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 30),
                        CustomTextFormField(
                          onChanged: (value) {
                            email = value;
                          },
                          labelText: "Email",
                          hintText: 'Enter your email.',
                          controller: emailController,
                          maxwidth: 700,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Please enter a valid email.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        CustomTextFormField(
                          onChanged: (value) {
                            password = value;
                          },
                          suffixIcon: _isPasswordVisible ? CupertinoIcons.eye :CupertinoIcons.eye_slash ,
                          suffixIconOnTap: _togglePasswordVisibility,
                          obscureText: !_isPasswordVisible,
                          labelText: "Password",
                          hintText: "Enter your password.",
                          controller: passwordController,
                          maxwidth: 700,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        CustomButton(
                          color: AppColors.buttonColor,
                          widthPercentage: 0.5,
                          padding: 8,
                          buttonText: 'Login',
                          textSize: 20,
                          textColor: AppColors.white,
                          maxwidth: 400,
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              _handleCustomerLogin();
                            }
                          },
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account?"),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => CustomerRegistrationScreen()),
                                );
                              },
                              child: Text('Register'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    Center(
                      child: Positioned(
                          child: CustomCircularProgressIndicator()
                      ),
                    ),
                ],
              )
            ),
          ),
        ),
      ),
    );
  }

  void _handleCustomerLogin() async {
    setState(() {
      _isLoading = true;
    });
    String loginResult = await _authController.loginCustomers(emailController.text, passwordController.text);

    setState(() {
      _isLoading = false;
    });
    if (loginResult == 'Success') {
      // Navigate to home or dashboard page after successful login
      debugPrint('Login Successful');
      showSnackBar(context, 'Login Successful.', bgColor: Colors.blueAccent.shade700);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen(),));
      // Navigate to next screen or handle successful login action
    } else {
      debugPrint('Login error : $loginResult');
      showSnackBar(context, "Email or password don't match.", bgColor: Colors.redAccent);
    }
  }
}
