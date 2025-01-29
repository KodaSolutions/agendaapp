import 'package:agenda_app/calendar/calendarSchedule.dart';
import 'package:agenda_app/services/approveApptService.dart';
import 'package:agenda_app/usersConfig/functions.dart';
import 'package:agenda_app/usersConfig/selBoxUser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../projectStyles/appColors.dart';
import '../PopUpTabs/deleteNewApmtDialog.dart';
import '../PopUpTabs/rescheduleDialog.dart';

class CardAptm extends StatefulWidget {
  final int index;
  final int? oldIndex;
  final Function(int) onExpansionChanged;
  final List<Appointment2> newAptm;
  final ExpansionTileController tileController;
  final VoidCallback? onAppointmentUpdated;
  late void Function(
      bool
      ) onShowBlur;
  CardAptm({super.key, required this.index, this.oldIndex, required this.onExpansionChanged, required this.tileController, required this.newAptm, this.onAppointmentUpdated, required this.onShowBlur});

  @override
  State<CardAptm> createState() => _CardAptmState();
}

class _CardAptmState extends State<CardAptm> {

  String? user;
  int? oldIndex;
  bool isUserSel = false;
  String? selectedUserId;
  var formatter = new DateFormat('dd-MM-yyyy');
  var timeFormatter = DateFormat('h:mm a');
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
  void initState() {
    super.initState();
    print(widget.newAptm[widget.index].appointmentDate);
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
                ),Row(
                  children: [
                    Text(
                      'Hora de cita: ',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                    Text(
                      widget.newAptm[widget.index].appointmentDate != null
                          ? timeFormatter.format(widget.newAptm[widget.index].appointmentDate!)
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
                      'Tipo de cita: ',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                    Text(
                      '${widget.newAptm[widget.index].apptmType}',
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
                Row(
                  children: [
                    Text(
                      'Cel.: ',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                    SelectableText(
                      '${widget.newAptm[widget.index].contactNumber}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.04),
                    ),
                  ],
                ),
              ],
            ),
            children: [
              Stack(
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
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.65,
                                  height: MediaQuery.of(context).size.height * 0.055,
                                  decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        border: Border(
                                            left: BorderSide(
                                              color: AppColors3.blackColor,
                                              width: 1,
                                            ),
                                            right: BorderSide(
                                              color: AppColors3.blackColor,
                                              width: 1,
                                            ),
                                            bottom: BorderSide(
                                              color: AppColors3.blackColor,
                                              width: 1,
                                            ),
                                            top: BorderSide(
                                              color: AppColors3.blackColor,
                                              width: 1,
                                            )
                                        )
                                    ),
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: SelBoxUser(onSelUser: onSelUser, requiredRole: 1,),
                                      ),
                                    ],
                                  )
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
                                  ],
                                ),
                              ],
                            )
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.02,
                    ),
                    child: PopupMenuButton(
                      icon: const Icon(CupertinoIcons.ellipsis_vertical),
                      color: AppColors3.bgColor,
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(FontAwesomeIcons.whatsapp,
                                  color: AppColors3.primaryColor),
                              SizedBox(width: 10),
                              Text('WhatsApp'),
                            ],
                          ),
                          onTap: () {
                            sendWhatsMsg(phone: '+52${widget.newAptm[widget.index].contactNumber}', bodymsg: 'Hola ${widget.newAptm[widget.index].clientName}, ');
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.pencil,
                                  color: AppColors3.primaryColor),
                              SizedBox(width: 10),
                              Text('Reagendar'),
                            ],
                          ),
                          onTap: () {
                            widget.onShowBlur(true);
                            showDialog(
                                context: context,
                                builder: (builder) {
                                  return RescheduleDialog(onShowBlur: widget.onShowBlur, appointmentId: widget.newAptm[widget.index].id, onAppointmentUpdated: widget.onAppointmentUpdated,);
                                }
                            ).then((_) {
                              widget.onShowBlur(false);
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.delete,
                                  color: Colors.red),
                              SizedBox(width: 10),
                              Text('Eliminar',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          onTap: () {
                            widget.onShowBlur(true);
                            showDialog(
                                context: context,
                                builder: (builder) {
                                  return DeleteNewApmtDialog(onShowBlur: widget.onShowBlur, newAptm: widget.newAptm, index: widget.index, tileController: widget.tileController, onAppointmentUpdated: widget.onAppointmentUpdated);
                                }
                            ).then((_) {
                              widget.onShowBlur(false);
                            });
                          }
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ]
        ),
      )
    );
  }
}
