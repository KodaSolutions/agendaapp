class SessionManager {
  // Instancia única de la clase
  static final SessionManager _instance = SessionManager._internal();
  // Variable booleana para saber si es doctor o asistente
  bool isDoctor = false;
  String Nombre = '';
  String? userRole;
  String baseURL = 'https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api';
  // Constructor privado
  SessionManager._internal();

  // Método para obtener la instancia
  static SessionManager get instance => _instance;

  bool isRoleDoctor(String name) {
    return name.toLowerCase().contains('doctor');
  }

}
