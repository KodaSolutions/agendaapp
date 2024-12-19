import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../calendar/calendarioScreenCita.dart';
import '../../models/appointmentModel.dart';
import '../../projectStyles/appColors.dart';
import '../../utils/PopUpTabs/deleteAppointment.dart';
import '../../utils/PopUpTabs/saveAppointment.dart';
import '../../utils/listenerApptm.dart';
import '../../utils/listenerSlidable.dart';
import '../../utils/timer.dart';

class ApptmInfo extends StatefulWidget {
  final bool isDocLog;
  final Function(bool) onShowBlurrModal;
  final Listenerapptm? listenerapptm;
  final Listenerslidable? listenerslidable;
  final List<String> timeParts;
  final List<Appointment> filteredAppointments;
  final Appointment appointment;
  final String clientName;
  final String treatmentType;
  final int index;
  final String dateLookandFill;
  final DateTime selectedDate;
  final String? firtsIndexTouchHour;
  final String? firtsIndexTouchDate;
  final int? expandedIndexToCharge;
  final void Function(bool, int?, String, String, bool, String) reachTop;
  final Function (bool, DateTime) initializateApptm;
  const ApptmInfo({super.key, required this.clientName, required this.treatmentType, required this.index, required this.dateLookandFill, required this.reachTop,
    required this.appointment, required this.timeParts, this.firtsIndexTouchHour, this.firtsIndexTouchDate, this.expandedIndexToCharge,
    required this.selectedDate, this.listenerapptm, required this.filteredAppointments, required this.initializateApptm, this.listenerslidable,
    required this.onShowBlurrModal, required this.isDocLog});

  @override
  State<ApptmInfo> createState() => _ApptmInfoState();
}

class _ApptmInfoState extends State<ApptmInfo> {

  late Future<List<Appointment>> appointments;
  late List<Appointment> filteredAppointments;
  List<int> draggedItems = [];
  String _dateLookandFill = '';
  String _dateLookandFillAfterSave = '';
  String? dateOnly;
  String antiqueHour = '';
  String antiqueDate = '';
  late DateTime dateTimeToinitModal;
  bool isHourCorrect = false;
  //
  int? expandedIndex;
  bool isTaped = false;
  late int index;
  late bool modalReachTop;
  int? _oldIndex;
  bool isDragX = false;
  int itemDragX = 0;
  bool positionBtnIcon = false;
  bool _isTimerShow = false;
  bool isCalendarShow = false;
  //
  TextEditingController _timerController = TextEditingController();
  TextEditingController timerControllertoShow = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  //

  void _onDateToAppointmentForm(
      String dateToAppointmentForm, bool showCalendar) {
    setState(() {
      _dateController.text = dateToAppointmentForm;
      isCalendarShow = showCalendar;
    });
  }

  void _onTimeChoose(bool isTimerShow, TextEditingController timerController, int selectedIndexAmPm) {
    setState(() {
      _isTimerShow = isTimerShow;
      _timerController = timerController;

      DateTime now = DateTime.now();
      DateTime selectedDate = DateFormat('yyyy-MM-dd').parse(_dateController.text);
      List<String> timeParts = timerController.text.split(':');
      DateTime selectedDateTime = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, int.parse(timeParts[0]), int.parse(timeParts[1]),
      );
      if (selectedDate.isAtSameMomentAs(now) && selectedDateTime.isBefore(now)) {
        isHourCorrect = false;
        _timerController.text = timerControllertoShow.text = 'Seleccione hora válida';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pueden seleccionar horarios pasados')),
        );
      } else {
        isHourCorrect = true;
        String formattedTime = DateFormat('hh:mm a').format(DateFormat('HH:mm').parse(timerController.text));
        _timerController.text = formattedTime;
      }
    });
  }

  Future<void> refreshAppointments() async {
    setState(() {
      appointments = fetchAppointments(dateTimeToinitModal);
    });
  }

  Future<List<Appointment>> fetchAppointments(DateTime selectedDate,
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
        return allAppointments
            .where((appointment) =>
        appointment.appointmentDate != null &&
            appointment.appointmentDate!.year == selectedDate.year &&
            appointment.appointmentDate!.month == selectedDate.month &&
            appointment.appointmentDate!.day == selectedDate.day)
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Vefique conexión a internet');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    index = widget.index;
    _oldIndex = null;
    expandedIndex = widget.expandedIndexToCharge;
    isTaped = expandedIndex != null;
    if (widget.firtsIndexTouchHour != null) {
      _timerController.text = widget.firtsIndexTouchHour!;
      antiqueHour = widget.firtsIndexTouchHour!;
    }
    if (widget.firtsIndexTouchDate != null) {
      _dateController.text = widget.firtsIndexTouchDate!;
      antiqueDate = widget.firtsIndexTouchDate!;
    }
    if (widget.dateLookandFill.length > 4) {
      dateOnly = widget.dateLookandFill;
      dateTimeToinitModal = DateTime.parse(dateOnly!);
    } else {
      dateOnly = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
      dateTimeToinitModal = DateTime.parse(dateOnly!);
    }
    widget.listenerapptm!.registrarObservador((newValue, newDate, newId){
        if(newValue == true){
          String formattedDate = DateFormat('yyyy-MM-dd').format(newDate);
          _dateLookandFillAfterSave = formattedDate;
        }
    });
    widget.listenerslidable!.registrarObservador((newDragStatus, newDragId){
        if(newDragStatus == true){
            isDragX = newDragStatus;
            itemDragX = newDragId;
            if (!draggedItems.contains(itemDragX)) {
              draggedItems.add(itemDragX);
            }
        }else{
          setState(() {
            isDragX = false;
            draggedItems.remove(newDragId);
          });
        }
    });
    print('widgetIsDocLog3${widget.isDocLog}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (expandedIndex == index) {
              setState(() {
                expandedIndex = null;
                isTaped = false;
              });
            } else {
              setState(() {
                Appointment appointmetsToModify = widget.filteredAppointments[index];
                _timerController.text = DateFormat('HH:mm').format(appointmetsToModify.appointmentDate!);
                DateTime formattedTime24hrs = DateFormat('HH:mm').parse(_timerController.text);
                String formattedTime12hrs = DateFormat('h:mm a').format(formattedTime24hrs);
                _timerController.text = formattedTime12hrs;
                _dateController.text = DateFormat('yyyy-MM-dd').format(appointmetsToModify.appointmentDate!);
                _dateLookandFill = dateOnly!;
                expandedIndex = index;
                isTaped = true;
                modalReachTop = true;
                widget.reachTop(modalReachTop, expandedIndex, _timerController.text, _dateController.text, positionBtnIcon, _dateLookandFill);
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.02,
              vertical: MediaQuery.of(context).size.width * 0.01,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: draggedItems.contains(index) ? const Radius.circular(0) : const Radius.circular(15),
                bottomRight: draggedItems.contains(index) == true ? const Radius.circular(0) : const Radius.circular(15),
                topLeft: const Radius.circular(15),
                bottomLeft: const Radius.circular(15),
              ),
              border: _oldIndex != index ? Border.all(
                color: expandedIndex == index ? AppColors3.primaryColor : !isTaped && expandedIndex != index ? AppColors3.primaryColor : AppColors3.primaryColor.withOpacity(0.3),
                width: 1.5,
              ) : const Border(
                left: BorderSide(color: AppColors3.primaryColor, width: 1.5),
                top: BorderSide(color: AppColors3.primaryColor, width: 1.5),
                bottom: BorderSide(color: AppColors3.primaryColor, width: 1.5),
                right: BorderSide(color: AppColors3.primaryColor, width: 1.5),
              ),
              color: AppColors3.whiteColor,
            ),
            alignment: Alignment.center,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                widget.appointment.doctorId == 1 ? 'Dr 1' : 'Dr 2',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.width * 0.05,
                                  color: expandedIndex == widget.index ? AppColors3.primaryColor : !isTaped && expandedIndex != index ? AppColors3.primaryColor : AppColors3.primaryColor.withOpacity(0.3),
                                ),
                              ),
                              Text(
                                ' ${widget.clientName}',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.05,
                                  color: expandedIndex == index ? AppColors3.blackColor : !isTaped && expandedIndex!= index ? AppColors3.blackColor : AppColors3.primaryColor.withOpacity(0.3),
                                ))]),
                          const Spacer(),
                          Visibility(
                              visible: expandedIndex == index ? true : false,
                              child: Container(
                                  alignment: Alignment.topRight,
                                  color: Colors.transparent,
                                  child: IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        setState(() {
                                          expandedIndex = null;
                                          isTaped = false;
                                        });},
                                      icon: Icon(
                                        CupertinoIcons.minus,
                                        size: MediaQuery.of(context).size.width * 0.09,
                                        color: AppColors3.primaryColor,
                                      ))))]),
                      Text(
                        widget.treatmentType,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          color: expandedIndex == widget.index ? AppColors3.blackColor : !isTaped && expandedIndex != widget.index ? AppColors3.blackColor : AppColors3.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      ///componentes de la segunda card >>>>>>
                      Visibility(
                        visible: expandedIndex == index ? true : false,
                          child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.width * 0.02,
                                bottom: MediaQuery.of(context).size.width * 0.02,
                            ),
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: MediaQuery.of(context).size.width * .026),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: AppColors3.primaryColor,
                                borderRadius: BorderRadius.circular(
                                    10),
                              ),
                              child: const Text(
                                'Fecha:',
                                style: TextStyle(
                                  color: AppColors3.whiteColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: TextFormField(
                                controller: _dateController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: MediaQuery.of(context).size.width * 0.03,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  labelText: 'DD/M/AAAA',
                                  suffixIcon: const Icon(Icons.calendar_today, color: AppColors3.primaryColor,)),
                                readOnly: true,
                                onTap: () {
                                  setState(() {
                                    isCalendarShow == true ? isCalendarShow = false : isCalendarShow = true;
                                  });
                                },
                              ),
                            ),
                          ),
                          AnimatedContainer(duration: const Duration(milliseconds: 105),
                            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                            margin: EdgeInsets.only(bottom: isCalendarShow ? MediaQuery.of(context).size.width * 0.02 : 0),
                            height: isCalendarShow ? 300 : 0,
                            decoration: const BoxDecoration(
                                color: AppColors3.whiteColor
                            ),
                            clipBehavior: Clip.hardEdge, // Recort
                            child: CalendarioCita(onDayToAppointFormSelected: _onDateToAppointmentForm),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: MediaQuery.of(context).size.width * 0.024,),
                            margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.03),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: AppColors3.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Hora:',
                              style: TextStyle(
                                color: AppColors3.whiteColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: TextFormField(
                                  controller: _timerController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: MediaQuery.of(context).size.width * 0.03,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    labelText: 'HH:MM',
                                    suffixIcon: const Icon(
                                        Icons.access_time, color: AppColors3.primaryColor,),
                                  ),
                                  readOnly: true,
                                  onTap: () {
                                    setState(() {
                                      _isTimerShow == false
                                          ? _isTimerShow = true
                                          : _isTimerShow = false;
                                    });
                                  },
                                ),
                              ),
                          AnimatedContainer(duration: const Duration(milliseconds: 85),
                            //padding: const EdgeInsets.only(left: , right: 1, bottom: 10),
                            margin: EdgeInsets.only(
                                bottom: _isTimerShow ? MediaQuery.of(context).size.width * 0.03 : 0,
                                left: MediaQuery.of(context).size.width * 0.01,
                                right: MediaQuery.of(context).size.width * 0.01,
                            ),
                            height: _isTimerShow ? 250 : 0,
                            decoration: const BoxDecoration(
                                color: AppColors3.whiteColor
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: TimerFly(onTimeChoose: _onTimeChoose),
                          ),
                          Visibility(
                              visible: !isCalendarShow && !_isTimerShow,
                              child: Padding(
                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.025,
                                bottom: MediaQuery.of(context).size.width * 0.02,
                                right: MediaQuery.of(context).size.width * 0.025,
                              ),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width * 0.05,
                                      right: MediaQuery.of(context).size.width * 0.02,
                                    ),
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            elevation: 4,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                              side: const BorderSide(color: AppColors3.redDelete, width: 1),
                                            ),
                                            backgroundColor: AppColors3.whiteColor,
                                            surfaceTintColor: AppColors3.whiteColor,
                                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05,
                                            ),
                                          ),
                                          onPressed: () {
                                            widget.onShowBlurrModal(true);
                                            showDeleteAppointmentDialog(
                                                context, widget, widget.appointment.id,
                                                widget.isDocLog,
                                                refreshAppointments).then((_){
                                              widget.onShowBlurrModal(false);
                                            });
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            color: AppColors3.redDelete,
                                            size: MediaQuery.of(context).size.width * 0.085,
                                          ))),
                                    ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            elevation: 4,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                              side: const BorderSide(
                                                  color: AppColors3.primaryColor,
                                                  width: 1),
                                            ),
                                            backgroundColor: AppColors3.primaryColor,
                                            surfaceTintColor: AppColors3.primaryColor,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context).size.width * 0.05,
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              widget.onShowBlurrModal(true);
                                              showDialog(barrierDismissible: false, context: context, builder: (builder) {
                                                return ConfirmationDialog(
                                                  appointment: widget.appointment,
                                                  dateController: _dateController,
                                                  timeController: _timerController,
                                                  fetchAppointments: fetchAppointments,
                                                );
                                              },).then((result) {
                                                if (result == true) {
                                                  widget.onShowBlurrModal(false);
                                                  setState(() {
                                                    modalReachTop = true;
                                                    expandedIndex = null;
                                                    isTaped = false;
                                                    positionBtnIcon = true;
                                                    _dateLookandFill = dateOnly!;
                                                    fetchAppointments(dateTimeToinitModal);
                                                    late DateTime dateSelected = dateTimeToinitModal;
                                                    DateTime date = dateTimeToinitModal;
                                                    dateSelected = date;
                                                    dateOnly = DateFormat('yyyy-MM-dd').format(dateSelected);
                                                    widget.reachTop(
                                                        modalReachTop,
                                                        expandedIndex,
                                                        _timerController.text,
                                                        _dateController.text,
                                                        positionBtnIcon,
                                                        _dateLookandFillAfterSave);
                                                    widget.initializateApptm(true, dateSelected);
                                                  });
                                                } else {
                                                  widget.onShowBlurrModal(false);
                                                  _timerController.text = antiqueHour;
                                                  _dateController.text = antiqueDate;
                                                }
                                              });
                                            });
                                          },
                                          child: Icon(
                                            CupertinoIcons.checkmark,
                                            color: AppColors3.whiteColor,
                                            size: MediaQuery.of(context).size.width * 0.09,
                                          ),
                                        )
                                  ])))
                        ],
                      ))
                      ///componentes de la segunda card
                      //
                    ],
                  ),
                ),
                /// componente de la primera card, cuadro de hora
                Visibility(
                  visible: expandedIndex != index ? true : false,
                  child: Container(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: !isTaped ? AppColors3.primaryColor : AppColors3.primaryColor.withOpacity(0.3), //const Color(0xFFC5B6CD),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: !isTaped ? AppColors3.primaryColor : AppColors3.primaryColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.06,
                          color: AppColors3.whiteColor,
                        ),
                        children: [
                          TextSpan(
                            text: '${widget.timeParts[0]}\n',
                          ),
                          TextSpan(
                            text: widget.timeParts[1],
                            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.045),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                /// componente de la primera card, cuadro de hora
              ],
            ),
          ),
        ),
      ],
    );

  }
}
