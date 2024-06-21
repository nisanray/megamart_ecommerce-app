import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:megamart/views/customers/nav_screens/widgets/banner_widget.dart';
import 'package:megamart/views/customers/nav_screens/widgets/category_text.dart';
import 'package:megamart/views/customers/nav_screens/widgets/search_input_widget.dart';
import 'package:megamart/views/customers/nav_screens/widgets/welcome_text.dart';
import '/utils/custom_textfields.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // WelcomeText(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 20),
          child: SearchInputWidget(),
        ),
        BannerWidget(),
        CategoryText()

      ],
    );
  }

  }

