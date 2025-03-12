import 'package:get/get.dart';
import '../models/fields.dart';
import '../repository/fields_repository.dart';

class FieldController extends GetxController {
  final FieldRepository repository;
  var fields = <Field>[].obs; // Danh sách các trường
  var isLoading = false.obs; // Trạng thái tải

  FieldController(this.repository);

  @override
  void onInit() {
    fetchFields();
    super.onInit();
  }

  Future<void> fetchFields() async {
    try {
      isLoading.value = true; // Bắt đầu trạng thái tải
      fields.value = await repository.getAll(); // Lấy danh sách trường từ repository
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    } finally {
      isLoading.value = false; // Kết thúc trạng thái tải
    }
  }
}
