import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../../forms/appoinmentForm.dart';
import '../../projectStyles/appColors.dart';
import '../../services/clienteService.dart';
import '../../utils/PopUpTabs/deleteClientDialog.dart';
import '../../utils/showToast.dart';
import '../../utils/toastWidget.dart';

class ClientInfo extends StatefulWidget {
  final bool docLog;
  final String name;
  final int phone;
  final String email;
  final int id;

  const ClientInfo({super.key, required this.id, required this.docLog, required this.name, required this.phone, required this.email});

  @override
  State<ClientInfo> createState() => _ClientInfoState();
}

class _ClientInfoState extends State<ClientInfo> {
  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;
  late bool isDocLog;
  String name = '';
  TextEditingController phoneController = TextEditingController();
  TextEditingController phoneControllerToView = TextEditingController();
  TextEditingController emailControllerToView = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool editInfo = false;
  int maxLines = 2;
  bool showBlurr = false;
  late String initials;

  String? oldNameValue;
  String? oldPhone;
  String? oldEmail;

  final storage = const FlutterSecureStorage();
  bool isButtonEnabled = false;

  final ClientService _clientService = ClientService();
  String? errorMessage;
  Map<String, dynamic>? appointmentData;

  Future<void> fetchAppointment() async {
    final data = await _clientService.fetchAppointmentByUser(widget.id);
    setState(() {
      if (data.containsKey('error')) {
        errorMessage = data['error'];
      } else {
        appointmentData = data;
      }
    });
  }
  void updateUserInfo() async {
    final url = Uri.parse('https://beauteapp-dd0175830cc2.herokuapp.com/api/editUserInfo/${widget.id}');
    final token = await storage.read(key: 'jwt_token');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'name': nameController.text,
          'number':phoneController.text,
          'email': emailController.text,
        }),
      );
        if (response.statusCode == 200) {
          showOverlay(
            context,
            const CustomToast(
              message: 'Datos actualizados correctamente',
            ),
          );
          isButtonEnabled = false;
        } else {
          CustomToast(
              message: "Error al actualizar los datos: ${response.body}");
          print("Error al actualizar los datos: ${response.body}");
        }

    } catch (e) {
      CustomToast(message: "Error al hacer la solicitud: $e");
      print("Error al hacer la solicitud: $e");
    }
  }

  Future<void> sendWhatsMsg(
      {required String phone, required String bodymsg}) async {
    if (!await launchUrl(Uri.parse('https://wa.me/$phone?text=$bodymsg'))) {
      throw Exception('No se puede enviar mensaje a $phone');
    }
  }

  Future<void> callNumber({required String phone}) async {
    if (!await launchUrl(Uri.parse("tel://$phone"))) {
      throw Exception('No se puede llamar a $phone');
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

  void hideKeyBoard() {
    if (visibleKeyboard) {
      FocusScope.of(context).unfocus();
    }
  }
  Future<void> deleteClient(int id) async{
    const baseUrl = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/deleteClient/';
    try {
      final response = await http.post(
        Uri.parse(baseUrl + '$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if(response.statusCode == 200){
        print('Cliente eleminado con exito');
      }else{
        print('Response: ${response.body}');
      }
    }catch(e){
      print('Error: $e');
    }
  }

  String getInitials(String name) {
    List<String> nameParts = name.split(' ');
    String firstInitial = nameParts.isNotEmpty ? nameParts[0][0].toUpperCase() : '';
    String secondInitial = nameParts.length > 1 ? nameParts[1][0].toUpperCase() : '';
    return '$firstInitial$secondInitial';
  }

  @override
  void initState() {
    // TODO: implement initState
    keyboardVisibilityController = KeyboardVisibilityController();
    isDocLog = widget.docLog;
    name = widget.name;
    initials = getInitials(name);
    nameController.text = widget.name;
    emailController.text = widget.email;
    phoneController.text = widget.phone.toString();
    checkKeyboardVisibility();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
          phoneController.text = '\n${phoneController.text}';
          emailController.text = '\n${emailController.text}';
      });
    });
    fetchAppointment();

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardVisibilitySubscription.cancel();
    phoneController.dispose();
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors3.whiteColor,
      body: Stack(
        children: [Column(
          children: [
            AppBar(
              leadingWidth: !editInfo ? null : 100,
              backgroundColor: AppColors3.primaryColor,
              leading: !editInfo
                  ? IconButton(
                onPressed: () {
                  setState(() {
                    Navigator.of(context).pop();
                  });
                },
                icon: const Icon(
                  CupertinoIcons.back,
                  color: Colors.white,
                ),
              )
                  : TextButton(
                  onPressed: () {
                    setState(() {
                      maxLines = 2;
                      editInfo = false;
                      phoneController.text = '\n${phoneController.text}';
                      emailController.text = '\n${emailController.text}';
                      emailController.text = oldEmail!;
                      nameController.text = oldNameValue!;
                      phoneController.text = oldPhone!;
                    });
                  },
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.045),
                  )),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: editInfo == false
                          ? () {
                        setState(() {
                          editInfo = true;
                          oldEmail = emailController.text;
                          oldNameValue = nameController.text;
                          oldPhone = phoneController.text;
                          maxLines = 1;
                          phoneController.text = phoneController.text.trim();
                          emailController.text = emailController.text.trim();
                        });
                      }
                          : () {
                        setState(() {
                          maxLines = 2;
                          editInfo = false;
                          phoneController.text = '\n${phoneController.text}';
                          emailController.text = '\n${emailController.text}';
                          oldPhone == phoneController.text && oldEmail == emailController.text && oldNameValue == nameController.text ?
                          null : updateUserInfo();
                        });
                      },
                      child: Text(
                        !editInfo ? 'Editar' : 'Guardar',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.045),
                      ),
                    ),
                  ],
                )
              ],
            ),
            Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.035),
              decoration: const BoxDecoration(
                color: AppColors3.primaryColor,
              ),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 420),
                    height: visibleKeyboard ? 0 : 130,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 70,
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: AppColors3.primaryColor,
                            fontSize: !visibleKeyboard ? MediaQuery.of(context).size.width * 0.085 : 0),
                      ),
                    ),
                  ),
                  Row(
                      children: [
                        Expanded(
                            child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: MediaQuery.of(context).size.width * 0.02,
                                  vertical: MediaQuery.of(context).size.width * 0.02,
                                ),
                                decoration: BoxDecoration(
                                  border: !editInfo
                                      ? null
                                      : Border.all(color: AppColors3.primaryColorMoreStrong),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: TextFormField(
                                        readOnly: !editInfo,
                                        textAlign: TextAlign.center,
                                        controller: nameController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.zero,
                                          filled: editInfo,
                                          fillColor:  AppColors3.primaryColorMoreStrong.withOpacity(0.2),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                        ),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context).size.width *
                                              0.065,
                                        )))))
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.11,
                            margin: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.02,
                              vertical: MediaQuery.of(context).size.width * 0.02,
                            ),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color: Colors.white,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                onTap: !editInfo ? () {
                                  setState(() {
                                    setState(() {
                                      String phoneCode = '+52${phoneController.text.trim()}';
                                      sendWhatsMsg(phone: phoneCode, bodymsg: 'Hola, $name. Te mando mensaje para reasignar tu cita en Beaute Clinique.\n');
                                    });
                                  });
                                } : null,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(FontAwesomeIcons.whatsapp,
                                      size: MediaQuery.of(context).size.width * 0.12,
                                      color: editInfo ? AppColors3.primaryColorMoreStrong.withOpacity(0.3) : AppColors3.primaryColorMoreStrong,),
                                    Text('Mensaje',
                                      style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.055,
                                        color: editInfo ? AppColors3.primaryColorMoreStrong.withOpacity(0.3) : AppColors3.primaryColorMoreStrong,),),
                                  ],
                                ),
                              ),
                            ),
                          )
                      ),
                      Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.11,
                            margin: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.02,
                              vertical: MediaQuery.of(context).size.width * 0.02,
                            ),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color: Colors.white,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                onTap: !editInfo ? () {
                                  setState(() {
                                    callNumber(phone: phoneController.text);
                                  });
                                }: null,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.call,
                                      size: MediaQuery.of(context).size.width * 0.12,
                                      color: editInfo ? AppColors3.primaryColorMoreStrong.withOpacity(0.3) : AppColors3.primaryColorMoreStrong,),
                                    Text('Llamar',
                                      style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.055,
                                        color: editInfo ? AppColors3.primaryColorMoreStrong.withOpacity(0.3) : AppColors3.primaryColorMoreStrong,),),
                                  ],
                                ),
                              ),
                            ),
                          )
                      ),
                      Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.11,
                            margin: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.02,
                              vertical: MediaQuery.of(context).size.width * 0.02,
                            ),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color: Colors.white,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                onTap: editInfo == false ? () {
                                  setState(() {
                                    Navigator.push(context,
                                      CupertinoPageRoute(
                                        builder: (context) => AppointmentForm(docLog: isDocLog, nameClient: name, idScreenInfo: widget.id,),
                                      ),
                                    );
                                  });
                                } : null,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_card,
                                        size: MediaQuery.of(context).size.width * 0.12,
                                        color: editInfo ? AppColors3.primaryColorMoreStrong.withOpacity(0.3) : AppColors3.primaryColorMoreStrong),
                                    Text('Crear cita',
                                      style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.055,
                                          color: editInfo ? AppColors3.primaryColorMoreStrong.withOpacity(0.3) : AppColors3.primaryColorMoreStrong),),
                                  ],
                                ),
                              ),
                            ),
                          )
                      ),
                    ],
                  )
                ],
              ),
            ),
            Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.04),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03,
                                  vertical: MediaQuery.of(context).size.width * 0.03),
                              padding: EdgeInsets.only(left: editInfo ? 0:  MediaQuery.of(context).size.width * 0.03, top: editInfo ? 0 : MediaQuery.of(context).size.width * 0.03,
                                bottom: editInfo ? 0 : MediaQuery.of(context).size.width * 0.03,),
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  border: editInfo ? null : Border.all(color: AppColors3.primaryColorMoreStrong,)
                              ),
                              child: !editInfo ? RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'No. Celular',
                                      style: TextStyle(color: AppColors3.primaryColorMoreStrong,
                                          fontSize: 22), // Color para "No. Celular"
                                    ),
                                    TextSpan(
                                      text: phoneController.text,
                                      style: TextStyle(color: AppColors3.primaryColorMoreStrong.withOpacity(0.35),
                                          fontSize: 20), // Color para el texto del controlador
                                    ),
                                  ],
                                ),
                              ) : TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                maxLines: maxLines,
                                controller: phoneController,
                                decoration: InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColors3.primaryColorMoreStrong, width: 2.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  //unfocus
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColors3.primaryColorMoreStrong, width: 1.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColors3.primaryColorMoreStrong, width: 1),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  labelText: 'No. Celuar',
                                  labelStyle: const TextStyle(
                                    color: AppColors3.primaryColorMoreStrong,
                                  )
                                ),
                                style: const TextStyle(fontSize: 20, color: AppColors3.primaryColorMoreStrong),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03,
                                  vertical: MediaQuery.of(context).size.width * 0.03),
                              padding: EdgeInsets.only(left: editInfo ? 0:  MediaQuery.of(context).size.width * 0.03, top: editInfo ? 0 : MediaQuery.of(context).size.width * 0.03,
                                bottom: editInfo ? 0 : MediaQuery.of(context).size.width * 0.03,),
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  border: editInfo ? null : Border.all(color: AppColors3.primaryColorMoreStrong,)
                              ),
                              child: !editInfo ? RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Correo electronico',
                                      style: TextStyle(color: AppColors3.primaryColorMoreStrong,
                                          fontSize: 22), // Color para "No. Celular"
                                    ),
                                    TextSpan(
                                      text: emailController.text,
                                      style: TextStyle(color: AppColors3.primaryColorMoreStrong.withOpacity(0.3),
                                          fontSize: 20), // Color para el texto del controlador
                                    ),
                                  ],
                                ),
                              ) : TextFormField(
                                maxLines: maxLines,
                                controller: emailController,
                                decoration: InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColors3.primaryColorMoreStrong, width: 2.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  //unfocus
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColors3.primaryColorMoreStrong, width: 1.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColors3.primaryColorMoreStrong, width: 1),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  labelText: 'Correo electrónico',
                                  labelStyle: const TextStyle(color: AppColors3.primaryColorMoreStrong),
                                ),
                                style: const TextStyle(fontSize: 20, color: AppColors3.primaryColorMoreStrong,),
                              ),
                            ),
                          ),
                    ],
                  ),
                  Row(
                    children: [
                        Expanded(child: Container(
                            margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03,
                                vertical: MediaQuery.of(context).size.width * 0.03),
                            padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.03,
                              top:MediaQuery.of(context).size.width * 0.03,
                              right:MediaQuery.of(context).size.width * 0.03,
                              bottom: MediaQuery.of(context).size.width * 0.03,),
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                border: Border.all(color: AppColors3.primaryColorMoreStrong,)
                            ),
                            child:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Citas',
                                  style: TextStyle(color: AppColors3.primaryColorMoreStrong, fontSize: 22),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Próxima: ',
                                      style: TextStyle(
                                        color: AppColors3.primaryColorMoreStrong.withOpacity(0.3),
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      appointmentData?['appointment_date'] ?? 'No hay cita próxima',
                                      style: const TextStyle(
                                        color: AppColors3.primaryColorMoreStrong,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Cant. de citas:',
                                      style: TextStyle(
                                        color: AppColors3.primaryColorMoreStrong.withOpacity(0.3),
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      appointmentData?['visit_count']?.toString() ?? '0',
                                      style: const TextStyle(
                                        color: AppColors3.primaryColorMoreStrong,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                        ),),
                    ],
                  ),
                      Visibility(
                        visible: editInfo,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03),
                          width: MediaQuery.of(context).size.width,
                          child:  ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              side: const BorderSide(color: AppColors3.primaryColorMoreStrong,),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                showBlurr = true;
                              });
                              showDeleteConfirmationDialog(context, () {
                                deleteClient(widget.id);
                                showOverlay(
                                  context,
                                  const CustomToast(
                                    message: 'Cliente eliminado',
                                  ),
                                );
                                Navigator.of(context).pop();
                              }).then((_){
                                setState(() {
                                  showBlurr = false;
                                });
                              });
                            },
                            child: const Text('Eliminar contacto', style: TextStyle(color: Colors.red),),
                          ),
                        ),),
                  ]
                )
            ),
        ),
          Visibility(
            visible: showBlurr,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Container(
                color: Colors.black54.withOpacity(0.3),
              )
            )
          )
          ]),
        ]));
  }
}
