import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/account_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final AccountController accountController = Get.find<AccountController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final RxBool isOtpVerified = false.obs; // Biến trạng thái kiểm tra OTP

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên mật khẩu', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Nhập email của bạn để nhận mã OTP:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final email = emailController.text.trim();
                  if (email.isNotEmpty) {
                    bool success = await accountController.sendOtp(email);
                    if (success) {
                      Get.snackbar(
                        'Thành công',
                        'Mã OTP đã được gửi đến email của bạn.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    }
                  } else {
                    Get.snackbar(
                      'Lỗi',
                      'Vui lòng nhập email.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(10),
                ),
                child: const Text(
                  'Gửi OTP',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              // Nhập mã OTP
              const Text(
                'Nhập mã OTP:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Mã OTP',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final email = emailController.text.trim();
                  final otp = otpController.text.trim();

                  if (otp.isNotEmpty) {
                    bool success = await accountController.verifyOtp(email, otp);
                    if (success) {
                      isOtpVerified.value = true; // Đánh dấu OTP đã được xác minh
                      Get.snackbar(
                        'Thành công',
                        'Mã OTP chính xác, vui lòng đặt mật khẩu mới.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    }
                  } else {
                    Get.snackbar(
                      'Lỗi',
                      'Vui lòng nhập mã OTP.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(10),
                ),
                child: const Text(
                  'Xác minh OTP',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),

              const SizedBox(height: 20),
              // Hiển thị phần đặt mật khẩu mới nếu OTP đã xác minh
              Obx(() {
                if (isOtpVerified.value) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nhập mật khẩu mới:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Mật khẩu mới',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          final email = emailController.text.trim();
                          final otp = otpController.text.trim();
                          final newPassword = newPasswordController.text.trim();

                          if (newPassword.isNotEmpty) {
                            bool success = await accountController.verifyOtpAndResetPassword(
                                email, otp, newPassword);
                            Get.offAllNamed('/login_screen');
                            // if (success) {
                            //   Get.offAllNamed('/login_screen');
                            //   Get.snackbar(
                            //     'Thành công',
                            //     'Đổi mật khẩu thành công',
                            //     snackPosition: SnackPosition.BOTTOM,
                            //     backgroundColor: Colors.red,
                            //     colorText: Colors.white,
                            //   );
                            // } else {
                            //   Get.snackbar(
                            //     'Có lỗi',
                            //     'Đổi mật khẩu không thành công',
                            //     snackPosition: SnackPosition.BOTTOM,
                            //     backgroundColor: Colors.red,
                            //     colorText: Colors.white,
                            //   );
                            // }
                          } else {
                            Get.snackbar(
                              'Lỗi',
                              'Vui lòng nhập mật khẩu mới.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.all(10),
                        ),
                        child: const Text(
                          'Cập nhật mật khẩu',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink(); // Không hiển thị gì nếu chưa xác minh
              }),
            ],
          ),
        ),
      ),
    );
  }
}

