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
  final void Function(
    bool,
  ) showContentToModify;


  const AgendaSchedule(
      {Key? key, required this.docLog, required this.showContentToModify})
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
  bool _VarmodalReachTop = false;
  bool _isTaped = false;
  int? _expandedIndex;
  bool _btnToReachTop = false;
  bool docLog = false;
  bool _showModalCalledscndTime = false;
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


  void _showModaltoDate(
      BuildContext context,
      CalendarTapDetails details,
      bool varmodalReachTop,
      expandedIndex,
      _timerOfTheFstIndexTouched,
      _dateOfTheFstIndexTouched,
      _btnToReachTop,
      _dateLookandFill,
      _showBlurr) {
    showModalBottomSheet(
      backgroundColor: !varmodalReachTop
          ? Colors.transparent
          : Colors.black54.withOpacity(0.3),
      isScrollControlled: varmodalReachTop,
      showDragHandle: false,
      barrierColor: Colors.black54,
      context: context,
      builder: (context) {
        return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: AppointmentScreen(
                  isDocLog: docLog,
                  expandedIndex: _expandedIndex,
                  selectedDate: details.date!,
                  firtsIndexTouchHour: _timerOfTheFstIndexTouched,
                  firtsIndexTouchDate: _dateOfTheFstIndexTouched,
                  btnToReachTop: _btnToReachTop,
                  dateLookandFill: _dateLookandFill,
                  reachTop: (bool reachTop,
                      int? expandedIndex,
                      String timerOfTheFstIndexTouched,
                      String dateOfTheFstIndexTouched,
                      bool auxToReachTop,
                      String dateLookandFill,
                      bool showBlurr, bool sendMsg) {
                    setState(() {
                      if (!varmodalReachTop) {
                        Navigator.pop(context);
                        _timerOfTheFstIndexTouched = timerOfTheFstIndexTouched;
                        _dateOfTheFstIndexTouched = dateOfTheFstIndexTouched;
                        _btnToReachTop = auxToReachTop;
                        varmodalReachTop = true;
                        _expandedIndex = expandedIndex;
                        _showModalCalledscndTime = true;
                        _dateLookandFill = dateLookandFill;
                        this.showBlurr = showBlurr;
                        print('calendarSchedule $showBlurr');
                        _showModaltoDate(
                            context,
                            details,
                            varmodalReachTop,
                            _expandedIndex,
                            _timerOfTheFstIndexTouched,
                            _dateOfTheFstIndexTouched,
                            _btnToReachTop,
                            _dateLookandFill,
                            this.showBlurr);
                      } else {
                        varmodalReachTop = reachTop;
                        if (auxToReachTop == false) {
                          Navigator.pop(context);
                        }
                      }
                    });
                  }, showBlurr: showBlurr),
            ));
      },
    ).then((_) {
      if (_showModalCalledscndTime == true &&
          _expandedIndex != null &&
          varmodalReachTop == true) {
        _expandedIndex = null;
      }
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

                  ///modal
                  onTap: (CalendarTapDetails details) {
                    if (details.targetElement == CalendarElement.calendarCell ||
                        details.targetElement == CalendarElement.appointment) {
                      _VarmodalReachTop = false;
                      _showModaltoDate(context, details, _VarmodalReachTop,
                          null,
                          _timerOfTheFstIndexTouched,
                          _dateOfTheFstIndexTouched,
                          _btnToReachTop,
                          _dateLookandFill,
                          showBlurr);
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

                    final bool hasEvent = _appointments.any((Appointment2
                            appointment) =>
                        appointment.appointmentDate != null &&
                        details.date.day == appointment.appointmentDate!.day &&
                        details.date.month ==
                            appointment.appointmentDate!.month &&
                        details.date.year == appointment.appointmentDate!.year);

                    final bool hasEventDoc1 = _appointments.any(
                        (Appointment2 appointment) =>
                            appointment.appointmentDate != null &&
                            details.date.day ==
                                appointment.appointmentDate!.day &&
                            details.date.month ==
                                appointment.appointmentDate!.month &&
                            details.date.year ==
                                appointment.appointmentDate!.year &&
                            appointment.doctorId == 1);

                    final bool hasEventDoc2 = _appointments.any(
                        (Appointment2 appointment) =>
                            appointment.appointmentDate != null &&
                            details.date.day ==
                                appointment.appointmentDate!.day &&
                            details.date.month ==
                                appointment.appointmentDate!.month &&
                            details.date.year ==
                                appointment.appointmentDate!.year &&
                            appointment.doctorId == 2);

                    if (isToday && hasEvent) {
                      return Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: AppColors3.primaryColor),
                          color: AppColors3.bgColor,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors3.primaryColor,
                            shape: BoxShape.circle,
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
                        ),
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
                    } else {
                      return hasEventDoc1 == true && hasEventDoc2 == false// && isInCurrentMonth == true
                          ? Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors3.primaryColor.withOpacity(0.3),
                                ),
                                color: isInCurrentMonth ? Colors.transparent : AppColors3.secundaryColor
                              ),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      details.date.day.toString(),
                                      style: TextStyle(
                                        color: isInCurrentMonth ? AppColors3.primaryColor : AppColors3.primaryColor.withOpacity(0.9),
                                        fontSize: MediaQuery.of(context).size.width * 0.06,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context).size.width * 0.01),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: isInCurrentMonth ? AppColors3.primaryColor
                                              : AppColors3.primaryColor.withOpacity(0.35)),
                                          color: isInCurrentMonth ? AppColors3.primaryColor : AppColors3.primaryColor.withOpacity(0.35),
                                          //Colors.purple.withOpacity(0.35),
                                          shape: BoxShape.circle),
                                      width: MediaQuery.of(context).size.width * 0.055,
                                      height: MediaQuery.of(context).size.width * 0.055,
                                    )
                                  )
                                ]
                              ))
                          : hasEventDoc1 == false && hasEventDoc2 == true
                              ? Container(
                                  width: null,
                                  height: null,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    //Colors.blue.withOpacity(0.35),
                                    border: Border.all(
                                      color: isInCurrentMonth ? AppColors3.primaryColor.withOpacity(0.5) :
                                      AppColors3.primaryColor.withOpacity(0.35),
                                    ),
                                      color: isInCurrentMonth ? AppColors3.bgColor : AppColors3.bgColor
                                  ),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          details.date.day.toString(),
                                          style: TextStyle(
                                            color: isInCurrentMonth ? AppColors3.primaryColor : AppColors3.secundaryColor.withOpacity(0.9),
                                            fontSize: MediaQuery.of(context).size.width * 0.06,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              bottom: MediaQuery.of(context).size.width * 0.01),
                                          decoration: BoxDecoration(
                                              color: isInCurrentMonth ? AppColors3.blackColor : AppColors3.blackColor.withOpacity(0.2),
                                              shape: BoxShape.circle),
                                          width: MediaQuery.of(context).size.width * 0.055,
                                          height: MediaQuery.of(context).size.width * 0.055,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : hasEventDoc1 && hasEventDoc2
                                  ? Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors3.primaryColor.withOpacity(0.35)),
                                        color: isInCurrentMonth ? Colors.transparent : AppColors3.secundaryColor
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: MediaQuery.of(context).size.width * 0.01),
                                                  decoration: BoxDecoration(
                                                       //const Color(0xFF9C27B0)),
                                                      color: isInCurrentMonth ? AppColors3.blackColor : AppColors3.blackColor.withOpacity(0.2),
                                                      shape: BoxShape.circle),
                                                  width: MediaQuery.of(context).size.width * 0.055,
                                                  height: MediaQuery.of(context).size.width * 0.055,
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: MediaQuery.of(context).size.width * 0.01),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: isInCurrentMonth ? AppColors3.primaryColor : AppColors3.primaryColor.withOpacity(0.3)),//const Color(0xFF8AB6DD),),
                                                      color: isInCurrentMonth ? AppColors3.primaryColor : AppColors3.primaryColor.withOpacity(0.3),
                                                      shape: BoxShape.circle),
                                                  width: MediaQuery.of(context).size.width * 0.055,
                                                  height: MediaQuery.of(context).size.width * 0.055,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ))
                                  : Container(
                                      width: null,
                                      height: null,
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
                                                : AppColors3.secundaryColor.withOpacity(0.75),
                                            fontSize: MediaQuery.of(context).size.width * 0.055,
                                          ),
                                        ),
                                      ),
                                    );}
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
    );
  }
}
