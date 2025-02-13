import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:agenda_app/globalVar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/svg.dart';
import '../../calendar/calendarSchedule.dart';
import '../../forms/appoinmentForm.dart';
import '../../navBar.dart';
import '../../projectStyles/appColors.dart';
import '../../utils/PopUpTabs/closeConfirm.dart';
import 'clientList.dart';
import 'forToday.dart';
import 'package:agenda_app/views/admin/forTodayModal.dart';


class AssistantAdmin extends StatefulWidget {
  final bool docLog;
  const AssistantAdmin({super.key, required this.docLog});

  @override
  State<AssistantAdmin> createState() => _AssistantAdminState();
}

class _AssistantAdminState extends State<AssistantAdmin> {

  Fortodaymodal fortodaymodal = Fortodaymodal();
  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;
  bool scrollToDayComplete = false;
  bool _hideBtnsBottom = false;
  int _selectedScreen = 0;
  bool _cancelConfirm = false;
  double? screenWidth;
  double? screenHeight;
  late bool platform; //0 IOS 1 Androide
  bool _showBlurr = false;
  String currentScreen = "agenda";
  bool isSwitched = false;


  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
      setState(() {
        visibleKeyboard = visible;
        if(_selectedScreen == 3){
        }
      });
    });
  }

  void _onShowBlur(bool showBlur){
    setState(() {
      _showBlurr = showBlur;
    });
  }

  Future<void> onOpenModal() async {
    bool? result = await fortodaymodal.showModal(context);
    if (result == true) {
      setState(() {
        _showBlurr = false;
      });
    }
  }

  void _onshowContentToModify(bool showContentToModify) {
  }

  void _onHideBtnsBottom(bool hideBtnsBottom) {
    setState(() {
      _hideBtnsBottom = hideBtnsBottom;
    });
  }

  void onBlurrModal(bool blurrModal) {
    setState(() {
      _showBlurr = blurrModal;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    print(screenHeight);
  }

  @override
  void initState() {
    _selectedScreen = 1;
    keyboardVisibilityController = KeyboardVisibilityController();
    Platform.isIOS ? platform = false : platform = true;
    checkKeyboardVisibility();
    super.initState();
  }

  @override
  void dispose() {
    keyboardVisibilitySubscription.cancel();
    super.dispose();
  }

  void _onCancelConfirm(bool cancelConfirm) {
    setState(() {
      _cancelConfirm = cancelConfirm;
    });
  }

  onBackPressed(didPop) {
    if (!didPop) {
      setState(() {
        _selectedScreen == 3
            ? _selectedScreen = 1
            : showDialog(
                barrierDismissible: false,
                context: context,
                builder: (builder) {
                  return AlertCloseDialog(
                    onCancelConfirm: _onCancelConfirm,
                  );
                },
              ).then((_) {
                if (_cancelConfirm == true) {
                  if (_cancelConfirm) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      SystemNavigator.pop();
                    });
                  }
                }
              });
      });
      return;
    }
  }

  void _onItemSelected(int option){
    setState(() {
       print(option);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        onBackPressed(didPop);
      },
      child: Scaffold(
        backgroundColor: AppColors3.bgColor,
        endDrawer: navBar(
          onItemSelected: _onItemSelected, onShowBlur: _onShowBlur, isDoctorLog: widget.docLog, currentScreen: currentScreen,
          onLockScreen: (doNothing ) {  }),
        body: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: screenHeight! < 880.5 ? MediaQuery.of(context).size.height * 0.07 : MediaQuery.of(context).size.height * 0.045),///here
              decoration: const BoxDecoration(
                color: AppColors3.bgColor,
              ),
              child: Column(
                children: [
                  Container(
                    color: AppColors3.bgColor,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: _selectedScreen == 3
                            ? MediaQuery.of(context).size.width * 0.045
                            : MediaQuery.of(context).size.width * 0.045,
                        right: MediaQuery.of(context).size.width * 0.025,),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Visibility(
                                visible: false,//_selectedScreen != 1,
                                child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedScreen = 1;
                                        _hideBtnsBottom = false;
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      CupertinoIcons.back,
                                      size: MediaQuery.of(context).size.width * 0.08,
                                      color: AppColors3.primaryColor,
                                    )),
                              ),
                              Text(
                                _selectedScreen == 1
                                    ? 'Calendario'
                                    : _selectedScreen == 3
                                    ? 'Clientes'
                                    : _selectedScreen == 4
                                    ? 'Para hoy'
                                    : 'Calendario',//esto es por el refresh
                                style: TextStyle(
                                  color: AppColors3.primaryColor,
                                  fontSize: screenWidth! < 370.00
                                      ? MediaQuery.of(context).size.width * 0.078
                                      : MediaQuery.of(context).size.width * 0.082,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Visibility(
                                visible: _selectedScreen == 1 ? true : false,
                                child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  setState(() {
                                    _selectedScreen = 5;
                                  });
                                  Timer(Duration(milliseconds: 500), () {
                                    setState(() {
                                      _selectedScreen = 1;
                                    });
                                  });
                                },
                                icon: Icon(
                                  CupertinoIcons.refresh,
                                  size: MediaQuery.of(context).size.width * 0.065,
                                  color: AppColors3.primaryColorMoreStrong,
                                ),
                              ),),
                              IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  setState(() {
                                    _showBlurr = true;
                                  });
                                  await onOpenModal();
                                },
                                icon: Icon(
                                  CupertinoIcons.calendar_today,
                                  size: MediaQuery.of(context).size.width * 0.095,
                                  color: AppColors3.primaryColorMoreStrong,
                                ),
                              ),
                              Builder(builder: (BuildContext context){
                                return IconButton(
                                  onPressed: (){
                                    Scaffold.of(context).openEndDrawer();
                                  },
                                  icon: SvgPicture.asset(
                                    'assets/icons/navBar.svg',
                                    colorFilter: const ColorFilter.mode(AppColors3.primaryColorMoreStrong, BlendMode.srcIn),
                                    width: MediaQuery.of(context).size.width * 0.105,
                                  ),);
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        bottom: _selectedScreen != 4
                            ? MediaQuery.of(context).size.width * 0.04
                            : MediaQuery.of(context).size.width * 0.0,
                      ),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors3.blackColor.withOpacity(0.5),
                            blurRadius: 3,
                            offset: Offset(0, 8),
                          )
                        ],
                          color: AppColors3.bgColor,
                          borderRadius: BorderRadius.only(
                              topLeft: _selectedScreen == 4
                                  ? const Radius.circular(15)
                                  : const Radius.circular(0),
                              topRight: _selectedScreen == 4
                                  ? const Radius.circular(15)
                                  : const Radius.circular(0),
                              bottomLeft: const Radius.circular(15),
                              bottomRight: const Radius.circular(15)),
                          border: _selectedScreen != 4
                              ? const Border(
                              bottom: BorderSide(
                                color: AppColors3.bgColor,
                                width: 2.5,
                              ))
                              : null,
                      ),
                      child: Container(
                        margin: EdgeInsets.only(
                          top: _selectedScreen == 1
                              ? MediaQuery.of(context).size.width * 0.03
                              : MediaQuery.of(context).size.width * 0.0,
                          bottom: _selectedScreen == 4 ? MediaQuery.of(context).size.width * 0.02 : MediaQuery.of(context).size.width * 0.04,
                          left: _selectedScreen != 4 && _selectedScreen != 3
                              ? MediaQuery.of(context).size.width * 0.045
                              : MediaQuery.of(context).size.width * 0.0,
                          right: _selectedScreen != 4 && _selectedScreen != 3
                              ? MediaQuery.of(context).size.width * 0.045
                              : MediaQuery.of(context).size.width * 0.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _buildBody(),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !_hideBtnsBottom,
                    child: Container(
                      margin: EdgeInsets.only(
                          bottom: screenWidth! < 391
                              ? MediaQuery.of(context).size.width * 0.055
                              : MediaQuery.of(context).size.width * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  setState(() {
                                    _selectedScreen = 1;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.055),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(
                                    _selectedScreen != 1
                                        ? CupertinoIcons.calendar
                                        : CupertinoIcons.calendar,
                                    color: _selectedScreen == 1
                                        ? AppColors3.primaryColorMoreStrong
                                        : AppColors3.primaryColorMoreStrong.withOpacity(0.3),
                                    size: MediaQuery.of(context).size.width * 0.12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors3.primaryColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                  MediaQuery.of(context).size.width * 0.06),
                              surfaceTintColor: AppColors3.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: const BorderSide(
                                    color: AppColors3.primaryColor, width: 2),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (context) => AppointmentForm(docLog: widget.docLog),
                                ),
                              );
                            },
                            child: Icon(
                              _selectedScreen != 2
                                  ? CupertinoIcons.add
                                  : CupertinoIcons.add,
                              color: _selectedScreen == 2
                                  ? AppColors3.whiteColor
                                  : AppColors3.whiteColor,
                              size: MediaQuery.of(context).size.width * 0.1,
                            ),
                          ),
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  setState(() {
                                    if (mounted) {
                                      _selectedScreen = 3;
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _selectedScreen == 3 ?
                                    CupertinoIcons.person_fill :CupertinoIcons.person,
                                    color: _selectedScreen == 3
                                        ? AppColors3.primaryColorMoreStrong
                                        : AppColors3.primaryColorMoreStrong.withOpacity(0.3),
                                    size: MediaQuery.of(context).size.width * 0.11,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: _showBlurr,
                child: GestureDetector(
                  onTap: () {
                    _showBlurr = false;
                  },
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                      child: Container(
                        color: Colors.black54.withOpacity(0.3),
                      )),
                ))])));}

  Widget _buildBody() {
    switch (_selectedScreen) {
      case 1:
        return AgendaSchedule(
            docLog: widget.docLog, showContentToModify: _onshowContentToModify, onBlurrModal: onBlurrModal);
      case 3:
        return ClientDetails(onHideBtnsBottom: _onHideBtnsBottom, docLog: widget.docLog, onShowBlur: _onShowBlur, );
      case 4:
        return NotificationsScreen(onCloseForToday: (sel) {
            setState(() {
              _selectedScreen = sel;
              _hideBtnsBottom = false;
            });
          },
        );
      case 5:
        return Center(child: CircularProgressIndicator(
          color: AppColors3.primaryColor,
        ));
      default:
        return Container();
    }
  }
}
