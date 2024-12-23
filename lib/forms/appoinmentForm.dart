import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:agenda_app/forms/boxSpecies.dart';
import 'package:agenda_app/usersConfig/selBoxUser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../calendar/calendarioScreenCita.dart';
import '../globalVar.dart';
import '../models/clientModel.dart';
import '../projectStyles/appColors.dart';
import '../regEx.dart';
import '../services/getClientsService.dart';
import '../styles/AppointmentStyles.dart';
import '../usersConfig/functions.dart';
import '../utils/PopUpTabs/addNewClientandAppointment.dart';
import '../utils/PopUpTabs/appointmetSuccessfullyCreated.dart';
import '../utils/PopUpTabs/closeAppointmentScreen.dart';
import '../utils/timer.dart';
import 'clientForm.dart';

class AppointmentForm extends StatefulWidget {
  final bool docLog;
  final String? dateFromCalendarSchedule;
  final String? nameClient;
  final int? idScreenInfo;

  const AppointmentForm({
    super.key,
    required this.docLog,
    this.dateFromCalendarSchedule,
    this.nameClient,
    this.idScreenInfo,
  });

  @override
  _AppointmentFormState createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> with SingleTickerProviderStateMixin {

  SelBoxUser selBoxUser = SelBoxUser(onSelUser: (a, b){}, requiredRole: null,);
  late AnimationController animationController;
  late Animation<double> opacidad;
  final GlobalKey<ClientFormState> myWidgetKey = GlobalKey<ClientFormState>();
  final DropdownDataManager dropdownDataManager = DropdownDataManager();
  Client? _selectedClient;
  var _clientTextController = TextEditingController();
  TextEditingController pacienteController = TextEditingController();
  final _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController timerControllertoShow = TextEditingController();
  final treatmentController = TextEditingController();
  FocusNode fieldClientNode = FocusNode();
  FocusNode pacienteNode = FocusNode();
  FocusNode clientNode = FocusNode();
  TextEditingController? _drSelected = TextEditingController();


  bool _showdrChooseWidget = false;
  int day = 0;
  int month = 0;
  int year = 0;
  bool isTimerShow = false;
  bool isDocLog = false;
  bool saveNewClient = false;
  bool _showCalendar = false;
  int _optSelected = 0;
  bool drFieldDone = false;
  bool clientFieldDone = false;
  bool dateFieldDone = false;
  bool timeFieldDone = false;
  bool treatmentFieldDone = false;
  bool? clientInDB;
  int? number;
  bool isHourCorrect = false;
  TextEditingController emailController = TextEditingController();
  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;
  bool _cancelConfirm = false;
  late BuildContext dialogforappointment;
  String nameToCompare = '';
  String? specie;
  bool amPm = false;
  int? doctor_id_body = 0;
  bool platform = false; //ios False androide True
  String toTime = '';
  int? newClientID;
  bool showBlurr = false;
  bool isLoading = false;
  bool isLoadingUsers = false;
  //
  String nameDr1 = 'Doctor1';
  String nameDr2 = 'Doctor2';
  String nameDr3 = 'Doctor3';//etc
  List<Map<String, dynamic>> users = [];
  String? error;
  List<Map<String, dynamic>> doctorUsers = [];

  List<String> usersRoles = [];

  Future<void> getUserRole() async {
      //usersRoles = SessionManager.;
  }
  //late Map<String, dynamic> doctors;


  Future<void> createClient() async {
    try {
      var response = await http.post(
        Uri.parse('https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api/createClient'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _clientTextController.text,
          'number': number,
          'email': emailController.text,
        }),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          newClientID = data['client']['id'];
        });
      } else {
        print('Error al crear cliente: ${response.body}');
      }
    } catch (e) {
      print('Error al enviar datos: $e');
    }
  }

  Future<void> addClientAndSubmitAppointment() async {
    setState(() {
      showBlurr = true;
    });
    bool? confirmed = await showAddClientAndAppointment();
    if (confirmed == true) {
      await createClient();
      if (newClientID != null) {
        submitAppointment();
      } else {
        print('Error: ID del cliente no está disponible.');
      }
    } else {
      return;
    }
  }

  void changeFocus(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }


  Future<bool?> showAddClientAndAppointment() {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          alignment: visibleKeyboard ? Alignment.topCenter : Alignment.center,
          children: [
            Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04),
                    child: AddClientAndAppointment(
                        clientNamefromAppointmetForm: _clientTextController.text,
                        onSendDataToAppointmentForm: _onRecieveDataToAppointmentForm,
                        onConfirm: _onConfirm),
                  )),
          ],
        );
      },
    ).then((value){
      setState(() {
        showBlurr = false;
      });
      return value;
    });
  }

  void _onCancelConfirm(bool cancelConfirm, BuildContext dialogContext) {
    setState(() {
      _cancelConfirm = cancelConfirm;
      dialogforappointment = dialogContext;
    });
  }

  void _onRecieveDataToAppointmentForm(
      String _name, String _email, int celnumber, bool blurr) {
    setState(() {
      _clientTextController.text = _name;
      emailController.text = _email;
      number = celnumber;
      showBlurr = blurr;
    });
  }

  void _onConfirm() {}

  onBackPressed(didPop) {
    if (!didPop) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (builder) {
          return AlertCloseAppointmentScreen(
            onCancelConfirm: _onCancelConfirm,
          );
        },
      ).then((_) {
        if (_cancelConfirm == true) {
          if (_cancelConfirm) {
            Navigator.of(context).pop();
          }
        }
      });
      return;
    }
  }

  void _onAssignedDoctor(bool isSelected, TextEditingController drSelected,
      int optSelected, int idDoc) {
    setState(() {
      _drSelected = drSelected;
      _optSelected = optSelected;
      doctor_id_body = idDoc;
      animationController.reverse().then((_){
        _showdrChooseWidget = !isSelected;
        animationController.reset();
      });
    });
  }

  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
      setState(() {
        visibleKeyboard = visible;
      });
    });
  }

  void _onTimeChoose(bool _isTimerShow, TextEditingController selectedTime,
      int selectedIndexAmPm) {
    setState(() {
      animationController.reverse().then((_){
        isTimerShow = _isTimerShow;
        animationController.reset();
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

  void onPet (String? pet) {
    specie = pet!;
  }

  void _onDateToAppointmentForm(
      String dateToAppointmentForm, bool showCalendar) {
    setState(() {
      animationController.reverse().then((_){
        _showCalendar = showCalendar;
        animationController.reset();
      });
      _dateController.text = dateToAppointmentForm;
    });
  }

  void hideKeyBoard() {
    if (visibleKeyboard) {
      FocusScope.of(context).unfocus();
    }
  }

  void _updateSelectedClient(Client? client) {
    clientFieldDone = true;
    if (client != null) {
      setState(() {
        clientInDB = true;
        _selectedClient = client;
        number = client.number;
      });
    } else if (client == null) {
      setState(() {
        clientInDB = false;
        _selectedClient = Client(
            id: 1,
            name: _clientTextController.text,
            email: '0', //emailController.text,
            number: 0);
      });
    } else {
      return;
    }
  }

  Future<void> loadUserswithRole() async {
    setState(() {
      isLoadingUsers = true;
      error = null;
    });
    try {
      final usersList = await loadUsersWithRoles();
      setState(() {
        users = usersList;
        doctorUsers = usersList
            .where((user) => user['role'] == 1)
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

  Future<void> submitAppointment() async {
    setState(() {
      isLoading = true;

    });
    toTime = _timeController.text;
    DateFormat dateFormat12Hour = DateFormat('hh:mm a');
    DateFormat dateFormat24Hour = DateFormat('HH:mm');
    DateTime dateTime = dateFormat12Hour.parse(toTime);
    String time24HourFormat = dateFormat24Hour.format(dateTime);
    toTime = time24HourFormat;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');
    if (token == null) {
      print("No token found");
      return;
    }

    String url = 'https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api/createAppoinment';
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'is_web' : false,
          'dr_id': doctor_id_body!,
          'client_id': newClientID != null ? newClientID : (widget.nameClient != null ? widget.idScreenInfo : _selectedClient?.id.toString()),
          'pet_name': pacienteController.text,
          'species': specie?.toLowerCase(),
          'date': _dateController.text,
          'time': toTime,
          'treatment': treatmentController.text,
          'name': _clientTextController.text,
          'contact_number': number.toString()
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          setState(() {
            isLoading = false;
            showBlurr = true;
            showDialog(context: context,  barrierDismissible: false, builder: (BuildContext context){
              return Appointmetsuccessfullycreated(docLog: widget.docLog);
            }).then((_){
              setState(() {
                showBlurr = false;
              });
            });
        });
        }
        print('Respuesta del servidor: ${response.body}');
      } else {
        print(
            'Error al crear la cita: StatusCode: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error al enviar los datos: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserswithRole();
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    opacidad = Tween(begin: 0.0, end:  1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
    if (widget.dateFromCalendarSchedule != null) {
      _dateController.text = widget.dateFromCalendarSchedule!;
    }
    Platform.isIOS ? platform = true : platform = false;
    isDocLog = widget.docLog;
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
    dropdownDataManager.fetchUser();
    if (widget.nameClient != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _clientTextController.text = widget.nameClient!;
          clientFieldDone = true;
        });
      });
    }
    animationController.addListener((){
      setState(() {
      });
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    keyboardVisibilitySubscription.cancel();
    _clientTextController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    treatmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: platform,
      onPopInvoked: (didPop) {
        onBackPressed(didPop);
      },
      child: Scaffold(
        backgroundColor: AppColors3.whiteColor,
        body: Form(
          child: Stack(
            children: [
              CustomScrollView(
                physics: visibleKeyboard ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    backgroundColor: AppColors3.whiteColor,
                    pinned: true,
                    leadingWidth: MediaQuery.of(context).size.width,
                    leading: Container(
                        margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.width * 0.02),
                        decoration: const BoxDecoration(color: Colors.transparent),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(
                                        CupertinoIcons.back,
                                        size: MediaQuery.of(context).size.width * 0.08,
                                        color: AppColors3.primaryColor,
                                      ),
                                    ),
                                    Text(
                                        'Nueva cita',
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width * 0.095,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors3.primaryColor,
                                        ))
                                  ])
                            ])),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Visibility(
                            visible: true,
                            child: TitleContainer(
                              child: Text(
                                'Doctor: ',
                                style: TextStyle(
                                  color: AppColors3.whiteColor,
                                  fontSize: MediaQuery.of(context).size.width * 0.045,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: true,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.02,
                                  horizontal: MediaQuery.of(context).size.width * 0.026),
                              child: Stack(
                                children: [
                                  TextFormField(
                                    enabled: isLoadingUsers ? false : true,
                                    controller: _drSelected,
                                    decoration: InputDecoration(
                                      hintText: 'Seleccione una opción...',
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context).size.width * 0.03),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: AppColors3.primaryColor,
                                            width: 1,
                                          )
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: AppColors3.primaryColor,
                                            width: 1,
                                          )
                                      ),
                                      focusedBorder:  OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: AppColors3.primaryColor,
                                            width: 1,
                                          )
                                      ),
                                      suffixIcon: Icon(
                                        Icons.arrow_drop_down_circle_outlined,
                                        size: MediaQuery.of(context).size.width * 0.085,
                                        color: AppColors3.primaryColor,
                                      ),
                                    ),
                                    readOnly: true,
                                    onTap: () {
                                      setState(() {
                                        if(_showdrChooseWidget == false){
                                          _showdrChooseWidget = true;
                                          animationController.forward();
                                        } else{
                                          animationController.reverse().then((_){
                                            _showdrChooseWidget = false;
                                            animationController.reset();
                                          });
                                        }
                                        drFieldDone = true;
                                      },
                                      );
                                    },
                                    onEditingComplete: () {
                                      setState(() {
                                        drFieldDone = true;
                                      });
                                    },
                                  ),
                                  if (isLoadingUsers)
                                    Positioned.fill(
                                      child: Container(
                                        color: Colors.white.withOpacity(0.7), // Fondo semitransparente
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            ),
                          ),
                          TitleContainer(
                            child: Text('Cliente:',
                              style: TextStyle(
                                color: AppColors3.whiteColor,
                                fontSize: MediaQuery.of(context).size.width * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.02,
                                horizontal: MediaQuery.of(context).size.width * 0.026),
                            child: Autocomplete<Client>(
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                if (textEditingValue.text == '') {
                                  return const Iterable<Client>.empty();
                                }
                                return dropdownDataManager.getSuggestions(textEditingValue.text).where((Client client) => client.id != 1);
                                },
                              displayStringForOption: (Client option) => option.name,
                              onSelected: (Client selection) {
                                setState(() {
                                  _clientTextController.text = selection.name;
                                  nameToCompare = selection.name;
                                  _updateSelectedClient(selection);
                                });
                                },
                              fieldViewBuilder: (BuildContext context, fieldTextEditingController /*TextEditingController fieldTextEditingController*/,
                                  FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                                fieldClientNode = fieldFocusNode;
                                _clientTextController = fieldTextEditingController;
                                return FieldsToWrite(
                                  inputFormatters: [
                                    RegEx(type: InputFormatterType.alphanumeric),
                                  ],
                                  eneabled: widget.nameClient == null ? true : false,
                                  textInputAction: TextInputAction.done,
                                  readOnly: false,
                                  labelText: 'Cliente',
                                  suffixIcon: Icon(
                                    CupertinoIcons.person,
                                    color: widget.nameClient != null ? AppColors3.greyColor : AppColors3.primaryColor,
                                    size: MediaQuery.of(context).size.width * 0.075,
                                  ),
                                  controller: widget.nameClient != null ? _clientTextController : fieldTextEditingController,
                                  fillColor: Colors.transparent,
                                  focusNode: fieldFocusNode,
                                  onChanged: (text) {},
                                  onEdComplete: () {
                                    setState(() {
                                      clientFieldDone = true;
                                      nameToCompare == _clientTextController.text ? null : _updateSelectedClient(null);
                                      changeFocus(context, fieldFocusNode, clientNode);
                                    });
                                    },
                                  onTapOutside: (PointerDownEvent tapout) {
                                    setState(() {
                                      _clientTextController.text.isEmpty ? clientFieldDone = false : clientFieldDone = true;
                                      nameToCompare == _clientTextController.text ? null : _updateSelectedClient(null);
                                    });
                                    },
                                );
                                },
                            ),
                          ),
                          TitleContainer(
                            child: Text(
                              'Nombre del paciente: ',
                              style: TextStyle(
                                color: AppColors3.whiteColor,
                                fontSize: MediaQuery.of(context).size.width * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: MediaQuery.of(context).size.width * 0.02,
                                horizontal: MediaQuery.of(context).size.width * 0.026),
                            child: FieldsToWrite(
                              focusNode: pacienteNode,
                              eneabled: drFieldDone && clientFieldDone,
                              labelText: 'Paciente',
                              controller: pacienteController,
                              suffixIcon: Icon(
                                Icons.pets,
                                color: drFieldDone && clientFieldDone && widget.dateFromCalendarSchedule == null
                                    ? AppColors3.primaryColor : isDocLog && clientFieldDone && widget.dateFromCalendarSchedule == null ?
                                AppColors3.primaryColor : AppColors3.primaryColor.withOpacity(0.3),
                                size: MediaQuery.of(context).size.width * 0.07,
                              ), readOnly: false,
                              
                            ),
                          ),
                          TitleContainer(
                            child: Text(
                              'Especie: ',
                              style: TextStyle(
                                color: AppColors3.whiteColor,
                                fontSize: MediaQuery.of(context).size.width * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.width * 0.02,
                      horizontal: MediaQuery.of(context).size.width * 0.026),
                          child: Pet(onPet: onPet),),
                          TitleContainer(
                            child: Text('Fecha:',
                              style: TextStyle(
                                color: AppColors3.whiteColor,
                                fontSize: MediaQuery.of(context).size.width * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: MediaQuery.of(context).size.width * 0.02,
                                horizontal: MediaQuery.of(context).size.width * 0.026),
                            child: FieldsToWrite(
                              eneabled: drFieldDone && clientFieldDone && pacienteController.text.isNotEmpty &&
                                  widget.dateFromCalendarSchedule == null ? true : isDocLog && clientFieldDone &&
                                  widget.dateFromCalendarSchedule == null ? true : false,
                              readOnly: true,
                              labelText: 'DD/M/AAAA',
                              controller: _dateController,
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: drFieldDone && clientFieldDone && widget.dateFromCalendarSchedule == null
                                    ? AppColors3.primaryColor : isDocLog && clientFieldDone && widget.dateFromCalendarSchedule == null ?
                                AppColors3.primaryColor : AppColors3.primaryColor.withOpacity(0.3),
                                size: MediaQuery.of(context).size.width * 0.07,
                              ),
                              onTap: () {
                                setState(() {
                                  _clientTextController.text.isNotEmpty ? drFieldDone = true : null;
                                  hideKeyBoard();
                                  if(_showCalendar == false){
                                    _showCalendar = true;
                                    animationController.forward();
                                  }
                                });
                                },
                            ),
                          ),
                          TitleContainer(
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
                            padding: EdgeInsets.symmetric(
                                vertical: MediaQuery.of(context).size.width * 0.02,
                                horizontal: MediaQuery.of(context).size.width * 0.026),
                            child: FieldsToWrite(
                              eneabled: _dateController.text.isNotEmpty ? true : false,
                              labelText: 'HH:MM',
                              readOnly: true,
                              controller: _timeController,
                              suffixIcon: Icon(
                                Icons.access_time,
                                color: _dateController.text.isNotEmpty
                                    ? AppColors3.primaryColor : AppColors3.primaryColor.withOpacity(0.3),
                                size: MediaQuery.of(context).size.width * 0.075,
                              ),
                              onTap: () {
                                setState(() {
                                  hideKeyBoard();
                                  if (isTimerShow == false) {
                                    isTimerShow = true;
                                    animationController.forward();
                                  }
                                });
                                },
                            ),
                          ),
                          TitleContainer(
                            child: Text(
                              'Tratamiento:',
                              style: TextStyle(
                                color: AppColors3.whiteColor,
                                fontSize:
                                MediaQuery.of(context).size.width *
                                    0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: MediaQuery.of(context).size.width * 0.02,
                                horizontal: MediaQuery.of(context).size.width * 0.026),
                            child: FieldsToWrite(
                              inputFormatters: [
                                RegEx(type: InputFormatterType.alphanumeric),
                              ],
                              suffixIcon: Icon(
                                CupertinoIcons.pencil_ellipsis_rectangle,
                                size: MediaQuery.of(context).size.width *
                                    0.085,
                                color: _timeController.text.isNotEmpty && isHourCorrect ? AppColors3.primaryColor
                                    : AppColors3.primaryColor.withOpacity(0.3),
                              ),
                              eneabled: _timeController.text.isNotEmpty && isHourCorrect ? true : false,
                              labelText: 'Tratamiento',
                              readOnly: false,
                              controller: treatmentController,
                            ),
                          ),
                          Row(
                            children: [
                              Checkbox(
                                checkColor: AppColors3.whiteColor,
                                value: saveNewClient,
                                onChanged: clientInDB == null || clientInDB == true ? null : (bool? value) {
                                  setState(() {
                                    saveNewClient = value ?? false;
                                  });
                                  },
                                fillColor: WidgetStateColor.resolveWith(
                                        (states) {
                                          if (states
                                              .contains(WidgetState.selected)) {
                                            return AppColors3.primaryColor;
                                          } else {
                                            return Colors.transparent;
                                          }
                                        }),
                              ),
                              TextButton(
                                onPressed: clientInDB == null || clientInDB == true
                                    ? null : () {
                                  setState(() {
                                    saveNewClient == false ? saveNewClient = true : saveNewClient = false;
                                  });
                                  },
                                child: Text(
                                  'Agregar nuevo cliente',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.045,
                                    color: clientInDB == null || clientInDB == true
                                        ? AppColors3.primaryColor.withOpacity(0.3)
                                        : AppColors3.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: treatmentController.text.isNotEmpty && !saveNewClient && isHourCorrect && isLoading == false && _clientTextController.text.isNotEmpty
                                ? submitAppointment :  isLoading == false && saveNewClient && treatmentController.text.isNotEmpty && isHourCorrect && _clientTextController.text.isNotEmpty
                                ? addClientAndSubmitAppointment : null,
                            style: ElevatedButton.styleFrom(
                              surfaceTintColor: AppColors3.whiteColor,
                              splashFactory: InkRipple.splashFactory,
                              padding: EdgeInsets.symmetric(
                                  vertical: MediaQuery.of(context).size.height * 0.0225,
                                  horizontal: MediaQuery.of(context).size.width * 0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                side: BorderSide(
                                    color: treatmentController.text.isNotEmpty ? AppColors3.primaryColor : AppColors3.primaryColor.withOpacity(0.3),
                                    width: 2),
                              ),
                            ),
                            child: isLoading ? const CircularProgressIndicator(
                              color: AppColors3.primaryColor,
                            ) : Text(
                                'Crear cita',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.06,
                                  color: AppColors3.primaryColor,
                                )),)
                        ])
                  )
                ],
              ),
              ///timer
                Visibility(
                  visible: isTimerShow,
                  child: AnimatedBuilder(
                    animation: animationController,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          color: AppColors3.blackColor.withOpacity(0.27),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.width * 0.46),
                              TitleContainer(
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
                                child: FieldsToWrite(
                                  fillColor: AppColors3.whiteColor,
                                  labelText: 'HH:MM',
                                  readOnly: true,
                                  controller: _timeController,
                                  suffixIcon: const Icon(Icons.access_time),
                                  onTap: () {
                                    animationController.reverse().then((_){
                                      isTimerShow = false;
                                      animationController.reset();
                                    });},
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: MediaQuery.of(context).size.width * 0.02,
                                ),
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).size.width * 0.025,
                                  left: MediaQuery.of(context).size.width * 0.038,
                                ),
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height * 0.35,
                                decoration: BoxDecoration(
                                  border:
                                  Border.all(color: AppColors3.blackColor.withOpacity(0.5), width: 0.5),
                                  color: AppColors3.whiteColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: TimerFly(onTimeChoose: _onTimeChoose),
                              ),
                            ],
                          ),
                        ),
                      ),
                    builder: (context, timerOp){
                      return Opacity(opacity: opacidad.value, child: timerOp);
                    },
                  ),
                ),
              ///calendario
              Visibility(
                  visible: _showCalendar,
                  child: AnimatedBuilder(
                    animation: animationController,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.022),
                        color: AppColors3.blackColor.withOpacity(0.27),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TitleContainer(
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
                              padding: EdgeInsets.symmetric(
                                  vertical: MediaQuery.of(context).size.width * 0.02,
                                  horizontal: MediaQuery.of(context).size.width * 0.02),
                              child: FieldsToWrite(
                                fillColor: AppColors3.whiteColor,
                                readOnly: true,
                                labelText: 'DD/M/AAAA',
                                controller: _dateController,
                                suffixIcon: const Icon(Icons.calendar_today),
                                onTap: () {
                                    animationController.reverse().then((_){
                                      _showCalendar = false;
                                      animationController.reset();
                                  });
                                },
                              ),
                            ),
                            CalendarContainer(
                              child: CalendarioCita(
                                  onDayToAppointFormSelected: _onDateToAppointmentForm),
                                  )
                                ]))),
                    builder: (context, calendarOp){
                      return Opacity(opacity: opacidad.value, child: calendarOp,);
                    },
                  )),

              ///widgetChooseDr
              Visibility(
                visible: _showdrChooseWidget, // Solo será visible cuando sea true
                child: AnimatedBuilder(
                  animation: animationController,
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        color: AppColors3.blackColor.withOpacity(0.27),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            children: [
                              TitleContainer(
                                margin: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height * 0.12,
                                  left: MediaQuery.of(context).size.width * 0.03,
                                  right: MediaQuery.of(context).size.width * 0.03,
                                ),
                                child: Text(
                                  'Doctor: ',
                                  style: TextStyle(
                                    color: AppColors3.whiteColor,
                                    fontSize: MediaQuery.of(context).size.width * 0.045,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: MediaQuery.of(context).size.width * 0.02,
                                  horizontal: MediaQuery.of(context).size.width * 0.026,
                                ),
                                child: TextFormField(
                                  controller: _drSelected,
                                  decoration: InputDecoration(
                                    fillColor: AppColors3.whiteColor,
                                    filled: true,
                                    hintText: 'Seleccione una opción...',
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: MediaQuery.of(context).size.width * 0.03,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    suffixIcon: Icon(
                                      Icons.arrow_drop_down_circle_outlined,
                                      size: MediaQuery.of(context).size.width * 0.085,
                                      color: AppColors3.primaryColor,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color: AppColors3.primaryColor,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  readOnly: true,
                                  onTap: () {
                                      animationController.reverse().then((_){
                                        _showdrChooseWidget = false;
                                        animationController.reset();
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: MediaQuery.of(context).size.width * 0.025,
                                ),
                                child: DoctorsMenu(
                                  //users.where((user) => user['role'] == 1).map((user)
                                  doctors: doctorUsers,
                                  optSelectedToRecieve: _optSelected,
                                  onAssignedDoctor: _onAssignedDoctor),)
                                ])))),
                    builder: (context, doctorChooseOp){
                    return Opacity(opacity: opacidad.value,child: doctorChooseOp);
                  },)),
              Visibility(
                  visible: showBlurr,
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        color: AppColors3.blackColor.withOpacity(0.27),
                      )),
                ),
            ]))));
  }
}
