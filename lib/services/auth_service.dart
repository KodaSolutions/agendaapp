import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import '/globalVar.dart';
import '../views/admin/admin.dart';
import 'angedaDatabase/databaseService.dart';

class PinEntryScreen extends StatefulWidget {
  final String userId; // Changed from int to String
  final bool docLog;
  final void Function(bool) onCloseScreeen;

  const PinEntryScreen({
    super.key,
    required this.userId,
    required this.docLog,
    required this.onCloseScreeen,
  });

  @override
  PinEntryScreenState createState() => PinEntryScreenState();
}

class PinEntryScreenState extends State<PinEntryScreen> with SingleTickerProviderStateMixin {
  late AnimationController aniController;
  late Animation<double> shakeX;
  final textfield = TextEditingController();
  final storage = const FlutterSecureStorage();

  String enteredPin = '';
  bool pinVisible = false;
  int count = 0;
  double? screenWidth;
  double? screenHeight;

  bool isTokenExpired(String token) {
    final decodedToken = JwtClaim.fromMap(json.decode(B64urlEncRfc7515.decodeUtf8(token.split(".")[1])));
    return decodedToken.expiry!.isBefore(DateTime.now());
  }

  //SessionManager.instance.isDoctor = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    print('screenWidth $screenWidth');
  }

  @override
  void initState() {
    super.initState();
    aniController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 20),
    );
    shakeX = Tween(begin: 0.0, end: 10.5).animate(CurvedAnimation(parent: aniController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    aniController.dispose();
    super.dispose();
  }

  void authenticate() async {
    try {
      String jsonBody = json.encode({
        'identification': widget.userId,
        'password': enteredPin,
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
        setState(() {
          aniController.forward();
          aniController.addListener(() {
            if (aniController.status == AnimationStatus.completed) {
              aniController.reverse().then((_) {
                count = count + 1;
                if (count < 7) {
                  aniController.forward();
                } else {
                  setState(() {
                    aniController.stop();
                    aniController.reset();
                    count = 0;
                  });
                }
              });
            }
          });
          enteredPin = '';
        });
      }
    } catch (e) {
      print("Authentication Error: $e");
    }
  }
  Future<void> logout(BuildContext context) async {
    await storage.delete(key: 'jwt_token');
    String? token = await storage.read(key: 'jwt_token');
    if (token != null) {
      var response = await http.post(
        Uri.parse('https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await storage.delete(key: 'jwt_token');
      } else {
        print('Error al cerrar sesión: ${response.body}');
      }
    }

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  Future<void> refreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    if(token != null){
      var response = await http.post(
        Uri.parse('https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api/refresh'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        await prefs.setString('jwt_token', data['token']);
        print("Token actualizado");
      } else {
        print('Error al refrescar el token');
      }
    }
  }
  Future<void> handleToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    if(token != null && isTokenExpired(token)){
      print("Token vencido, refrescando...");
      await refreshToken();
    } else {
      print("El token es válido.");
    }
  }
  Future<bool> isLoggedIn() async {
    String? token = await storage.read(key: 'jwt_token');
    if (token != null && !isTokenExpired(token)) {
      return true;
    }
    return false;
  }


  onNumberTapped(number) {
    setState(() {
      if (enteredPin.length < 4) {
        textfield.text += number;
        enteredPin += number.toString();
        enteredPin.length >= 4 ? authenticate() : null;
      }
    });
  }

  onCancelText() {
    setState(() {
      if (enteredPin.isNotEmpty) {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
        textfield.text = enteredPin;
      }
    });
  }

  Widget inputField() {
    return Container(
      color: const Color(0xFFA0A0A0).withOpacity(0.7),
      height: 100,
      alignment: Alignment.bottomCenter,
      child: TextFormField(
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        controller: textfield,
      ),
    );
  }

  Widget keyField(numK, desc, col, blur) {
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          focusColor: Colors.white,
          splashColor: Colors.white,
          onTap: () => onNumberTapped(numK),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.182,
            height: MediaQuery.of(context).size.width * 0.182,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: col.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        numK,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          inherit: false,
                          fontSize: MediaQuery.of(context).size.width * 0.09,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        textAlign: TextAlign.start,
                        desc,
                        style: TextStyle(
                          inherit: false,
                            fontSize:
                            MediaQuery.of(context).size.width * 0.025,
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget backSpace() {
    return Container(
      margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.07),
      alignment: Alignment.centerRight,
      //mainAxisAlignment: MainAxisAlignment.end,
      child: TextButton(
        onPressed: enteredPin.isNotEmpty
            ? () {
                onCancelText();
              }
            : () {
                widget.onCloseScreeen(true);
              },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        child:
        Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.085),
          child: Text(
            enteredPin.isNotEmpty ? 'Eliminar' : 'Cancelar',
            style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.0475),
          ),
        ),

      ),
    );
  }

  Widget gridView() {
    return Container(
        padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.16,
            right: MediaQuery.of(context).size.width * 0.16,
            top: MediaQuery.of(context).size.width * 0.03),
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: MediaQuery.of(context).size.width * 0.06,
          mainAxisSpacing: MediaQuery.of(context).size.width * 0.06,
          crossAxisCount: 3,
          shrinkWrap: true,
          children: [
            keyField('1', '', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            keyField(
                '2', 'A B C', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            keyField(
                '3', 'D E F', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            keyField(
                '4', 'G H I', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            keyField(
                '5', 'J K L', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            keyField(
                '6', 'M N O', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            keyField(
                '7', 'P Q R S', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            keyField(
                '8', 'T U V', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            keyField(
                '9', 'W X Y Z', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            /*    keyField('', '', Colors.transparent, 0.0),
            keyField('0', 'X Y Z', const Color(0xFFA0A0A0).withOpacity(0.2),7.0),
            keyField('', '', Colors.transparent, 0.0),*/
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111111).withOpacity(0.7),
            ),
            child: Column(
              children: [
                //inputField(),
                Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.15,
                ),
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      aniController.status == AnimationStatus.forward ? 'Pin Incorrecto' : aniController.status == AnimationStatus.completed ? 'Ingrese Pin' : 'Ingrese el pin',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.065,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              ///codigo para el pin
              Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.04,
                    top: MediaQuery.of(context).size.height * 0.02,
                  ),
                  child: AnimatedBuilder(
                      animation: aniController,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          4,
                          (index) {
                            return Container(
                              margin: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.height *
                                      0.014,
                                  right: MediaQuery.of(context).size.height *
                                      0.014),
                              width: pinVisible
                                  ? 30
                                  : MediaQuery.of(context).size.width * 0.03,
                              height: pinVisible
                                  ? 40
                                  : MediaQuery.of(context).size.width * 0.03,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border:
                                    Border.all(width: 1.2, color: Colors.white),
                                color: index < enteredPin.length
                                    ? pinVisible
                                        ? Colors.black54
                                        : Colors.white
                                    : Colors.transparent,
                              ),
                              child: pinVisible && index < enteredPin.length
                                  ? Center(
                                      child: Text(
                                      enteredPin[index],
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ))
                                  : null,
                            );
                          },
                        ),
                      ),
                      builder: (context, childToShake) {
                        return Transform.translate(
                          offset: Offset(shakeX.value, 0),
                          child: childToShake,
                        );
                      })),

              ///termina para el pin

                gridView(),
                Padding(
                  padding: EdgeInsets.only(
                    top: screenWidth! < 391 ? MediaQuery.of(context).size.width * 0.0:  MediaQuery.of(context).size.width * 0.055,//0 para iphone
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      keyField('0', '',
                          const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      backSpace(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
  }
}
