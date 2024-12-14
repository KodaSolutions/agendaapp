import 'dart:ui';
import 'package:agenda_app/usersConfig/apmntList.dart';
import 'package:agenda_app/usersConfig/cardAptm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../regEx.dart';
import '../../kboardVisibilityManager.dart';
import '../projectStyles/appColors.dart';

class NewAppointments extends StatefulWidget {

  const NewAppointments({super.key});

  @override
  State<NewAppointments> createState() => _NewAppointmentsState();
}

class _NewAppointmentsState extends State<NewAppointments> with SingleTickerProviderStateMixin {

  late AnimationController animationController;
  late Animation<double> opacidad;
  late String formattedDate;
  late KeyboardVisibilityManager keyboardVisibilityManager;

  bool listFF = false;
  double? screenWidth;
  double? screenHeight;
  double optSize = 0;
  bool showBlurr = false;
  int blurShowed = 0;
  int selectedPage = 0;
  int? oldIndex = 0;
  //TODO al pasarse newApmnt al sliverlist se puede pasar una lista filtrada (newApmntfilter) para generar dinamicamente las citas.
  List<Map<String, dynamic>> newApmnt = [
    {"id": 1, "name": "Cliente1", "date": "10/12/24", "time": "17:00", "detalles": [{"pet": "Mascota1", "mail": "cliente1@correo.com", "phone": "9991999999"}]},
    {"id": 2, "name": "Cliente2", "date": "10/12/25", "time": "17:00", "detalles": [{"pet": "Mascota2", "mail": "cliente2@correo.com", "phone": "9992999999"}]},
    {"id": 3, "name": "Cliente3", "date": "10/12/26", "time": "17:00", "detalles": [{"pet": "Mascota3", "mail": "cliente3@correo.com", "phone": "9993999999"}]},
    {"id": 4, "name": "Cliente4", "date": "10/12/27", "time": "17:00", "detalles": [{"pet": "Mascota4", "mail": "cliente4@correo.com", "phone": "9994999999"}]},
    {"id": 5, "name": "Cliente5", "date": "10/12/28", "time": "17:00", "detalles": [{"pet": "Mascota5", "mail": "cliente5@correo.com", "phone": "9995999999"}]},
  ];

  late List<ExpansionTileController> tileControllers;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  @override
  void initState() {
    // TODO: implement initState
    tileControllers = List.generate(
      newApmnt.length, (index) => ExpansionTileController(),
    );
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    opacidad = Tween(begin: 0.0, end:  1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
    animationController.addListener((){
      setState(() {
      });
    });
    keyboardVisibilityManager = KeyboardVisibilityManager();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardVisibilityManager.dispose();
    super.dispose();
  }
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors3.whiteColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors3.bgColor,
                leadingWidth: MediaQuery.of(context).size.width,
                pinned: true,
                leading: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        CupertinoIcons.back,
                        size: MediaQuery.of(context).size.width * 0.08,
                        color: AppColors3.primaryColor,
                      ),
                    ),
                    Expanded(
                        child: Text(
                              'Citas recibidas',
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.085,
                                fontWeight: FontWeight.bold,
                                color: AppColors3.primaryColor,
                              ),
                            )
                          ),
                  ],
                ),
              ),
              if (!listFF) ...[//TODO variable temporal la condicion seria un List.isNotEmpty
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return CardAptm(
                          index: index,
                          oldIndex: oldIndex,
                          tileController: tileControllers[index],
                          newAptm: newApmnt,
                          onExpansionChanged: (int newIndex) {
                            setState(() {
                              if (oldIndex != null && oldIndex != newIndex) {
                                tileControllers[oldIndex!].collapse();
                              }
                              oldIndex = newIndex;
                            });
                          });
                      },
                    childCount: newApmnt.length,
                  ),
                ),
              ] else ...[
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 200),
                      Center(
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.black,
                                )
                              : Text(
                                  "No hay citas pendientes",
                                  style: TextStyle(
                                      color: AppColors3.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.06),
                                )),
                    ],
                  ),
                )
              ]
            ],
          ),
        ],
      ),
    );
  }
}
