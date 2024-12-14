import 'package:agenda_app/kboardVisibilityManager.dart';
import 'package:agenda_app/projectStyles/appColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MOdifyUser extends StatefulWidget {
  final String name;
  final String psw;
  final Function (bool) onShowBlurr;
  const MOdifyUser({super.key, required this.onShowBlurr, required this.name, required this.psw});

  @override
  State<MOdifyUser> createState() => _MOdifyUserState();
}

class _MOdifyUserState extends State<MOdifyUser> {

  late KeyboardVisibilityManager keyboardVisibilityManager;


  @override
  void initState() {
    // TODO: implement initState
    keyboardVisibilityManager = KeyboardVisibilityManager();
    nameController.text = widget.name;
    pswController.text = widget.psw;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardVisibilityManager.dispose();
    super.dispose();
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController pswController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        margin: EdgeInsets.only(
          right: MediaQuery.of(context).size.width * 0.05,
          left: MediaQuery.of(context).size.width * 0.05,
          bottom: keyboardVisibilityManager.visibleKeyboard ? MediaQuery.of(context).size.width * 0.4 : 0,
        ),
        padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 0.02,
            left: MediaQuery.of(context).size.width * 0.02,
            bottom: MediaQuery.of(context).size.width * 0.03,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors3.blackColor),
          borderRadius: BorderRadius.circular(10),
          color: AppColors3.whiteColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(onPressed: (){
                  widget.onShowBlurr(false);
                }, icon: Icon(CupertinoIcons.xmark)),
              ],
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors3.primaryColor,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10)),
                  ),
                  child: Text('Nombre', style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    color: AppColors3.whiteColor,
                    fontWeight: FontWeight.bold,

                  ),),
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelText: 'Modificar nombre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.04),
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors3.primaryColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10)),
              ),
              child: Text('Contraseña', style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                color: AppColors3.whiteColor,
                fontWeight: FontWeight.bold,

              ),),
            ),
            TextFormField(
              controller: pswController,
              decoration: const InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: 'Modificar contraseña',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.04),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: (){}, child: Text('Aceptar')),),
          ],
        ),
      ),
    );
  }
}
