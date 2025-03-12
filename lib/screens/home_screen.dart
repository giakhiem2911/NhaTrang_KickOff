import 'package:btl_64131000_64131905/controller/booking_controller.dart';
import 'package:btl_64131000_64131905/screens/fields_screen.dart';
import 'package:btl_64131000_64131905/screens/schedule_screen.dart';
import 'package:btl_64131000_64131905/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controller/account_controller.dart';
import '../controller/field_controller.dart';
import '../repository/fields_repository.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final BookingController bookingController = Get.put(BookingController());
  final FieldController fieldController =
  Get.put(FieldController(FieldRepository(Supabase.instance.client)));
  final AccountController accountController = Get.find<AccountController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
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
        if (fieldController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (fieldController.fields.isEmpty) {
          return const Center(child: Text('Không có dữ liệu.'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Section
              Container(
                width: double.infinity,
                height: 200,
                child: Image.network(
                  'https://media.diadiem247.com/uploads/thumb/2021/06/25/dhnt.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Error loading image'));
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Tagline Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    "Life's Great with Football",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Top Fields Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Top sân nổi bật',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fieldController.fields.length,
                itemBuilder: (context, index) {
                  final field = fieldController.fields[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Image.network(
                          field.image_url,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported);
                          },
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  field.name,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  field.phone,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: Colors.green,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${field.opening_hours}'),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
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
        currentIndex: 0,
        onTap: (index) {
          switch(index){
            case 0:
              Get.off(() => HomeScreen()); // Trang chủ
              break;
            case 1:
              Get.to(() => FieldsScreen()); // Danh sách
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
                        accountController.logoutCustomer();
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
