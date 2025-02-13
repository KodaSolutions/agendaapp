import 'package:agenda_app/projectStyles/appColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  TextEditingController nameController = TextEditingController();
  FocusNode nameFocus = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    nameFocus.addListener(() {
      setState((){
        print('asdas${nameFocus.hasFocus}');
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
              pinned: true,
              leadingWidth: MediaQuery.of(context).size.width,
              leading: Row(
                children: [
                  IconButton(onPressed: (){
                    Navigator.of(context).pop();
                  }, icon: Icon(CupertinoIcons.chevron_back, size: MediaQuery.of(context).size.width * 0.08,
                    color: AppColors3.primaryColor,)),
                  Text(' Perfil', style: TextStyle(
                    color: AppColors3.primaryColor,
                    fontSize: MediaQuery.of(context).size.width * 0.065,
                  ),),
                ],
              ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.06),
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.15,
                )),
                Text('Clínica Veterinaria Peninsular',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: MediaQuery.of(context).size.width * 0.055,
                ),),
                Container(
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.03,
                      right: MediaQuery.of(context).size.width * 0.03,
                      top: MediaQuery.of(context).size.width * 0.06,
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.03,
                      vertical: MediaQuery.of(context).size.width * 0.03,
                  ),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                          width: nameFocus.hasFocus ? 1.5 : 1,
                          color: nameFocus.hasFocus ? AppColors3.primaryColor : AppColors3.blackColor),
                      right: BorderSide(
                          width: nameFocus.hasFocus ? 1.5 : 1,
                          color: nameFocus.hasFocus ? AppColors3.primaryColor : AppColors3.blackColor),
                      top: BorderSide(
                          width: nameFocus.hasFocus ? 1.5 : 1,
                          color: nameFocus.hasFocus ? AppColors3.primaryColor : AppColors3.blackColor),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    color: AppColors3.primaryColor.withOpacity(0.3),
                  ),
                  child: Text(
                    'Nombre del Doctor:',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.048,
                    ),),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03),
                child: TextFormField(
                  focusNode: nameFocus,
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 0.8),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1.4, color: AppColors3.primaryColor),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ),),
              ],
            ),
          )
        ],
      ),
    );
  }
}
