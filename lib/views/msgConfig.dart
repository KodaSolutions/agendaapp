import 'dart:ui';

import 'package:agenda_app/forms/msgForm.dart';
import 'package:agenda_app/utils/PopUpTabs/deletePredetMsg.dart';
import 'package:agenda_app/utils/sliverlist/msgCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../projectStyles/appColors.dart';
import '../services/customMessagesService.dart';
import '../utils/listenerSlidable.dart';

final CustomMessageService messageService = CustomMessageService();

class MsgConfig extends StatefulWidget {
  const MsgConfig({super.key});

  @override
  State<MsgConfig> createState() => _MsgConfigState();
}

class _MsgConfigState extends State<MsgConfig> with TickerProviderStateMixin {

  List<SlidableController> slidableControllers = [];
  TextEditingController seekController = TextEditingController();
  bool showBlurr = false;
  List<Map<String, dynamic>> messages = [];
  List<Map<String, dynamic>> filteredMsg = [];
  bool isLoading = true;


  void filtrarMensajes(String query) {
    query = query.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredMsg = messages;
      } else {
        filteredMsg = messages.where((mensaje) {
          final titulo = mensaje["title"]?.toLowerCase() ?? "";
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

    super.initState();
    fetchMessages();
  }
  Future<void> fetchMessages() async {
    try {
      final fetchedMessages = await messageService.getActiveMessages();
      setState(() {
        messages = fetchedMessages;
        filteredMsg = fetchedMessages;
        isLoading = false;
        initializeSlidableControllers(messages.length);
      });
    } catch (e) {
      print('Error al obtener mensajes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  ///esta funcion esta pendiente, no hace lo que deberia, se agrego en el boton de crear
  void reloadMsgs() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final fetchedMessages = await messageService.getActiveMessages();
      if (!mounted) return;

      for (var controller in slidableControllers) {
        controller.dispose(); // Limpiamos los controladores existentes
      }

      setState(() {
        messages = fetchedMessages;
        filteredMsg = List.from(fetchedMessages);
        slidableControllers.clear();
        isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          initializeSlidableControllers(messages.length);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      print('Error al recargar mensajes: $e');
    }
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
                  fontWeight: FontWeight.bold,
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
                            IconButton(onPressed: () async {
                              final result = await Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => const MsgForm(
                                  ),
                                ),
                              );
                              if (result != null && mounted) {
                                 //reloadMsgs();
                              }
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
                                        child: Center(child: DeletePredMsg())
                                    );
                                  },
                                );
                                if (confirm == true) {
                                  try {
                                    await messageService.deleteMessage(filteredMsg[index]['id']);
                                    setState(() {
                                      messages.removeAt(index);
                                      filteredMsg.removeAt(index);
                                      showBlurr = false;
                                    });
                                    /*ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Mensaje eliminado con éxito')),
                                    );*/
                                  } catch (e) {
                                    setState(() {
                                      showBlurr = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error al eliminar mensaje: $e')),
                                    );
                                  }
                                } else {
                                  setState(() {
                                    showBlurr = false;
                                  });
                                }
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
                                      id: filteredMsg[index]['id'],
                                      title: filteredMsg[index]['title'],
                                      bodyMsg: filteredMsg[index]['content'],
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
