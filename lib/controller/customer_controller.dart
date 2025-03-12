import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerController extends GetxController {
  final supabase = Supabase.instance.client;

  var name = ''.obs;
  var phone = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;

  void fetchCustomerInfo() async {
    isLoading.value = true;
    try {
      final user = supabase.auth.currentUser; // Lấy người dùng hiện tại
      if (user == null) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      final result = await supabase
          .from('customer')
          .select('name, phone, email, password')
          .eq('email', user.email ?? '') // Dựa vào email của người dùng
          .maybeSingle();

      if (result != null) {
        name.value = result['name'] ?? '';
        phone.value = result['phone'] ?? '';
        email.value = result['email'] ?? '';
        password.value = result['password'] ?? '';
      } else {
        Get.snackbar('Lỗi', 'Không tìm thấy tài khoản');
      }
    } catch (_) {
      Get.snackbar('Lỗi', 'An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }
}
