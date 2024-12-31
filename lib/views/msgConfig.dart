import 'dart:ui';

import 'package:agenda_app/forms/msgForm.dart';
import 'package:agenda_app/utils/PopUpTabs/deletePredetMsg.dart';
import 'package:agenda_app/utils/sliverlist/msgCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../projectStyles/appColors.dart';
import '../utils/listenerSlidable.dart';

class MsgConfig extends StatefulWidget {
  const MsgConfig({super.key});

  @override
  State<MsgConfig> createState() => _MsgConfigState();
}

class _MsgConfigState extends State<MsgConfig> with TickerProviderStateMixin {

  List<SlidableController> slidableControllers = [];
  TextEditingController seekController = TextEditingController();
  bool showBlurr = false;
  List <Map<String, String>> filteredMsg = [];

  List<Map<String, String>> mensajes = [
    {
      "titulo": "Vacunación preventiva",
      "cuerpo": "Recuerde vacunar a sus mascotas para protegerlas de enfermedades."
    },
    {
      "titulo": "Horario extendido",
      "cuerpo": "Nuestra veterinaria estará abierta hasta las 10 PM este viernes."
    },
    {
      "titulo": "Adopción de mascotas",
      "cuerpo": "Visítenos este sábado para conocer a mascotas en busca de un hogar."
    },
    {
      "titulo": "Consulta gratuita",
      "cuerpo": "Traiga a su mascota para una consulta gratuita este fin de semana."
    },
    {
      "titulo": "Nueva sucursal",
      "cuerpo": "¡Hemos abierto una nueva sucursal en el centro de la ciudad!"
    },
    {
      "titulo": "Promoción en alimentos",
      "cuerpo": "Descuento del 20% en alimentos premium para mascotas hasta el lunes."
    },
    {
      "titulo": "Servicios de urgencias",
      "cuerpo": "Ofrecemos servicios de urgencias veterinarias las 24 horas."
    },
  ];
  void filtrarMensajes(String query) {
    query = query.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredMsg = mensajes;
      } else {
        filteredMsg = mensajes.where((mensaje) {
          final titulo = mensaje["titulo"]?.toLowerCase() ?? "";
          // final cuerpo = mensaje["cuerpo"]?.toLowerCase() ?? "";
          return titulo.contains(query);
        }).toList();
      }
    });
  }

  final Listenerslidable listenerslidable = Listenerslidable();
  bool dragStatus = false; //false = start
  bool isDragX = false;
  int itemDragX = 0;

  void hideBorderRadius(){
    listenerslidable.setChange(
      isDragX,
      itemDragX,
    );
  }
  void showBorderRadius(){
    listenerslidable.setChange(
      false,
      itemDragX,
    );
  }

  void initializeSlidableControllers(int number) {
    slidableControllers.clear();
    for (int i = 0; i < number; i++) {
      final controller = SlidableController(this);
      controller.animation.addListener(() {
        double dragRatio = controller.ratio;
        if(mounted){
          if (dragRatio != 0) {
            setState(() {
              isDragX = true;
              itemDragX = i;
              hideBorderRadius();
            });
          } else {
            setState(() {
              itemDragX = i;
              isDragX = false;
              showBorderRadius();
            });
          }
        }
      });
      slidableControllers.add(controller);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    filteredMsg = mensajes;//TODO esto tambien se quita y va cuando se haga el fetch
    initializeSlidableControllers(mensajes.length);//TODO esto se quita de aqui cuando se haga el fetch de mensajes,para que se creen los controladores junto con los mensajes
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in slidableControllers) {
      controller.animation.removeListener(() {});
      controller.dispose();
    }
    slidableControllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leadingWidth: MediaQuery.of(context).size.width,
            leading: Row(
              children: [
                IconButton(onPressed: (){
                  Navigator.of(context).pop();
                }, icon: Icon(CupertinoIcons.chevron_back, size: MediaQuery.of(context).size.width * 0.08,
                  color: AppColors3.primaryColor,)),
                Text('Gestionar mensajes', style: TextStyle(
                  color: AppColors3.primaryColor,
                  fontSize: MediaQuery.of(context).size.width * 0.065,
                ),),
              ],
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                  child: Container(
                      margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.03,
                        left: MediaQuery.of(context).size.width * 0.03,
                        bottom: MediaQuery.of(context).size.width * 0.03,
                        top: MediaQuery.of(context).size.width * 0.02,
                      ),
                      child: Row(
                          children: [
                            Expanded(
                                child: CupertinoTextField(
                                    controller: seekController,
                                    placeholder: 'Buscar mensaje por título...',
                                    prefix: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Icon(
                                        CupertinoIcons.search,
                                        size: 20.0,
                                        color: CupertinoColors.systemGrey.withOpacity(0.6),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: CupertinoColors.systemGrey.withOpacity(0.6), width: 2),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    onChanged: (text){
                                      filtrarMensajes(text);
                                    })),
                            const SizedBox(width: 20,),
                            IconButton(onPressed: (){
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => const MsgForm(
                                  ),
                                ),
                              );
                            }, icon: Icon(Icons.message_outlined, size: MediaQuery.of(context).size.width * 0.082,))
                          ]))
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.02,
                        right: MediaQuery.of(context).size.width * 0.02,
                        bottom:  MediaQuery.of(context).size.width * 0.02,
                      ),
                      child: Slidable(
                        controller: slidableControllers[index],
                        key: ValueKey(index),
                        startActionPane: null,
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          /*   dismissible: DismissiblePane(

                  onDismissed: () {
                  },
                ),*/
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                setState(() {
                                  showBlurr = true;
                                });
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const Material(
                                        color: Colors.transparent,
                                        child: Center(
                                            child: DeletePredMsg()
                                        )
                                    );
                                  },
                                );
                                if (confirm == true) {
                                  print("Mensaje elimination");
                                  setState(() {
                                    showBlurr = false;
                                  });
                                }else{
                                  setState(() {
                                    print("Mensaje cancelado");
                                    showBlurr = false;
                                  });                                }
                              },
                              backgroundColor: AppColors3.redDelete,
                              foregroundColor: AppColors3.whiteColor,
                              icon: Icons.delete,
                              label: 'Eliminar',
                            ),
                            SlidableAction(
                              onPressed: (context) async {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) => MsgForm(
                                      title: mensajes[index]['titulo'] ?? 'Titulo no disponible',
                                      bodyMsg: mensajes[index]['cuerpo'] ?? 'Texto no disponible',
                                    ),
                                  ),
                                );
                              },
                              backgroundColor: AppColors3.primaryColor,
                              foregroundColor: AppColors3.whiteColor,
                              icon: Icons.edit,
                              label: 'Modificar',
                            ),
                          ],
                        ),
                        child: MsgCard(
                          filteredMsg: filteredMsg,
                          index: index,
                          query: seekController.text,
                          listenerslidable: listenerslidable,
                        ),
                      ),);
                  },
                    childCount: filteredMsg.length,
                  ))
            ],
          ),
        ),
        Visibility(
            visible: showBlurr,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showBlurr = false;
                });
              },
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white.withOpacity(0.3),
                  ),),
            )),
      ],
    );
  }
}
