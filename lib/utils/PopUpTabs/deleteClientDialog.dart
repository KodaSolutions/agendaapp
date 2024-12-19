import 'package:flutter/material.dart';

import '../../projectStyles/appColors.dart';

Future<bool> showDeleteConfirmationDialog(BuildContext context, Function onDelete) {
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (BuildContext context) {
      return Material(
        color: Colors.transparent,
        child:
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04),
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.05),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(blurRadius: 3.5, offset: Offset(0, 0))
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: Text(
                      'Confirmar eliminación',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.07,
                        color: AppColors3.primaryColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.07,
                        vertical: MediaQuery.of(context).size.height * 0.02),
                    child: Text(
                      '¿Estás seguro de que deseas eliminar este cliente?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.03),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors3.primaryColorMoreStrong,
                                width: 2.5,
                              ),
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.05,
                              color: AppColors3.primaryColorMoreStrong,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          onDelete();
                          Navigator.of(context).pop(true);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.03),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors3.redDelete,
                                width: 2.5,
                              ),
                            ),
                          ),
                          child: Text(
                            'Eliminar',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.05,
                              color: AppColors3.redDelete,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      );
    },
  ).then((value) => value ?? false);
}
