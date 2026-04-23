// lib/common_widget/secondary_button.dart
import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class SecondaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const SecondaryButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: TColor.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: TColor.primary,
          ),
        ),
      ),
    );
  }
}
