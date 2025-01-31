import 'package:agenda_app/usersConfig/functions.dart';
import 'package:agenda_app/utils/showToast.dart';
import 'package:agenda_app/utils/toastWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../projectStyles/appColors.dart';
import '../../services/customMessagesService.dart';

class SendMsgDialog extends StatefulWidget {
  final String? phone;
  final String clientName;
  final int clientId;
  const SendMsgDialog({super.key, required this.phone, required this.clientName, required this.clientId});

  @override
  _SendMsgDialogState createState() => _SendMsgDialogState();
}

class _SendMsgDialogState extends State<SendMsgDialog> {
  final CustomMessageService messageService = CustomMessageService();
  String? selectedOption;
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  String nonNumberMsg = 'Este cliente no tiene un celular registrado.';

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      final fetchedMessages = await messageService.getActiveMessages();
      if (mounted) {
        setState(() {
          messages = fetchedMessages;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error al obtener mensajes: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                      alignment: Alignment.centerRight,
                      width: double.infinity,
                      color: AppColors3.whiteColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recordatorio',
                            style: TextStyle(
                              color: AppColors3.primaryColor,
                              fontSize: MediaQuery.of(context).size.width * 0.065,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(CupertinoIcons.xmark, color: AppColors3.blackColor),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.03,
                        vertical: MediaQuery.of(context).size.width * 0.03,
                      ),
                      color: AppColors3.whiteColor,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Mensaje para ${widget.clientName}',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.045,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.05),
                            child: Row(
                              children: [
                                Text(widget.phone != 'null' ? widget.phone! : nonNumberMsg,
                                  style: TextStyle(
                                      color: widget.phone != 'null' ? AppColors3.primaryColor : AppColors3.redDelete
                                  ),),
                              ],
                            ),
                          ),
                          if (isLoading)
                            const CircularProgressIndicator()
                          else
                            ...List.generate((messages.length / 2).ceil(), (rowIndex) {
                              return DropdownButtonFormField<String>(
                                value: selectedOption,
                                onChanged: (value) {
                                  setState(() {
                                    selectedOption = value;
                                  });
                                },
                                items: messages.map((message) => DropdownMenuItem<String>(
                                  value: message['id'].toString(),
                                  child: Text(
                                    message['title'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )).toList(),
                                decoration: InputDecoration(
                                  labelText: 'Seleccione una opción',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          topLeft: Radius.circular(10)
                                      ),
                                      borderSide: BorderSide(
                                        color: AppColors3.primaryColor,
                                        width: 1,
                                      )
                                  ),
                                ),
                              );
                            }),
                          Padding(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.width * 0.05,
                              bottom: MediaQuery.of(context).size.width * 0.02
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: AppColors3.primaryColor,
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.03, horizontal: MediaQuery.of(context).size.height * 0.035)
                              ),
                              onPressed: selectedOption != null ? () async {
                                if(widget.phone != '' && widget.phone!.length == 10) {
                                  final String phoneCode = '+52${widget.phone}';
                                  final selectedMessage = messages.firstWhere(
                                          (msg) => msg['id'].toString() == selectedOption
                                  );
                                  await sendWhatsMsg(
                                      phone: phoneCode,
                                      bodymsg: selectedMessage['content']
                                  ).then((_) {
                                    Navigator.of(context).pop();
                                  });
                                } else {
                                  showOverlay(context, const CustomToast(
                                      message: 'Este usuario no tiene registrado su número de celular'
                                  ));
                                }
                              } : () {
                                showOverlay(context, const CustomToast(
                                    message: 'Por favor, seleccione una opción'
                                ));
                              },
                              child: const Text(
                                'Enviar',
                                style: TextStyle(
                                    color: AppColors3.whiteColor,
                                  fontSize: 18
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
