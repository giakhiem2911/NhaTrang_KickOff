import 'package:btl_64131000_64131905/screens/booking_screen.dart';
import 'package:btl_64131000_64131905/screens/home_screen.dart';
import 'package:btl_64131000_64131905/screens/schedule_screen.dart';
import 'package:btl_64131000_64131905/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/booking_controller.dart';
import '../controller/field_controller.dart';
import '../controller/account_controller.dart';
import 'login_screen.dart'; // Thêm import này

class FieldsScreen extends StatelessWidget {
  final FieldController fieldController = Get.find<FieldController>();
  final BookingController bookingController = Get.put(BookingController());
  final AccountController accountController = Get.find<AccountController>(); // Khởi tạo AccountController
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      appBar: AppBar(
        leading: Icon(Icons.sports_soccer, color: Colors.white),
        title: const Text(
          'Danh sách sân bóng',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: () {
              _showBookingsDialog(context);
            },
            icon: const Icon(Icons.notifications),
            color: Colors.white,
          ),
          IconButton(
            onPressed: () {
              _showAccountDialog(context);
            },
            icon: const Icon(Icons.person),
            color: Colors.white,
          ),
        ],
      ),
      body: Obx(() {
        if (fieldController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (fieldController.fields.isEmpty) {
          return const Center(
              child: Text('Không có sân bóng nào.',
                  style: TextStyle(fontSize: 16)));
        }

        return ListView.builder(
          itemCount: fieldController.fields.length,
          itemBuilder: (context, index) {
            final field = fieldController.fields[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                leading: Image.network(
                  field.image_url,
                  width: 80,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported,
                        size: 60, color: Colors.grey);
                  },
                ),
                title: Text(
                  field.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('SĐT: ${field.phone}',
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Text('${field.opening_hours}',
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Nút đặt lịch
                    ElevatedButton.icon(
                      onPressed: () {
                        if (accountController.currentCustomer.value == null) {
                          // Nếu người dùng chưa đăng nhập, hiển thị thông báo
                          Get.snackbar(
                            'Thông báo',
                            'Bạn cần đăng nhập để đặt sân.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          Get.toNamed('/login_screen'); // Điều hướng đến màn hình đăng nhập
                        } else {
                          // Nếu đã đăng nhập, điều hướng đến BookingScreen
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Get.to(() => BookingScreen(currentFieldId: field.id));
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: const Text('Đặt lịch'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // Hiển thị thông báo khi nhấn vào phần tử
                  Get.snackbar('Sân bóng được chọn', field.name,
                      snackPosition: SnackPosition.BOTTOM);
                },
              ),
            );
          },
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Danh sách'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Tài khoản'),
        ],
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.to(() => HomeScreen()); // Trang chủ
              break;
            case 1:
              Get.off(() => FieldsScreen()); // Danh sách
              break;
            case 2:
              Get.to(() => ScheduleScreen()); // Lịch
              break;
            case 3:
              Get.to(() => SettingsScreen()); // Tài khoản
              break;
          }
        },
      ),
    );
  }

  void _showBookingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông báo'),
          content: SizedBox(
            width: double.maxFinite,
            child: Obx(() {
              // Kiểm tra xem người dùng đã đăng nhập chưa
              if (!accountController.isLoggedIn) {
                return const Center(child: Text('Bạn chưa đăng nhập. Vui lòng đăng nhập để xem thông báo nhé!'));
              }

              List<String> bookedFields = [];

              bookingController.bookings.forEach((date, fieldsBookings) {
                fieldsBookings.forEach((fieldId, timeSlots) {
                  List<Map<String, dynamic>> bookedSlots = timeSlots.where((slot) => !slot['isAvailable']).toList();
                  if (bookedSlots.isNotEmpty) {
                    bookedFields.add('Bạn có lịch đá vào ngày: $date');
                  }
                });
              });

              if (bookedFields.isEmpty) {
                return const Text('Bạn chưa đặt sân nào.');
              }

              return ListView.builder(
                itemCount: bookedFields.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(bookedFields[index]),
                  );
                },
              );
            }),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
  void _showAccountDialog(BuildContext context) {
    nameController.text = accountController.name.value;
    phoneController.text = accountController.phoneNumber.value;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông tin tài khoản'),
          content: SizedBox(
            width: double.maxFinite,
            child: Obx(() {
              // Kiểm tra trạng thái đăng nhập
              if (!accountController.isLoggedIn) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Bạn chưa đăng nhập.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => LoginScreen());
                      },
                      child: const Text('Đăng nhập', style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                    ),
                  ],
                );
              } else {
                // Nếu đã đăng nhập, hiển thị thông tin người dùng
                final user = accountController.currentCustomer.value;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tên:  ${nameController.text}'),
                    Text('Email: ${user?.email ?? "Không có"}'),
                    Text('Số điện thoại:  ${phoneController.text}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        accountController.logoutCustomer(); // Đăng xuất
                        Navigator.of(context).pop(); // Đóng dialog
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              }
            }),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}
