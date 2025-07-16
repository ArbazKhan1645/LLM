import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/modules/authentcation/consts/app_colors.dart';
import 'package:llm_video_shopify/app/modules/authentcation/consts/app_themes.dart';
import 'package:llm_video_shopify/app/modules/authentcation/controllers/authentcation_controller.dart';

import 'package:llm_video_shopify/app/modules/authentcation/widgets/widgets/round_button.dart';
import 'package:llm_video_shopify/app/modules/authentcation/widgets/widgets/textfield_widget.dart';

class SignInForm extends StatefulWidget {
  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final AuthenticationController controller =
      Get.find<AuthenticationController>();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Form(
          key: controller.signInFormKey,
          child: ListView(
            children: [
              Text(
                'Welcome Back',
                style: AppThemes.large.copyWith(fontWeight: FontWeight.bold),
              ),

              Text(
                'Sign in to your account',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),

              CustomTextField(
                controller: controller.signInEmailController,
                hintText: 'Email Address',
                prefixIcon: const Icon(Icons.email, color: Colors.lightBlue),

                validator: controller.validateEmail,
              ),

             CustomTextField(
                  controller: controller.signInPasswordController,
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock, color: Colors.lightBlue),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 16),

              // Remember Me and Forgot Password
              Row(
                children: [
                  Obx(
                    () => Row(
                      children: [
                        Checkbox(
                          value: controller.rememberMe.value,
                          onChanged: (value) => controller.toggleRememberMe(),
                          activeColor: AppColors.primaryBlue,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        const Text(
                          'Remember me',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      // Navigate to forgot password
                      Get.toNamed('/forgot-password');
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Sign In Button
              Obx(
                () => MaterialButton(
                  onPressed:
                      controller.isLoading.value
                          ? null
                          : controller.signInWithEmail,
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
                            'SIGN IN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 24),

              // Divider
              // Row(
              //   children: [
              //     Expanded(child: Divider(color: Colors.grey.shade300)),
              //     Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 16),
              //       child: Text(
              //         'OR',
              //         style: TextStyle(
              //           color: Colors.grey.shade500,
              //           fontWeight: FontWeight.w500,
              //         ),
              //       ),
              //     ),
              //     Expanded(child: Divider(color: Colors.grey.shade300)),
              //   ],
              // ),

              // const SizedBox(height: 24),

              // // Social Sign In Buttons
              // Row(
              //   children: [
              //     Expanded(
              //       child: OutlinedButton.icon(
              //         onPressed: () {
              //           // TODO: Implement Google Sign In
              //           // controller._showWarningSnackbar(
              //           //   'Coming Soon',
              //           //   'Google Sign In will be available soon',
              //           // );
              //         },
              //         icon: const Icon(Icons.g_mobiledata, size: 24),
              //         label: const Text('Google'),
              //         style: OutlinedButton.styleFrom(
              //           padding: const EdgeInsets.symmetric(vertical: 12),
              //           side: BorderSide(color: Colors.grey.shade300),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(12),
              //           ),
              //         ),
              //       ),
              //     ),
              //     const SizedBox(width: 16),
              //     Expanded(
              //       child: OutlinedButton.icon(
              //         onPressed: () {
              //           // TODO: Implement Facebook Sign In
              //           // controller._showWarningSnackbar(
              //           //   'Coming Soon',
              //           //   'Facebook Sign In will be available soon',
              //           // );
              //         },
              //         icon: const Icon(Icons.facebook, size: 24),
              //         label: const Text('Facebook'),
              //         style: OutlinedButton.styleFrom(
              //           padding: const EdgeInsets.symmetric(vertical: 12),
              //           side: BorderSide(color: Colors.grey.shade300),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(12),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 32),

              // Sign Up Link
              Center(
                child: GestureDetector(
                  onTap: controller.navigateToSignUp,
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14),
                      children: [
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        TextSpan(
                          text: 'Sign Up',
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
            ],
          ),
        ),
      ),
    );
  }
}
