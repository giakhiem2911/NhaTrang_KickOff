import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/booking_controller.dart';

class BookingScreen extends StatefulWidget {
  final int currentFieldId;
  BookingScreen({required this.currentFieldId});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingController bookingController = Get.put(BookingController());
  DateTime selectedDate = DateTime.now(); // Ngày được chọn
  String? selectedTime; // Khung giờ được chọn

  @override
  Widget build(BuildContext context) {
    String formattedDate = "${selectedDate.toLocal()}".split(' ')[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Đặt lịch sân bóng',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Phần chọn ngày
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn ngày:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null && pickedDate != selectedDate) {
                          setState(() {
                            selectedDate = pickedDate;
                            selectedTime = null; // Reset khung giờ đã chọn
                          });
                        }
                      },
                      child: const Text('Chọn ngày'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // Phần chọn khung giờ
          Expanded(
            child: Obx(() {
              // Lấy các khung giờ cho ngày đã chọn và sân hiện tại
              final timeSlots = bookingController.getTimeSlotsForDate(formattedDate, widget.currentFieldId);
              return ListView.builder(
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  final timeSlot = timeSlots[index];
                  return ListTile(
                    title: Text(
                      timeSlot['time'],
                      style: TextStyle(
                        color: timeSlot['isAvailable'] ? Colors.black : Colors.red,
                        fontWeight: timeSlot['isAvailable'] ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    leading: Radio<String>(
                      value: timeSlot['time'],
                      groupValue: selectedTime,
                      onChanged: timeSlot['isAvailable']
                          ? (value) {
                        setState(() {
                          selectedTime = value;
                        });
                      }
                          : null, // Không cho chọn nếu đã đặt
                      activeColor: Colors.green,
                    ),
                    trailing: timeSlot['isAvailable']
                        ? const Text(
                      'Trống',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    )
                        : const Text(
                      'Đã đặt',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              );
            }),
          ),
          const Divider(),
          // Nút xác nhận
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedTime != null) {
                    bookingController.bookTimeSlot(formattedDate, selectedTime!, widget.currentFieldId);
                    Get.snackbar(
                      'Đặt lịch thành công',
                      'Bạn đã đặt sân vào $selectedTime, ngày $formattedDate',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } else {
                    Get.snackbar(
                      'Lỗi',
                      'Vui lòng chọn một khung giờ để đặt lịch.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Xác nhận đặt lịch',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
