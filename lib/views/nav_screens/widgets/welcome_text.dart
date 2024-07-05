import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 5,left: 15,right: 15,top: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Howdy , What are you\n looking for 👀',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),

            ),
            Container(
              child: SvgPicture.asset("assets/icons/cart.svg"),
            ),
          ],
        ),
      );;
  }
}
