import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../regEx.dart';
import '../projectStyles/appColors.dart';
import '../utils/PopUpTabs/clientSuccessfullyAdded.dart';


class EmailInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // No permitir que el texto comience con un espacio
    if (newValue.text.startsWith(' ')) {
      return oldValue;
    }

    // Permitir borrar un espacio intermedio
    if (oldValue.text.endsWith(' ') &&
        !newValue.text.endsWith(' ') &&
        newValue.text.length == oldValue.text.length - 1 &&
        oldValue.text.length > 1) {
      return newValue;
    }

    // Aplicar filtros de caracteres permitidos y denegados
    String filteredText = newValue.text;

    // Filtrar los caracteres permitidos
    filteredText = RegExp(r'[a-zA-Z0-9._%-@]')
        .allMatches(filteredText)
        .map((match) => match.group(0))
        .join();

    // Negar los caracteres no permitidos
    filteredText = filteredText.replaceAll(RegExp(r'[<>?:;/+%]'), '');

    return TextEditingValue(
      text: filteredText,
      selection: newValue.selection.copyWith(
        baseOffset: filteredText.length,
        extentOffset: filteredText.length,
      ),
    );
  }
}

class ClientForm extends StatefulWidget {
  final void Function(
    bool,
  ) onHideBtnsBottom;
  final void Function(
    int,
    bool,
  ) onFinishedAddClient;

  const ClientForm(
      {super.key,
      required this.onHideBtnsBottom,
      required this.onFinishedAddClient});

  @override
  ClientFormState createState() => ClientFormState();
}

class ClientFormState extends State<ClientForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;
  bool hideBtnsBottom = false;
  late FocusNode focusNodeClient;
  late FocusNode focusNodeCel;
  late FocusNode focusNodeEmail;
  bool errorInit = false;
  double? screenWidth;
  double? screenHeight;
  bool showBlurr = false;
  //errores
  bool nameError = false;
  bool celError = false;
  bool emailError = false;
  //
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
        !visibleKeyboard ? widget.onHideBtnsBottom(false) : null;
      });
    });
  }

  Future<void> createClient() async {
    setState(() {
      _nameController.text.isEmpty ? nameError = true : nameError = false;
      _emailController.text.isEmpty ? emailError = true : emailError = false;
      _numberController.text.isEmpty || _numberController.text.length < 10 ? celError = true : celError = false;
    });
    try {
      var response = await http.post(
        Uri.parse('https://beauteapp-dd0175830cc2.herokuapp.com/api/createClient'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'number': _numberController.text,
          'email': _emailController.text,
        }),
      );
      if (response.statusCode == 201) {
        setState(() {
          if (mounted) {
            showBlurr = true;
            hideKeyBoard();
            showDialog(context: context, builder: (BuildContext context){
              return const ClienteAddedDialog();
            }).then((_){
              if(mounted){
                Navigator.of(context).pop();
              }
            });
          }
        });

      } else if(response.statusCode == 422) {
        var errorResponse = jsonDecode(response.body);
        if(errorResponse['errors'] != null && errorResponse['errors']['number'] != null) {
          showClienteNumberExistsAlert(context, errorResponse['errors']['number'][0]);
        }else {
          _numberController.text.isEmpty ? null :
          showClienteNumberExistsAlert(context, 'Error al crear cliente: ${response.body}');
        }
      }else {
        print('Error al crear cliente: ${response.body}');
      }
    }catch (e) {
      print('Error al enviar datos: $e');
      showClienteNumberExistsAlert(context, 'Error al enviar datos: $e');
    }
  }

  void changeFocus(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  @override
  void initState() {
    hideKeyBoard();
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
    focusNodeClient = FocusNode();
    focusNodeCel = FocusNode();
    focusNodeEmail = FocusNode();
    super.initState();
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
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.03,
                right: MediaQuery.of(context).size.width * 0.03,
                top: visibleKeyboard ? screenWidth! < 391.0 ? MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.width * 0.05 : screenWidth! < 391.0 ? MediaQuery.of(context).size.width * 0.3 : MediaQuery.of(context).size.width * 0.45),
            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
            decoration: BoxDecoration(
              color: AppColors3.whiteColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top:MediaQuery.of(context).size.width * 0.03),
                      child: Text(
                        'Agregar cliente',
                        style: TextStyle(
                          fontSize:
                          MediaQuery.of(context).size.width * 0.08,
                          fontWeight: FontWeight.bold,
                          color: AppColors3.primaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                        icon: const Icon(Icons.close, color: AppColors3.primaryColor,))
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.03),
                    height: visibleKeyboard
                        ? (screenWidth! < 391 ? MediaQuery.of(context).size.height * 0.46
                            : MediaQuery.of(context).size.height * 0.5)
                        : screenWidth! < 391.0 ? MediaQuery.of(context).size.height * 0.535
                  : MediaQuery.of(context).size.height * 0.6,
                    child: SingleChildScrollView(
                      physics:  const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenWidth! < 370
                                        ? MediaQuery.of(context).size.width * 0.01
                                        : MediaQuery.of(context).size.width * 0.02,
                                    horizontal: MediaQuery.of(context).size.width * 0.02),
                                margin: EdgeInsets.symmetric(
                                    horizontal: MediaQuery.of(context).size.width * 0.0,
                                    vertical: MediaQuery.of(context).size.width * 0.025),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: AppColors3.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Nombre del cliente',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).size.width * 0.045,
                                  top: 0),
                              child: TextFormField(
                                inputFormatters: [
                                  RegEx(type: InputFormatterType.name),
                                  //NameInputFormatter(),
                                ],
                                focusNode: focusNodeClient,
                                controller: _nameController,
                                decoration: InputDecoration(
                                  error: nameError ? const Text('Agregar nombre', style: TextStyle(
                                    color: Colors.red,
                                  ),) : null,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: screenWidth! < 370
                                          ? MediaQuery.of(context).size.width * 0.02
                                          : MediaQuery.of(context).size.width * 0.0325,
                                      horizontal:
                                      MediaQuery.of(context).size.width * 0.02),
                                  hintText: 'Nombre completo',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(color: AppColors3.primaryColorMoreStrong)
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(color: AppColors3.primaryColorMoreStrong)),
                                    focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(color: AppColors3.primaryColorMoreStrong, width: 1.5),
                                  ),
                                ),
                                onTap: () {
                                  !visibleKeyboard
                                      ? widget.onHideBtnsBottom(!visibleKeyboard)
                                      : null;
                                },
                                onEditingComplete: () =>
                                    changeFocus(context, focusNodeClient, focusNodeCel),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: screenWidth! < 370
                                      ? MediaQuery.of(context).size.width * 0.01
                                      : MediaQuery.of(context).size.width * 0.02,
                                  horizontal: MediaQuery.of(context).size.width * 0.02),
                              margin: EdgeInsets.symmetric(
                                  horizontal: MediaQuery.of(context).size.width * 0.0),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: AppColors3.primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'No. Celular',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).size.width * 0.045,
                                  top: MediaQuery.of(context).size.width * 0.0225),
                              child: TextFormField(
                                textInputAction: TextInputAction.done,
                                focusNode: focusNodeCel,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(10),
                                  RegEx(type: InputFormatterType.numeric),
                                ],
                                controller: _numberController,
                                decoration: InputDecoration(
                                  error: celError && _numberController.text.isEmpty? const Text('Agregar número', style: TextStyle(
                                    color: Colors.red,
                                  ),) : celError && _numberController.text.length < 10 ? const Text('El número debe tener 10 digitos', style: TextStyle(
                                    color: Colors.red,
                                  ),) : null,
                                  hintText: 'No. Celular',
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: screenWidth! < 370
                                          ? MediaQuery.of(context).size.width * 0.02
                                          : MediaQuery.of(context).size.width * 0.0325,
                                      horizontal:
                                      MediaQuery.of(context).size.width * 0.02),
                                  border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(
                                            color: AppColors3.primaryColorMoreStrong)),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(color: AppColors3.primaryColorMoreStrong)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(color: AppColors3.primaryColorMoreStrong, width: 1.5),
                                  ),
                                ),
                                onTap: () {
                                  !visibleKeyboard
                                      ? widget.onHideBtnsBottom(!visibleKeyboard)
                                      : null;
                                },
                                onEditingComplete: () =>
                                    changeFocus(context, focusNodeCel, focusNodeEmail),
                                onChanged: (celnumber) {
                                  setState(() {
                                    if (celnumber.length != 10) {
                                      errorInit = true;
                                    } else {
                                      errorInit = false;
                                    }
                                  });
                                },
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: screenWidth! < 370
                                      ? MediaQuery.of(context).size.width * 0.01
                                      : MediaQuery.of(context).size.width * 0.02,
                                  horizontal: MediaQuery.of(context).size.width * 0.02),
                              margin: EdgeInsets.symmetric(
                                  horizontal: MediaQuery.of(context).size.width * 0.0),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: AppColors3.primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Correo electrónico',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).size.width * 0.045,
                                  top: MediaQuery.of(context).size.width * 0.0225),
                              child: TextFormField(
                                inputFormatters: [
                                  RegEx(type: InputFormatterType.email),
                                  ],
                                focusNode: focusNodeEmail,
                                controller: _emailController,
                                decoration: InputDecoration(
                                  error: emailError ? const Text('Agregar correo', style: TextStyle(color: Colors.red),) : null,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: screenWidth! < 370
                                          ? MediaQuery.of(context).size.width * 0.02
                                          : MediaQuery.of(context).size.width * 0.0325,
                                      horizontal: MediaQuery.of(context).size.width * 0.02),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: AppColors3.primaryColorMoreStrong)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(color: AppColors3.primaryColorMoreStrong)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(color: AppColors3.primaryColorMoreStrong, width: 1.5),
                                  ),
                                  hintText: 'Correo electrónico',
                                ),
                                onTap: () {
                                  !visibleKeyboard
                                      ? widget.onHideBtnsBottom(!visibleKeyboard)
                                      : null;
                                },
                                onEditingComplete: () => focusNodeEmail.unfocus(),
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).size.width * 0.03),
                                child: ElevatedButton(
                                    onPressed: errorInit
                                        ? null
                                        : () {
                                      createClient();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      splashFactory: InkRipple.splashFactory,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context).size.width * 0.01,
                                          vertical: MediaQuery.of(context).size.width * 0.0112),
                                      surfaceTintColor: AppColors3.primaryColorMoreStrong,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        side: const BorderSide(
                                            color: AppColors3.primaryColor, width: 2),
                                      ),
                                      fixedSize: Size(
                                        MediaQuery.of(context).size.width * 0.6,
                                        MediaQuery.of(context).size.height * 0.075,
                                      ),
                                      backgroundColor: Colors.white,
                                    ),
                                    child: Text('Agregar Cliente',
                                        style: TextStyle(
                                          fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.055,
                                          color: AppColors3.primaryColor,
                                        ))))
                          ])),
                ),

              ],
            )),
          Visibility(
              visible: showBlurr,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Container(
                    color: Colors.black54.withOpacity(0.01),
                  ),
                ),),
        ]));
  }
}
