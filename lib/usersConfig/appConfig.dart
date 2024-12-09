import 'package:agenda_app/kboardVisibilityManager.dart';
import 'package:agenda_app/projectStyles/appColors.dart';
import 'package:agenda_app/regEx.dart';
import 'package:agenda_app/usersConfig/selBoxUser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppConfig extends StatefulWidget {
  const AppConfig({super.key});

  @override
  State<AppConfig> createState() => _AppConfigState();
}

class _AppConfigState extends State<AppConfig> {

  late KeyboardVisibilityManager keyboardVisibilityManager;

  FocusNode nameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode pswFocus = FocusNode();
  FocusNode newPswFocus = FocusNode();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController pswController = TextEditingController();
  TextEditingController newPswController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String? user;
  String? rol;
  bool isValidationActive = false;

  void lockforEmpetyFields() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.width * 0.08,
              bottom: MediaQuery.of(context).size.width * 0.08,
              left: MediaQuery.of(context).size.width * 0.02,
            ),
            content: Text('Formulario válido', style: TextStyle(
                color: AppColors3.whiteColor,
                fontSize: MediaQuery.of(context).size.width * 0.045),),
        ),
      );
    }
  }


  @override
  void dispose() {
    keyboardVisibilityManager.dispose();
    nameController.dispose();
    emailController.dispose();
    pswController.dispose();
    newPswController.dispose();
    super.dispose();
  }

  bool isUserSel = false;

  void onSelUser (String? user){
    this.user = user;
    if(user != null){
      setState(() {
        isUserSel = true;
      });
    }
  }
  void onSelRol (String? rol){
    this.rol = rol;
    if(rol != null){
      setState(() {
        lockforEmpetyFields();
      });
    }
  }

  void addFocusListeners(List<FocusNode> focusNodes) {
    for (var focusNode in focusNodes) {
      focusNode.addListener(() {
        setState(() {
          print('Focus state for ${focusNode.toString()}: ${focusNode.hasFocus}');
        });
      });
    }
  }

  void addTextListeners(List<TextEditingController> controllers) {
    for (var controller in controllers) {
      controller.addListener(() {
        setState(() {
          isValidationActive ? lockforEmpetyFields() : null;
        });
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    keyboardVisibilityManager = KeyboardVisibilityManager();
    addFocusListeners([nameFocus, emailFocus, pswFocus, newPswFocus]);
    addTextListeners([nameController, emailController, pswController]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors3.whiteColor,
      body: CustomScrollView(
        physics: keyboardVisibilityManager.visibleKeyboard ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors3.whiteColor,
            pinned: true,
            leadingWidth: MediaQuery.of(context).size.width,
            leading: Row(
              children: [
                IconButton(onPressed: (){
                  Navigator.of(context).pop();
                }, icon: Icon(CupertinoIcons.chevron_back, size: MediaQuery.of(context).size.width * 0.08,
                  color: AppColors3.primaryColor,)),
                Text('Usuarios', style: TextStyle(
                  color: AppColors3.primaryColor,
                  fontSize: MediaQuery.of(context).size.width * 0.065,
                ),),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.03,
                      right: MediaQuery.of(context).size.width * 0.03,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.01,
                      vertical: MediaQuery.of(context).size.width * 0.03,
                    ),
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.width * 0.03,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                        textAlign: TextAlign.left,
                                        'Registrar usuario',
                                        style: TextStyle(
                                            color: AppColors3.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.065)),
                                  ],
                                ),
                                const Row(
                                  children: [
                                    Text('Por favor llene los campos para completar el registro')
                                  ],
                                )
                              ],
                            )),
                        Form(
                          key: _formKey,
                          child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              focusNode: nameFocus,
                              inputFormatters: [
                                RegEx(type: InputFormatterType.name),
                              ],
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: MediaQuery.of(context).size.width * 0.02,
                                    vertical: MediaQuery.of(context).size.width * 0.035),
                                filled: nameFocus.hasFocus ? true : false,
                                fillColor: AppColors3.greyColor.withOpacity(0.2),
                                hintText: 'Ingrese nombre',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'El nombre es obligatorio';
                                }
                                if (value.length < 3) {
                                  return 'El nombre debe tener al menos 3 caracteres';
                                }
                                return null; // Campo válido
                              },
                            ),
                            TextFormField(
                              controller: emailController,
                              focusNode: emailFocus,
                              inputFormatters: [
                                RegEx(type: InputFormatterType.email),
                              ],
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical:
                                    MediaQuery.of(context).size.width *
                                        0.035,
                                    horizontal:
                                    MediaQuery.of(context).size.width *
                                        0.02,
                                  ),
                                  filled: emailFocus.hasFocus ? true : false,
                                  fillColor:
                                  AppColors3.greyColor.withOpacity(0.2),
                                  hintText: 'Ingrese correo electrónico'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'El correo es obligatorio';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(value)) {
                                  return 'Por favor ingrese un correo válido';
                                }
                                return null; // Campo válido
                              },
                            ),
                            SelBoxRol(onSelRol: onSelRol),
                            TextFormField(
                              controller: pswController,
                              focusNode: pswFocus,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal:
                                      MediaQuery.of(context).size.width *
                                          0.02,
                                      vertical:
                                      MediaQuery.of(context).size.width *
                                          0.035),
                                  filled: pswFocus.hasFocus ? true : false,
                                  fillColor:
                                  AppColors3.greyColor.withOpacity(0.2),
                                  hintText: 'Contraseña'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'La contraseña es obligatoria';
                                }
                                if (value.length < 6) {
                                  return 'La contraseña debe tener al menos 6 caracteres';
                                }
                                return null; // Campo válido
                              },
                            ),
                          ],
                        ),),
                      ],
                    )),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.03),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors3.primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          minimumSize: Size(double.infinity,
                              MediaQuery.of(context).size.width * 0.1)),
                      onPressed: () {
                        lockforEmpetyFields();
                      },
                      child: Text(
                        'Crear',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                        ),
                      )),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
              child: Column(children: [
            Container(
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.03,
                  top: MediaQuery.of(context).size.width * 0.05,
                  right: MediaQuery.of(context).size.width * 0.03,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.01,
                  vertical: MediaQuery.of(context).size.width * 0.03,
                ),
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Column(children: [
                  Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.width * 0.03,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                  textAlign: TextAlign.left,
                                  'Control de usuarios',
                                  style: TextStyle(
                                      color: AppColors3.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.065)),
                            ],
                          ),
                          Padding(padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.width * 0.03,
                            top: MediaQuery.of(context).size.width * 0.01,
                          ),child: const Row(
                            children: [
                              Text('Por favor seleccione algún usuario ')
                            ],
                          ),),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Flexible(
                                  child: SelBoxUser(onSelUser: onSelUser),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width * 0.02,
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: isUserSel ? () {} : null,
                                    child: Icon(Icons.delete_forever,
                                    color: isUserSel ? AppColors3.redDelete : AppColors3.redDelete.withOpacity(0.3)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Visibility(
                            visible: user != null ? true : false,
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    'Reestablecer contraseña para el usuario: $user'),
                              ),
                              TextFormField(
                                controller: newPswController,
                                focusNode: newPswFocus,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width * 0.02,
                                        vertical: MediaQuery.of(context).size.width * 0.035),
                                    suffixIcon: IconButton(onPressed: (){}, icon: Icon(Icons.check)),
                                    filled: newPswFocus.hasFocus ? true : false,
                                    fillColor: AppColors3.greyColor.withOpacity(0.2),
                                    hintText: 'Nueva contraseña'),
                              ),
                            ],
                          ),),),
                        ],
                      )),
                ]))
          ])),
        ]));
  }
}
