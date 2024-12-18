import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../projectStyles/appColors.dart';
import '../services/auth_service.dart';
import '../styles/ladingDraw.dart';

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
                                            IconButton(onPressed: (){}, icon: Icon(Icons.check, color: AppColors3.whiteColor,
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