import 'package:flutter/material.dart';

import '../../../constants.dart';

class CompaniesMenu extends StatelessWidget {
  const CompaniesMenu({
    Key? key,
    required this.text,
    required this.imageUrl, // Replace 'icon' with 'imageUrl'
    this.press,
  }) : super(key: key);

  final String text, imageUrl; // Replace 'icon' with 'imageUrl'
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: kPrimaryColor,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: const Color(0xFFF5F6F9),
        ),
        onPressed: press,
        child: Row(
          children: [
            Image.network(
              imageUrl, // Use 'imageUrl' here
              width: 50,
            ),
            const SizedBox(width: 20),
            Expanded(child: Text(text)),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}
