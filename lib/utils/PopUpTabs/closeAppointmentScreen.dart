import 'dart:ui';
import 'package:flutter/material.dart';

import '../../projectStyles/appColors.dart';

class AlertCloseAppointmentScreen extends StatefulWidget {
  final void Function(bool, BuildContext) onCancelConfirm;

  const AlertCloseAppointmentScreen({super.key, required this.onCancelConfirm});

  @override
  State<AlertCloseAppointmentScreen> createState() =>
      _AlertCloseAppointmentScreen();
}

class _AlertCloseAppointmentScreen extends State<AlertCloseAppointmentScreen> {
  bool cancelConfirm = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Container(
            color: Colors.black54.withOpacity(0.3),
          ),
        ),
        Center(
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.02),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.25,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(blurRadius: 3.5, offset: Offset(0, 0))
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width * 0.028,
                    ),
                    child: Text(
                      textAlign: TextAlign.center,
                      '¿Deseas salir \nsin guardar?',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.075,
                        color: AppColors3.primaryColor,
                      ),
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: TextButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              cancelConfirm = true;
                            });
                            widget.onCancelConfirm(cancelConfirm, context);
                            print(cancelConfirm);
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.red, width: 2))
                            ),
                            child: const Text(
                              'Salir',
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                          )
                        ),
                      ),
                      TextButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(4),
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: AppColors2.primaryColor, width: 2))
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: AppColors2.primaryColor, fontSize: 20),
                          ),
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
