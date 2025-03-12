import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/account_controller.dart';
import 'forgotpassword_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  final AccountController accountController = Get.put(AccountController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Đăng nhập',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool success = await accountController.loginCustomer(
                  emailController.text,
                  passwordController.text,
                );
                if (success) {
                  // Nếu đăng nhập thành công, điều hướng đến trang chủ
                  Get.offAll(() => HomeScreen());
                }
              },
              child: const Text('Đăng nhập', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.to(() => ForgotPasswordScreen()); // Điều hướng đến màn hình quên mật khẩu
              },
              child: const Text(
                'Quên mật khẩu?',
                style: TextStyle(color: Colors.red),
              ),
            ),

            TextButton(
              onPressed: () {
                Get.toNamed('/register_screen');
              },
              child: const Text('Chưa có tài khoản? Đăng ký ngay!', style: TextStyle(color: Colors.green),),
            ),
          ],
        ),
      ),
    );
  }
}
