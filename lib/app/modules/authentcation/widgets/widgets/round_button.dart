import 'package:flutter/material.dart';
import 'package:llm_video_shopify/app/modules/authentcation/consts/app_colors.dart';
import 'package:llm_video_shopify/app/modules/authentcation/consts/app_themes.dart';

class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.width,
    required this.hieght,
    required this.radius,
    required this.bgColor,
    required this.onPressed,
    this.text = 'Sign up',
  });

  final double width;
  final double hieght;
  final double radius;
  final Color bgColor;
  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: hieght,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: bgColor,
        ),
        child: Center(
          child: Text(
            text,
            style: AppThemes.large.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
