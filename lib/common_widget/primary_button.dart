// lib/common_widget/primary_button.dart
import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: TColor.primary,
          foregroundColor: TColor.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child:
            isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }
}
