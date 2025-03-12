import 'package:get/get.dart';
import 'booking_controller.dart';

class MyScheduleController extends GetxController {
  final BookingController bookingController = Get.find();

  // Lấy danh sách các lịch đã đặt
  List<Map<String, dynamic>> get bookedSchedules {
    List<Map<String, dynamic>> schedules = [];
    bookingController.bookings.forEach((date, fields) {
      fields.forEach((fieldId, slots) {
        for (var slot in slots) {
          if (!slot['isAvailable']) {
            schedules.add({
              'date': date,
              'time': slot['time'],
              'fieldId': fieldId,
            });
          }
        }
      });
    });
    return schedules;
  }
}
