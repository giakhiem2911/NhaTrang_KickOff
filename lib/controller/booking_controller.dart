import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/fields.dart';

class BookingController extends GetxController {
  var bookings = <String, Map<int, List<Map<String, dynamic>>>>{}.obs;
  var selectedTime = ''.obs;
  var selectedDate = DateTime.now().obs;
  List<Field> fields = [];

  Field getFieldById(int fieldId) {
    return fields.firstWhere(
          (field) => field.id == fieldId,
      orElse: () => Field(
        id: -1,
        name: 'Sân không xác định',
        address: 'Không xác định',
        phone: 'Không xác định',
        image_url: '',
        opening_hours: 'Không xác định',
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    loadBookings();
  }

  List<Map<String, dynamic>> generateDefaultTimeSlots() {
    return List.generate(17, (index) {
      final hour = index + 6;
      return {
        'time': '${hour.toString().padLeft(2, '0')}:00 - ${(hour + 1).toString().padLeft(2, '0')}:00',
        'isAvailable': true,
      };
    });
  }

  Future<void> loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? bookingsString = prefs.getString('bookings');

    if (bookingsString != null) {
      final Map<String, dynamic> loadedBookings = json.decode(bookingsString);
      bookings.value = loadedBookings.map((key, value) {
        final Map<int, List<Map<String, dynamic>>> fields = {};
        value.forEach((fieldId, timeSlots) {
          fields[int.parse(fieldId)] = List<Map<String, dynamic>>.from(timeSlots);
        });
        return MapEntry(key, fields);
      });
    }
  }

  Future<void> saveBookings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bookings', json.encode(bookings));
  }

  List<Map<String, dynamic>> getTimeSlotsForDate(String date, int fieldId) {
    if (!bookings.containsKey(date)) {
      bookings[date] = {};
    }
    if (!bookings[date]!.containsKey(fieldId)) {
      bookings[date]![fieldId] = generateDefaultTimeSlots();
    }
    return bookings[date]![fieldId]!;
  }

  void bookTimeSlot(String date, String timeSlot, int fieldId) {
    if (bookings.containsKey(date) && bookings[date]!.containsKey(fieldId)) {
      final slots = bookings[date]![fieldId]!;
      for (var slot in slots) {
        if (slot['time'] == timeSlot) {
          slot['isAvailable'] = false;
          break;
        }
      }
      saveBookings();
    }
  }

  void cancelBooking(String date, String timeSlot, int fieldId) {
    if (bookings.containsKey(date) && bookings[date]!.containsKey(fieldId)) {
      final slots = bookings[date]![fieldId]!;
      for (var slot in slots) {
        if (slot['time'] == timeSlot) {
          slot['isAvailable'] = true;
          break;
        }
      }
      saveBookings();
    }
  }
}
