import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../projectStyles/appColors.dart';
import '../utils/sliverlist/cardTypes.dart';

class ApmntType extends StatefulWidget {
  const ApmntType({super.key});

  @override
  State<ApmntType> createState() => _ApmntTypeState();
}

class _ApmntTypeState extends State<ApmntType> {

  List<Map<String, dynamic>> types = [
    {'id':1, 'tipo': 'Cirugía'},
    {'id':2, 'tipo': 'Estética'},
    {'id':3, 'tipo': 'Consulta general'},
    {'id':4, 'tipo': 'Test'}
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors3.whiteColor,
          appBar: AppBar(
            backgroundColor: AppColors3.whiteColor,
            leadingWidth: MediaQuery.of(context).size.width,
            leading: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                            CupertinoIcons.chevron_back, size: MediaQuery.of(context).size.width * 0.08,
                            color: AppColors3.primaryColor
                        )
                    ),
                    Text(
                        'Tipos de cita',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors3.primaryColor,
                          fontSize: MediaQuery.of(context).size.width * 0.065,
                        )
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.02),
                  child: IconButton(
                    onPressed: () {

                    },
                    icon: Icon(
                        CupertinoIcons.add
                    ),
                  ),
                )
              ],
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.width * 0.1,
                    right: MediaQuery.of(context).size.width * 0.01,
                    left: MediaQuery.of(context).size.width * 0.01
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                    return CardTypes(types: types, index: index);
                  },
                  childCount: types.length
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
