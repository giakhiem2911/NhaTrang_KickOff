import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/users.dart';

class AccountController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final CustomerRepository repository = CustomerRepository(Supabase.instance.client);
  final Rx<Map<String, dynamic>?> userProfile = Rx<Map<String, dynamic>?>(null);
  RxBool isOtpSent = false.obs;
  String? otpCode;
  var name = ''.obs;
  var phoneNumber = ''.obs;
  var password = ''.obs;
  Rx<User?> currentCustomer = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    currentCustomer.value = supabase.auth.currentUser;
    if (currentCustomer.value != null) {
      fetchUserProfile(currentCustomer.value!.id);
    }
  }
  bool get isLoggedIn => currentCustomer.value != null;

  Future<bool> loginCustomer(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        // Cập nhật currentCustomer sau khi đăng nhập thành công
        currentCustomer.value = response.user;
        Get.snackbar(
          'Thành công',
          'Đăng nhập thành công.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Lỗi',
          'Sai email hoặc mật khẩu.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Sai email hoặc mật khẩu.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
  final uuid = Uuid();
  Future<bool> registerCustomer(String username, String phone, String email, String password) async {
    try {
      final response = await supabase.auth.signUp(email: email, password: password);

      if (response.user != null) {
        await supabase.from('customer').insert({
          'id': uuid.v4(),
          'name': username,
          'phone': phone,
          'email': email,
          'password': password,
        });
        return true;
      }
      return false;
    } catch (e) {
      if (e.toString().contains('over_email_send_rate_limit')) {
        Get.snackbar(
          'Lỗi',
          'Bạn đã yêu cầu gửi email quá nhiều lần. Vui lòng chờ ít nhất 60 giây trước khi thử lại.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Lỗi',
          'Đăng ký không thành công: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await supabase
          .from('otp_requests')
          .select('otp')
          .eq('email', email)
          .limit(1)
          .single();

      // Kiểm tra xem response có null hay không
      if (response == null) {
        throw Exception('Không tìm thấy thông tin người dùng');
      }

      if (response['otp'] == otp) {
        // await supabase.from('customer').update({'otp': null}).eq('email', email);
        return true;
      } else {
        Get.snackbar(
          'Lỗi',
          'Mã OTP không hợp lệ.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể xác minh mã OTP: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  String _generateOtp() {
    final random = Random();
    return List.generate(6, (index) => random.nextInt(10)).join(); // Tạo OTP gồm 6 chữ số
  }

  RxBool isOtpSending = false.obs;

  Future<bool> sendOtp(String email) async {
    if (isOtpSending.value) {
      Get.snackbar(
        'Thông báo',
        'Đang gửi mã OTP. Vui lòng chờ.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    isOtpSending.value = true; // Đánh dấu là đang gửi OTP

    try {
      String otpCode = _generateOtp();
      await supabase.from('otp_requests').insert({
        'email': email,
        'otp': otpCode,
      });

      // await _sendOtpEmail(email, otpCode);
      return true;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể gửi mã OTP: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isOtpSending.value = false; // Đánh dấu là đã hoàn thành gửi OTP
    }
  }

  Future<void> fetchUserProfile(String userId) async {
    try {
      final response = await supabase
          .from('customer')
          .select('*')
          .eq('id', userId)
          .single(); // Lấy duy nhất một bản ghi

      if (response != null) {
        userProfile.value = response;
        print('Thông tin người dùng đã được tải: $userProfile');
      } else {
        print('Không tìm thấy thông tin người dùng với ID: $userId');
      }
    } catch (e) {
      print('Lỗi khi tải thông tin người dùng: $e');
    }
  }
  Future<bool> verifyOtpAndResetPassword(String email, String otp, String newPassword) async {
    try {
      final response = await supabase
          .from('otp_requests')
          .select('otp')
          .eq('email', email)
          .limit(1)
          .single();
      if (response == null) {
        print('Không tìm thấy OTP cho email: $email');
        throw Exception('Không tìm thấy thông tin người dùng');
      } else {
        print('OTP từ cơ sở dữ liệu: ${response['otp']}');
      }
      if (response != null && response['otp'] == otp) {
        // Cập nhật mật khẩu
        await supabase.auth.updateUser(UserAttributes(password: newPassword));

        // Xóa OTP sau khi xác minh
        await supabase.from('otp_requests').update({'otp': null}).eq('email', email);

        Get.snackbar(
          'Thành công',
          'Đặt lại mật khẩu thành công. Bạn có thể đăng nhập ngay.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Lỗi',
          'Mã OTP không hợp lệ.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print('Lỗi khi xác minh OTP và cập nhật mật khẩu: $e');
      return false;
    }
  }

  void logoutCustomer() async {
    try {
      await supabase.auth.signOut();
      currentCustomer.value = null;
      Get.snackbar(
        'Đăng xuất thành công',
        'Hẹn gặp lại!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Đăng xuất thất bại',
        'Lỗi: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
