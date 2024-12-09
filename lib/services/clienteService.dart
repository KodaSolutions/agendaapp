import 'dart:convert';

import 'package:http/http.dart' as http;

class ClientService {
  final String baseUrl = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/deleteClient/';

  Future<void> deleteClient(int id) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + '$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        print('Cliente eliminado con éxito');
      } else {
        print('Error al eliminar el cliente: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
//funciones clientinfo
  Future<Map<String, dynamic>> fetchAppointmentByUser(int id) async {
    final String url = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/getAppoinmentsByUser/$id';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        return {
          'error': jsonDecode(response.body)['message'],
        };
      } else {
        return {
          'error': 'Error en la solicitud: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'error': 'Ha ocurrido un error: $e',
      };
    }
  }
  //funcion updateUserInfo aun en desuso, solo se migro
  Future<void> updateUserInfo({required int id, required String token, required String name, required String phone, required String email,
  }) async {
    final url = Uri.parse(baseUrl + 'editUserInfo/$id');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'name': name,
          'number': phone,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        print('Datos actualizados correctamente');
      } else {
        print('Error al actualizar los datos: ${response.body}');
      }
    } catch (e) {
      print("Error al hacer la solicitud: $e");
    }
  }
}
