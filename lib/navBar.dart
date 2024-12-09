import 'package:agenda_app/projectStyles/appColors.dart';
import 'package:agenda_app/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'forms/alertForm.dart';
import 'globalVar.dart';

class navBar extends StatefulWidget {
  final bool isDoctorLog;
  final void Function(bool) onShowBlur;
  final Function(int) onItemSelected;
  final void Function(bool) onLockScreen;
  final String currentScreen;

  const navBar({super.key, required this.onItemSelected, required this.onShowBlur, required this.isDoctorLog, required this.currentScreen,
    required this.onLockScreen});

  @override
  State<navBar> createState() => _navBarState();
}

class _navBarState extends State<navBar> {

  void closeMenu(BuildContext context){
    Navigator.of(context).pop();
  }

  Future<void> createAlert() async {
    Navigator.of(context).pop();
    return showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return AlertForm(isDoctorLog: widget.isDoctorLog);
        }).then((_){widget.onShowBlur(false);});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Drawer(
            backgroundColor: AppColors3.whiteColor,
            child: Stack(
              children: [
                Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.width*0.17),
                    child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 30, left: 20),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: MediaQuery.of(context).size.width*0.05,
                                    backgroundColor: AppColors3.primaryColor,
                                    child: SvgPicture.asset(
                                      'assets/icons/drIcon.svg',
                                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                      height: MediaQuery.of(context).size.width * 0.067,
                                    ),
                                  ),
                                  Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      child:
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(SessionManager.instance.Nombre == 'Dulce' ? 'Nombre Asistente' : SessionManager.instance.Nombre,
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width*0.05, color: AppColors3.primaryColor)),
                                          Text('Nombre de tu empresa', style: TextStyle(color: AppColors3.primaryColor.withOpacity(0.8)),)
                                        ],
                                      )
                                  )
                                ]
                            ),
                          ),
                          //    bool isBluetoothOn = await flutterBlue.isOn;
                          Visibility(
                            visible: !widget.isDoctorLog,
                            child: Container(
                              padding: const EdgeInsets.only(top:40),
                              child: ElevatedButton(
                                  onPressed: (){
                                    setState(() {
                                      widget.onShowBlur(true);
                                      createAlert();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors3.whiteColor,
                                    side: const BorderSide(color: AppColors3.primaryColor, width: 1.0),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    minimumSize: Size(170, 55),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    elevation: 5.0,
                                    shadowColor: Colors.black54,
                                  ),
                                  child: Text(
                                    'Mandar alerta',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).size.width*0.05,
                                        color: AppColors3.primaryColor
                                    ),
                                  )
                              ),
                            ),),
                          ///Icono escoger impresora
                          /*IconButton(onPressed: (){
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => testPrint(),
                              ),
                            );

                          }, icon: Icon(Icons.ac_unit)),*/
                          Expanded(
                              child: Container(
                                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width*0.03),
                                  alignment: Alignment.bottomCenter,
                                  child:
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextButton(
                                            onPressed: () {
                                              PinEntryScreenState().logout(context);
                                            },
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.exit_to_app, color: AppColors3.primaryColor),
                                                  SizedBox(width: 10),
                                                  Text('Cerrar sesion', style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.05, color: AppColors3.primaryColor))
                                                ]))])))])),

              ],
            )
          );
  }
}
