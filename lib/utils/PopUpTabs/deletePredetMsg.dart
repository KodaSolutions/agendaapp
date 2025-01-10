import 'package:agenda_app/projectStyles/appColors.dart';
import 'package:flutter/material.dart';

class DeletePredMsg extends StatefulWidget {

  const DeletePredMsg({super.key});

  @override
  State<DeletePredMsg> createState() => _DeletePredMsgState();
}

class _DeletePredMsgState extends State<DeletePredMsg> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.12),
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
          decoration: BoxDecoration(
            color: AppColors3.whiteColor,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: AppColors3.primaryColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('Eliminar mensaje', style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width * 0.06,

                  ),)
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                children: [
                  Expanded(child: Text(
                    '¿Deseas eliminar este mensaje?', style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.06,

                  ),)),
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // Cancelar
                    },
                    child: Text('Cancelar',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.05,

                    ),),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // Confirmar
                    },
                    child: Text('Eliminar',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        color: AppColors3.redDelete,
                      ),),
                  ),
                ],
              )
            ],
          ),
        );
  }
}
