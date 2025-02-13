import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../calendar/calendarSchedule.dart';
import '../../projectStyles/appColors.dart';
import '../../utils/paintToNotifications.dart';
import '../../utils/sliverlist/notiCards.dart';

class NotificationsScreen extends StatefulWidget {
  final Function(int) onCloseForToday;

  const NotificationsScreen({super.key, required this.onCloseForToday});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  double? screenWidth;
  double? screenHeight;
  int? userId;
  late Future<List<Appointment2>> todayAppointments;
  late Future<List<Appointment2>> tomorrowAppointments;

  @override
  void initState() {
    super.initState();
    todayAppointments = Future.value([]);
    tomorrowAppointments = Future.value([]);
    print('screenWidth $screenWidth');
    loadUserId();
  }
  Future<void> loadUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
    });
    if (userId != null) {
      todayAppointments = fetchAppointmentsByDate(userId!, DateTime.now().toString());
      tomorrowAppointments = fetchAppointmentsByDate(userId!, DateTime.now().add(Duration(days: 1)).toString());
    }
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    print('screenWidth $screenWidth');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.transparent
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                    children: [
                      ///este column representa el fondo
                      Column(
                          children: [
                            SizedBox(
                              height: screenWidth! < 370.00
                                  ? MediaQuery.of(context).size.height * 0.027
                                  : MediaQuery.of(context).size.height * 0.0252,
                            ),
                            Expanded(
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: AppColors3.primaryColor,
                                          width: 2.5,
                                        ))))
                          ]),
                      Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: screenWidth! < 370.00
                                      ? MediaQuery.of(context).size.width * 0.725 //pantallas < 370
                                      : screenWidth! < 391.00 ? MediaQuery.of(context).size.width * 0.7225 :
                                  MediaQuery.of(context).size.width * 0.7525, //pantallas > 370
                                ),
                                CustomPaint(
                                  painter: TrianglePainter(),
                                  size: Size(MediaQuery.of(context).size.width * 0.1,
                                      MediaQuery.of(context).size.width * 0.065),
                                ),
                              ],
                            ),
                            Expanded(
                                child: SingleChildScrollView(
                                    child: Column(children: [
                                      _buildSection('HOY', todayAppointments),
                                      _buildSection('MAÑANA', tomorrowAppointments),
                                    ])))
                          ])
                    ]))),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.03),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors2.BgprimaryColor.withOpacity(0.5),
            ),
            child: IconButton(
              onPressed: (){
                setState(() {
                  widget.onCloseForToday(1);
                });
              }, icon: Icon(Icons.close,size: MediaQuery.of(context).size.width * 0.065,
            color: Colors.black,
            ),
            ),
          ),
        ),

      ],
    );
  }
/*  */
  Widget _buildSection(
      String title, Future<List<Appointment2>> appointmentsFuture) {
    return Column(
      children: [
        Row(children: [
          Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.04,
                  left: MediaQuery.of(context).size.width * 0.02,
                  right: MediaQuery.of(context).size.width * 0.02),
              child: Text(title,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                  )))
        ]),
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.02),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.0035,
          decoration: const BoxDecoration(
            color: AppColors2.primaryColor,
          ),
        ),
        FutureBuilder<List<Appointment2>>(
          future: appointmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No hay citas');
            } else {
              return Column(
                children: snapshot.data!.map((appointment) {
                  return NotiCards(
                    nameDoc: '',
                    appointment: appointment, onCalculateHeightCard: (wd ) {  },);
                }).toList(),
              );
            }
          },
        ),
      ],
    );
  }
}
