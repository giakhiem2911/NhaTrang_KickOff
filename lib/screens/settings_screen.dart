import 'package:btl_64131000_64131905/screens/schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/account_controller.dart';
import '../controller/booking_controller.dart';
import 'fields_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class SettingsScreen extends StatelessWidget {
  final AccountController accountController = Get.put(AccountController());
  final BookingController bookingController = Get.put(BookingController());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final RxBool isEditing = false.obs; // Biến trạng thái chỉnh sửa
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: Icon(Icons.sports_soccer, color: Colors.white),
        title: const Text(
          'KICK OFF NHA TRANG',
          style: TextStyle(color: Colors.white),
        ),
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
        if (accountController.currentCustomer.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Bạn chưa đăng nhập.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => RegisterScreen());
                  },
                  child: const Text('Đăng ký', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                ),
              ],
            ),
          );
        }

        final customer = accountController.currentCustomer.value;
        nameController.text = accountController.name.value;
        phoneController.text = accountController.phoneNumber.value;
        phoneController.text = accountController.phoneNumber.value;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin tài khoản',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text('Email: ${customer?.email ?? 'Không có thông tin'}'),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên',
                  border: OutlineInputBorder(),
                ),
                enabled: isEditing.value,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                enabled: isEditing.value,
              ),
              const SizedBox(height: 20),
              if (!isEditing.value)
                ElevatedButton(
                  onPressed: () {
                    isEditing.value = true; // Bật chế độ chỉnh sửa
                  },
                  child: const Text('Chỉnh sửa thông tin', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                ),
              if (isEditing.value)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Lưu thông tin mới
                        accountController.name.value = nameController.text;
                        accountController.phoneNumber.value = phoneController.text;
                        isEditing.value = false; // Tắt chế độ chỉnh sửa
                        Get.snackbar('Thành công', 'Thông tin đã được cập nhật.',
                            snackPosition: SnackPosition.BOTTOM);
                      },
                      child: const Text('Lưu', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        isEditing.value = false; // Hủy chỉnh sửa
                      },
                      child: const Text('Hủy', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  accountController.logoutCustomer();
                },
                child: const Text('Đăng xuất', style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Danh sách'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Lịch'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Tài khoản'),
        ],
        currentIndex: 3,
        onTap: (index) {
          switch(index){
            case 0:
              Get.off(() => HomeScreen()); // Trang chủ
              break;
            case 1:
              Get.to(() => FieldsScreen()); // Danh sách sân bóng
              break;
            case 2:
              Get.to(() => ScheduleScreen()); // Lịch
              break;
            case 3:
              Get.to(() => SettingsScreen()); // Cài đặt
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
                Navigator.of(context).pop();
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
                        Navigator.of(context).pop();
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
                Navigator.of(context).pop();
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}
