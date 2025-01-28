import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:intl/intl.dart';

import '../../calendar/calendarioScreenCita.dart';
import '../../projectStyles/appColors.dart';
import '../../styles/AppointmentStyles.dart';
import '../../usersConfig/selBoxUser.dart';
import '../timer.dart';

class RescheduleDialog extends StatefulWidget {

  final String? dateFromCalendarSchedule;
  final void Function(
      bool
      ) onShowBlur;

  const RescheduleDialog({super.key, this.dateFromCalendarSchedule, required this.onShowBlur});

  @override
  State<RescheduleDialog> createState() => _RescheduleDialogState();
}

class _RescheduleDialogState extends State<RescheduleDialog> with SingleTickerProviderStateMixin {

  final _dateController = TextEditingController();
  late AnimationController animationController;
  int day = 0;
  int month = 0;
  int year = 0;
  bool isTimerShow = false;
  bool isHourCorrect = false;
  bool showRescheduleDialog = true;
  TextEditingController _timeController = TextEditingController();
  bool _showCalendar = false;
  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;
  late Animation<double> opacidad;
  bool platform = false; //ios False androide True
  bool isLoading = false;
  String? user;
  int? oldIndex;
  bool isUserSel = false;
  String? selectedUserId;

  void _onTimeChoose(bool _isTimerShow, TextEditingController selectedTime,
      int selectedIndexAmPm) {
    setState(() {
      animationController.reverse().then((_){
        isTimerShow = _isTimerShow;
        animationController.reset();
        showRescheduleDialog = true;
      });
      String toCompare = selectedTime.text;
      List<String> timeToCompare = toCompare.split(':');
      int hourToCompareConvert = int.parse(timeToCompare[0]);
      int minuteToCompareConvert = int.parse(timeToCompare[1]);
      DateTime dateTimeNow = DateTime.now();
      DateTime selectedDateT = DateFormat('yyyy-MM-dd').parse(_dateController.text);

      DateTime selectedDateTimeToCompare = DateTime(
          selectedDateT.year,
          selectedDateT.month,
          selectedDateT.day,
          hourToCompareConvert,
          minuteToCompareConvert);

      if (selectedDateT.year == dateTimeNow.year &&
          selectedDateT.month == dateTimeNow.month &&
          selectedDateT.day == dateTimeNow.day &&
          selectedDateTimeToCompare.isBefore(dateTimeNow)) {
        isHourCorrect = false;
        _timeController.text = 'Seleccione hora válida';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.width * 0.08,
              bottom: MediaQuery.of(context).size.width * 0.08,
              left: MediaQuery.of(context).size.width * 0.02,
            ),
            content: Text('No se pueden seleccionar horarios pasados',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.045
              ),),
          ),
        );
      } else {
        isHourCorrect = true;
        String toShow = selectedTime.text;
        DateTime formattedTime24hrs = DateFormat('HH:mm').parse(toShow);
        String formattedTime12hrs = DateFormat('hh:mm a').format(formattedTime24hrs);
        _timeController.text = formattedTime12hrs;
      }
    });
  }

  void _onDateToAppointmentForm(
      String dateToAppointmentForm, bool showCalendar) {
    setState(() {
      animationController.reverse().then((_){
        _showCalendar = showCalendar;
        animationController.reset();
        showRescheduleDialog = true;
      });
      _dateController.text = dateToAppointmentForm;
    });
  }

  void hideKeyBoard() {
    if (visibleKeyboard) {
      FocusScope.of(context).unfocus();
    }
  }

  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
          setState(() {
            visibleKeyboard = visible;
          });
        });
  }

  void onSelUser(String? displayText, String? userId) {
    setState(() {
      user = displayText;
      selectedUserId = userId;
      isUserSel = displayText != null && userId != null;
    });
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    opacidad = Tween(begin: 0.0, end:  1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
    if (widget.dateFromCalendarSchedule != null) {
      _dateController.text = widget.dateFromCalendarSchedule!;
    }
    Platform.isIOS ? platform = true : platform = false;
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
    animationController.addListener((){
      setState(() {
      });
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    keyboardVisibilitySubscription.cancel();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Center(
            child: IntrinsicHeight(
                child: Stack(
                  children: [
                    Visibility(
                      visible: showRescheduleDialog,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.04),
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.015,
                            left: MediaQuery.of(context).size.height * 0.015,
                            right: MediaQuery.of(context).size.height * 0.015
                        ),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: AppColors3.whiteColor,
                        ),
                        child: Column(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: MediaQuery.of(context).size.height * 0.01,
                                          bottom: MediaQuery.of(context).size.height * 0.02
                                      ),
                                      child: Text(
                                        'Reagendar cita',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context).size.width * 0.07,
                                          color: AppColors3.primaryColor,
                                        ),
                                      ),
                                    ),
                                    TitleContainer(
                                      margin: EdgeInsets.zero,
                                      decoration: const BoxDecoration(
                                          color: AppColors3.primaryColor,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10)
                                          )
                                      ),
                                      child: Text('Fecha:',
                                        style: TextStyle(
                                          color: AppColors3.whiteColor,
                                          fontSize: MediaQuery.of(context).size.width * 0.045,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context).size.width * 0.02,
                                      ),
                                      child: FieldsToWrite(
                                        inputdecoration: InputDecoration(
                                          hintText: 'DD/MM/AAAA',
                                          suffixIcon: Icon(
                                            Icons.calendar_today,
                                            color: AppColors3.blackColor,
                                            size: MediaQuery.of(context).size.width * 0.07,
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context).size.width * 0.03),
                                          border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                  bottomRight: Radius.circular(10),
                                                  bottomLeft: Radius.circular(10)
                                              ),
                                              borderSide: BorderSide(
                                                color: AppColors3.primaryColor,
                                                width: 1,
                                              )
                                          ),
                                          enabledBorder: const OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                  bottomRight: Radius.circular(10),
                                                  bottomLeft: Radius.circular(10)
                                              ),
                                              borderSide: BorderSide(
                                                color: AppColors3.primaryColor,
                                                width: 1,
                                              )
                                          ),
                                          focusedBorder: const OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                  bottomRight: Radius.circular(10),
                                                  bottomLeft: Radius.circular(10)
                                              ),
                                              borderSide: BorderSide(
                                                color: AppColors3.primaryColor,
                                                width: 1,
                                              )
                                          ),
                                        ),
                                        eneabled: true,
                                        readOnly: true,
                                        labelText: 'DD/M/AAAA',
                                        controller: _dateController,
                                        onTap: () {
                                          setState(() {
                                            hideKeyBoard();
                                            if(_showCalendar == false){
                                              _showCalendar = true;
                                              animationController.forward();
                                              showRescheduleDialog = false;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    TitleContainer(
                                      margin: EdgeInsets.zero,
                                      decoration: const BoxDecoration(
                                          color: AppColors3.primaryColor,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10)
                                          )
                                      ),
                                      child: Text(
                                        'Hora:',
                                        style: TextStyle(
                                          color: AppColors3.whiteColor,
                                          fontSize: MediaQuery.of(context).size.width * 0.045,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context).size.width * 0.02,
                                      ),
                                      child: FieldsToWrite(
                                        inputdecoration: InputDecoration(
                                          hintText: 'HH:MM',
                                          suffixIcon: Icon(
                                            Icons.access_time,
                                            color: _dateController.text.isNotEmpty
                                                ? AppColors3.blackColor : AppColors3.blackColor.withOpacity(0.3),
                                            size: MediaQuery.of(context).size.width * 0.075,
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context).size.width * 0.03),
                                          border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                  bottomRight: Radius.circular(10),
                                                  bottomLeft: Radius.circular(10)
                                              ),
                                              borderSide: BorderSide(
                                                color: AppColors3.primaryColor,
                                                width: 1,
                                              )
                                          ),
                                          enabledBorder: const OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                  bottomRight: Radius.circular(10),
                                                  bottomLeft: Radius.circular(10)
                                              ),
                                              borderSide: BorderSide(
                                                color: AppColors3.primaryColor,
                                                width: 1,
                                              )
                                          ),
                                          focusedBorder: const OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                  bottomRight: Radius.circular(10),
                                                  bottomLeft: Radius.circular(10)
                                              ),
                                              borderSide: BorderSide(
                                                color: AppColors3.primaryColor,
                                                width: 1,
                                              )
                                          ),
                                        ),
                                        eneabled: _dateController.text.isNotEmpty ? true : false,
                                        labelText: 'HH:MM',
                                        readOnly: true,
                                        controller: _timeController,
                                        onTap: () {
                                          setState(() {
                                            hideKeyBoard();
                                            if (isTimerShow == false) {
                                              isTimerShow = true;
                                              animationController.forward();
                                              showRescheduleDialog = false;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    TitleContainer(
                                      margin: EdgeInsets.zero,
                                      decoration: const BoxDecoration(
                                          color: AppColors3.primaryColor,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10)
                                          )
                                      ),
                                      child: Text(
                                        'Doctor',
                                        style: TextStyle(
                                          color: AppColors3.whiteColor,
                                          fontSize: MediaQuery.of(context).size.width * 0.045,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(
                                          top: MediaQuery.of(context).size.width * 0.0,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                            border: Border(
                                              left: BorderSide(
                                                color: AppColors3.primaryColor,
                                                width: 1,
                                              ),
                                              right: BorderSide(
                                                color: AppColors3.primaryColor,
                                                width: 1,
                                              ),
                                              bottom: BorderSide(
                                                color: AppColors3.primaryColor,
                                                width: 1,
                                              )
                                            )
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: SelBoxUser(onSelUser: onSelUser, requiredRole: 1,),
                                              ),
                                            ],
                                          ),
                                        )
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.005, top: MediaQuery.of(context).size.height * 0.015),
                              child: ElevatedButton(
                                onPressed: () {
                                  _timeController.text.isNotEmpty ? Navigator.of(context).pop(false) : null;
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _timeController.text.isNotEmpty ? AppColors3.primaryColor : null,
                                  splashFactory: InkRipple.splashFactory,
                                  padding: EdgeInsets.symmetric(
                                      vertical: MediaQuery.of(context).size.height * 0.02,
                                      horizontal: MediaQuery.of(context).size.width * 0.15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                child: isLoading ? const CircularProgressIndicator(
                                  color: AppColors3.blackColor,
                                ) : Text(
                                    'Reagendar',
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width * 0.05,
                                      color: _timeController.text.isNotEmpty ? AppColors3.whiteColor : AppColors3.greyColor.withOpacity(0.3),
                                    )),),
                            )
                          ],
                        )
                      ),
                    ),
                    Visibility(
                      visible: showRescheduleDialog,
                      child: Container(
                        alignment: Alignment.topRight,
                        padding: EdgeInsets.only(right: 15),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          icon: const Icon(
                            CupertinoIcons.xmark,
                            color: AppColors3.primaryColor,
                          ),
                        ),
                      ),
                    )
                  ],
                )
            ),
          ),
          Visibility(
            visible: isTimerShow,
            child: AnimatedBuilder(
              animation: animationController,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isTimerShow = false;
                    showRescheduleDialog = true;
                  });
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.04,
                        right: MediaQuery.of(context).size.width * 0.04
                    ),
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TitleContainer(
                          decoration: const BoxDecoration(
                              color: AppColors3.primaryColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10)
                              )
                          ),
                          child: Text(
                            'Hora:',
                            style: TextStyle(
                              color: AppColors3.whiteColor,
                              fontSize:
                              MediaQuery.of(context).size.width * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        FieldsPading(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.025,
                              right: MediaQuery.of(context).size.width * 0.025,
                              bottom: MediaQuery.of(context).size.width * 0.025),
                          child: FieldsToWrite(
                            inputdecoration: InputDecoration(
                              fillColor: AppColors3.whiteColor,
                              filled: true,
                              hintText: 'HH:MM',
                              suffixIcon: const Icon(Icons.access_time),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: MediaQuery.of(context).size.width * 0.03),
                              border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10)
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColors3.primaryColor,
                                    width: 1,
                                  )
                              ),
                              enabledBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10)
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColors3.primaryColor,
                                    width: 1,
                                  )
                              ),
                              focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10)
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColors3.primaryColor,
                                    width: 1,
                                  )
                              ),
                            ),
                            labelText: 'HH:MM',
                            readOnly: true,
                            controller: _timeController,
                            onTap: () {
                              animationController.reverse().then((_){
                                isTimerShow = false;
                                animationController.reset();
                                showRescheduleDialog = true;
                              });},
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.02,
                          ),
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.width * 0.025,
                            top: MediaQuery.of(context).size.width * 0.025,
                            left: MediaQuery.of(context).size.width * 0.02,
                            right: MediaQuery.of(context).size.width * 0.02
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.3,
                          decoration: BoxDecoration(
                            border:
                            Border.all(color: AppColors3.blackColor.withOpacity(0.5), width: 0.5),
                            color: AppColors3.whiteColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TimerFly(
                              hour: _timeController.text == '' ? null : _timeController.text,
                              onTimeChoose: _onTimeChoose),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              builder: (context, timerOp){
                return Opacity(opacity: opacidad.value, child: timerOp);
              },
            ),),
          ///calendario
          Visibility(
              visible: _showCalendar,
              child: AnimatedBuilder(
                animation: animationController,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showCalendar = false;
                      showRescheduleDialog = true;
                    });
                  },
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.04,
                              right: MediaQuery.of(context).size.width * 0.04
                          ),
                          color: Colors.transparent,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TitleContainer(
                                  decoration: const BoxDecoration(
                                      color: AppColors3.primaryColor,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10)
                                      )
                                  ),
                                  margin: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width * 0.03,
                                    right: MediaQuery.of(context).size.width * 0.03,
                                  ),
                                  child: Text(
                                    'Fecha:',
                                    style: TextStyle(
                                      color: AppColors3.whiteColor,
                                      fontSize: MediaQuery.of(context).size.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).size.width * 0.025,
                                    left: MediaQuery.of(context).size.width * 0.03,
                                    right: MediaQuery.of(context).size.width * 0.03,
                                  ),
                                  child: FieldsToWrite(
                                    inputdecoration: InputDecoration(
                                      suffixIcon: const Icon(Icons.calendar_today),
                                      fillColor: AppColors3.whiteColor,
                                      filled: true,
                                      hintText: 'DD/MM/AAAA',
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: MediaQuery.of(context).size.width * 0.03,
                                      ),
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10)
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors3.primaryColor,
                                            width: 1,
                                          )
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10)
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors3.primaryColor,
                                            width: 1,
                                          )
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10)
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors3.primaryColor,
                                            width: 1,
                                          )
                                      ),
                                    ),
                                    readOnly: true,
                                    labelText: 'DD/MM/AAAA',
                                    controller: _dateController,
                                    onTap: () {
                                      animationController.reverse().then((_){
                                        _showCalendar = false;
                                        animationController.reset();
                                        showRescheduleDialog = true;
                                      });
                                    },
                                  ),
                                ),
                                CalendarContainer(
                                  child: CalendarioCita(
                                      onDayToAppointFormSelected: _onDateToAppointmentForm),
                                )
                              ]))),
                ),
                builder: (context, calendarOp){
                  return Opacity(opacity: opacidad.value, child: calendarOp,);
                },
              )),
        ],
      )
    );
  }
}