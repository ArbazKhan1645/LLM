import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/models/customer_model/user_model.dart';
import 'package:llm_video_shopify/app/modules/authentcation/consts/app_colors.dart';
import 'package:llm_video_shopify/app/modules/authentcation/consts/app_themes.dart';
import 'package:llm_video_shopify/app/modules/authentcation/controllers/authentcation_controller.dart';
import 'package:llm_video_shopify/app/modules/authentcation/widgets/dropdown_widget.dart';
import 'package:llm_video_shopify/app/modules/authentcation/widgets/widgets/textfield_widget.dart';

class SignUpForm extends StatefulWidget {
  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final AuthenticationController controller = Get.put(
    AuthenticationController(),
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Form(
          key: controller.signUpFormKey,
          child: ListView(
            children: [
              Text(
                'Create an Account',
                style: AppThemes.large.copyWith(fontWeight: FontWeight.bold),
              ),

              // Personal Information
              CustomTextField(
                controller: controller.fullNameController,
                hintText: 'Full Name',
                prefixIcon: const Icon(Icons.person, color: Colors.lightBlue),
                validator: controller.validateName,
              ),

              CustomTextField(
                controller: controller.emailController,
                hintText: 'Email Address',
                prefixIcon: const Icon(Icons.email, color: Colors.lightBlue),

                validator: controller.validateEmail,
              ),

              CustomTextField(
                controller: controller.passwordController,
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock, color: Colors.lightBlue),

                obscureText: true,
                validator: controller.validatePassword,
              ),
              const SizedBox(height: 16),

              // Professional Status
              Obx(
                () => CustomDropdown<String>(
                  label: "Professional Status *",
                  value: controller.selectedStatus.value,
                  items: controller.professionalStatuses,
                  itemToString: (item) => item,
                  onChanged: (val) {
                    controller.selectedStatus.value = val;
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Industry (Optional)
              Obx(
                () => CustomDropdown<String>(
                  label: "Industry (Optional)",
                  value: controller.selectedIndustry.value,
                  items: controller.industries,
                  itemToString: (item) => item,
                  onChanged: (val) {
                    controller.selectedIndustry.value = val;
                  },
                ),
              ),

              // Business Information (shown only for business accounts)
              Obx(
                () =>
                    controller.selectedUserType.value == UserType.business
                        ? Column(
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.business,
                                        color: AppColors.primaryBlue,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Business Information',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  CustomTextField(
                                    controller:
                                        controller.businessNameController,
                                    hintText: 'Business Name',
                                    prefixIcon: const Icon(
                                      Icons.store,
                                      color: Colors.lightBlue,
                                    ),
                                    validator: controller.validateBusinessName,
                                  ),

                                  CustomTextField(
                                    controller:
                                        controller.businessLinkController,
                                    hintText: 'Business Website/Link',
                                    prefixIcon: const Icon(
                                      Icons.web,
                                      color: Colors.lightBlue,
                                    ),

                                    validator: controller.validateBusinessLink,
                                  ),

                                  CustomTextField(
                                    controller:
                                        controller.businessAddressController,
                                    hintText: 'Business Address',
                                    prefixIcon: const Icon(
                                      Icons.location_on,
                                      color: Colors.lightBlue,
                                    ),
                                    maxLines: 2,
                                    validator: (value) {
                                      if (controller.selectedUserType.value ==
                                          UserType.business) {
                                        if (value == null || value.isEmpty) {
                                          return 'Business address is required';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                        : const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Terms and Conditions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(
                        text: 'By creating an account, you agree to our ',
                      ),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sign Up Button
              Obx(
                () => MaterialButton(
                  onPressed:
                      controller.isLoading.value
                          ? null
                          : controller.signUpWithEmail,
                  minWidth: double.infinity,
                  height: 55.h,
                  color: AppColors.primaryBlue,
                  disabledColor: AppColors.primaryBlue.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child:
                      controller.isLoading.value
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 20),

              // Sign In Link
              Center(
                child: GestureDetector(
                  onTap: controller.navigateToSignIn,
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}
