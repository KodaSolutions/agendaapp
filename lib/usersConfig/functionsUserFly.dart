import 'dart:convert';
import 'package:http/http.dart' as http;
import '../globalVar.dart';

Future<List<Map<String, dynamic>>> loadUsersFromApi() async {
  try {
    final response = await http.get(Uri.parse('https://agendapp-cvp-75a51cfa88cd.herokuapp.com/userAll'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final usersList = (data['user'] as List)
          .where((user) => user['role_id'] != 3)
          .map((user) {
        final name = user['name'].toString();
        final isDoctor = SessionManager.instance.isRoleDoctor(name);
        return {
          'id': user['id'].toString(),
          'name': name,
          'identification': user['identification'].toString(),
          'isDoctor': isDoctor,
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
