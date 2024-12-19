import 'dart:ui';

import 'package:agenda_app/services/authService2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../projectStyles/appColors.dart';
import '../styles/ladingDraw.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _identificationController = TextEditingController();
  final FocusNode _identificationFocusNode = FocusNode();
  final TextEditingController _pinController = TextEditingController();

  bool showPinEntryScreen = false;
  String userIdentification = '';
  bool showPinField = false;
  final FocusNode _inputFocusNode = FocusNode();
  final AuthService2 authService = AuthService2();
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    _identificationController.addListener(_onIdentificationChanged);
    pageController = PageController(
        initialPage: 0
    );
  }

  @override
  void dispose() {
    _identificationController.removeListener(_onIdentificationChanged);
    _identificationController.dispose();
    _identificationFocusNode.dispose();
    _inputFocusNode.dispose();
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
    }
  }

  void changePage (int pageToGo){
    pageController.animateToPage(pageToGo, duration: const Duration(milliseconds: 300), curve: Curves.linear);
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
            Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.4,
                      ),
                      child: CircleAvatar(
                        backgroundColor: AppColors3.whiteColor,
                        radius: MediaQuery.of(context).size.height * 0.2,
                        child: const Image(
                          image: AssetImage("assets/icons/logoCVP.png"),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width * 0.25,
                    ),
                    child: PageView(
                      onPageChanged: (value) {
                        value == 1
                          ? FocusScope.of(context).requestFocus(_inputFocusNode)
                          : FocusScope.of(context).requestFocus(_identificationFocusNode);
                      },
                      controller: pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildIdentificationField(),
                        _buildPinField(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentificationField() {
    return Container(
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.095,
          right: MediaQuery.of(context).size.width * 0.095,
          bottom: MediaQuery.of(context).size.width * 0.095,
        ),
        child: Row(
          children: [
            Flexible(child: TextField(
              onChanged: (value) {
                if (value.length == 3) {
                  changePage(1);
                }
              },
              controller: _identificationController,
              focusNode: _identificationFocusNode,
              autocorrect: false,
              style: TextStyle(
                color: AppColors3.blackColor,
                fontSize: MediaQuery.of(context).size.width * 0.05,
              ),
              decoration: InputDecoration(
                isDense: true,
                counterText: '',
                hintText: 'Ingresar identificador...',
                hintStyle: TextStyle(
                  color: AppColors3.blackColor.withOpacity(0.5),
                  fontSize: 18,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.width * 0.04,
                  horizontal: MediaQuery.of(context).size.width * 0.06,
                ),
                filled: true,
                fillColor: AppColors3.whiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: AppColors3.whiteColor,
                    width: 0
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: AppColors3.whiteColor,
                    width: 0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: AppColors3.whiteColor,
                    width: 0,
                  ),
                ),
                prefixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.035,
                          right: MediaQuery.of(context).size.width * 0.01),
                      child: SvgPicture.asset(
                        'assets/icons/drIcon.svg',
                        color: AppColors3.blackColor,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.015,
                        right: MediaQuery.of(context).size.width * 0.03,
                      ),
                      height: MediaQuery.of(context).size.width * 0.09,
                      width: MediaQuery.of(context).size.width * 0.006,
                      decoration: BoxDecoration(
                        color: AppColors3.blackColor,
                        border: Border.all(width: 0.5, color: AppColors3.blackColor),
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),),
          ],
        )
    );
  }

  Widget _buildPinField() {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.095,
        right: MediaQuery.of(context).size.width * 0.095,
        bottom: MediaQuery.of(context).size.width * 0.095,
      ),
      child: Row(
        children: [
          IconButton(
            color: AppColors3.whiteColor,
            onPressed: () {
              setState(() {
                changePage(0);
                _identificationController.clear();
              });
            },
            icon: Icon(
              CupertinoIcons.left_chevron,
              size: MediaQuery.of(context).size.width * 0.095,
            ),
          ),
          Flexible(
            child: TextField(
              focusNode: _inputFocusNode,
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: AppColors3.blackColor,
                fontSize: 26,
              ),
              decoration: InputDecoration(
                counterText: '',
                isDense: true,
                hintText: 'Ingresar PIN...',
                hintStyle: TextStyle(
                  color: AppColors3.blackColor.withOpacity(0.5),
                  fontSize: 18,
                ),
                filled: true,
                fillColor: AppColors3.whiteColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                    width: 2,
                  ),
                ),
                prefixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.035,
                        right: MediaQuery.of(context).size.width * 0.01,
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/pinIcon.svg',
                        color: AppColors3.blackColor,
                        width: MediaQuery.of(context).size.width * 0.105,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.015,
                        right: MediaQuery.of(context).size.width * 0.03,
                      ),
                      height: MediaQuery.of(context).size.width * 0.09,
                      width: MediaQuery.of(context).size.width * 0.006,
                      decoration: BoxDecoration(
                        color: AppColors3.blackColor,
                        border: Border.all(width: 0.5, color: AppColors3.blackColor),
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                  ],
                )
              ),
              onChanged: (value) {
                if (value.length == 4) {
                  print('Autenticando...');
                  authService.authenticate(context, userIdentification, true, value, _pinController);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /*Widget _buildPinField() {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.095,
        right: MediaQuery.of(context).size.width * 0.095,
        bottom: MediaQuery.of(context).size.width * 0.095,
      ),
      child: Row(
        children: [
          IconButton(
            color: AppColors3.whiteColor,
            onPressed: () {
              setState(() {
                showPinField = false;
                _identificationController.clear();
              });
            },
            icon: Icon(
              CupertinoIcons.left_chevron,
              size: MediaQuery.of(context).size.width * 0.095,
            ),
          ),
          Flexible(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors3.whiteColor,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              height: MediaQuery.of(context).size.height * 0.065,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.035,
                      right: MediaQuery.of(context).size.width * 0.035,
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/pinIcon.svg',
                      color: AppColors3.primaryColor,
                      width: MediaQuery.of(context).size.width * 0.105,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.015,
                      right: MediaQuery.of(context).size.width * 0.015,
                    ),
                    height: MediaQuery.of(context).size.width * 0.09,
                    width: MediaQuery.of(context).size.width * 0.006,
                    decoration: BoxDecoration(
                      color: AppColors3.primaryColor,
                      border: Border.all(width: 0.5, color: AppColors3.primaryColor),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                  Flexible(
                    child: TextField(
                      focusNode: _inputFocusNode,
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true, // Oculta el texto ingresado
                      maxLength: 4,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: AppColors3.primaryColor,
                        fontSize: 26,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        isDense: true,
                        hintText: 'Ingresar PIN...',
                        hintStyle: TextStyle(
                          color: AppColors3.primaryColor.withOpacity(0.5),
                          fontSize: 18,
                        ),
                        filled: true,
                        fillColor: AppColors3.whiteColor,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 4) {
                          print('Autenticando...');
                          authService.authenticate(context, userIdentification, true, value, _pinController);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }*/
}