import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fields.dart';

class FieldRepository {
  final SupabaseClient client;

  FieldRepository(this.client);

  Future<List<Field>> getAll() async {
    try {
      // Gọi select() để lấy dữ liệu từ bảng 'locations'
      final response = await client.from('locations').select('id, name, address, phone, opening_hours, image_url');

      // Kiểm tra lỗi trong phản hồi
      if (response == null) {
        throw Exception('Lỗi khi lấy danh sách sân bóng!');
      }

      // Chuyển đổi dữ liệu thành danh sách Field
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Field.fromMap(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách sân bóng: $e');
      return []; // Trả về danh sách rỗng trong trường hợp lỗi
    }
  }
}
