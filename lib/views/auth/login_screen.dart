import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:megamart/controllers/auth_controller.dart';
import 'package:megamart/utils/colors.dart';
import 'package:megamart/views/auth/register_screen.dart';
import 'package:megamart/views/main_screen.dart';
import 'package:megamart/utils/show_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

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
        body: Container(
          padding: const EdgeInsets.all(15),
          color: AppColors.backgroundColor.withOpacity(0.08),
          width: MediaQuery.sizeOf(context).width,
          height:  MediaQuery.sizeOf(context).height,
          child: Form(
            key: _formKey,
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo/logo7.png',
                      color: Colors.deepPurpleAccent.shade700,
                      width: 250,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Customer Login.",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    _buildTextFormField(
                      controller: emailController,
                      labelText: "Email",
                      hintText: "Enter your email",
                      icon: Icons.email,
                      onChanged: (value) {
                        email = value;
                      },
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
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: passwordController,
                      labelText: "Password",
                      hintText: "Enter your password",
                      icon: Icons.lock,
                      obscureText: !_isPasswordVisible,
                      suffixIcon: _isPasswordVisible
                          ? CupertinoIcons.eye
                          : CupertinoIcons.eye_slash,
                      suffixIconOnTap: _togglePasswordVisibility,
                      onChanged: (value) {
                        password = value;
                      },
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
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent.shade400,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        textStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isLoading ? null : () {
                        if (_formKey.currentState!.validate()) {
                          _handleCustomerLogin();
                        }
                      },
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white),
                        ),
                      )
                          : const Text('Login', style: TextStyle(color: Colors.white),),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?",style: TextStyle(fontSize: 15),),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CustomerRegistrationScreen()),
                            );
                          },
                          child: const Text('Register',style: TextStyle(color: Colors.blueAccent,fontSize: 15),),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    IconData? suffixIcon,
    VoidCallback? suffixIconOnTap,
    required ValueChanged<String> onChanged,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.deepPurpleAccent.shade700),
        suffixIcon: suffixIcon != null
            ? IconButton(
          icon: Icon(suffixIcon),
          onPressed: suffixIconOnTap,
          color: Colors.deepPurpleAccent.shade700,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurpleAccent.shade400,width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurpleAccent.shade700,width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        labelStyle: TextStyle(color: Colors.deepPurpleAccent.shade700),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }

  void _handleCustomerLogin() async {
    setState(() {
      _isLoading = true;
    });
    String loginResult = await _authController.loginCustomers(
        emailController.text, passwordController.text);

    setState(() {
      _isLoading = false;
    });
    if (loginResult == 'Success') {
      // Save login state
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);

      // Navigate to home or dashboard page after successful login
      debugPrint('Login Successful');
      showSnackBar(context, 'Login Successful.',
          bgColor: Colors.blueAccent.shade700);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ));
      // Navigate to next screen or handle successful login action
    } else {
      debugPrint('Login error : $loginResult');
      showSnackBar(context, "Email or password don't match.",
          bgColor: Colors.redAccent);
    }
  }
}
