import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:megamart/views/customers/nav_screens/widgets/banner_widget.dart';
import 'package:megamart/views/customers/nav_screens/widgets/category_text.dart';
import 'package:megamart/views/customers/nav_screens/widgets/search_input_widget.dart';
import 'package:megamart/views/customers/nav_screens/widgets/welcome_text.dart';
import '/utils/custom_text_form_fields.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const routeName = '/home';

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
        CategoryText(),
        Container(
          height: 100,
          width: 100,
          color: Colors.blueAccent.shade700,
          child: Center(child: Text("dshfsfhsfhdsjfn",style: TextStyle(color: Colors.white),)),
        )

      ],
    );
  }

  }

