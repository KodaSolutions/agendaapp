import 'package:agenda_app/usersConfig/selBoxUser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../projectStyles/appColors.dart';

class CardAptm extends StatefulWidget {
  final int index;
  const CardAptm({super.key, required this.index});

  @override
  State<CardAptm> createState() => _CardAptmState();
}

class _CardAptmState extends State<CardAptm> {

  String? user;
  bool isUserSel = false;
  String? selectedUserId;
  List<ExpansionTileController> controllers = [];
  late int? currentOpenIndex;

  List<Map<String, dynamic>> newApmnt = [
    {"id": 1, "name": "Cliente1", "date": "10/12/24", "time": "17:00", "detalles": [{"pet": "Mascota1", "mail": "cliente1@correo.com", "phone": "9999999999"}]},
    {"id": 2, "name": "Cliente2", "date": "10/12/24", "time": "17:00", "detalles": [{"pet": "Mascota1", "mail": "cliente1@correo.com", "phone": "9999999999"}]},
    {"id": 3, "name": "Cliente3", "date": "10/12/24", "time": "17:00", "detalles": [{"pet": "Mascota1", "mail": "cliente1@correo.com", "phone": "9999999999"}]},
    {"id": 4, "name": "Cliente4", "date": "10/12/24", "time": "17:00", "detalles": [{"pet": "Mascota1", "mail": "cliente1@correo.com", "phone": "9999999999"}]},
    {"id": 5, "name": "Cliente5", "date": "10/12/24", "time": "17:00", "detalles": [{"pet": "Mascota1", "mail": "cliente1@correo.com", "phone": "9999999999"}]},
  ];

  void onSelUser(String? displayText, String? userId) {
    setState(() {
      user = displayText;
      selectedUserId = userId;
      isUserSel = displayText != null && userId != null;
    });
  }

  @override
  void initState() {
    super.initState();
    currentOpenIndex = null;
    controllers = newApmnt.map((apmnt) => ExpansionTileController()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.width * 0.03,
        horizontal: MediaQuery.of(context).size.width * 0.03
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors3.whiteColor,
        boxShadow: [
          BoxShadow(
            color: AppColors3.blackColor.withOpacity(0.1),
            offset: const Offset(4, 4),
            blurRadius: 2,
            spreadRadius: 0.1,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ExpansionTile(
            controller: controllers[widget.index],
            onExpansionChanged: (value) {
              print('valor actual $currentOpenIndex');
              setState(() {
                if (value) {
                  if (currentOpenIndex != null) {
                    print('no es nulo');
                  }
                  // Actualiza el índice actual al que se está abriendo
                  currentOpenIndex = widget.index;
                } else if (currentOpenIndex == widget.index) {
                  print('igual al anterior');
                  // Si se cierra el actual, limpia el índice
                  currentOpenIndex = null;
                }
              });
              print('hola4 $currentOpenIndex');
            },
            initiallyExpanded: false,
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(
                    color: AppColors3.primaryColor,
                    width: 2
                )
            ),
            title: Text(
              'Cita ${newApmnt[widget.index]['id']}',
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
                      '${newApmnt[widget.index]['date']}',
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
                      '${newApmnt[widget.index]['name']}',
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
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.width * 0.04,
                    top: MediaQuery.of(context).size.width * 0.04,
                    left: MediaQuery.of(context).size.width * 0.0),
                decoration: const BoxDecoration(
                    color: AppColors3.bgColor,
                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                    border: Border(
                        top: BorderSide(color: AppColors3.primaryColor, width: 2)
                    )
                ),
                child: Column(
                  children: newApmnt[widget.index]['detalles'].map<Widget>((detalle) {
                    return ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Mascota: ",
                                style: TextStyle(
                                    color: AppColors3.primaryColor,
                                    fontSize: MediaQuery.of(context).size.width * 0.05),
                              ),
                              Text(
                                '${detalle['pet']}',
                                style: TextStyle(
                                  color: AppColors3.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.width * 0.05,
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
                                    fontSize: MediaQuery.of(context).size.width * 0.05),
                              ),
                              Text(
                                '${detalle['mail']}',
                                style: TextStyle(
                                    color: AppColors3.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.width * 0.05),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Teléfono: ",
                                style: TextStyle(
                                    color: AppColors3.primaryColor,
                                    fontSize: MediaQuery.of(context).size.width * 0.05),
                              ),
                              Text(
                                '${detalle['phone']}',
                                style: TextStyle(
                                  color: AppColors3.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.width * 0.05,
                                ),
                              ),
                            ],
                          ),
                          Padding(padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.width * 0.04,
                          ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: SelBoxUser(onSelUser: onSelUser, requiredRole: 1,),
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: (){}, child: const Icon(Icons.check)),
                                    SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: (){}, child: Icon(CupertinoIcons.xmark)),
                                  ],
                                ),
                              ],
                            )
                          ),
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
  }
}
