import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:agenda_app/calendar/toDate/toDateContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../forms/appoinmentForm.dart';
import '../../models/appointmentModel.dart';
import '../../projectStyles/appColors.dart';
import '../../utils/listenerApptm.dart';

class AppointmentScreen extends StatefulWidget {
  final void Function(bool, int?, String, String, bool, String) reachTop;
  final bool isDocLog;
  final DateTime selectedDate;
  final int? expandedIndex;
  final String? firtsIndexTouchHour;
  final String? firtsIndexTouchDate;
  final bool btnToReachTop;
  final String dateLookandFill;


  const AppointmentScreen(
      {super.key,
      required this.selectedDate,
      required this.reachTop,
      required this.expandedIndex,
      required this.isDocLog,
      this.firtsIndexTouchHour,
      this.firtsIndexTouchDate,
      required this.btnToReachTop,
      required this.dateLookandFill});

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> with SingleTickerProviderStateMixin{

  bool isDocLog = false;
  bool _showBlurr = false;
  late Future<List<Appointment>> appointments;
  bool modalReachTop = false;// todo cambio aqui
  final Listenerapptm _listenerapptm = Listenerapptm();
  TextEditingController _timerController = TextEditingController();
  TextEditingController timerControllertoShow = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  String antiqueHour = '';
  String antiqueDate = '';
  bool modifyAppointment = false;
  int? expandedIndex;
  bool isTaped = false;
  String? dateOnly;
  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;
  bool isCalendarShow = false;
  bool isHourCorrect = false;
  bool positionBtnIcon = false;
  int isSelectedHelper = 7;
  String _dateLookandFill = '';
  double offsetX = 0.0;
  int movIndex = 0;
  bool dragStatus = false; //false = start
  bool lockBtn = false;
  bool sendMsg = false;

  DateTime dateToLockBtn = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
      setState(() {
        visibleKeyboard = visible;
      });
    });
  }

  void hideKeyBoard() {
    if (visibleKeyboard) {
      FocusScope.of(context).unfocus();
    }
  }



  double? screenWidth;
  double? screenHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  /*Future<List<Appointment>> fetchAppointments(DateTime selectedDate,
      {int? id}) async {
    String baseUrl =
        'https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api/getAppoinments';
    String baseUrl2 =
        'https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api/getAppoinmentsAssit';
    String url = id != null ? '$baseUrl/$id' : baseUrl2;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey('appointments') && data['appointments'] != null) {
        List<dynamic> appointmentsJson = data['appointments'];

        List<Appointment> allAppointments =
        appointmentsJson.map((json) => Appointment.fromJson(json)).toList();
        return allAppointments.where((appointment) => appointment.appointmentDate != null &&
            appointment.appointmentDate!.year == selectedDate.year &&
            appointment.appointmentDate!.month == selectedDate.month &&
            appointment.appointmentDate!.day == selectedDate.day).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Vefique conexión a internet');
    }
  }

  Future<void> initializeAppointments(DateTime date) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');
      if (userId != null) {
        setState(() {
          appointments = fetchAppointments(date, id: userId);
        });
      } else {
        setState(() {
          appointments = fetchAppointments(date);
        });
      }
    } catch (e) {
      setState(() {
        appointments = Future.error("Error retrieving user ID: $e");
      });
    }
  }*/

  late DateTime dateTime;
  late String formattedTime;
  late DateTime dateTimeToinitModal;

  void handleButtonPress() {
    setState(() {
      _dateLookandFill = dateOnly!;
      positionBtnIcon = !positionBtnIcon;
      modalReachTop = positionBtnIcon;
      widget.reachTop(
        modalReachTop,
        expandedIndex,
        _timerController.text,
        _dateController.text,
        positionBtnIcon,
        _dateLookandFill,
      );
    });
  }


  @override
  void initState() {
    widget.selectedDate.isBefore(dateToLockBtn) ? lockBtn = true : lockBtn = false;
    super.initState();
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
    positionBtnIcon = widget.btnToReachTop;
    isDocLog = widget.isDocLog;
    expandedIndex = widget.expandedIndex;
    isTaped = expandedIndex != null;
    if (widget.dateLookandFill.length > 4) {
      dateOnly = widget.dateLookandFill;
      dateTimeToinitModal = DateTime.parse(dateOnly!);
    } else {
      dateOnly = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
      dateTimeToinitModal = DateTime.parse(dateOnly!);
    }
    //positionBtnIcon ? _showBlurr = widget.showBlurr : null;
  }

  String slideDirection = 'No slide detected';
  int statusAnimation = 0;
  double dragX = 0;
  bool firstStop = false;
  bool isDragginDismisEnd = false;
  bool isDragginDismisStart = false;

  void onSendMsg (bool sendMsg){
    setState(() {
      _showBlurr = true;
      this.sendMsg = true;
    });
    handleButtonPress();
  }

  void changeAptms(){
    _listenerapptm.setChange(
      true,
      dateTimeToinitModal,
      3,
    );
  }

  void onShowBlurrModal(bool showBlurrModal){
    setState(() {
      _showBlurr = showBlurrModal;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timerController.dispose();
    _dateController.dispose();
    timerControllertoShow.dispose();
    keyboardVisibilitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final colorforShadow = Colors.grey.withOpacity(0.5);
    List<BoxShadow> normallyShadow = [
      const BoxShadow(
        color: Colors.black54,
        blurRadius: 3,
        offset: Offset(0, 0),
      ),
      BoxShadow(
        color: Colors.white,
        offset: Offset(0, MediaQuery.of(context).size.width * -0.02),
      ),
      BoxShadow(
        color: Colors.white,
        offset: Offset(MediaQuery.of(context).size.width * -0.02, 0),
      ),
    ];

    List<BoxShadow> normallyShadowLookandFill = [
      BoxShadow(
        color: colorforShadow,
        spreadRadius: 0,
        blurRadius: 0,
        offset: Offset(0, MediaQuery.of(context).size.width * 0.007), // Desplazamiento hacia abajo (sombra inferior)
      ),
    ];

    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.09),
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.035),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            color: AppColors3.whiteColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.08,
                color: AppColors3.whiteColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.12,
                      width: MediaQuery.of(context).size.width * 0.02,
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.width * 0.01),
                      decoration: BoxDecoration(
                        color: AppColors3.whiteColor,
                        border: Border(
                            top: BorderSide(
                                color: AppColors3.greyColor.withOpacity(0.6),
                                width: isSelectedHelper == 0 ? 1.5 : 3.5),
                            bottom: BorderSide(
                                color: AppColors3.greyColor.withOpacity(0.6),
                                width: isSelectedHelper == 0 ? 1.5 : 1.5)),
                        boxShadow: isSelectedHelper == 0
                            ? normallyShadowLookandFill
                            : null,
                      ),
                    ),

                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final itemWidth = constraints.maxWidth / 5;
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              DateTime date = widget.selectedDate.add(Duration(days: index - 2));
                              bool isSelected = dateTimeToinitModal.day == date.day &&
                                      dateTimeToinitModal.month == date.month &&
                                      dateTimeToinitModal.year == date.year;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSelectedHelper = index;
                                    dateTimeToinitModal = date;
                                    dateOnly = DateFormat('yyyy-MM-dd').format(dateTimeToinitModal);
                                    dateTimeToinitModal.isBefore(dateToLockBtn) ? lockBtn = true : lockBtn = false;
                                    dateTimeToinitModal = DateTime.parse(dateOnly!);
                                    //initializeAppointments(dateTimeToinitModal);
                                    expandedIndex = null;
                                    changeAptms();
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).size.width * 0.01),
                                  width: itemWidth,
                                  decoration: BoxDecoration(
                                    color: AppColors3.whiteColor,
                                    borderRadius: BorderRadius.circular(0),
                                    border: index <= 5
                                        ? Border(
                                            left: BorderSide(
                                              color: AppColors3.greyColor.withOpacity(0.6),
                                              width: 1.5,
                                            ),
                                            top: BorderSide(
                                              color: AppColors3.greyColor.withOpacity(0.6),
                                              width: isSelected == true ? 1 : 3.5,
                                            ),
                                            bottom: BorderSide(
                                              color: AppColors3.greyColor.withOpacity(0.6),
                                              width: 1.5,
                                            ),
                                          )
                                        : null,
                                    boxShadow: isSelected
                                        ? normallyShadowLookandFill
                                        : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        DateFormat('EEE', 'es_ES').format(date).toUpperCase(),
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppColors3.primaryColor
                                              : AppColors3.greyColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isSelected
                                              ? MediaQuery.of(context).size.width * 0.057
                                              : MediaQuery.of(context).size.width * 0.038,
                                        ),
                                      ),
                                      Text(
                                        "${date.day}",
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppColors3.primaryColor
                                              : AppColors3.greyColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isSelected
                                              ? MediaQuery.of(context).size.width * 0.051
                                              : MediaQuery.of(context).size.width * 0.036,
                                            ))
                                      ])));
                        });
                  })),
                  Container(
                      height: MediaQuery.of(context).size.height * 0.12,
                      width: MediaQuery.of(context).size.width * 0.02,
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.width * 0.01),
                      decoration: BoxDecoration(
                        color: AppColors3.whiteColor,
                        border: Border(
                          top: BorderSide(
                              color: AppColors3.greyColor.withOpacity(0.6),
                              width: isSelectedHelper == 4 ? 1.5 : 3.5),
                          bottom: BorderSide(
                            width: 1.5,
                            color: AppColors3.greyColor.withOpacity(0.6),
                          ),
                          left: BorderSide(
                            width: 1.5,
                            color: AppColors3.greyColor.withOpacity(0.6),
                          ),
                        ),
                        boxShadow: isSelectedHelper == 4
                            ? normallyShadowLookandFill
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              ///aqui termina el horizontalSelectable de dias
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.03,
              ),
              Expanded(
                child: ToDateContainer(
                  isDocLog: widget.isDocLog,
                reachTop: (
                    bool reachTop,
                    int? expandedIndex,
                    String timerOfTheFstIndexTouched,
                    String dateOfTheFstIndexTouched,
                    bool auxToReachTop,
                    String dateLookandFill) {
                  _timerController.text = timerOfTheFstIndexTouched;
                  _dateController.text = dateOfTheFstIndexTouched;
                  if (reachTop == true) {
                    positionBtnIcon = true;
                    modalReachTop = true;
                    expandedIndex = expandedIndex;
                    widget.reachTop(
                        modalReachTop,
                        expandedIndex,
                        _timerController.text,
                        _dateController.text,
                        positionBtnIcon,
                        _dateLookandFill);
                  }
                },
                dateLookandFill: widget.dateLookandFill,
                selectedDate: widget.selectedDate,
                expandedIndexToCharge: expandedIndex,
                listenerapptm: _listenerapptm,
                  firtsIndexTouchDate: widget.firtsIndexTouchDate,
                  firtsIndexTouchHour: widget.firtsIndexTouchHour,
                  onShowBlurr: onShowBlurrModal,
              ),),


            ///
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors3.primaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.0,
                  ),
                  surfaceTintColor: AppColors3.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(color: lockBtn ? AppColors3.greyColor.withOpacity(0.3) : AppColors3.primaryColor, width: 2),
                  ),
                ),
                onPressed: lockBtn ? null : () {
                  dateOnly = DateFormat('yyyy-MM-dd').format(dateTimeToinitModal);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => AppointmentForm(
                        docLog: isDocLog,
                        dateFromCalendarSchedule: dateOnly,
                      ),
                    ),
                  );
                },
                child: Icon(
                  CupertinoIcons.add,
                  color: AppColors3.whiteColor,
                  size: MediaQuery.of(context).size.width * 0.09,
                ),
              ),
            ],
          ),
        ),
 /*       Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.red,
        ),*/

        Visibility(
          visible: _showBlurr,
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent.withOpacity(0.0),
                ),

          ),
        ),

        ///btn expandir
        Positioned(
          left: MediaQuery.of(context).size.width * 0.445,
          bottom: positionBtnIcon == false
              ? screenWidth! < 370
                  ? MediaQuery.of(context).size.height * 0.467
                  : MediaQuery.of(context).size.height * 0.475 //0.467
              : positionBtnIcon == true
                  ? screenWidth! < 370
                      ? MediaQuery.of(context).size.height * 0.905
                      : MediaQuery.of(context).size.height * 0.912
                  : null,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              handleButtonPress();
              /*setState(() {
                _dateLookandFill = dateOnly!;

                //
                //
                if (positionBtnIcon == false) {
                  positionBtnIcon = true;
                  modalReachTop = true;
                  widget.reachTop(
                      modalReachTop,
                      expandedIndex,
                      _timerController.text,
                      _dateController.text,
                      positionBtnIcon,
                      _dateLookandFill);
                } else {
                  positionBtnIcon = false;
                  modalReachTop = false;
                  widget.reachTop(
                      modalReachTop,
                      expandedIndex,
                      _timerController.text,
                      _dateController.text,
                      positionBtnIcon,
                      _dateLookandFill);
                }
              });*/
            },
            icon: Icon(
              !positionBtnIcon
                  ? CupertinoIcons.chevron_compact_up
                  : CupertinoIcons.chevron_compact_down,
              color: _showBlurr ? AppColors3.greyColor.withOpacity(0.1) : AppColors3.greyColor,
              size: MediaQuery.of(context).size.width * 0.11,
            ),
          ),
        ),
      ]);
  }

  // Método para construir cada opción de Radio
}
