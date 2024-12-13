import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardUsers extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final int index;
  const CardUsers({super.key, required this.users, required this.index});

  @override
  State<CardUsers> createState() => _CardUsersState();
}

class _CardUsersState extends State<CardUsers> {

  late List<TextEditingController> controllers;
  int? cardSelected;

  @override
  void initState() {
    super.initState();
    // Inicializa un controlador por cada usuario
    controllers = widget.users.map((user) => TextEditingController(text: user['name'])).toList();
  }

  @override
  void dispose() {
    // Limpia todos los controladores
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03),
        child: Row(
          children: [
            Flexible(child: TextFormField(
              controller: controllers[widget.index],
            ),),
            IconButton(onPressed: (){
              setState(() {
                print('index ${widget.index}');
                cardSelected = widget.index;
              });

            }, icon: Icon(Icons.edit)),
            IconButton(onPressed: (){
              setState(() {
                print('index ${widget.index}');
                cardSelected = null;
              });
            }, icon: Icon(CupertinoIcons.xmark)),
          ],
        ));
  }
}
