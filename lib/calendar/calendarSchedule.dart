import 'dart:convert';
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../calendar/toDate/toDateModal.dart';
import '../projectStyles/appColors.dart';
import '../services/angedaDatabase/databaseService.dart';

class AgendaSchedule extends StatefulWidget {
  final bool docLog;
  final Function(bool) onBlurrModal;
  final void Function(
    bool,
  ) showContentToModify;


  const AgendaSchedule(
      {Key? key, required this.docLog, required this.showContentToModify, required this.onBlurrModal})
      : super(key: key);

  @override
  State<AgendaSchedule> createState() => _AgendaScheduleState();
}

class _AgendaScheduleState extends State<AgendaSchedule> {
  String getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Enero';
      case 2:
        return 'Febrero';
      case 3:
        return 'Marzo';
      case 4:
        return 'Abril';
      case 5:
        return 'Mayo';
      case 6:
        return 'Junio';
      case 7:
        return 'Julio';
      case 8:
        return 'Agosto';
      case 9:
        return 'Septiembre';
      case 10:
        return 'Octubre';
      case 11:
        return 'Noviembre';
      case 12:
        return 'Diciembre';
      default:
        return '';
    }
  }

  CalendarController _calendarController = CalendarController();
  List<Appointment2> _appointments = [];
  int initMonth = 0;
  int? currentMonth = 0;
  int? visibleYear = 0;
  DateTime now = DateTime.now();
  bool docLog = false;
  String _timerOfTheFstIndexTouched = '';
  String _dateOfTheFstIndexTouched = '';
  String _dateLookandFill = '';
  bool showBlurr = false;

  @override
  void initState() {
    super.initState();
    docLog = widget.docLog;
    initMonth = now.month;
    currentMonth = _calendarController.displayDate?.month;
    visibleYear = now.year;
    _loadAppointments();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _calendarController;
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');
      if (userId == null) {
        throw Exception('User ID not found');
      }
      final appointments = await fetchAppointments(userId);
      setState(() {
        _appointments = appointments;
      });
    } catch (e) {
      print('Error loading appointments: $e');
    }
  }

  Future<List<Appointment2>> fetchAppointments(int userId) async {
    List<Appointment2> appointments = [];
    final dbService = DatabaseService();
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;
      if (isConnected) {
        print('Cargando appointments para ID: $userId desde la API');
        final response = await http.get(
          Uri.parse('https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api/getAppoinments/$userId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${await getToken()}',
          },
        );
        if (response.statusCode == 200) {
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
          } else {
            print('La respuesta no contiene una lista de citas.');
          }
        } else {
          print('Error al cargar citas desde la API: ${response.statusCode}');
        }
      } else {
        print('Sin conexión a internet, cargando datos locales de appointments');
        List<Map<String, dynamic>> localAppointments = await dbService.getAppointments();
        appointments = localAppointments.map((appointmentMap) => Appointment2.fromJson(appointmentMap)).toList();
      }
    } catch (e) {
      print('Error al realizar la solicitud o cargar datos locales: $e');
    }

    return appointments;
  }

    ///en duda si debo o no guardar el token, o si hacer global porque se repite
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }


  void _showModaltoDate(BuildContext context, CalendarTapDetails details) {
    widget.onBlurrModal(true);
    showModalBottomSheet(
      backgroundColor: Colors.white,
      isScrollControlled: true,
      showDragHandle: true,
      barrierColor: Colors.black54.withOpacity(0.3),
      context: context,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.95,
      ),
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 350),
        vsync: Scaffold.of(context),
      ),
      builder: (context) {
        return AppointmentScreen(
                  selectedDate: details.date!,
                  firtsIndexTouchHour: _timerOfTheFstIndexTouched,
                  firtsIndexTouchDate: _dateOfTheFstIndexTouched,
                  dateLookandFill: _dateLookandFill);
      },
    ).then((_){
      widget.onBlurrModal(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
           Container(
             margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.width * 0.035),
             decoration: BoxDecoration(
               color: AppColors3.primaryColor,
               borderRadius: BorderRadius.circular(10),
             ),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 IconButton(
                   //padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.07),
                     icon: Icon(
                       CupertinoIcons.back,
                       color: AppColors3.whiteColor,
                       size: MediaQuery.of(context).size.width * 0.094,
                     ),
                     onPressed: () {
                       setState(() {
                         int previousMonth = currentMonth! - 1;
                         int previousYear = visibleYear!;
                         if (previousMonth < 1) {
                           previousMonth = 12;
                           previousYear--;
                         }
                         _calendarController.displayDate =
                             DateTime(previousYear, previousMonth, 1);
                       });

                     },
                 ),
                 Text(
                   currentMonth != null
                       ? '${getMonthName(currentMonth!)} $visibleYear'
                       : '${getMonthName(initMonth)} $visibleYear',
                   textAlign: TextAlign.center,
                   style: TextStyle(
                       fontSize: MediaQuery.of(context).size.width * 0.075,
                       color: AppColors3.whiteColor),
                 ),
           IconButton(
                     icon: Icon(
                       CupertinoIcons.forward,
                       color: AppColors3.whiteColor,
                       size: MediaQuery.of(context).size.width * 0.094,
                     ),
                     onPressed: () {
                       int nextMonth = currentMonth! + 1;
                       int nextYear = visibleYear!;
                       if (nextMonth > 12) {
                         nextMonth = 1;
                         nextYear++;
                       }
                       _calendarController.displayDate =
                           DateTime(nextYear, nextMonth, 1);
                     },
                   ),
               ],
            ),
           ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors3.primaryColorMoreStrong, width: 1.2),
                color: Colors.transparent
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SfCalendar(
                  todayHighlightColor: AppColors3.secundaryColor,
                  showCurrentTimeIndicator: true,
                  headerHeight: 0,
                  firstDayOfWeek: 1,
                  view: CalendarView.month,
                  controller: _calendarController,
                  dataSource: MeetingDataSource(_appointments),
                  monthViewSettings: MonthViewSettings(
                    appointmentDisplayMode: MonthAppointmentDisplayMode.none
                  ),

                  ///modal
                  onTap: (CalendarTapDetails details) {
                    if (details.targetElement == CalendarElement.calendarCell ||
                        details.targetElement == CalendarElement.appointment) {
                      _showModaltoDate(context, details);
                    }
                  },
                  onViewChanged: (ViewChangedDetails details) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      int? visibleMonthController =
                          _calendarController.displayDate?.month;
                      currentMonth = visibleMonthController;
                      int? visibleYearController =
                          _calendarController.displayDate?.year;
                      visibleYear = visibleYearController;
                      setState(() {});
                    });
                  },
                  initialDisplayDate: DateTime.now(),
                  monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                    final bool isToday =
                        details.date.month == DateTime.now().month &&
                            details.date.day == DateTime.now().day &&
                            details.date.year == DateTime.now().year;

                    final bool isInCurrentMonth =
                        details.date.month == currentMonth &&
                            details.date.year == visibleYear;

                    final bool hasEventGral = _appointments.any((Appointment2
                            appointment) =>
                        appointment.appointmentDate != null &&
                        details.date.day == appointment.appointmentDate!.day &&
                        details.date.month == appointment.appointmentDate!.month &&
                        details.date.year == appointment.appointmentDate!.year &&
                    appointment.apptmType == 'Consulta general');

                    int eventCountGral = _appointments.where((appointment) =>
                    appointment.appointmentDate != null &&
                        appointment.appointmentDate!.day == details.date.day &&
                        appointment.appointmentDate!.month == details.date.month &&
                        appointment.appointmentDate!.year == details.date.year &&
                        appointment.apptmType == 'Consulta general').length;

                    final bool hasEventEstetic = _appointments.any((Appointment2 ///esta variable arroja si hay citas
                            appointment) =>
                        appointment.appointmentDate != null &&
                        details.date.day == appointment.appointmentDate!.day &&
                        details.date.month ==
                            appointment.appointmentDate!.month &&
                        details.date.year == appointment.appointmentDate!.year &&
                            appointment.apptmType == 'Estética');

                    final bool hasevent = hasEventGral || hasEventEstetic;

                    int eventCountEstetic = _appointments.where((appointment) => ///esta variable arroja la cantidad de citas que hay
                    appointment.appointmentDate != null &&
                        appointment.appointmentDate!.day == details.date.day &&
                        appointment.appointmentDate!.month == details.date.month &&
                        appointment.appointmentDate!.year == details.date.year &&
                        appointment.apptmType == 'Estética').length; ///el detalle es que todavia no recibie el nuevo campo
                    ///y no se como contarlas entonces devuelve las mismas cantidad que sus variables "semejantes"

                    if (isToday && hasevent) {
                      return Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                          color: AppColors3.blackColor,
                          width: 1.0,
                        ),
                          color: AppColors3.primaryColor,
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                details.date.day.toString(),
                                style: TextStyle(
                                  color: AppColors3.whiteColor,
                                  fontSize: MediaQuery.of(context).size.width * 0.06,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Visibility(
                                    visible: eventCountGral == 0 ? false : true,
                                    child: Container(///general
                                    margin: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).size.width * 0.005,
                                      right: MediaQuery.of(context).size.width * 0.005,
                                    ),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: AppColors3.primaryColor),
                                        color: AppColors3.whiteColor,
                                        //Colors.purple.withOpacity(0.35),
                                        shape: BoxShape.circle),
                                    width: MediaQuery.of(context).size.width * 0.045,
                                    height: MediaQuery.of(context).size.width * 0.045,
                                    child: Center(child: Text('$eventCountGral',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.03,
                                        color: AppColors3.primaryColor,
                                      ),),),
                                  ),),
                                  Visibility(
                                    visible: eventCountEstetic == 0 ? false : true,
                                    child: Container(///cita estetica
                                    margin: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).size.width * 0.005,
                                      right: MediaQuery.of(context).size.width * 0.005,
                                    ),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: isInCurrentMonth ? AppColors3.primaryColor
                                            : AppColors3.primaryColor.withOpacity(0.35)),
                                        color: isInCurrentMonth ? AppColors3.secundaryColor : AppColors3.secundaryColor.withOpacity(0.2),
                                        //Colors.purple.withOpacity(0.35),
                                        shape: BoxShape.circle),
                                    width: MediaQuery.of(context).size.width * 0.045,
                                    height: MediaQuery.of(context).size.width * 0.045,
                                    child: Center(child: Text('$eventCountEstetic',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.03,
                                        color: isInCurrentMonth ? AppColors3.whiteColor : AppColors3.greyColor.withOpacity(0.6),
                                      ),),),
                                  ),),
                                ],
                              ),
                            )
                            /*Container(
                              decoration: BoxDecoration(
                                color: AppColors3.primaryColor,
                                border: Border.all(
                                  color: AppColors3.blackColor,
                                  width: 1.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  details.date.day.toString(),
                                  style: const TextStyle(
                                    color: AppColors3.whiteColor,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),*/
                          ],
                        )
                      );

                    } else if (isToday) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors3.primaryColor),
                          color: AppColors3.whiteColor,
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all( color: AppColors3.primaryColorMoreStrong, width: 2),
                              shape: BoxShape.circle,
                              color: AppColors3.whiteColor
                          ),
                          child: Text(
                            details.date.day.toString(),
                            style: TextStyle(
                              color: AppColors3.primaryColor,
                              fontSize: MediaQuery.of(context).size.width * 0.07,
                            ),
                          ),
                        ),
                      );
                    } else if (hasEventEstetic && hasEventGral) {
                      return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isInCurrentMonth ? AppColors3.primaryColor : AppColors3.primaryColor.withOpacity(0.3),
                            ),
                            color: isInCurrentMonth ? Colors.transparent : AppColors3.greyColor.withOpacity(0.2),
                          ),
                          child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    details.date.day.toString(),
                                    style: TextStyle(
                                      color: isInCurrentMonth ? AppColors3.primaryColor : AppColors3.secundaryColor.withOpacity(0.4),
                                      fontSize: MediaQuery.of(context).size.width * 0.06,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(///general
                                        margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context).size.width * 0.005,
                                          right: MediaQuery.of(context).size.width * 0.005,
                                        ),
                                        decoration: BoxDecoration(
                                            border: Border.all(color: isInCurrentMonth ? AppColors3.primaryColor
                                                : AppColors3.primaryColor.withOpacity(0.35)),
                                            color: isInCurrentMonth ? AppColors3.primaryColor : AppColors3.primaryColor.withOpacity(0.2),
                                            //Colors.purple.withOpacity(0.35),
                                            shape: BoxShape.circle),
                                        width: MediaQuery.of(context).size.width * 0.045,
                                        height: MediaQuery.of(context).size.width * 0.045,
                                        child: Center(child: Text('$eventCountGral',
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context).size.width * 0.03,
                                            color: isInCurrentMonth ? AppColors3.whiteColor : AppColors3.greyColor.withOpacity(0.6),
                                          ),),),
                                      ),
                                      Container(///cita estetica
                                        margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context).size.width * 0.005,
                                          right: MediaQuery.of(context).size.width * 0.005,
                                        ),
                                        decoration: BoxDecoration(
                                            border: Border.all(color: isInCurrentMonth ? AppColors3.primaryColor
                                                : AppColors3.primaryColor.withOpacity(0.35)),
                                            color: isInCurrentMonth ? AppColors3.secundaryColor : AppColors3.secundaryColor.withOpacity(0.2),
                                            //Colors.purple.withOpacity(0.35),
                                            shape: BoxShape.circle),
                                        width: MediaQuery.of(context).size.width * 0.045,
                                        height: MediaQuery.of(context).size.width * 0.045,
                                        child: Center(child: Text('$eventCountEstetic',
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context).size.width * 0.03,
                                            color: isInCurrentMonth ? AppColors3.whiteColor : AppColors3.greyColor.withOpacity(0.6),
                                          ),),),
                                      ),
                                    ],
                                  ),
                                )
                              ]));
                    } else if (hasEventGral) {
                      return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isInCurrentMonth ? AppColors3.primaryColor : AppColors3.primaryColor.withOpacity(0.3),
                            ),
                            color: isInCurrentMonth ? Colors.transparent : AppColors3.greyColor.withOpacity(0.2),
                          ),
                          child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    details.date.day.toString(),
                                    style: TextStyle(
                                      color: isInCurrentMonth ? AppColors3.primaryColor : AppColors3.secundaryColor.withOpacity(0.4),
                                      fontSize: MediaQuery.of(context).size.width * 0.06,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).size.width * 0.005,
                                      right: MediaQuery.of(context).size.width * 0.005,
                                    ),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: isInCurrentMonth ? AppColors3.primaryColor
                                            : AppColors3.primaryColor.withOpacity(0.35)),
                                        color: isInCurrentMonth ? AppColors3.primaryColor : AppColors3.primaryColor.withOpacity(0.2),
                                        //Colors.purple.withOpacity(0.35),
                                        shape: BoxShape.circle),
                                    width: MediaQuery.of(context).size.width * 0.045,
                                    height: MediaQuery.of(context).size.width * 0.045,
                                    child: Center(child: Text('$eventCountGral',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.03,
                                        color: isInCurrentMonth ? AppColors3.whiteColor : AppColors3.greyColor.withOpacity(0.6),
                                      ),),),
                                  ),
                                )
                              ]));
                    } else if (hasEventEstetic) {
                      return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isInCurrentMonth ? AppColors3.primaryColor : AppColors3.primaryColor.withOpacity(0.3),
                            ),
                            color: isInCurrentMonth ? Colors.transparent : AppColors3.greyColor.withOpacity(0.2),
                          ),
                          child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    details.date.day.toString(),
                                    style: TextStyle(
                                      color: isInCurrentMonth ? AppColors3.primaryColor : AppColors3.secundaryColor.withOpacity(0.4),
                                      fontSize: MediaQuery.of(context).size.width * 0.06,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).size.width * 0.005,
                                      right: MediaQuery.of(context).size.width * 0.005,
                                    ),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: isInCurrentMonth ? AppColors3.primaryColor
                                            : AppColors3.primaryColor.withOpacity(0.35)),
                                        color: isInCurrentMonth ? AppColors3.secundaryColor : AppColors3.secundaryColor.withOpacity(0.2),
                                        //Colors.purple.withOpacity(0.35),
                                        shape: BoxShape.circle),
                                    width: MediaQuery.of(context).size.width * 0.045,
                                    height: MediaQuery.of(context).size.width * 0.045,
                                    child: Center(child: Text('$eventCountEstetic',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.03,
                                        color: isInCurrentMonth ? AppColors3.whiteColor : AppColors3.greyColor.withOpacity(0.6),
                                      ),),),
                                  ),
                                )
                              ]));
                    }else {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors3.whiteColor,
                          border: Border.all(
                            color: AppColors3.primaryColor,
                            width: 0.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            details.date.day.toString(),
                            style: TextStyle(
                              color: isInCurrentMonth
                                  ? AppColors3.primaryColor
                                  : AppColors3.secundaryColor.withOpacity(0.4),
                              fontSize: MediaQuery.of(context).size.width * 0.055,
                            ),
                          ),
                        ),
                      );;
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment2> source) {
    appointments = source;
  }
}

class Appointment2 {
  final int? id;
  final bool? is_web;
  final bool? is_approved;
  final int? clientId;
  final int? createdBy;
  final int? doctorId;
  final DateTime? appointmentDate;
  final String? treatmentType;
  final String? paymentMethod;
  final String? status;
  final String? clientName;
  bool? notificationRead;
  final String? apptmType;
  String? contactNumber;

  Appointment2({
    this.id,
    this.is_web,
    this.is_approved,
    this.clientId,
    this.createdBy,
    this.doctorId,
    this.appointmentDate,
    this.treatmentType,
    this.paymentMethod,
    this.status,
    this.clientName,
    this.notificationRead,
    this.apptmType,
    this.contactNumber,
  });

  factory Appointment2.fromJson(Map<String, dynamic> json) {
    return Appointment2(
      id: json['id'] as int?,

      clientId: json['client_id'] as int?,
      createdBy: json['created_by'] as int?,
      doctorId: json['doctor_id'] as int?,
      appointmentDate: json['appointment_date'] != null
          ? DateTime.parse(json['appointment_date'])
          : null,
      treatmentType: json['treatment_type'] as String?,
      paymentMethod: json['payment_method'] as String?,
      status: json['status'] as String?,
      clientName: json['client_name'] as String?,
      notificationRead: json['notification_read'] == 1,
      is_web: json['is_web'] == 0,
      is_approved: json['is_approved'] == null,
      apptmType: json['apptmType'],
      contactNumber: json['contact_number'],
    );
  }
}
