import 'dart:convert';
import 'package:agenda_app/utils/sliverlist/cardAptm.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../kboardVisibilityManager.dart';
import '../calendar/calendarSchedule.dart';
import '../projectStyles/appColors.dart';
import '../services/angedaDatabase/databaseService.dart';
import 'package:http/http.dart' as http;

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
  List<Appointment2> _appointments = [];

  bool listFF = false;
  double? screenWidth;
  double? screenHeight;
  double optSize = 0;
  bool showBlurr = false;
  int blurShowed = 0;
  int selectedPage = 0;
  int? oldIndex = 0;

  ///MANDAR A SERVICIO
  Future<void> _loadAppointments() async {
    try {
      final appointments = await fetchAppointments();
      setState(() {
        _appointments = appointments;
        tileControllers = List.generate(
          _appointments.length, (index) => ExpansionTileController(),
        );
      });
      print('bye $_appointments');
    } catch (e) {
      print('Error loading appointments: $e');
    }
  }

  Future<List<Appointment2>> fetchAppointments() async {
    List<Appointment2> appointments = [];
    final dbService = DatabaseService();
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;
      if (isConnected) {
        final response = await http.get(
          Uri.parse('https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api/getPendingAppointments'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${await getToken()}',
          },
        );

        if (response.statusCode == 200) {
          print('adios');
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse is Map<String, dynamic> && jsonResponse['appointments'] is List) {
            appointments = List<Appointment2>.from(
              jsonResponse['appointments']
                  .map((appointmentJson) => Appointment2.fromJson(appointmentJson as Map<String, dynamic>)),
            );

            print('hola alan');

            print('Datos de appointments sincronizados correctamente');
          } else {
            print('La respuesta no contiene una lista de citas.');
          }
        } else {
          print('Error al cargar citas desde la API: ${response.statusCode}');
        }
      } else {
        print('Sin conexión a internet, cargando datos locales de appointments');
        List<Map<String, dynamic>> localAppointments = await dbService.getAppointments();
        appointments = localAppointments.map((appointmentMap) => Appointment2.fromJson(appointmentMap)).toList();
      }
    } catch (e) {
      print('Error al realizar la solicitud o cargar datos locales: $e');
    }

    return appointments;
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

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
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    opacidad = Tween(begin: 0.0, end:  1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
    animationController.addListener((){
      setState(() {
      });
    });
    keyboardVisibilityManager = KeyboardVisibilityManager();
    _loadAppointments();
    print('hola jeje $_appointments');
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
                                fontSize: MediaQuery.of(context).size.width * 0.065,
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
                          newAptm: _appointments,
                          onExpansionChanged: (int newIndex) {
                            setState(() {
                              if (oldIndex != null && oldIndex != newIndex) {
                                tileControllers[oldIndex!].collapse();
                              }
                              oldIndex = newIndex;
                            });
                          }, onAppointmentUpdated: () {
                        _loadAppointments();
                      },
                          );
                      },
                    childCount: _appointments.length,
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
