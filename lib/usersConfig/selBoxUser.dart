import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'functions.dart';

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
  final int? requiredRole;
  const SelBoxUser({super.key, required this.onSelUser, required this.requiredRole});

  @override
  State<SelBoxUser> createState() => _SelBoxUserState();
}

class _SelBoxUserState extends State<SelBoxUser> {
  String? selectedUser;
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadUserswithRole();
  }

  Future<void> loadUserswithRole() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final usersList = await loadUsersWithRoles();
      setState(() {
        users = usersList
            .where((user) => user['role'] == 1)
            .map((user) => {'id': user['id'],
          'name': user['name'],
          'identification': user['identification'].toString(),
          'role': user['role']})
            .toList();
        isLoading = false;
      });
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
      isExpanded: true,
      alignment: Alignment.topCenter,
      decoration: InputDecoration(
        isDense: true,
        labelText: widget.requiredRole == 1 ? 'Doctor...' : 'Seleccione usuario',
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: selectedUser,
      items: widget.requiredRole == 1 ? users.where((user) => user['role'] == 1).map((user) {
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
      }).toList() : users.map((user) {
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