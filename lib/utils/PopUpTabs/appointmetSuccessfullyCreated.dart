import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../projectStyles/appColors.dart';
import '../../views/admin/admin.dart';

class Appointmetsuccessfullycreated extends StatelessWidget {
  final bool docLog;

  const Appointmetsuccessfullycreated({super.key, required this.docLog});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04),
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.08),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(blurRadius: 3.5, offset: Offset(0, 0))
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Material(
                  color: Colors.transparent,
                  child: Text(
                    '¡Cita creada!',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.085,
                      color: AppColors3.primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.08,),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      CupertinoPageRoute(
                        builder: (context) => AssistantAdmin(docLog: docLog,),
                      ),
                          (Route<dynamic> route) => false,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.03),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors3.primaryColor,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Text(
                      'Inicio',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        color: AppColors3.primaryColor,
                      ))))
                    ])))
      ],
    );
  }
}

