import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../calendar/calendarSchedule.dart';
import 'package:http/http.dart' as http;
import '../../projectStyles/appColors.dart';
import '../../services/angedaDatabase/databaseService.dart';

Future<List<Appointment2>> fetchAppointmentsByDate(int userId, String date) async {
  List<Appointment2> appointments = [];
  final dbService = DatabaseService();

  try {
    var connectivityResult = await Connectivity().checkConnectivity();
    bool isConnected = connectivityResult != ConnectivityResult.none;

    if(isConnected){
      print('Cargando appointments para ID: $userId en la fecha: $date desde la API');
      final response = await http.get(
        Uri.parse('https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api/getAppointmentsByDate/$userId/$date'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getToken()}',
        },
      );
      if(response.statusCode == 200){
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map<String, dynamic> && jsonResponse['appointments'] is List) {
          appointments = List<Appointment2>.from(
            jsonResponse['appointments']
                .map((appointmentJson) => Appointment2.fromJson(appointmentJson as Map<String, dynamic>)),
          );
          List<Map<String, dynamic>> appointmentsToSave = jsonResponse['appointments']
              .map<Map<String, dynamic>>((appointmentJson) => appointmentJson as Map<String, dynamic>)
              .toList();
          await dbService.insertAppointments(appointmentsToSave);
          print('Datos de appointments sincronizados correctamente');
        }else{
          print('La respuesta no contiene una lista de citas');
        }
      }else{
        print('Error al cargar citas desde la API: ${response.statusCode}');
      }
    }else{
      String formattedDate = formatDate(DateTime.parse(date));
      print('Sin conexión a internet, cargando datos locales de appointments para la fecha: $formattedDate...');
      List<Map<String, dynamic>> localAppointments = await dbService.getAppointmentsByDate(formattedDate);
      appointments = localAppointments.map((appointmentMap) => Appointment2.fromJson(appointmentMap)).toList();
    }
  }catch(e) {
    print('Error al realizar la solicitud o cargar datos locales: $e');
  }

  return appointments;
}
Future<String?> getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt_token');
}
String formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class NotiCards extends StatefulWidget {
  final Appointment2 appointment;
  final Function(double) onCalculateHeightCard;

  const NotiCards({super.key, required this.appointment, required this.onCalculateHeightCard});

  @override
  _NotiCardsState createState() => _NotiCardsState();
}

class _NotiCardsState extends State<NotiCards> {
  late bool isRead;
  final _keyNoti = GlobalKey<FormState>();
  String hour = '';

  Future<void> readNotification(int appointmentId) async {
    const baseUrl =
        'https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api/appointments';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('No token found');
      } else {
        final response = await http.put(
          Uri.parse('$baseUrl/$appointmentId/read'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          setState(() {});
          print('Notificacion marcada como leida');
        } else {
          throw Exception('Error al marcar la notificacion como leida');
        }
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<void> unReadNotification(int appointmentId) async {
    const baseUrl =
        'https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api/appointments';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('No token found');
      } else {
        final response = await http.put(
          Uri.parse('$baseUrl/$appointmentId/unRead'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          setState(() {});
          print('Notificacion marcada como desleida');
        } else {
          throw Exception('Error al marcar la notificacion como desleida');
        }
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  String formatTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }

  bool isToday(DateTime appointmentDate) {
    DateTime now = DateTime.now();
    return appointmentDate.year == now.year &&
        appointmentDate.month == now.month &&
        appointmentDate.day == now.day;
  }

  @override
  void initState() {
    super.initState();
    isRead = widget.appointment.notificationRead!;
    hour = formatTime(widget.appointment.appointmentDate!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCalculateHeightCard(_keyNoti.currentContext!.size!.height);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          key: _keyNoti,
          margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.02),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                    bottom: MediaQuery.of(context).size.height * 0.0025),
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.height * 0.01,
                    right: MediaQuery.of(context).size.height * 0.01),
                decoration: BoxDecoration(
                  color: !isRead
                      ? AppColors3.primaryColor
                      : AppColors3.primaryColor.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¡Cita próxima!',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.055,
                        color: !isRead ? AppColors3.whiteColor : AppColors3.whiteColor,
                      ),
                    ),
                    const Spacer(),
                    Visibility(
                      visible: true,
                      child: Container(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02,
                          vertical: MediaQuery.of(context).size.width * 0.01
                      ),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: AppColors3.whiteColor
                      ),
                      child: Text( widget.appointment.doctorId == 1 ? 'Doctor 1' : 'Doctor 2',
                        style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: isRead ? AppColors3.blackColor.withOpacity(0.3) : AppColors3.blackColor),),
                    ),),
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: isRead == false
                              ? () async {
                                  try {
                                    await readNotification(widget.appointment.id!);
                                    setState(() {
                                      isRead = true;
                                    });
                                  } catch (e) {
                                    print('Error: $e');
                                  }
                                }
                              : () async {
                                  try {
                                    await unReadNotification(
                                        widget.appointment.id!);
                                    setState(() {
                                      isRead = false;
                                    });
                                  } catch (e) {
                                    print('Error: $e');
                                  }
                                },
                          icon: Icon(
                            isRead ? Icons.mark_email_read_outlined : Icons.markunread_mailbox_sharp,
                            color: AppColors3.whiteColor,
                            size: MediaQuery.of(context).size.width * 0.07,
                          ))
                      ])

                    ])),
            Container(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
                decoration: BoxDecoration(
                  color: !isRead
                      ? AppColors3.primaryColor.withOpacity(0.3)
                      : AppColors3.primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                            isToday(widget.appointment.appointmentDate!) ? 'Prepárate para tu cita de hoy.' : 'Prepárate para tu cita de mañana.',
                          style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: !isRead ? AppColors3.blackColor : AppColors3.whiteColor.withOpacity(0.75),
                        ))
                  ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Paciente: ',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            color: !isRead
                                ? AppColors3.blackColor
                                : AppColors3.whiteColor.withOpacity(0.75),
                          ),
                        ),
                        Text(
                          widget.appointment.clientName ?? 'Desconocido',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            color: !isRead
                                ? AppColors3.blackColor
                                : AppColors3.whiteColor.withOpacity(0.75),
                        ))
                  ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Hora: ',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            color: !isRead ? AppColors3.blackColor : AppColors3.whiteColor,
                          ),
                        ),
                        Text(
                          widget.appointment.appointmentDate != null
                              ? hour
                              : 'Desconocido',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: !isRead ? AppColors3.blackColor : AppColors3.whiteColor,
                        ))
                  ])
                ]))
          ]))
    ]);
  }
}
