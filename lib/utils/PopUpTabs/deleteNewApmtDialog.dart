import 'package:flutter/material.dart';

import '../../calendar/calendarSchedule.dart';
import '../../projectStyles/appColors.dart';
import '../../services/approveApptService.dart';
import '../../usersConfig/functions.dart';

class DeleteNewApmtDialog extends StatefulWidget {

  final List<Appointment2> newAptm;
  final int index;
  final VoidCallback? onAppointmentUpdated;
  final ExpansionTileController tileController;
  final void Function(
      bool
      ) onShowBlur;

  const DeleteNewApmtDialog({super.key, required this.onShowBlur, required this.newAptm, required this.index, required this.onAppointmentUpdated, required this.tileController});

  @override
  State<DeleteNewApmtDialog> createState() => _DeleteNewApmtDialogState();
}

class _DeleteNewApmtDialogState extends State<DeleteNewApmtDialog> {

  final approveApptService _approveApptService = approveApptService();
  bool _isLoading = false;

  Future<void> _rejectAppointment(String phone, String nameClient) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _approveApptService.rejectAppointment(
        widget.newAptm[widget.index].id!,
        'Cita rechazada por el administrador',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita rechazada exitosamente'),
            backgroundColor: Colors.orange,
          ),
        );
        widget.onAppointmentUpdated?.call();
        widget.tileController.collapse();
        Navigator.of(context).pop(false);
        sendWhatsMsg(phone: '+52${phone}', bodymsg: 'Hola ${nameClient}, ');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: IntrinsicHeight(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04),
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.03,
                top: MediaQuery.of(context).size.height * 0.02,
                left: MediaQuery.of(context).size.height * 0.015,
                right: MediaQuery.of(context).size.height * 0.015
            ),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: AppColors3.whiteColor,
            ),
            child: Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.01,
                              bottom: MediaQuery.of(context).size.height * 0.03
                          ),
                          child: Text(
                            '¿Eliminar cita?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width * 0.07,
                              color: AppColors3.primaryColor,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                                widget.onShowBlur(false);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors3.blackColor,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    color: AppColors3.blackColor,
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            ),
                            TextButton(
                              onPressed: _isLoading ? null : () => _rejectAppointment(widget.newAptm[widget.index].contactNumber!, widget.newAptm[widget.index].clientName!),
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppColors3.redDelete,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                child: Text(
                                  'Eliminar',
                                  style: TextStyle(
                                      color: AppColors3.redDelete,
                                      fontSize: 18
                                  ),
                                ),
                              )
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
