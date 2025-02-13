import 'dart:convert';

import 'package:agenda_app/views/login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../globalVar.dart';
import '../views/admin/admin.dart';
import 'angedaDatabase/databaseService.dart';

class AuthService2 {
  final String baseUrl = 'https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api/login';

  Future<void> authenticate(BuildContext context, String userId, bool docLog, String pin, TextEditingController pinController) async {
    try {
      String jsonBody = json.encode({
        'identification': userId,
        'password': pin,
        'fcm_token': await FirebaseMessaging.instance.getToken(),
      });

      var response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        final dbService = DatabaseService();
        await dbService.saveSession(
            data['token'],
            data['user']['id'],
            data['user']['role'] == 'doctor'
        );

        await dbService.saveUser({
          'id': data['user']['id'],
          'name': data['user']['name'],
          'email': data['user']['email'],
          'identification': data['user']['identification'],
          'role': data['user']['role'],
          'fcm_token': data['user']['fcm_token'],
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token']);
        await prefs.setInt('user_id', data['user']['id']);
        SessionManager.instance.isDoctor = data['user']['role'] == 'doctor';
        SessionManager.instance.Nombre = data['user']['name'];

        SessionManager.instance.userRole = data['user']['role'];

        if(context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(
              builder: (context) => AssistantAdmin(
                docLog: SessionManager.instance.isDoctor,
              ),
            ),
            (Route<dynamic> route) => false,
          );
        }

      } else {
        print("Autenticación fallida: ${response.body}");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          pinController.clear(); // Limpia el campo de PIN en el hilo principal
        });
      }
    } catch (e) {
      print("Authentication Error: $e");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        pinController.clear(); // Limpia el campo de PIN en el hilo principal
      });
    }
  }
}
