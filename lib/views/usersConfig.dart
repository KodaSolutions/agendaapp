import 'dart:ui';
import 'package:agenda_app/usersConfig/functions.dart';
import 'package:agenda_app/utils/PopUpTabs/modifyUser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../projectStyles/appColors.dart';
import '../utils/sliverlist/cardUsers.dart';

class UsersConfig extends StatefulWidget {
  const UsersConfig({super.key});

  @override
  State<UsersConfig> createState() => _UsersConfigState();
}

class _UsersConfigState extends State<UsersConfig> {

  bool isLoadingUsers = false;
  List<Map<String, dynamic>> users = [];
  String? error;
  bool blurr = false;
  String name = 'name';
  String psw = 'XXXX';

  Future<void> loadUserswhitRole() async {
    setState(() {
      isLoadingUsers = true;
      error = null;
    });
    try {
      final usersList = await loadUsersWithRoles();
      setState(() {
        users = usersList;
        isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        isLoadingUsers = false;
        error = e.toString();
      });
    }
  }

  void onShowBlurr (bool blurr){
    setState(() {
      this.blurr = blurr;
    });

  }

  void onModifyUser (String name, int index, bool blurr){
    print(name);
    print(blurr);
    print(index);
    setState(() {
      this.name = name;
      this.psw = psw;
      this.blurr = blurr;
    });

  }


  @override
  void initState() {
    loadUserswhitRole();
    // TODO: implement initState
    super.initState();
  }

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
          children: [
            IconButton(onPressed: (){
              Navigator.of(context).pop();
            }, icon: Icon(CupertinoIcons.chevron_back, size: MediaQuery.of(context).size.width * 0.08,
              color: AppColors3.primaryColor,)),
            Text('Usuarios', style: TextStyle(
              color: AppColors3.primaryColor,
              fontSize: MediaQuery.of(context).size.width * 0.065,
            ),),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
              delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                return CardUsers(
                  users: users,
                  index: index,
                  onModifyUser: onModifyUser,
                );
              }, childCount: users.length)),
        ],
      ),
      ),
        Visibility(
          visible: blurr,
          child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Center(
              child: MOdifyUser(onShowBlurr: onShowBlurr, name: name, psw: psw),
            )
          ),
        ),),
      ],
    );
  }
}
//
