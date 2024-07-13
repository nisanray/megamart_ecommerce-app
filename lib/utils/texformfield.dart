import 'package:flutter/material.dart';
import 'shared_styles.dart'; // Import the shared styling function

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  const CustomTextFormField({super.key, 
    required this.controller,
    required this.label,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: TextFormField(
            controller: controller,
            decoration: inputDecoration(label), // Use the shared styling function
            validator: validator,
          ),
        ),
      ],
    );
  }
}
