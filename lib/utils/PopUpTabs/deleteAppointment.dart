import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../projectStyles/appColors.dart';
import '../../views/admin/admin.dart';

Future<bool> showDeleteAppointmentDialog(BuildContext context, Widget widget, int? id, bool docLog, Function refreshAppointments) async {

  Future<void> deleteAppt(int id) async {
    const baseUrl =
        'https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api/deleteAppoinment/';

    try {
      final response = await http.post(
        Uri.parse(baseUrl + '$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("Appointment eliminado con éxito");
        if (responseData['fcm_token'] != null) {
          print("Token FCM del doctor: ${responseData['fcm_token']}");
        }
        refreshAppointments();
      } else {
        print('Error eliminando appointment: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  return await showDialog<bool>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (BuildContext context) {
      print('doc delcitaBUILD ${docLog}');
      return Stack(
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.02,
                bottom: MediaQuery.of(context).size.height * 0.02,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(blurRadius: 3.5, offset: Offset(0, 0)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          textAlign: TextAlign.center,
                          '¿Seguro que desea eliminar esta cita?',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.075,
                            color: AppColors3.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.035,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal:
                              MediaQuery.of(context).size.width * 0.03,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors3.primaryColor,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize:
                                MediaQuery.of(context).size.width * 0.05,
                                color: AppColors3.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              side:
                              const BorderSide(color: Colors.red, width: 1),
                            ),
                            backgroundColor: Colors.white,
                            surfaceTintColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal:
                              MediaQuery.of(context).size.width * 0.05,
                            ),
                          ),
                          onPressed: () {
                            deleteAppt(id!);
                            Navigator.of(context).pushAndRemoveUntil(
                              CupertinoPageRoute(
                                builder: (context) => AssistantAdmin(docLog: docLog),
                              ),
                                  (Route<dynamic> route) => false,
                            );
                            },
                          child: Text(
                            'Eliminar',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize:
                              MediaQuery.of(context).size.width * 0.048,
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
        ],
      );
    },
  ) ?? false;
}
