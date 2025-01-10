import 'package:agenda_app/projectStyles/appColors.dart';
import 'package:agenda_app/utils/showToast.dart';
import 'package:agenda_app/utils/toastWidget.dart';
import 'package:flutter/material.dart';

import '../../services/userService.dart';
import '../../views/usersConfig.dart';

class CardUsers extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final String query;
  final int index;
  final Function (String, int, bool, String) onModifyUser;
  final Function (bool) onBlurr;
  const CardUsers({super.key, required this.users, required this.index, required this.onModifyUser, required this.query, required this.onBlurr});

  @override
  State<CardUsers> createState() => _CardUsersState();
}

class _CardUsersState extends State<CardUsers> {

  int? cardSelected;
  @override
  void initState() {
    super.initState();
    selectedUserId = widget.users[widget.index]['id'];
    user = widget.users[widget.index]['name'];
  }
  ///funciones editar y eliminar
  String? user;
  bool isUserSel = false;
  String? selectedUserId;
  void onSelUser(String? displayText, String? userId) {
    setState(() {
      user = displayText;
      selectedUserId = userId;
      isUserSel = displayText != null && userId != null;
    });
  }
  void deleteUser() async {
    widget.onBlurr(true);

    if (selectedUserId == null) return;

    // Mostrar diálogo de confirmación
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmar eliminación',
            style: TextStyle(color: AppColors3.redDelete),
          ),
          content: Text(
            '¿Estás seguro que deseas eliminar al usuario: $user?',
            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.045),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      widget.onBlurr(false);
      return;
    }

    // Mostrar indicador de carga
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    // Llamar al servicio para eliminar usuario
    final result = await UserServices.deleteUser(selectedUserId!);

    // Asegurarse de que el widget está montado antes de usar `context`
    if (mounted) {
      Navigator.of(context).pop(); // Cierra el indicador de carga
      widget.onBlurr(false);

      // Mostrar mensaje con `ScaffoldMessenger`
     /* ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.width * 0.08,
            bottom: MediaQuery.of(context).size.width * 0.08,
            left: MediaQuery.of(context).size.width * 0.02,
          ),
          content: Text(
            result['message'],
            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.045),
          ),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );*/

      // Navegar a la configuración de usuarios si la operación fue exitosa
      if (result['success']) {
        Future.microtask(() {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UsersConfig()),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(
            horizontal:  MediaQuery.of(context).size.width * 0.02,
            vertical: MediaQuery.of(context).size.width * 0.02),
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width * 0.04,
          horizontal: MediaQuery.of(context).size.width * 0.01,
        ),
      decoration: BoxDecoration(
        color: AppColors3.whiteColor,
          borderRadius: const BorderRadius.all(
              Radius.circular(10),
          ),
        border: Border.all(
          color: Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors3.primaryColorMoreStrong.withOpacity(0.1),
            blurRadius: 3,
            spreadRadius: 1,
            offset: const Offset(3, 3),
          )
        ],
      ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.035),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    highlightTextTitle(widget.users[widget.index]['name'] , widget.query),
                    Text(widget.users[widget.index]['role'] == 1 ? 'Médico Veterinario -' ' ${widget.users[widget.index]['identification']}' :
                    widget.users[widget.index]['role'] == 2 ? 'Asistente -' ' ${widget.users[widget.index]['identification']}' : 'Administrador -' ' ${widget.users[widget.index]['identification']}',
                      style: TextStyle(
                        color: AppColors3.primaryColor.withOpacity(0.4),
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),),
                  ],
                )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: widget.users[widget.index]['role'] == 3 ? ()=> showOverlay(context, CustomToast(message: 'No es posible esta acción para este usuario')) : () {
                      print('${widget.users[widget.index]['role']}');
                      widget.onModifyUser(
                        widget.users[widget.index]['name'],
                        widget.index,
                        true,
                        widget.users[widget.index]['id'],
                      );
                    },
                    icon: Icon(
                      Icons.edit_document,
                      color: AppColors3.primaryColor,
                      size: MediaQuery.of(context).size.width * 0.065,
                    )
                ),
                IconButton(
                    onPressed: widget.users[widget.index]['role'] == 3 ? ()=> showOverlay(context, CustomToast(message: 'No es posible borrar este usuario')) : deleteUser, icon: Icon(Icons.delete,
                  color: AppColors3.redDelete,
                  size: MediaQuery.of(context).size.width * 0.065,)),
              ],
            )
          ],
        ),);
  }

  Widget highlightTextTitle(String text, String query) {
    if (query.isEmpty) {
      return Text(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text,
          style: TextStyle(
            color: AppColors3.primaryColor,
            fontSize: MediaQuery.of(context).size.width * 0.0525));
    }

    final lowerCaseText = text.toLowerCase();
    final lowerCaseQuery = query.toLowerCase();

    final startIndex = lowerCaseText.indexOf(lowerCaseQuery);
    if (startIndex == -1) {
      return Text(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text,
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.0525));
    }

    final beforeMatch = text.substring(0, startIndex);
    final matchText = text.substring(startIndex, startIndex + query.length);
    final afterMatch = text.substring(startIndex + query.length);

    return Text.rich(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        TextSpan(
            children: [
              TextSpan(
                  text: beforeMatch,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                      color: AppColors3.primaryColor,
                      fontSize: MediaQuery.of(context).size.width * 0.0525)),
              TextSpan(
                  text: matchText,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.0525,
                      color: AppColors3.primaryColor,
                      fontWeight: FontWeight.bold,
                  )),
              TextSpan(
                  text: afterMatch,
                  style: TextStyle(
                    color: AppColors3.primaryColor,
                    fontSize: MediaQuery.of(context).size.width * 0.0525))]));
  }
}
