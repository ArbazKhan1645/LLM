import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:llm_video_shopify/app/modules/authentcation/consts/app_colors.dart';
import 'package:llm_video_shopify/app/modules/authentcation/consts/app_themes.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemToString;
  final void Function(T?) onChanged;

  const CustomDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemToString,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
            color: Color(0xFF0C1037),
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          height: 55.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              dropdownColor: AppColors.white,
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.black),
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15.sp,
                letterSpacing: 0.5,
              ),
              hint: Text("Select", style: AppThemes.small),
              onChanged: onChanged,
              items:
                  items
                      .map(
                        (item) => DropdownMenuItem<T>(
                          value: item,
                          child: Text(itemToString(item)),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
