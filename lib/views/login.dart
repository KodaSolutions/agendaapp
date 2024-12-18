import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../globalVar.dart';
import '../projectStyles/appColors.dart';
import '../services/angedaDatabase/databaseService.dart';
import '../services/auth_service.dart';
import '../styles/ladingDraw.dart';
import 'admin/admin.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _identificationController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final FocusNode _identificationFocusNode = FocusNode();
  final FocusNode pinFocus = FocusNode();

  late PageController pageController;

  bool showPinEntryScreen = false;
  String userIdentification = '';

  void changePage (int pageToGo){
    pageController.animateToPage(pageToGo, duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }

  void authenticate() async {
    try {
      String jsonBody = json.encode({
        //'identification': widget.userId,
        'password': pinController.text,
        'fcm_token': await FirebaseMessaging.instance.getToken(),
      });

      var response = await http.post(
        Uri.parse('https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        final dbService = DatabaseService();
        await dbService.saveSession(
            data['token'],
            data['user']['id'],
            data['user']['role'] == 'doctor'
        );

        await dbService.saveUser({
          'id': data['user']['id'],
          'name': data['user']['name'],
          'email': data['user']['email'],
          'identification': data['user']['identification'],
          'role': data['user']['role'],
          'fcm_token': data['user']['fcm_token'],
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token']);
        await prefs.setInt('user_id', data['user']['id']);
        print('hola: ${data['user']}');
        SessionManager.instance.isDoctor = data['user']['role'] == 'doctor';
        SessionManager.instance.Nombre = data['user']['name'];

        SessionManager.instance.userRole = data['user']['role'];

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(
              builder: (context) => AssistantAdmin(
                docLog: SessionManager.instance.isDoctor,
              ),
            ),
                (Route<dynamic> route) => false,
          );
        }
      } else {
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.08,
                  bottom: MediaQuery.of(context).size.width * 0.08,
                  left: MediaQuery.of(context).size.width * 0.02,
                ),
                content: Text('Error al iniciar sesión',
                  style: TextStyle(
                      color: AppColors3.whiteColor,
                      fontSize: MediaQuery.of(context).size.width * 0.045),)),
          );
        }
      }
    } catch (e) {
      print("Authentication Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: 0
    );
    // Agregar listener para detectar cambios en el texto
    _identificationController.addListener(_onIdentificationChanged);
  }

  @override
  void dispose() {
    _identificationController.removeListener(_onIdentificationChanged);
    _identificationController.dispose();
    _identificationFocusNode.dispose();
    super.dispose();
  }

  void _onIdentificationChanged() {
    if (_identificationController.text.length == 3) {
      _handleIdentificationSubmit();
    }
  }

  void _handleIdentificationSubmit() {
    if (_identificationController.text.length == 3) {
      setState(() {
        userIdentification = _identificationController.text;
        showPinEntryScreen = true;
      });
      FocusScope.of(context).unfocus(); // Cerrar el teclado
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            const LadingDraw(),
                Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: AnimatedContainer(
                            margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.15),
                            duration: Duration(milliseconds: 300),
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                image: AssetImage('assets/kodaSol/kodaIconOrig.jpg'),
                                fit: BoxFit.contain,
                              ),
                            ),),
                        ),
                        Expanded(
                            child: PageView(
                              controller: pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Ingresar identificador', style: TextStyle(
                                        height: 2.5,
                                        color: AppColors3.whiteColor,
                                        fontSize: MediaQuery.of(context).size.width * 0.055
                                    ),),
                                    Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context).size.width * 0.095,
                                        ),
                                        child: Row(
                                          children: [
                                            Flexible(child: TextField(
                                              controller: _identificationController,
                                              focusNode: _identificationFocusNode,
                                              style: TextStyle(
                                                color: AppColors3.blackColor,
                                                fontSize: MediaQuery.of(context).size.width * 0.05,
                                              ),
                                              decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding: EdgeInsets.symmetric(
                                                  vertical: MediaQuery.of(context).size.width * 0.02,
                                                  horizontal: MediaQuery.of(context).size.width * 0.05,
                                                ),
                                                filled: true,
                                                fillColor: AppColors3.whiteColor,
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(20.0),
                                                  borderSide: const BorderSide(
                                                    color: AppColors3.secundaryColor,
                                                  ),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(20.0),
                                                  borderSide: const BorderSide(
                                                    color: AppColors3.secundaryColor,
                                                  ),
                                                ),
                                                prefixIcon: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: MediaQuery.of(context).size.width * 0.035,
                                                          right: MediaQuery.of(context).size.width * 0.015),
                                                      child: SvgPicture.asset(
                                                        'assets/icons/docVector2.svg',
                                                        color: AppColors3.primaryColor,
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          left: MediaQuery.of(context).size.width * 0.015,
                                                          right: MediaQuery.of(context).size.width * 0.04),
                                                      height: MediaQuery.of(context).size.width * 0.09,
                                                      width: MediaQuery.of(context).size.width * 0.006,
                                                      decoration: BoxDecoration(
                                                        color: AppColors3.primaryColor,
                                                        border: Border.all(width: 0.5, color: AppColors3.primaryColor),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),),
                                            IconButton(onPressed: (){
                                              changePage(1);
                                            }, icon: Icon(Icons.arrow_forward_ios, color: AppColors3.whiteColor,
                                                size: MediaQuery.of(context).size.width * 0.07)),
                                          ],
                                        )
                                    ),
                                  ],
                                ),
                                //
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Ingresar pin', style: TextStyle(
                                        height: 2.5,
                                        color: AppColors3.whiteColor,
                                        fontSize: MediaQuery.of(context).size.width * 0.055
                                    ),),
                                    Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context).size.width * 0.095,
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(onPressed: (){
                                              changePage(0);
                                            }, icon: Icon(Icons.arrow_back_ios, color: AppColors3.whiteColor,
                                                size: MediaQuery.of(context).size.width * 0.07)),
                                            Flexible(child: TextField(
                                              controller: pinController,
                                              focusNode: pinFocus,
                                              style: TextStyle(
                                                color: AppColors3.blackColor,
                                                fontSize: MediaQuery.of(context).size.width * 0.05,
                                              ),
                                              decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding: EdgeInsets.symmetric(
                                                  vertical: MediaQuery.of(context).size.width * 0.02,
                                                  horizontal: MediaQuery.of(context).size.width * 0.05,
                                                ),
                                                filled: true,
                                                fillColor: AppColors3.whiteColor,
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(20.0),
                                                  borderSide: const BorderSide(
                                                    color: AppColors3.secundaryColor,
                                                  ),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(20.0),
                                                  borderSide: const BorderSide(
                                                    color: AppColors3.secundaryColor,
                                                  ),
                                                ),
                                                prefixIcon: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: MediaQuery.of(context).size.width * 0.035,
                                                          right: MediaQuery.of(context).size.width * 0.015),
                                                      child: Icon(Icons.lock,color: AppColors3.primaryColor,
                                                      size: MediaQuery.of(context).size.width * 0.07),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          left: MediaQuery.of(context).size.width * 0.015,
                                                          right: MediaQuery.of(context).size.width * 0.04),
                                                      height: MediaQuery.of(context).size.width * 0.09,
                                                      width: MediaQuery.of(context).size.width * 0.006,
                                                      decoration: BoxDecoration(
                                                        color: AppColors3.primaryColor,
                                                        border: Border.all(width: 0.5, color: AppColors3.primaryColor),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),),
                                            IconButton(onPressed: (){
                                              authenticate();
                                            }, icon: Icon(Icons.check, color: AppColors3.whiteColor,
                                                size: MediaQuery.of(context).size.width * 0.07)),
                                          ],
                                        )
                                    ),
                                  ],
                                )
                              ],
                            )),
                      ],
                    ),
                  ),

            // Pin Entry Screen
            Visibility(
              visible: showPinEntryScreen,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: PinEntryScreen(
                  userId: userIdentification,
                  docLog: true,
                  onCloseScreeen: (closeScreen) {
                    setState(() {
                      if (closeScreen) {
                        showPinEntryScreen = false;
                        _identificationController.clear();
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}