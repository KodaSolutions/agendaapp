import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../projectStyles/appColors.dart';
import '../../../../utils/showToast.dart';
import '../../../../utils/toastWidget.dart';

class ApmntOptions extends StatefulWidget {
  final double heigthCard;
  final List<dynamic> apmntInfo;
  final VoidCallback onClose;
  final Function(double) columnHeight;
  final void Function(int) onShowBlur;
  final dynamic columnH;
  final List<Map<String, dynamic>> apointment;

  const ApmntOptions({super.key, required this.onClose, required this.columnH, required this.onShowBlur, required this.columnHeight, required this.heigthCard, required this.apmntInfo, required this.apointment,
  });

  @override
  State<ApmntOptions> createState() => _ApmntOptionsState();
}

class _ApmntOptionsState extends State<ApmntOptions> {

  final GlobalKey _columnKey = GlobalKey();
  double _columnHeight = 0.0;
  List<dynamic> apmntDetails = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateHeight();
    });
    apmntDetails = widget.apmntInfo[3];
    print(apmntDetails);
  }

  void _calculateHeight() {
    final RenderBox? renderBox =
    _columnKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _columnHeight = renderBox.size.height;
        widget.columnHeight(_columnHeight);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: GestureDetector(
            onTap: (){
              widget.onClose();
            },
            child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                child: Column(
                    key: _columnKey,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: widget.heigthCard,
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.04,
                          vertical: MediaQuery.of(context).size.width * 0.009,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: AppColors3.whiteColor,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Cita ${widget.apmntInfo[0]}',
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
                                  "Fecha de cita: ${widget.apmntInfo[2]}",
                                  style: TextStyle(
                                      color: AppColors3.primaryColor,
                                      fontSize: MediaQuery.of(context).size.width * 0.04),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Cliente: ${widget.apmntInfo[1]}",
                                  style: TextStyle(
                                      color: AppColors3.primaryColor,
                                      fontSize: MediaQuery.of(context).size.width * 0.04),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.01),
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.03,
                            vertical: MediaQuery.of(context).size.width * 0.02,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: AppColors3.whiteColor,
                          ),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(color: AppColors3.primaryColor.withOpacity(0.3),),
                                            )
                                        ),
                                        child: TextButton(
                                            onPressed: () {
                                              widget.onClose();
                                            },
                                            style: const ButtonStyle(
                                              alignment: Alignment.centerLeft,
                                            ),
                                            child: const Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Asignar       ',
                                                  style: TextStyle(
                                                      color: AppColors3.primaryColor
                                                  ),
                                                ),
                                                Icon(Icons.add_circle_rounded),
                                              ],
                                            )
                                        )
                                    ),
                                  ],
                                ),
                                Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                          onPressed: () {
                                            widget.onClose();
                                            //widget.onShowBlur(1);
                                          },
                                          style: const ButtonStyle(
                                              alignment: Alignment.centerLeft
                                          ),
                                          child: const Row(
                                              children: [
                                                Text(
                                                  'Eliminar       ',
                                                  style: TextStyle(
                                                      color: AppColors3.redDelete
                                                  ),
                                                ),
                                                Icon(Icons.delete, color: AppColors3.redDelete,),
                                              ]))
                                    ])
                              ]))
                    ]))));
  }
}
