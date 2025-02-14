import 'package:flutter/material.dart';

import '../../projectStyles/appColors.dart';
import '../showToast.dart';
import '../toastWidget.dart';

class CardTypes extends StatefulWidget {

  final List<Map<String, dynamic>> types;
  final int index;
  const CardTypes({super.key, required this.types, required this.index});

  @override
  State<CardTypes> createState() => _CardTypesState();
}

class _CardTypesState extends State<CardTypes> {
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
          color: widget.types[widget.index]['id'] == 1 ? AppColors3.redDelete : widget.types[widget.index]['id'] == 2 ? AppColors3.secundaryColor : AppColors3.primaryColor,
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
            child: Text(
              widget.types[widget.index]['tipo'],
              style: TextStyle(
                color: widget.types[widget.index]['id'] == 1 ? AppColors3.redDelete : widget.types[widget.index]['id'] == 2 ? AppColors3.secundaryColor : AppColors3.primaryColor,
                fontSize: MediaQuery.of(context).size.width * 0.0525
              )
            )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Visibility(
                visible: widget.types[widget.index]['id'] == 1 ? false : widget.types[widget.index]['id'] == 2 ? false : widget.types[widget.index]['id'] == 3 ? false : true,
                child: IconButton(
                    onPressed: () {

                    },
                    icon: Icon(
                      Icons.edit_document,
                      color: AppColors3.primaryColor,
                      size: MediaQuery.of(context).size.width * 0.065,
                    )
                ),
              ),
              Visibility(
                visible: widget.types[widget.index]['id'] == 1 ? false : widget.types[widget.index]['id'] == 2 ? false : widget.types[widget.index]['id'] == 3 ? false : true,
                child: IconButton(
                    onPressed: () {

                    },
                    icon: Icon(Icons.delete,
                      color: AppColors3.redDelete,
                      size: MediaQuery.of(context).size.width * 0.065,)
                ),
              ),
              Visibility(
                visible: widget.types[widget.index]['id'] == 1 ? true : widget.types[widget.index]['id'] == 2 ? true : widget.types[widget.index]['id'] == 3 ? true : false,
                child: IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.edit_document,
                      color: Colors.transparent,
                      size: MediaQuery.of(context).size.width * 0.065,
                    ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
