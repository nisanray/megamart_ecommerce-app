import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:megamart/controllers/auth_controller.dart';
import 'package:megamart/utils/circular_progress_indicator.dart';
import 'package:megamart/utils/colors.dart';
import 'package:megamart/utils/custom_button.dart';
import 'package:megamart/utils/custom_text_form_fields.dart';
import 'package:megamart/views/auth/login_screen.dart';
import 'package:megamart/views/main_screen.dart';
import 'dart:io';
import '../../utils/show_snackbar.dart';

class CustomerRegistrationScreen extends StatefulWidget {
  const CustomerRegistrationScreen({super.key});

  @override
  State<CustomerRegistrationScreen> createState() => _CustomerRegistrationScreenState();
}

class _CustomerRegistrationScreenState extends State<CustomerRegistrationScreen> {
  final AuthController _authController = AuthController();

  final _formkey = GlobalKey<FormState>();

  late String email;
  late String fullName;
  late String phoneNumber;
  late String password;
  bool _isLoading = false;
  bool isPasswordVisible = false;

  double space = 20;

  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  _signUpCustomer() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      _formkey.currentState!.save();
      try {
        // Convert XFile to Uint8List
        Uint8List? imageBytes = _image != null ? await _image!.readAsBytes() : null;
        String res = await _authController.signupCustomer(email, fullName, phoneNumber, password, imageBytes!);
        if (res != 'Success') {
          showSnackBar(context, res, bgColor: Colors.redAccent);
        } else {
          showSnackBar(context, 'Your account created successfully', bgColor: Colors.blueAccent.shade700);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
            return const MainScreen();
          }));
        }
// Rest of your existing logic...
      } catch (e) {
        showSnackBar(context, 'An error occurred: $e', bgColor: Colors.redAccent.withOpacity(0.8));
      }
      setState(() {
        _isLoading = false;
        _formkey.currentState?.reset();
      });
    }
  }

  _togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
        // Optional: Convert XFile to Uint8List
        Uint8List? imageBytes = await pickedFile.readAsBytes();
        // Call your method passing the Uint8List
        // For example:
        // String res = await _authController.signupCustomer(email, fullName, phoneNumber, password, imageBytes);
      }
    } catch (e) {
      showSnackBar(context, "An error occurred while picking the image $e", bgColor: Colors.redAccent.withOpacity(0.8));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: AppColors.backgroundColor.withOpacity(0.08),
            padding: const EdgeInsets.all(10),
            child: Form(
              key: _formkey,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height*0.12,
                        ),
                        const Text("Create customer account", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                        SizedBox(height: space),
                        Stack(
                          children: [
                            const CircleAvatar(
                              radius: 64,
                              backgroundImage: AssetImage('assets/images/pp.jpg',),
                            ),
                            CircleAvatar(
                              radius: 64,
                              backgroundColor: Colors.transparent,
                              backgroundImage: _image !=null ? FileImage(File(_image!.path)):null,
                            ),
                            Positioned(
                                right: 20,
                                top: 15,
                                child: GestureDetector(
                                  onTap:() => _pickImage(ImageSource.gallery), child: const Icon(CupertinoIcons.photo_on_rectangle,color: Colors.white,)))
                          ],
                        ),
                        SizedBox(height: space),
                        _buildTextFormField(
                          controller: TextEditingController(),
                            labelText: "Name", hintText: "Enter your full name.",
                            icon: Icons.text_fields,
                            onChanged: (value) {
                              fullName = value;
                            }, validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },),
                        // CustomTextFormFields(
                        //   onChanged: (value) {
                        //     fullName = value;
                        //   },
                        //   labelText: "Name",
                        //   hintText: "Enter your full name.",
                        //   controller: TextEditingController(),
                        //   maxwidth: 800,
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please enter your full name';
                        //     }
                        //     return null;
                        //   },
                        // ),
                        SizedBox(height: space),
                        _buildTextFormField(
                            controller: TextEditingController(),
                            labelText: "Email", hintText: "Enter your email",
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
                            },),
                        // CustomTextFormFields(
                        //   onChanged: (value) {
                        //     email = value;
                        //   },
                        //   labelText: "Email",
                        //   hintText: "Enter your email",
                        //   controller: TextEditingController(),
                        //   maxwidth: 800,
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please enter your email';
                        //     }
                        //     if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        //       return 'Please enter a valid email.';
                        //     }
                        //     return null;
                        //   },
                        // ),
                        SizedBox(height: space),
                        _buildTextFormField(
                            controller: TextEditingController(),
                            labelText: 'Phone',
                            hintText: 'Enter your phone number',
                            icon: CupertinoIcons.phone_fill,
                            onChanged: (value) {
                              phoneNumber = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your number';
                              }
                              if (!RegExp(r'^\+?[0-9]{11,}$').hasMatch(value)) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },),
                        // CustomTextFormFields(
                        //   onChanged: (value) {
                        //     phoneNumber = value;
                        //   },
                        //   labelText: "Phone",
                        //   hintText: "Enter your phone number",
                        //   controller: TextEditingController(),
                        //   maxwidth: 800,
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please enter your number';
                        //     }
                        //     if (!RegExp(r'^\+?[0-9]{11,}$').hasMatch(value)) {
                        //       return 'Please enter a valid phone number';
                        //     }
                        //     return null;
                        //   },
                        // ),
                        SizedBox(height: space),
                        _buildTextFormField(
                            controller: TextEditingController(),
                            labelText: 'Password',
                            hintText: 'Create a strong password',
                            icon: Icons.lock,
                            suffixIcon: isPasswordVisible
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
                              if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{6,}$').hasMatch(value)) {
                                return 'Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character.';
                              }
                              return null;
                            },),
                        // CustomTextFormFields(
                        //   onChanged: (value) {
                        //     password = value;
                        //   },
                        //   labelText: "Password",
                        //   hintText: "Create a strong password",
                        //   controller: TextEditingController(),
                        //   maxwidth: 800,
                        //   obscureText: false,
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please enter a password';
                        //     }
                        //     if (value.length < 8) {
                        //       return 'Password must be at least 8 characters.';
                        //     }
                        //     if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{6,}$').hasMatch(value)) {
                        //       return 'Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character.';
                        //     }
                        //     return null;
                        //   },
                        // ),
                        SizedBox(height: space),

                        CustomButton(
                          color: AppColors.deepPurple,
                          widthPercentage: .5,
                          padding: 10,
                          buttonText: "Register",
                          textSize: 20,
                          textColor: Colors.white,
                          maxwidth: 400,
                          onTap: () {
                            _signUpCustomer();
                          },
                        ),
                        const SizedBox(height: 50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already have an account?',style: TextStyle(fontSize: 15),),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                                  return const LogInScreen();
                                }));
                              },
                              child: const Text('Login',style: TextStyle(color: Colors.blueAccent,fontSize: 15),),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    const Center(
                      child: Positioned(
                        child: CustomCircularProgressIndicator()
                      ),
                    ),
                ],
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
    IconData? icon,
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
        prefixIcon: icon != null
            ? Icon(icon, color: Colors.deepPurpleAccent.shade700)
            : null, // Conditionally add prefixIcon
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
          borderSide: BorderSide(color: Colors.deepPurpleAccent.shade400, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurpleAccent.shade700, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        labelStyle: TextStyle(color: Colors.deepPurpleAccent.shade700),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }

}
