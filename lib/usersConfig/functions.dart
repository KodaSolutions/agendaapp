import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

Future<List<Map<String, dynamic>>> loadUsersWithRoles() async {
  try {
    final response = await http.get(Uri.parse('https://agendapp-cvp-75a51cfa88cd.herokuapp.com/userAll'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final usersList = (data['user'] as List).where((user) => user['role_id'] != 3).map((user) {
        return {
          'id': user['id'].toString(),
          'name': user['name'],
          'identification': user['identification'].toString(),
          'role': user['role_id'],
          //1 es doctor 2 asistente 3 admin
        };
      })
          .toList();
      return usersList;
    } else {
      throw Exception('Error al cargar usuarios: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

//funcion enviar mensaje por whats
Future<void> sendWhatsMsg(
    {required String phone, required String bodymsg}) async {
  if (!await launchUrl(Uri.parse('https://wa.me/$phone?text=$bodymsg'))) {
    throw Exception('No se puede enviar mensaje a $phone');
  }
}



