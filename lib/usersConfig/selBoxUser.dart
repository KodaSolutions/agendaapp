import 'package:flutter/material.dart';

class SelBoxRol extends StatefulWidget {
  final Function (String?) onSelRol;
  const SelBoxRol({super.key, required this.onSelRol});

  @override
  State<SelBoxRol> createState() => _SelBoxRolState();
}

class _SelBoxRolState extends State<SelBoxRol> {
  String? selectedRole; // Variable para almacenar el valor seleccionado

  List<String> listRoles = [
  'Doctor',
  'Asistente'
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02),
          hintText: 'Seleccione un rol',
        ),
        value: selectedRole,
      items: listRoles.map((rol) {
        return DropdownMenuItem(
            value: rol,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                rol,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ));
      }).toList(),
        onChanged: (value) {
          setState(() {
            selectedRole = value;
            widget.onSelRol(selectedRole);
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Por favor selecciona un rol';
          }
          return null;
        },

      );
  }
}
//

class SelBoxUser extends StatefulWidget {
  final Function (String?) onSelUser;
  const SelBoxUser({super.key, required this.onSelUser});

  @override
  State<SelBoxUser> createState() => _SelBoxUserState();
}

class _SelBoxUserState extends State<SelBoxUser> {
  String? selectedUser; // Variable para almacenar el valor seleccionado

  List<String> listUsers = [
    'name1',
    'name2'
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
        alignment: Alignment.topCenter,
        decoration: InputDecoration(
          isDense: true,
            labelText: 'Seleccione usuario',
            floatingLabelBehavior: FloatingLabelBehavior.never,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            )
        ),
        value: selectedUser,
        items: listUsers.map((rol) {
          return DropdownMenuItem(
              value: rol,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  rol,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ));
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedUser = value;
            widget.onSelUser(selectedUser);
          });
        },
      selectedItemBuilder: (BuildContext context) {
        return listUsers.map((String user) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          );
        }).toList();
      },
    );
  }
}
