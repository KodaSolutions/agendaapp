import 'package:agenda_app/projectStyles/appColors.dart';
import 'package:flutter/material.dart';

class CardUsers extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final String query;
  final int index;
  final Function (String, int, bool) onModifyUser;
  const CardUsers({super.key, required this.users, required this.index, required this.onModifyUser, required this.query});

  @override
  State<CardUsers> createState() => _CardUsersState();
}

class _CardUsersState extends State<CardUsers> {

  int? cardSelected;

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
                    highlightTextTitle(widget.users[widget.index]['name'], widget.query),
                    Text(widget.users[widget.index]['role'] == 1 ? 'Médico Veterinario' :
                    widget.users[widget.index]['role'] == 2 ? 'Asistente' : 'Administrador',
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
                    onPressed: (){
                      setState(() {
                        widget.onModifyUser(widget.users[widget.index]['name'], widget.index, true);
                      });
                    }, icon: Icon(Icons.edit_document,
                  color: AppColors3.primaryColor,
                  size: MediaQuery.of(context).size.width * 0.065,)),
                IconButton(
                    onPressed: (){
                      setState(() {
                      });
                    }, icon: Icon(Icons.delete,
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
