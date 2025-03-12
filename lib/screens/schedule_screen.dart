import 'package:btl_64131000_64131905/controller/account_controller.dart';
import 'package:btl_64131000_64131905/screens/fields_screen.dart';
import 'package:btl_64131000_64131905/screens/home_screen.dart';
import 'package:btl_64131000_64131905/screens/login_screen.dart';
import 'package:btl_64131000_64131905/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/booking_controller.dart';
import '../controller/field_controller.dart';
import '../models/fields.dart';

class ScheduleScreen extends StatelessWidget {
  final BookingController bookingController = Get.find<BookingController>();
  final FieldController fieldController = Get.find<FieldController>();
  final AccountController accountController = Get.find<AccountController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lịch của tôi',
          style: TextStyle(color: Colors.white),
        ),
        leading: Icon(Icons.sports_soccer, color: Colors.white),
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
        // Kiểm tra trạng thái đăng nhập
        if (!accountController.isLoggedIn) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Bạn cần đăng nhập để xem lịch đặt sân.'),
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
            ),
          );
        }

        if (bookingController.bookings.isEmpty) {
          return const Center(child: Text('Bạn chưa đặt sân nào.'));
        }

        return ListView.builder(
          itemCount: bookingController.bookings.length,
          itemBuilder: (context, index) {
            String date = bookingController.bookings.keys.elementAt(index);
            Map<int, List<Map<String, dynamic>>> fieldsBookings = bookingController.bookings[date]!;

            // Lấy danh sách khung giờ đã đặt
            List<Widget> bookedSlotsWidgets = [];

            fieldsBookings.forEach((fieldId, timeSlots) {
              List<Map<String, dynamic>> bookedSlots = timeSlots.where((slot) => !slot['isAvailable']).toList();

              if (bookedSlots.isNotEmpty) {
                // Lấy thông tin sân từ ID sân đã đặt
                final field = fieldController.fields.firstWhere(
                      (f) => f.id == fieldId,
                  orElse: () => Field(
                    id: -1,
                    name: 'Thông tin không có',
                    address: 'Không xác định',
                    phone: 'Không xác định',
                    image_url: '',
                    opening_hours: 'Không xác định',
                  ),
                );

                bookedSlotsWidgets.add(
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sân: ${field.name}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Ngày: $date',
                            style: const TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          ...bookedSlots.map((slot) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Thời gian đặt: ${slot['time']}',
                                    style: const TextStyle(fontSize: 14, color: Colors.red),
                                  ),
                                  Text(
                                    'Địa chỉ: ${field.address}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Số điện thoại: ${field.phone}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(),
                                  ElevatedButton(
                                    onPressed: () {
                                      _showCancelDialog(context, date, slot['time'], fieldId);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text(
                                      'Hủy đặt',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                );
              }
            });

            return Column(
              children: bookedSlotsWidgets
            );
          },
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Danh sách'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Tài khoản'),
        ],
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.to(() => HomeScreen()); // Trang chủ
              break;
            case 1:
              Get.to(() => FieldsScreen()); // Danh sách sân bóng
              break;
            case 2:
              Get.off(() => ScheduleScreen()); // Lịch
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
            width: double.maxFinite, // Đặt chiều rộng tối đa cho dialog
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
  void _showCancelDialog(BuildContext context, String date, String time, int fieldId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận hủy đặt'),
          content: Text('Bạn có chắc chắn muốn hủy đặt sân vào lúc $time ngày $date không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog nếu chọn "Không"
              },
              child: const Text('Không', style: TextStyle(color: Colors.green),),
            ),
            ElevatedButton(
              onPressed: () {
                // Gọi hàm hủy đặt trong BookingController
                bookingController.cancelBooking(date, time, fieldId);
                Navigator.of(context).pop(); // Đóng dialog
                Get.snackbar(
                  'Hủy đặt thành công',
                  'Bạn đã hủy đặt sân vào $time ngày $date',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Đồng ý', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

}
