import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? userData;
  final String? error;

  RegisterResponse({
    required this.success,
    required this.message,
    this.userData,
    this.error,
  });
}


class UserServices {
  static const String baseUrl = 'https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api';

  static Future<RegisterResponse> registerUser({
    required String name,
    required String email,
    required String password,
    required int roleId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/storeUser'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role_id': roleId,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return RegisterResponse(
          success: true,
          message: responseData['message'],
          userData: responseData['user'],
        );
      } else {
        String errorMessage = responseData['message'] ?? 'Error en el registro';
        if (responseData['error'] != null) {
          errorMessage = responseData['error'];
        }
        return RegisterResponse(
          success: false,
          message: errorMessage,
          error: errorMessage,
        );
      }
    } catch (e) {
      return RegisterResponse(
        success: false,
        message: 'Error de conexión',
        error: e.toString(),
      );
    }
  }

  static Map<String, String?> validateForm({
    required String name,
    required String email,
    required String password,
    required int? roleId,
  }) {
    Map<String, String?> errors = {};

    if (name.isEmpty) {
      errors['name'] = 'El nombre es obligatorio';
    } else if (name.length < 3) {
      errors['name'] = 'El nombre debe tener al menos 3 caracteres';
    }

    if (email.isEmpty) {
      errors['email'] = 'El correo es obligatorio';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(email)) {
      errors['email'] = 'Por favor ingrese un correo válido';
    }

    if (password.isEmpty) {
      errors['password'] = 'La contraseña es obligatoria';
    } else if (password.length <= 3) {
      errors['password'] = 'La contraseña debe tener al menos 6 caracteres';
    }

    if (roleId == null) {
      errors['role'] = 'Debe seleccionar un rol';
    }

    return errors;
  }
  static Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/deleteUser/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Usuario eliminado exitosamente'
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error al eliminar usuario'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}'
      };
    }
  }

  static Future<Map<String, dynamic>> changePassword(String userId, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resetPassword/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'password': newPassword,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Contraseña actualizada exitosamente'
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error al actualizar contraseña'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}'
      };
    }
  }
}