import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../globalVar.dart';
import '../../views/admin/admin.dart';
import '../../views/login.dart';
import 'databaseService.dart';

class DatabaseHelpers {
  final BuildContext context;

  DatabaseHelpers(this.context);

  Future<void> verifyDatabase() async {
    final dbService = DatabaseService();
    await dbService.checkTables();
  }

  Future<void> checkConnectionAndLoginStatus(bool isConnected) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    isConnected = connectivityResult != ConnectivityResult.none;

    if (isConnected) {
      await checkLoginStatus(isConnected);
    } else {
      await loadLocalData();
    }
  }

  Future<void> checkLoginStatus(bool isConnected) async {
    final dbService = DatabaseService();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    await Future.delayed(const Duration(seconds: 2));

    if (token != null) {
      var response = await http.get(
        Uri.parse('https://beauteapp-dd0175830cc2.herokuapp.com/api/user'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!isConnected) {
        final session = await dbService.getSession();
        if (session != null) {
          final user = await dbService.getUser(session['user_id']);
          if (user != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => AssistantAdmin(docLog: session['is_doctor'] == 1),
              ),
            );
          } else {
            goToLogin();
          }
        } else {
          goToLogin();
        }
        return;
      }

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        int userId = data['user']['id'];
        if (isConnected) {
          await syncClientsFromAPI();
          await syncAppointmentsFromAPI(userId);
        }
        SessionManager.instance.isDoctor = (data['user']['id'] == 1 || data['user']['id'] == 2);
        SessionManager.instance.Nombre = data['user']['name'];
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AssistantAdmin(docLog: SessionManager.instance.isDoctor)),
        );
      } else {
        prefs.remove('jwt_token');
        goToLogin();
      }
    } else {
      goToLogin();
    }
  }

  Future<void> loadLocalData() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AssistantAdmin(docLog: SessionManager.instance.isDoctor)),
    );
  }

  Future<void> syncClientsFromAPI() async {
    final dbService = DatabaseService();
    try {
      var response = await http.get(Uri.parse('https://beauteapp-dd0175830cc2.herokuapp.com/api/clientsAll'));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('clients')) {
          List<Map<String, dynamic>> clients = List<Map<String, dynamic>>.from(jsonResponse['clients']);
          await dbService.insertClient(clients);
          print('Datos de clientes sincronizados correctamente');

        } else {
          print('Respuesta inesperada: ${response.body}');
        }
      } else {
        print('Error al sincronizar clientes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al sincronizar clientes: $e');
    }
  }
  Future<void> syncAppointmentsFromAPI(int userId) async {
    final dbService = DatabaseService();
    const baseUrl = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/getAppoinments/';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('No token found');
      }
      print('Cargando appointments para ID: $userId');
      final response = await http.get(
        Uri.parse(baseUrl + '$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if(response.statusCode == 200){
        List<dynamic> data = jsonDecode(response.body)['appointments'];
        List<Map<String, dynamic>> appointments = data.map((json) => json as Map<String, dynamic>).toList();
        await dbService.insertAppointments(appointments);
        print('Datos de appointments sincronizados correctamente');
        print('appt: $appointments');
      }else{
        print('Error al sincronizar appointments: ${response.statusCode}');
      }
    }catch (e){
      print('Error al sincronizar appointments: $e');
    }
  }

  void goToLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Login()));
  }
}
