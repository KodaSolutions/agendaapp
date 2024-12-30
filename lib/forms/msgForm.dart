import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../projectStyles/appColors.dart';

class MsgForm extends StatefulWidget {
  final String? title;
  final String? bodyMsg;
  const MsgForm({super.key, this.title, this.bodyMsg});

  @override
  State<MsgForm> createState() => _MsgFormState();
}

class _MsgFormState extends State<MsgForm> {

  TextEditingController titleController = TextEditingController();
  TextEditingController bodyMsgController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    if(widget.title != null && widget.bodyMsg != null){
      titleController.text = widget.title!;
      bodyMsgController.text = widget.bodyMsg!;

    }
      super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leadingWidth: MediaQuery.of(context).size.width,
        leading: Row(
          children: [
            IconButton(onPressed: (){
              Navigator.of(context).pop();
            }, icon: Icon(CupertinoIcons.chevron_back, size: MediaQuery.of(context).size.width * 0.08,
              color: AppColors3.primaryColor,)),
            Text(widget.title == null ? 'Crear mensaje' : 'Editar mensaje',
              style: TextStyle(
              color: AppColors3.primaryColor,
              fontSize: MediaQuery.of(context).size.width * 0.065,
            ),),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.02,
                    left: MediaQuery.of(context).size.width * 0.02),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Text('Podrá encontrar el mensaje con el título en las swipe actions disponibles donde se muestran las citas.',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.04,
                            ),),),
                        ],
                      ),
                  ),
                Padding(padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.width * 0.04,
                    horizontal: MediaQuery.of(context).size.width * 0.02,
                ),
                child: TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Título, ejemplo: "Mensaje para estudios"',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors3.primaryColorMoreStrong),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.02,
                  right: MediaQuery.of(context).size.width * 0.02,
                  bottom: MediaQuery.of(context).size.width * 0.04,
                ),
                child: TextFormField(
                  controller: bodyMsgController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Contenido del mensaje...',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors3.primaryColorMoreStrong),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),

                ),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: widget.title == null ?
                            (){///codigo para CREAR
                          }
                            : (){
                          ///codigo para MODIFICAR
                        },
                        child: Text('Guardar')),
                  ],
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(

          )

        ],
      ),
    );
  }
}
