import 'package:supabase_flutter/supabase_flutter.dart';

class Customer {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? password;

  Customer({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      password: map['password'] as String?,
    );
  }
}

class CustomerRepository {
  final SupabaseClient client;

  CustomerRepository(this.client);

  Future<List<Customer>> getAll() async {
    try {
      final response = await client.from('customer').select('id, name, phone, email, password');

      // Kiểm tra lỗi trong phản hồi
      if (response == null) {
        throw Exception('Lỗi khi lấy danh sách sân bóng!');
      }

      // Chuyển đổi dữ liệu thành danh sách Field
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Customer.fromMap(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách sân bóng: $e');
      return []; // Trả về danh sách rỗng trong trường hợp lỗi
    }
  }
}
