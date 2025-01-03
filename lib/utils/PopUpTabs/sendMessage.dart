import 'package:agenda_app/usersConfig/functions.dart';
import 'package:agenda_app/utils/showToast.dart';
import 'package:agenda_app/utils/toastWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../projectStyles/appColors.dart';

class SendMsgDialog extends StatefulWidget {
  final String? phone;
  final String clientName;
  final int clientId;
  const SendMsgDialog({super.key, required this.phone, required this.clientName, required this.clientId});

  @override
  _SendMsgDialogState createState() => _SendMsgDialogState();
}

class _SendMsgDialogState extends State<SendMsgDialog> {
  String? selectedOption;
  final List<Map<String, String>> options = [
    {'option': 'opt 1', 'message': 'msg opt 1'},
    {'option': 'opt 2', 'message': 'msg opt 2'},
    {'option': 'opt 3', 'message': 'msg opt 3'},
    {'option': 'opt 4', 'message': 'msg opt 4'},

  ];
  String nonNumberMsg = '';

  @override
  void initState() {
    // TODO: implement initState
    widget.phone != '' ? null : nonNumberMsg = "Este cliente no tiene un celular registrado.";
    super.initState();
  }

  Widget _buildRadioBtn(Map<String, String> opt) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: opt['option']!,
          groupValue: selectedOption,
          onChanged: (value) {
            setState(() {
              selectedOption = value;
            });
          },
        ),
        Text(
          opt['option']!,
          style: TextStyle(
            fontWeight: selectedOption == opt['option'] ? FontWeight.bold : null),
        ),
        /*if (selectedOption == opt['option'])
          Text(
            opt['message']!,
            style: const TextStyle(color: Colors.grey),
          ),*/
      ],
    );
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
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10),),
              border: Border.all(color: AppColors3.blackColor)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03),
                    alignment: Alignment.centerRight,
                    width: double.infinity,
                    color: AppColors3.primaryColor,
                    child: Row(
                      children: [
                        Text(
                          'Recordatorio',
                          style: TextStyle(
                            color: AppColors3.whiteColor,
                            fontSize: MediaQuery.of(context).size.width * 0.065,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(CupertinoIcons.xmark, color: AppColors3.whiteColor),
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
                            ),),
                          ],
                        ),
                        Row(
                          children: [
                            Text('${widget.phone}'),
                          ],
                        ),
                        if(widget.phone == '')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(nonNumberMsg,
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.04,
                              color: AppColors3.redDelete,
                            ),),
                          ],
                        ),
                        ...List.generate((options.length / 2).ceil(), (rowIndex) {
                          return Row(
                            children: [
                              if (rowIndex * 2 < options.length)
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Radio<String>(
                                        value: options[rowIndex * 2]['option']!,
                                        groupValue: selectedOption,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedOption = value;
                                          });
                                        },
                                      ),
                                      Text(options[rowIndex * 2]['option']!),
                                    ],
                                  ),
                                ),
                              if (rowIndex * 2 + 1 < options.length)
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Radio<String>(
                                        value: options[rowIndex * 2 + 1]['option']!,
                                        groupValue: selectedOption,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedOption = value;
                                          });
                                        },
                                      ),
                                      Text(options[rowIndex * 2 + 1]['option']!),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        }),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.03,
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: selectedOption != null? () async {
                              if(widget.phone != '' && widget.phone!.length == 10){
                                await sendWhatsMsg(phone: widget.phone!, bodymsg: 'bodymsg').then((_){
                                  Navigator.of(context).pop();
                                });
                              }else {
                                showOverlay(context, const CustomToast(message: 'Este usario no tiene registrado su número de celular'));
                              }
                            } : () {
                              showOverlay(context, const CustomToast(message: 'Por favor, seleccione una opción'));
                            },
                            child: const Text('Enviar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
