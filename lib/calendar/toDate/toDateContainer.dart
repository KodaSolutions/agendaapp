import 'dart:convert';
import 'package:agenda_app/calendar/toDate/toDateApptmInfo.dart';
import 'package:agenda_app/utils/PopUpTabs/sendMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../models/appointmentModel.dart';
import '../../projectStyles/appColors.dart';
import '../../usersConfig/functions.dart';
import '../../utils/PopUpTabs/deleteAppointment.dart';
import '../../utils/listenerApptm.dart';
import '../../utils/listenerSlidable.dart';

class ToDateContainer extends StatefulWidget {
  final Function(bool) onShowBlurr;
  final Function(bool) showIconAdd;
  final Listenerapptm? listenerapptm;
  final String? firtsIndexTouchHour;
  final String? firtsIndexTouchDate;
  final String dateLookandFill;
  final DateTime selectedDate;
  const ToDateContainer({super.key, this.firtsIndexTouchHour, this.firtsIndexTouchDate,
    required this.dateLookandFill, required this.selectedDate, this.listenerapptm, required this.onShowBlurr, required this.showIconAdd});

  @override
  State<ToDateContainer> createState() => _ToDateContainerState();
}

class _ToDateContainerState extends State<ToDateContainer> with TickerProviderStateMixin {
  List<SlidableController> slidableControllers = [];
  final Listenerslidable listenerslidable = Listenerslidable();

  bool isDocLog = false;
  late Future<List<Appointment>> appointments;
  late bool modalReachTop;
  late DateTime dateTimeToinitModal;
  late int index;
  late Appointment appointment;
  String _dateLookandFill = '';

  int? oldIndex;

  //late DateTime selectedDate2;
  final TextEditingController _timerController = TextEditingController();
  TextEditingController timerControllertoShow = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String antiqueHour = '';
  String antiqueDate = '';
  bool _isTimerShow = false;
  bool modifyAppointment = false;
  int? expandedIndex;
  bool isTaped = false;
  String? dateOnly;
  bool visibleKeyboard = false;
  bool isCalendarShow = false;
  bool isHourCorrect = false;
  final int _selectedIndexAmPm = 0;
  bool positionBtnIcon = false;
  int isSelectedHelper = 7;
  double offsetX = 0.0;
  int movIndex = 0;
  bool dragStatus = false; //false = start
  bool isDragX = false;
  int itemDragX = 0;
  int helperModalDeleteClient = 0; //1 para complete, 2 para execute 3 para dismmis
  late List<ExpansionTileController> tileControllers;
  var appointmentsList = [];
  String nameDoctor = '';
  int? newIndexHelper;

  void hideBorderRadius(){
    listenerslidable.setChange(
      isDragX,
      itemDragX,
    );
  }
  void showBorderRadius(){
    listenerslidable.setChange(
      false,
      itemDragX,
    );
  }
  void onShowBlurrModal(bool showBlurr){
    widget.onShowBlurr(showBlurr);
  }

  Future<bool> showSendMsgDialog(BuildContext context, String? clientName, int clientId, String? phone) async {
    return await showDialog<bool>(
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) => SendMsgDialog(phone: phone!, clientName: clientName!, clientId: clientId),//cambiar cuando ya tenga los datos
    ) ?? false;
  }

  void reachTop (bool modalReachTop , int? _expandedIndex, String _timerController, String _dateController, bool positionBtnIcon, String _dateLookandFill){
      expandedIndex = _expandedIndex;
  }
  void _initializateApptm (bool inititializate, DateTime date){
    if(inititializate = true){
        initializeAppointments(date);
    }
  }

  void initializeSlidableControllers(int number) {
    slidableControllers.clear();
    for (int i = 0; i < number; i++) {
      final controller = SlidableController(this);
      controller.animation.addListener(() {
        double dragRatio = controller.ratio;
        switch (controller.animation.status) {
          case AnimationStatus.completed:
            setState(() {
              helperModalDeleteClient = 1;
            });
            break;
          case AnimationStatus.forward:
            setState(() {
              helperModalDeleteClient = 2;
            });
            break;
          case AnimationStatus.dismissed:
            setState(() {
              helperModalDeleteClient = 3;
            });
            break;
          default:
            break;
        }
        if (dragRatio != 0) {
          setState(() {
            isDragX = true;
            itemDragX = i;
            hideBorderRadius();
          });
        } else {
          setState(() {
            itemDragX = i;
            isDragX = false;
            showBorderRadius();
          });
        }
      });
      slidableControllers.add(controller);
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
        appointmentsList = await appointments;
        tileControllers =  List.generate(appointmentsList.length, (_) => ExpansionTileController());
        initializeSlidableControllers(appointmentsList.length);
      } else {
        setState(() {
          appointments = fetchAppointments(date);
        });
        appointmentsList = await appointments;
        tileControllers =  List.generate(appointmentsList.length, (_) => ExpansionTileController());
        initializeSlidableControllers(appointmentsList.length);
      }
    } catch (e) {
      setState(() {
        appointments = Future.error("Error retrieving user ID: $e");
      });
    }
  }
  bool isLoadingUsers = false;
  String? error;
  List<Map<String, dynamic>> doctorUsers = [];
  //
  Future<void> loadUserswithRole() async {
    setState(() {
      isLoadingUsers = true;
      error = null;
    });
    try {
      final usersList = await loadUsersWithRoles();
      setState(() {
        doctorUsers = usersList.where((user) => user['role'] != 2)
            .map((user) => {'id': user['id'], 'name': user['name'], 'role': user['role']})
            .toList();
        isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        isLoadingUsers = false;
        error = e.toString();
      });
    }
  }

  Future<List<Appointment>> fetchAppointments(DateTime selectedDate,
      {int? id}) async {
    String baseUrl = 'https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api/getAppoinments';
    String baseUrl2 = 'https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api/getAppoinmentsAssit';
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
        List<Appointment> allAppointments = appointmentsJson.map((json) => Appointment.fromJson(json)).toList();
        return allAppointments.where((appointment) =>
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

  Future<void> refreshAppointments() async {
    if(mounted){
      setState(() {
        appointments = fetchAppointments(dateTimeToinitModal);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
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
   appointments = fetchAppointments(dateTimeToinitModal);
   initializeAppointments(dateTimeToinitModal);
   widget.listenerapptm!.registrarObservador((newValue, newDate, newId){
     setState(() {
       if(newValue == true){
         initializeAppointments(newDate);
       }
     });
   });
   loadUserswithRole();
  }

  @override
  void dispose() {
    for (var controller in slidableControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
          alignment: Alignment.topCenter,
          color: AppColors3.whiteColor,
          child: FutureBuilder<List<Appointment>>(
              future: appointments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.22),
                    child: Center(child: CircularProgressIndicator(
                        color: AppColors3.primaryColor
                    ))
                  );
                } else if (snapshot.hasError) {
                  return Container(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.22),
                      child: Text(
                      textAlign: TextAlign.center,
                      "Verifica tu conexión a internet para consultar tus citas",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.06
                      ),)
                  ); //${snapshot.error}
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.22),
                    child: Text(
                      textAlign: TextAlign.center,
                      "No tienes citas para este día",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.06
                      ),),
                  );
                } else {
                  List<Appointment> filteredAppointments = snapshot.data!;
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredAppointments.length,
                      itemBuilder: (context, index) {
                        Appointment appointment = filteredAppointments[index];
                        String time = (appointment.appointmentDate != null)
                            ? DateFormat('hh:mm a')
                            .format(appointment.appointmentDate!)
                            : 'Hora desconocida';
                        List<String> timeParts = time.split(' ');
                        ///este gesture detector le pertenece a al container que muesta info y sirve para la animacion de borrar
                        return Container(
                            //color: newIndexHelper == null ? Colors.transparent : newIndexHelper == index ? Colors.transparent : Colors.white.withOpacity(0.3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0,
                              left: MediaQuery.of(context).size.width * 0.02,
                              right: MediaQuery.of(context).size.width * 0.02,
                              bottom: MediaQuery.of(context).size.width * 0.02,
                            ),
                            child: Stack(
                              children: [
                                Slidable(
                                  controller: slidableControllers[index],
                                  key: ValueKey(index),
                                  startActionPane: null,
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    dismissible: DismissiblePane(
                                      confirmDismiss: () async {
                                        if (helperModalDeleteClient == 1) {
                                          widget.onShowBlurr(true);
                                          bool result = await showDeleteAppointmentDialog(
                                            context,
                                            widget,
                                            appointment.id,
                                            refreshAppointments,
                                          );
                                          if (result) {
                                            refreshAppointments;
                                            return true;
                                          } else {
                                            widget.onShowBlurr(false);
                                            slidableControllers[index].close();
                                            return false;
                                          }
                                        } else {
                                          return false;
                                        }
                                      },
                                      onDismissed: () {
                                      },
                                    ),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) async {
                                          widget.onShowBlurr(true);
                                          bool result = await showDeleteAppointmentDialog(
                                            context, widget,
                                            appointment.id,
                                            refreshAppointments,
                                          );
                                          if (result) {
                                            widget.onShowBlurr(false);
                                            refreshAppointments();
                                          }else{
                                            widget.onShowBlurr(false);
                                          }
                                        },
                                        backgroundColor: AppColors3.redDelete,
                                        foregroundColor: AppColors3.whiteColor,
                                        icon: Icons.delete,
                                        label: 'Eliminar',
                                      ),
                                      SlidableAction(
                                        onPressed: (context) async {
                                          widget.onShowBlurr(true);
                                          await showSendMsgDialog(
                                            context,
                                            filteredAppointments[index].clientName,
                                            filteredAppointments[index].id!,
                                            filteredAppointments[index].contactNumber,
                                          ).then((_){
                                            widget.onShowBlurr(false);
                                          });
                                          ///aquif
                                        },
                                        backgroundColor: AppColors3.primaryColor,
                                        foregroundColor: AppColors3.whiteColor,
                                        icon: Icons.send,
                                        label: 'Mensajes',
                                      ),
                                    ],
                                  ),
                                  child: ApptmInfo(
                                    doctorUsers: doctorUsers,
                                    tileController: tileControllers[index],
                                    index: index, dateLookandFill: _dateLookandFill,
                                    appointment: appointment, timeParts: timeParts, selectedDate: widget.selectedDate,
                                    firtsIndexTouchHour: widget.firtsIndexTouchHour, firtsIndexTouchDate: widget.firtsIndexTouchDate,
                                    listenerapptm: widget.listenerapptm, filteredAppointments: filteredAppointments,
                                    initializateApptm: _initializateApptm, listenerslidable: listenerslidable,
                                    onShowBlurrModal: onShowBlurrModal,
                                    oldIndex: oldIndex,
                                    onExpansionChanged: (int newIndex, bool edit) {
                                      setState(() {
                                        newIndexHelper = newIndex;
                                      });
                                      if(edit){
                                        setState(() {
                                          newIndexHelper = null;
                                        });
                                      }
                                      if (oldIndex == newIndex) {
                                        widget.showIconAdd(true);
                                      }
                                      for (var controller in tileControllers){
                                        if(controller.isExpanded){
                                          widget.showIconAdd(false);
                                        }
                                      }
                                      setState(() {
                                        if (oldIndex != null && oldIndex != newIndex && !edit) {
                                          tileControllers[oldIndex!].collapse();
                                          newIndexHelper = null;
                                          newIndexHelper = newIndex;
                                        }
                                        oldIndex = newIndex;
                                      });
                                    },
                                  ),
                                ),
                                Visibility(
                                  visible: newIndexHelper == null ? false : newIndexHelper == index ? false : true,
                                  child: Row(
                                  children: [
                                    Expanded(child:
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        color: newIndexHelper == null ? Colors.transparent : AppColors3.whiteColor.withOpacity(0.6),
                                      ),
                                      child: Text('\n\n\n\n', style: TextStyle(
                                        color: AppColors3.whiteColor.withOpacity(0.6),
                                      ),),
                                    ),

                                    ),
                                  ],),),
                              ],
                            ));
                      });
                }
              }))
    );
  }
}
