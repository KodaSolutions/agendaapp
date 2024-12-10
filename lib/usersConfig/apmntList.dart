import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../kboardVisibilityManager.dart';
import '../projectStyles/appColors.dart';
import 'apmntOptions.dart';

class ApmntList extends StatefulWidget {
  //final ListenerremoverOL listenerremoverOL;
  final void Function(int) onShowBlur;
  final Function(double) onOptnSize;
  //final PrintService printService;
  //final ListenerOnDateChanged listenerOnDateChanged;
  //final String dateController;
  //final void Function(String) onDateChanged;

  const ApmntList({super.key, required this.onShowBlur, required this.onOptnSize});

  @override
  State<ApmntList> createState() => _ApmntListState();
}

class _ApmntListState extends State<ApmntList> {

  double optnSize = 0;
  List<GlobalKey> apmntKeys = [];
  OverlayEntry? overlayEntry;
  double widgetHeight = 0.0;
  bool isLoading = false;
  List<AnimationController> aniControllers = [];
  List<int> cantHelper = [];
  List<int> tapedIndices = [];
  List<dynamic> apmntInfo = [];
  late String formattedDate;
  List<Map<String, dynamic>> apmntTemp = [];

  late KeyboardVisibilityManager keyboardVisibilityManager;
  List<ExpansionTileController>? tileController = [];

  void itemCount (index, action){
    if(action == false){
      cantHelper[index] > 0 ? cantHelper[index]-- : cantHelper[index] = 0;
      if(cantHelper[index] == 0){
        tapedIndices.remove(index);
        aniControllers[index].reverse().then((_){
          aniControllers[index].reset();
        });
      }
    }else{
      cantHelper[index]++;
    }
  }

  Map<int, List<Map<String, dynamic>>> groupByTicket(List<Map<String, dynamic>> ticketProducts) {
    Map<int, List<Map<String, dynamic>>> groupedTickets = {};
    for (var product in ticketProducts) {
      if (!groupedTickets.containsKey(product['ticketID'])) {
        groupedTickets[product['ticketID']] = [];
      }
      groupedTickets[product['ticketID']]!.add(product);
    }
    return groupedTickets;
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    keyboardVisibilityManager.dispose();
  }

  @override
  void initState() {
    super.initState();
    keyboardVisibilityManager = KeyboardVisibilityManager();
    apmntKeys = List.generate(newApmnt.length, (index) => GlobalKey());
    //optnSize = apmntKeys[0].currentContext!.size!.height;
    /*fetchSales(widget.dateController, widget.dateController).then((_){
      WidgetsBinding.instance.addPostFrameCallback((_){
        optnSize = ticketKeys[0].currentContext!.size!.height;
      });
    });*/
    /*widget.listenerremoverOL.registrarObservador((newValue){
      if(newValue == true){
        removeOverlay();
      }
    });
    widget.listenerOnDateChanged.registrarObservador((callback, initData, finalData) async {
      if(callback){
        await fetchSales(initData, finalData).then((_){
          WidgetsBinding.instance.addPostFrameCallback((_){
            optnSize = ticketKeys[0].currentContext!.size!.height;
          });
        });
      }
    });*/
  }

  /*Future<void> fetchSales(String? initData, String? finalData) async{
    setState(() {
      isLoading = true;
    });
    widget.onDateChanged(initData!);
    try{
      final salesService = SalesServices();
      final tickets2 = await salesService.fetchSales(initData, finalData);
      setState(() {
        tileController = [];
        tickets = tickets2;
        tickets2.sort((a, b) => b['id'].compareTo(a['id']));
        ticketKeys = List.generate(tickets.length, (index) => GlobalKey()); // Actualiza ticketKeys
        for (int i = 0; i <= tickets.length; i++) {
          tileController?.add(ExpansionTileController());
        }
        cantHelper = List.generate(tickets.length, (index) => 0);
        Future.delayed(Duration(milliseconds: 250));
        isLoading = false;
      });
    }catch (e) {
      print('Error fetching sales: $e');
      setState(() {
        isLoading = false;
      });
    }
  }*/

  void colHeight (double colHeight) {
    widgetHeight = colHeight;
  }

  void showApmntOptions(int index) {
    //tileController![index].isExpanded ? tileController![index].collapse() : null;
    apmntInfo.addAll([
      newApmnt[index]['id'],
      newApmnt[index]['name'],
      newApmnt[index]['date'],
      newApmnt[index]['detalles'],
    ]);
    if (index >= 0 && index < newApmnt.length) {
      apmntTemp = [newApmnt[index]];
      print('holajeje $apmntTemp');
      removeOverlay();
      final key = apmntKeys[index];
      if (key.currentContext != null && key.currentContext!.findRenderObject() is RenderBox) {
        final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
        final size = renderBox.size;
        final position = renderBox.localToGlobal(Offset.zero);
        final screenHeight = MediaQuery.of(context).size.height;
        final availableSpaceBelow = screenHeight - position.dy;

        double topPosition;

        if (availableSpaceBelow >= widgetHeight) {
          topPosition = position.dy;
        } else {
          topPosition = screenHeight - widgetHeight - MediaQuery.of(context).size.height * 0.03;
        }

        overlayEntry = OverlayEntry(
          builder: (context) {
            return Positioned(
              top: topPosition - 7,
              left: position.dx,
              width: size.width,
              child: IntrinsicHeight(
                child: ApmntOptions(
                  heigthCard: optnSize,
                  onClose: removeOverlay,
                  columnHeight: colHeight,
                  onShowBlur: widget.onShowBlur,
                  columnH: null,
                  apmntInfo: apmntInfo,
                  apointment: apmntTemp,
                ),
              ),
            );
          },
        );
        Overlay.of(context).insert(overlayEntry!);
        widget.onShowBlur(1);
      } else {
        print("RenderBox is null or not valid for ticket $index");
      }
    } else {
      print("Invalid index or no tickets available");
    }
  }

  void removeOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
      apmntInfo.clear();

    }
    for (var controller in aniControllers) {
      if (controller.isAnimating) {
        controller.stop();
      }
    }
    if (mounted) {
      widget.onShowBlur(0);
    }
  }

  List<Map<String, dynamic>> newApmnt = [
    {"id": 1, "name": "Cliente1", "date": "10/12/24", "time": "17:00", "detalles": [{"pet": "Mascota1", "mail": "cliente1@correo.com", "phone": "9999999999"}]},
    {"id": 2, "name": "Cliente2", "date": "10/12/24", "time": "17:00", "detalles": [{"pet": "Mascota1", "mail": "cliente1@correo.com", "phone": "9999999999"}]},
    {"id": 3, "name": "Cliente3", "date": "10/12/24", "time": "17:00", "detalles": [{"pet": "Mascota1", "mail": "cliente1@correo.com", "phone": "9999999999"}]},
    {"id": 4, "name": "Cliente4", "date": "10/12/24", "time": "17:00", "detalles": [{"pet": "Mascota1", "mail": "cliente1@correo.com", "phone": "9999999999"}]},
    {"id": 5, "name": "Cliente5", "date": "10/12/24", "time": "17:00", "detalles": [{"pet": "Mascota1", "mail": "cliente1@correo.com", "phone": "9999999999"}]},
  ];

  @override
  Widget build(BuildContext context) {
    print(newApmnt);
    // final groupedTickets = groupByTicket(ticketProducts);
    return Container(
        color: AppColors3.bgColor,
        child: !isLoading ? (
            newApmnt.isNotEmpty ? ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: newApmnt.length,
              itemBuilder: (context, index) {
                return Container(
                    key: apmntKeys[index],
                    margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03, right: MediaQuery.of(context).size.width * 0.03, bottom: MediaQuery.of(context).size.width * 0.03),
                    decoration: BoxDecoration(
                      color: AppColors3.bgColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors3.blackColor.withOpacity(0.1),
                          offset: const Offset(4, 4),
                          blurRadius: 2,
                          spreadRadius: 0.1,
                        )
                      ],
                    ),
                    child: GestureDetector(
                      onLongPress: () {
                        print(apmntKeys);
                        keyboardVisibilityManager.hideKeyboard(context);
                        showApmntOptions(index);
                        widget.onShowBlur(2);

                      },
                      child: ExpansionTile(
                          //controller: tileController![index],
                          iconColor: AppColors3.bgColor,
                          collapsedIconColor: AppColors3.primaryColor,
                          backgroundColor: AppColors3.primaryColor,
                          collapsedBackgroundColor: Colors.transparent,
                          textColor: AppColors3.bgColor,
                          collapsedTextColor: AppColors3.primaryColor,
                          tilePadding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.04,
                              right: MediaQuery.of(context).size.width * 0.02,
                              top: MediaQuery.of(context).size.width * 0.01,
                              bottom: MediaQuery.of(context).size.width * 0.015
                          ),
                          initiallyExpanded: false,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  color: AppColors3.primaryColor,
                                  width: 2
                              )
                          ),
                          title: Text(
                            'Cita ${newApmnt[index]['id']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width * 0.05,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Fecha de cita: ',
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width * 0.04,
                                    ),
                                  ),
                                  Text(
                                    '${newApmnt[index]['date']}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).size.width * 0.04),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Cliente: ',
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.04
                                    ),
                                  ),
                                  Text(
                                    '${newApmnt[index]['name']}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).size.width * 0.04),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          children: [
                            Container(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.04, top: MediaQuery.of(context).size.width * 0.04, left: MediaQuery.of(context).size.width * 0.04),
                              decoration: const BoxDecoration(
                                  color: AppColors3.bgColor,
                                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                  border: Border(
                                      top: BorderSide(color: AppColors3.primaryColor, width: 2)
                                  )
                              ),
                              child: Column(
                                children: newApmnt[index]['detalles'].map<Widget>((detalle) {
                                  return ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: MediaQuery.of(context).size.width * 0.06),
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Mascota: ",
                                              style: TextStyle(
                                                  color: AppColors3.primaryColor,
                                                  fontSize: MediaQuery.of(context).size.width * 0.035),
                                            ),
                                            Text(
                                              '${detalle['pet']}',
                                              style: TextStyle(
                                                color: AppColors3.primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context).size.width * 0.04,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Correo: ",
                                              style: TextStyle(
                                                  color: AppColors3.primaryColor,
                                                  fontSize: MediaQuery.of(context).size.width * 0.035),
                                            ),
                                            Text(
                                              '${detalle['mail']}',
                                              style: TextStyle(
                                                  color: AppColors3.primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: MediaQuery.of(context).size.width * 0.035),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Teléfono: ",
                                              style: TextStyle(
                                                  color: AppColors3.primaryColor,
                                                  fontSize: MediaQuery.of(context).size.width * 0.035),
                                            ),
                                            Text(
                                              '\$${detalle['phone']}',
                                              style: TextStyle(
                                                color: AppColors3.primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context).size.width * 0.035,
                                              ),
                                            ),
                                          ],
                                        ),
                                        /*Row(
                                          children: [
                                            Text(
                                              "Total: ",
                                              style: TextStyle(
                                                  color: AppColors3.primaryColor,
                                                  fontSize: MediaQuery.of(context).size.width * 0.035),
                                            ),
                                            Text(
                                              '\$${detalle['cantidad'] * double.parse(detalle['precio'])}',
                                              style: TextStyle(
                                                color: AppColors3.primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context).size.width * 0.035,
                                              ),
                                            ),
                                          ],
                                        ),*/
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                          ]
                      ),
                    )
                );
              },
            ) : const Center(
              child: Text(
                'No hay citas nuevas',
                style: TextStyle(
                    color: AppColors3.primaryColor
                ),
              ),
            )
        ) : const Center(
          child: CircularProgressIndicator(
            color: AppColors3.primaryColor,
          ),
        )
    );
  }
}