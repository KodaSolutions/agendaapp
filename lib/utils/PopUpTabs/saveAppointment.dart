import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/appointmentModel.dart';
import '../../projectStyles/appColors.dart';

class ConfirmationDialog extends StatefulWidget {
  final Appointment appointment;
  final TextEditingController dateController;
  final TextEditingController timeController;
  final Function(DateTime) fetchAppointments;

  const ConfirmationDialog({
    super.key,
    required this.appointment,
    required this.dateController,
    required this.timeController,
    required this.fetchAppointments,
  });

  @override
  _ConfirmationDialogState createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  Future<void> saveAppointment() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('No existe el token');
      }
      DateTime selectedDate =
          DateFormat('yyyy-MM-dd').parse(widget.dateController.text);
      DateTime selectedTime = DateFormat.jm().parse(widget.timeController.text);
      DateTime updatedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      final response = await http.put(
        Uri.parse(
            'https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api/editAppoinment/${widget.appointment.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'date': DateFormat('yyyy-MM-dd').format(updatedDateTime),
          'time': DateFormat('HH:mm:ss').format(updatedDateTime),
        }),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          widget.fetchAppointments(updatedDateTime);
          Navigator.of(context).pop(true);
        });
      } else {
        Navigator.of(context).pop(false);
        throw Exception('Error al actualizar el appointment');
      }
    } catch (e) {
      print('Error saving appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar la cita')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
         Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04),
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.width * 0.045),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.08,
                    right: MediaQuery.of(context).size.width * 0.08,
                    top: MediaQuery.of(context).size.width * 0.08,
                    bottom: MediaQuery.of(context).size.width * 0.04,
                  ),
                  child: Text(
                    textAlign: TextAlign.center,
                    '¿Seguro que desea guardar los cambios?',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.075,
                      color: AppColors3.primaryColor,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.03,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors3.primaryColor,
                              width: 2.0,
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.055,
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
                          side: const BorderSide(
                              color: AppColors3.primaryColor, width: 1),
                        ),
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05,
                        ),
                      ),
                      onPressed: saveAppointment,
                      child: Text(
                        'Guardar',
                        style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.width * 0.055),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        // El AlertDialog en primer plano
      ],
    );
  }
}
