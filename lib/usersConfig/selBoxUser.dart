import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Rol {
  final int id;
  final String name;

  Rol({required this.id, required this.name});
}

class SelBoxRol extends StatefulWidget {
  final Function(int?) onSelRol;
  const SelBoxRol({super.key, required this.onSelRol});

  @override
  State<SelBoxRol> createState() => _SelBoxRolState();
}

class _SelBoxRolState extends State<SelBoxRol> {
  String? selectedRole;

  List<DropdownMenuItem<String>> get dropdownItems {
    return [
      const DropdownMenuItem(value: "1", child: Text("Doctor")),
      const DropdownMenuItem(value: "2", child: Text("Asistente")),
    ];
  }
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.02,
        ),
        hintText: 'Seleccione un rol',
      ),
      value: selectedRole,
      items: dropdownItems,
      onChanged: (value) {
        setState(() {
          selectedRole = value;
          widget.onSelRol(value != null ? int.parse(value) : null);
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
//cambiar a String, Dynamic.
class SelBoxUser extends StatefulWidget {
  final Function(String?, String?) onSelUser;
  const SelBoxUser({super.key, required this.onSelUser});

  @override
  State<SelBoxUser> createState() => _SelBoxUserState();
}

class _SelBoxUserState extends State<SelBoxUser> {
  String? selectedUser;
  List<Map<String, String>> users = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final response = await http.get(
          Uri.parse('https://agendapp-cvp-75a51cfa88cd.herokuapp.com/userAll')
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final usersList = (data['user'] as List)
            .where((user) => user['role_id'] != 3)
            .map((user) => {
          'id': user['id'].toString(),
          'name': user['name'].toString(),
          'identification': user['identification'].toString(),
        })
            .cast<Map<String, String>>()
            .toList();

        setState(() {
          users = usersList;
          selectedUser = null;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error al cargar usuarios';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Text('Error: $error');
    }
    return DropdownButtonFormField<String>(
      alignment: Alignment.topCenter,
      decoration: InputDecoration(
        isDense: true,
        labelText: 'Seleccione usuario',
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: selectedUser,
      items: users.map((user) {
        String displayText = "${user['name']} (${user['identification']})";
        return DropdownMenuItem(
          value: displayText,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              displayText,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;

        final selectedUserData = users.firstWhere(
              (user) => "${user['name']} (${user['identification']})" == value,
          orElse: () => {
            'id': '',
            'name': '',
            'identification': ''
          } as Map<String, String>,
        );

        setState(() {
          selectedUser = value;
          widget.onSelUser(
              value,
              selectedUserData['id']?.isEmpty ?? true ? null : selectedUserData['id']
          );
        });
      },
      selectedItemBuilder: (BuildContext context) {
        return users.map((user) {
          String displayText = "${user['name']} (${user['identification']})";
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayText,
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