import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../projectStyles/appColors.dart';
import '../services/getClientsService.dart';
import '../styles/AppointmentStyles.dart';

class AlertForm extends StatefulWidget {
  final bool isDoctorLog;
  const AlertForm({super.key, required this.isDoctorLog});

  @override
  State<AlertForm> createState() => _AlertFormState();
}

class _AlertFormState extends State<AlertForm> with SingleTickerProviderStateMixin {

  late AnimationController animationController;
  late Animation <double> rotate;

  double? screenWidth;
  double? screenHeight;
  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;
  late FocusNode focusNodeClient;
  late FocusNode focusNodeCel;
  late FocusNode focusNodeEmail;
  bool _showdrChooseWidget = false;
  TextEditingController? _drSelected = TextEditingController();
  TextEditingController bodyMessageController = TextEditingController();
  int? doctor_id_body = 0;
  int _optSelected = 0;
  bool isDocLog = false;
  bool drFieldDone = false;
  final DropdownDataManager dropdownDataManager = DropdownDataManager();

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

  void _onAssignedDoctor(
      bool dr1sel,
      bool dr2sel,
      TextEditingController drSelected,
      int optSelected,
      bool showdrChooseWidget) {
    setState(() {
      _drSelected = drSelected;
      if (_drSelected!.text == 'Doctor1') {
        doctor_id_body = 1;
      } else {
        doctor_id_body = 2;
      }
      _optSelected = optSelected;
      _showdrChooseWidget = showdrChooseWidget;
      print('_optSelected $_optSelected');
      animationController.reverse().then((_) {
        animationController.reset();
      });
      //
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }
  Future<void> sendNotification(int id) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      const baseUrl = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/sendNotification/';
      try {
        String? token = prefs.getString('jwt_token');
        final response = await http.post(
          Uri.parse(baseUrl + '$id'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'message': bodyMessageController.text,
          }),
        );
        if(response.statusCode==200){
          setState(() {
            Navigator.of(context).pop(true);
          });
        }else{
          Navigator.of(context).pop(false);
          throw Exception('Error al enviar la notificacion');
        }
    }catch(e){
        print('Error: $e');
    }
}

  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    rotate = Tween(begin: 0.0, end: pi).animate(CurvedAnimation(parent: animationController, curve: const Interval(0.0, 1, curve: Curves.easeInOut )));
    hideKeyBoard();
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
    focusNodeClient = FocusNode();
    focusNodeCel = FocusNode();
    focusNodeEmail = FocusNode();
    super.initState();
    dropdownDataManager.fetchUser();
    isDocLog = widget.isDoctorLog;
  }

  @override
  void dispose() {
    focusNodeClient.dispose();
    focusNodeCel.dispose();
    focusNodeEmail.dispose();
    keyboardVisibilitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child:Stack(
        alignment: visibleKeyboard ? Alignment.topCenter : Alignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(
                top: visibleKeyboard ? 40 : 0,
                left: MediaQuery.of(context).size.width * 0.03,
                right: MediaQuery.of(context).size.width * 0.03,
              ),
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03,
                vertical: MediaQuery.of(context).size.width * 0.03,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('Mandar alerta',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.08,
                            fontWeight: FontWeight.bold,
                            color: AppColors3.primaryColor,
                          ),
                        ),),

                        IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                Navigator.pop(context);
                              });
                            },
                            icon: const Icon(Icons.close, color: AppColors3.primaryColor)
                        ),
                      ],
                    ),
                    Container(
                      //height: visibleKeyboard ? MediaQuery.of(context).size.height * 0.6 : null,
                      child: SingleChildScrollView(
                        physics:  const BouncingScrollPhysics(),
                        child: Column(
                          children: <Widget>[
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  color: Colors.white,
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: Column(
                                      children: [
                                        Container(
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            width: MediaQuery.of(context).size.width,
                                            decoration: const BoxDecoration(
                                              color: AppColors3.primaryColor,
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                            ),
                                            child: Text('Doctor:', style: TextStyle(
                                              color: Colors.white,
                                              fontSize: MediaQuery.of(context).size.width * 0.05,
                                              fontWeight: FontWeight.bold,
                                            ),)
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: MediaQuery.of(context).size.width * 0.02,
                                          ),
                                          child: TextFormField(
                                            controller: _drSelected,
                                            decoration: InputDecoration(
                                                hintText: 'Seleccione una opción...',
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: MediaQuery.of(context).size.width * 0.03,
                                                  vertical: MediaQuery.of(context).size.width * 0.03,
                                                ),
                                              border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  borderSide: const BorderSide(
                                                      color: AppColors3.primaryColor)),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  borderSide: const BorderSide(color: AppColors3.primaryColor)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  borderSide: const BorderSide(color: AppColors3.primaryColor, width: 1.5),),
                                                suffixIcon: AnimatedBuilder(
                                                  animation: animationController,
                                                  child: Icon(
                                                    Icons.arrow_drop_down_circle_outlined,
                                                    size: MediaQuery.of(context).size.width * 0.085,
                                                    color: AppColors3.primaryColor,
                                                  ),
                                                  builder: (context, iconToRotate){
                                                    return Transform.rotate(angle: rotate.value, child:  iconToRotate,);
                                                  },
                                                )
                                            ),
                                            readOnly: true,
                                            onTap: () {
                                              setState(() {
                                                _showdrChooseWidget = _showdrChooseWidget
                                                    ? false
                                                    : true;
                                                _showdrChooseWidget == true ? animationController.forward() : animationController.reverse().then((_){
                                                  animationController.reset();
                                                });
                                              });
                                            },
                                            onEditingComplete: () {
                                              setState(() {
                                                drFieldDone = true;
                                              });
                                            },
                                          ),
                                        ),
                                        AnimatedContainer(duration: const Duration(milliseconds: 85),
                                          margin: EdgeInsets.only(bottom: _showdrChooseWidget ? MediaQuery.of(context).size.width * 0.02 : 0),
                                          height: _showdrChooseWidget ? 94 : 0,
                                          decoration: const BoxDecoration(),
                                          clipBehavior: Clip.hardEdge, // Recort
                                          child: DoctorsMenu(
                                            doctors: [
                                              {"id": 1, "nameDoctor": "Dr. Juan Pérez"},
                                              {"id": 2, "nameDoctor": "Dra. María López"},
                                              {"id": 3, "nameDoctor": "Dr. Carlos Ramírez"},
                                            ],
                                            optSelectedToRecieve: 1,
                                            onAssignedDoctor: (bool isSelected, TextEditingController controller, int option) {
                                              print("Doctor seleccionado: ${controller.text}, opción: $option");
                                            },
                                          ),
                                        ),
                                        Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            width: MediaQuery.of(context).size.width,
                                            decoration: const BoxDecoration(
                                              color: AppColors3.primaryColor,
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                            ),
                                            child: Text('Mensaje:', style: TextStyle(
                                              color: Colors.white,
                                              fontSize: MediaQuery.of(context).size.width * 0.05,
                                              fontWeight: FontWeight.bold,
                                            ),)
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: MediaQuery.of(context).size.width * 0.02,
                                            bottom: MediaQuery.of(context).size.width * 0.06,
                                          ),
                                          child: TextFormField(
                                            maxLines: 3,
                                            controller: bodyMessageController,
                                            decoration: InputDecoration(
                                              hintText: 'Mensaje...',
                                              contentPadding: EdgeInsets.symmetric(
                                                horizontal: MediaQuery.of(context).size.width * 0.03,
                                                vertical: MediaQuery.of(context).size.width * 0.03,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                            ),
                                            onTap: () {
                                              setState(() {
                                              });
                                            },
                                            onEditingComplete: () {
                                              setState(() {
                                              });
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.07),
                                          child: Row(
                                            children: [
                                              Expanded( // Mueve Expanded dentro de Row
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    sendNotification(_optSelected);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.04),
                                                    backgroundColor: Colors.white,
                                                    side: const BorderSide(color: Color(0XFF4F2263), width: 1.5),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                    elevation: 5.0,
                                                    shadowColor: Colors.black54,
                                                  ),
                                                  child: const Text('Mandar Alerta',
                                                    style: TextStyle(
                                                        fontSize: 20
                                                    ),),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )


                                      ],
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    )
                  ]
              ),
            )
          ],
        ),
    );
  }
}
