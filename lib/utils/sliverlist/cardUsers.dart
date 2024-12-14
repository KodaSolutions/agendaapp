import 'package:agenda_app/projectStyles/appColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardUsers extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final int index;
  final Function (String, int, bool) onModifyUser;
  const CardUsers({super.key, required this.users, required this.index, required this.onModifyUser});

  @override
  State<CardUsers> createState() => _CardUsersState();
}

class _CardUsersState extends State<CardUsers> {

  late List<TextEditingController> controllers;
  int? cardSelected;

  @override
  void initState() {
    super.initState();
    controllers = widget.users.map((user) => TextEditingController(text: user['name'])).toList();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.01),
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03),
        child: Row(
          children: [
            Expanded(child: Container(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width * 0.02,
                horizontal: MediaQuery.of(context).size.width * 0.02,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
              child: Text(controllers[widget.index].text,
              style: TextStyle(
                color: AppColors3.blackColor.withOpacity(0.4),
                fontSize: MediaQuery.of(context).size.width * 0.05,
              ),),
            ),),
            IconButton(onPressed: (){
              setState(() {
                widget.onModifyUser(controllers[widget.index].text, widget.index, true);
              });

            }, icon: Icon(Icons.edit, size: MediaQuery.of(context).size.width * 0.06,)),
            IconButton(onPressed: (){
              setState(() {
              });
            }, icon: Icon(Icons.delete_forever,
            color: AppColors3.redDelete,
            size: MediaQuery.of(context).size.width * 0.075,)),
          ],
        ));
  }
}
