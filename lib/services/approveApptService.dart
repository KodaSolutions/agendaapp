import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../calendar/calendarSchedule.dart';

class approveApptService {
  final String baseUrl = 'https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api';

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<bool> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<List<Appointment2>> fetchAppointments() async {
    List<Appointment2> appointments = [];
    try {
      bool isConnected = await checkConnectivity();

      if (!isConnected) {
        throw Exception('No hay conexión a internet');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/getPendingAppointments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getToken()}',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map<String, dynamic> && jsonResponse['appointments'] is List) {
          appointments = List<Appointment2>.from(
            jsonResponse['appointments'].map(
                    (appointmentJson) => Appointment2.fromJson(appointmentJson as Map<String, dynamic>)
            ),
          );
          print('Datos de appointments obtenidos correctamente');
        } else {
          throw Exception('La respuesta no contiene una lista de citas válida');
        }
      } else {
        throw Exception('Error al cargar citas desde la API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener las citas: $e');
      throw e;
    }

    return appointments;
  }

  Future<Map<String, dynamic>> approveAppointment(int appointmentId, int doctorId) async {
    try {
      bool isConnected = await checkConnectivity();

      if (!isConnected) {
        throw Exception('No hay conexión a internet');
      }

      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/appointments/$appointmentId/approve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'doctor_id': doctorId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Cita no encontrada');
      } else {
        throw Exception('Error al aprobar la cita: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en approveAppointment: $e');
      throw Exception('Error al aprobar la cita: $e');
    }
  }

  Future<Map<String, dynamic>> rejectAppointment(int appointmentId, String reason) async {
    try {
      bool isConnected = await checkConnectivity();

      if (!isConnected) {
        throw Exception('No hay conexión a internet');
      }

      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/appointments/$appointmentId/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al rechazar la cita: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en rejectAppointment: $e');
      throw Exception('Error al rechazar la cita: $e');
    }
  }

  Future<Map<String, dynamic>> rescheduleAppointment(int? appointmentId, int doctorId, TextEditingController dateController, TextEditingController timeController, context) async {
    print('hola jeje');

    try {
      bool isConnected = await checkConnectivity();

      if (!isConnected) {
        throw Exception('No hay conexión a internet');
      }

      final token = await getToken();
      DateTime selectedDate =
      DateFormat('yyyy-MM-dd').parse(dateController.text);
      DateTime selectedTime = DateFormat.jm().parse(timeController.text);

      try {
        print('adios');
        await http.put(
          Uri.parse(
              'https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api/editAppoinment/${appointmentId}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'date': DateFormat('yyyy-MM-dd').format(selectedDate),
            'time': DateFormat('HH:mm:ss').format(selectedTime),
          }),
        );
      } catch (e) {
        print('Error en rescheduleAppointment: $e');
        throw Exception('Error al reagendar la cita: $e');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/appointments/$appointmentId/approve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'doctor_id': doctorId,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita reagendada exitosamente'),
            backgroundColor: Colors.orange,
          ),
        );
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Cita no encontrada');
      } else {
        throw Exception('Error al aprobar la cita: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en rescheduleAppointment: $e');
      throw Exception('Error al reagendar la cita: $e');
    }
  }
}