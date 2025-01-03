import 'package:agenda_app/calendar/calendarSchedule.dart';
import 'package:agenda_app/services/approveApptService.dart';
import 'package:agenda_app/usersConfig/selBoxUser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../projectStyles/appColors.dart';

class CardAptm extends StatefulWidget {
  final int index;
  final int? oldIndex;
  final Function(int) onExpansionChanged;
  final List<Appointment2> newAptm;
  final ExpansionTileController tileController;
  final VoidCallback? onAppointmentUpdated;
  const CardAptm({super.key, required this.index, this.oldIndex, required this.onExpansionChanged, required this.tileController, required this.newAptm, this.onAppointmentUpdated});

  @override
  State<CardAptm> createState() => _CardAptmState();
}

class _CardAptmState extends State<CardAptm> {

  String? user;
  int? oldIndex;
  bool isUserSel = false;
  String? selectedUserId;
  var formatter = new DateFormat('dd-MM-yyyy');
  final approveApptService _approveApptService = approveApptService();
  bool _isLoading = false;


  void onSelUser(String? displayText, String? userId) {
    setState(() {
      user = displayText;
      selectedUserId = userId;
      isUserSel = displayText != null && userId != null;
    });
  }
  Future<void> _approveAppointment() async {
    if (!isUserSel || selectedUserId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _approveApptService.approveAppointment(
        widget.newAptm[widget.index].id!,
        int.parse(selectedUserId!),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita aprobada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onAppointmentUpdated?.call();
        widget.tileController.collapse();
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

  Future<void> _rejectAppointment() async {
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
  void initState() {
    super.initState();
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
            key: Key('${widget.index}'),
            controller: widget.tileController,
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                widget.onExpansionChanged(widget.index);
                isUserSel = false;
              }
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
              'Cita ${widget.newAptm[widget.index].id}',
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
                      widget.newAptm[widget.index].appointmentDate != null
                          ? formatter.format(widget.newAptm[widget.index].appointmentDate!)
                          : "No disponible",
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
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                    Text(
                      '${widget.newAptm[widget.index].clientName}',
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
                    left: MediaQuery.of(context).size.width * 0.04,
                    right: MediaQuery.of(context).size.width * 0.04
                ),
                decoration: const BoxDecoration(
                    color: AppColors3.bgColor,
                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                    border: Border(
                        top: BorderSide(color: AppColors3.primaryColor, width: 2)
                    )
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Tratamiento: ",
                          style: TextStyle(
                              color: AppColors3.primaryColorMoreStrong,
                              fontSize: MediaQuery.of(context).size.width * 0.04),
                        ),
                        Text(
                          '${widget.newAptm[widget.index].treatmentType}',
                          style: TextStyle(
                            color: AppColors3.primaryColorMoreStrong,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Método de pago: ",
                          style: TextStyle(
                              color: AppColors3.primaryColorMoreStrong,
                              fontSize: MediaQuery.of(context).size.width * 0.04),
                        ),
                        Text(
                          '${widget.newAptm[widget.index].paymentMethod}',
                          style: TextStyle(
                              color: AppColors3.primaryColorMoreStrong,
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width * 0.04),
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
                                    onPressed: isUserSel ? (_isLoading ? null : _approveAppointment) : null,
                                    child: const Icon(Icons.check)),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: _isLoading ? null : _rejectAppointment,
                                    child: const Icon(CupertinoIcons.xmark)),
                              ],
                            ),
                          ],
                        )
                    ),
                  ],
                ),
              )
            ]
        ),
      )
    );
  }
}
