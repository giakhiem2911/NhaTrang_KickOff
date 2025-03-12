import 'package:btl_64131000_64131905/screens/fields_screen.dart';
import 'package:btl_64131000_64131905/screens/forgotpassword_screen.dart';
import 'package:btl_64131000_64131905/screens/home_screen.dart';
import 'package:btl_64131000_64131905/screens/login_screen.dart';
import 'package:btl_64131000_64131905/screens/register_screen.dart';
import 'package:btl_64131000_64131905/screens/schedule_screen.dart';
import 'package:btl_64131000_64131905/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controller/account_controller.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ycwxueppuqryhripwaws.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inljd3h1ZXBwdXFyeWhyaXB3YXdzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMzNzE3NjYsImV4cCI6MjA0ODk0Nzc2Nn0.R24a_V4Fkk09SY9DTA_a9q4OIC5qNBykOaTENp9L-vI',
  );
  Get.put(AccountController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KICK OFF',
      getPages: [
        GetPage(name: '/home_screen', page: () => HomeScreen()),
        GetPage(name: '/fields_screen', page: () => FieldsScreen()),
        GetPage(name: '/schedule_screen', page: () => ScheduleScreen()),
        GetPage(name: '/settings_screen', page: () => SettingsScreen()),
        GetPage(name: '/login_screen', page: () => LoginScreen()),
        GetPage(name: '/register_screen', page: () => RegisterScreen()),
        GetPage(name: '/forgot_password', page: () => ForgotPasswordScreen()),
      ],
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}
