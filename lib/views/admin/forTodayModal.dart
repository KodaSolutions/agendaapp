import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../calendar/calendarSchedule.dart';
import '../../projectStyles/appColors.dart';
import '../../utils/sliverlist/notiCards.dart';

class Fortodaymodal extends StatefulWidget {

  @override
  _FortodaymodalState createState() => _FortodaymodalState();

  bool tap = false;

  Future<bool?> showModal(BuildContext context) async {
    if (tap == false) {
      return await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) {
          return Fortodaymodal();  // Retorna el widget del modal.
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(0.0, -1.0);  // Empieza desde arriba
          var end = const Offset(0.0, 0.0);
          var curve = Curves.linear;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
    }
    return null;
  }
}

class _FortodaymodalState extends State<Fortodaymodal> with SingleTickerProviderStateMixin {

  late AnimationController animationController;
  late Animation<double> dragYAnimation;

  double? screenWidth;
  double? screenHeight;
  int? userId;
  late Future<List<Appointment2>> todayAppointments;
  late Future<List<Appointment2>> tomorrowAppointments;

  double initDragY = 0;
  double lastDragY = 0;
  double dragY = 0;
  double heightCard = 0;
  double halfheightCard = 0;
  int totalCards = 0;

  void onDragY (details){
    setState(() {
        dragY = details.delta.dy + dragY;
        if(dragY > 0){
          dragY = 0;
        }
    });
  }

  void onStopedDragY(details){
    setState(() {
      if(dragY > halfheightCard){
        dragYAnimation = Tween<double>(begin: dragY, end: 0.0).animate(CurvedAnimation(
          parent: animationController,
          curve: Curves.linear,
        ));
        animationController.forward(from: 0.0);
      }else if(dragY < halfheightCard){
        dragYAnimation = Tween<double>(begin: dragY, end: -screenHeight!).animate(CurvedAnimation(
          parent: animationController,
          curve: Curves.linear,
        ));
        animationController.forward(from: 0.0).then((_){
          Navigator.of(context).pop(true);
        });
      }
    });
  }

  void onCalculateHeightCard(double heightCard){
    this.heightCard = 230 + heightCard * totalCards;
    halfheightCard = - (this.heightCard/2);
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    loadUserId();
    dragYAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(animationController)
      ..addListener(() {
        setState(() {
          dragY = dragYAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<void> loadUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
    });
    if (userId != null) {
      todayAppointments = fetchAppointmentsByDate(userId!, DateTime.now().toString());
      tomorrowAppointments = fetchAppointmentsByDate(userId!, DateTime.now().add(Duration(days: 1)).toString());
      List<Appointment2> countToday = await todayAppointments;
      List<Appointment2> countTomorrow = await tomorrowAppointments;
      int countTod = countToday.length;
      int countTom = countTomorrow.length;
      if(countTom + countTod < 6){
        totalCards = countTom + countTod;
      } else {
        totalCards = 5;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // blurTappable
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: double.infinity,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop(true);
              },
            ),
          ),
              AnimatedBuilder(
                animation: animationController,
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.width * 0.25,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors3.whiteColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _buildSection('HOY', todayAppointments),
                            _buildSection('MAÑANA', tomorrowAppointments),
                          ],
                        ),
                      ),),
                      GestureDetector(
                        onVerticalDragUpdate: (details) {
                          onDragY(details);
                        },
                        onVerticalDragEnd: (details) {
                          setState(() {
                            onStopedDragY(details);
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors3.whiteColor,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width * 0.2,
                          child: IconButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              icon: Icon(
                                CupertinoIcons.chevron_compact_up,
                                size: MediaQuery.of(context).size.width * 0.15,
                                color: AppColors3.blackColor.withOpacity(0.5),
                              ))))
                ])),
            builder: (context, modal) {
                  return Transform.translate(
                    offset: Offset(0, dragY),
                    child: modal,
                );
              })
        ]));
  }

  Widget _buildSection(String title, Future<List<Appointment2>> appointmentsFuture) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: true,
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.04,
                  left: MediaQuery.of(context).size.width * 0.02,
                  right: MediaQuery.of(context).size.width * 0.02,
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    color: AppColors3.primaryColorMoreStrong
                  ),
                ),
              ),
            ],
          ),),
        FutureBuilder<List<Appointment2>>(
          future: appointmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text(
                  'No hay citas',
                style: TextStyle(
                  color: AppColors3.blackColor.withOpacity(0.3)
                ),
              );
            } else {
              return Column(
                children: snapshot.data!.map((appointment) {
                  return NotiCards(appointment: appointment, onCalculateHeightCard: onCalculateHeightCard);
                }).toList(),
              );
            }
          })
    ]);
  }
}