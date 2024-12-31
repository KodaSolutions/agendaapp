import 'package:agenda_app/projectStyles/appColors.dart';
import 'package:flutter/material.dart';

import '../listenerSlidable.dart';

class MsgCard extends StatefulWidget {
  final Listenerslidable listenerslidable;
  final int index;
  final String query;
  final List <Map<String, String>> filteredMsg;
  const MsgCard({super.key, required this.listenerslidable, required this.index, required this.query, required this.filteredMsg});

  @override
  State<MsgCard> createState() => _MsgCardState();
}

class _MsgCardState extends State<MsgCard> {

  bool isDragX = false;
  int itemDragX = 0;
  List<int> draggedItems = [];

  @override
  void initState() {
    // TODO: implement initState
    widget.listenerslidable.registrarObservador((newDragStatus, newDragId){
      if(newDragStatus == true){
        isDragX = newDragStatus;
        itemDragX = newDragId;
        if (!draggedItems.contains(itemDragX)) {
          draggedItems.add(itemDragX);
        }
      }else{
        setState(() {
          isDragX = false;
          draggedItems.remove(newDragId);
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.width * 0.02,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors3.blackColor),
        borderRadius: BorderRadius.only(
          bottomRight: draggedItems.contains(widget.index) ? const Radius.circular(0) : const Radius.circular(10),
          topRight: draggedItems.contains(widget.index) ? const Radius.circular(0) : const Radius.circular(10),
          topLeft: const Radius.circular(10),
          bottomLeft: const Radius.circular(10),
        ),
        color: Colors.transparent,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: highlightTextTitle(widget.filteredMsg[widget.index]['titulo']!, widget.query)),
            ],
          ),
          Row(
            children: [
              Expanded(child: Text(
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                widget.filteredMsg[widget.index]['cuerpo']!,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.05
              ),),),
            ],
          ),
        ],
      )
    );
  }

  Widget highlightTextTitle(String text, String query) {
    if (query.isEmpty) {
      return Text(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
              color: AppColors3.blackColor,
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
                      color: AppColors3.blackColor,
                      fontSize: MediaQuery.of(context).size.width * 0.0525))]));
  }

}
