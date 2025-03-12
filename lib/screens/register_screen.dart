import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/account_controller.dart';


class RegisterScreen extends StatelessWidget {
  final AccountController accountController = Get.put(AccountController());
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Đăng ký',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Tên đăng nhập',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Xác nhận mật khẩu',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool success = await accountController.registerCustomer(
                  usernameController.text,
                  phoneController.text,
                  emailController.text,
                  passwordController.text,
                );
                if (success) {
                  Get.snackbar(
                    'Thành công',
                    'Hãy xác minh trong email và sau đó hãy đăng nhập!',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  Get.toNamed('/login_screen', arguments: emailController.text);
                } else {
                  Get.snackbar(
                    'Lỗi',
                    'Đăng ký không thành công. Vui lòng thử lại.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: const Text('Đăng ký', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed('/login_screen');
              },
              child: const Text('Đã có tài khoản, đăng nhập ngay!', style: TextStyle(color: Colors.green),),
            ),
          ],
        ),
      ),
    );
  }
}
