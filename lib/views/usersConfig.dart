import 'dart:ui';
import 'package:agenda_app/kboardVisibilityManager.dart';
import 'package:agenda_app/regEx.dart';
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

  late KeyboardVisibilityManager keyboardVisibilityManager;
  bool isLoadingUsers = false;
  List<Map<String, dynamic>> users = [];
  String? error;
  bool blurr = false;
  String name = '';
  TextEditingController seek = TextEditingController();
  List<Map<String, dynamic>> filteredUsers = [];


  Future<void> loadUserswhitRole() async {
    setState(() {
      isLoadingUsers = true;
      error = null;
    });
    try {
      final usersList = await loadUsersWithRoles();
      setState(() {
        users = usersList;
        filteredUsers = users;
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
    setState(() {
      this.name = name;
      this.blurr = blurr;
    });

  }

  void filterByUsers() {
    final query = seek.text.toLowerCase();
    final roleMapping = {
      1: 'doctor',
      2: 'asistente',
    };
    setState(() {
      if (query.isEmpty) {
        filteredUsers = users;
      } else {
        filteredUsers = users.where((user) {
          final matchesTextQuery = user['name'].toLowerCase().contains(query);
          final roleDescription = roleMapping[user['role']]?.toLowerCase() ?? '';
          final matchesRoleQuery = roleDescription.contains(query);
          return matchesTextQuery || matchesRoleQuery;
        }).toList();
      }});
  }


  @override
  void initState() {
    keyboardVisibilityManager = KeyboardVisibilityManager();
    loadUserswhitRole();
    // TODO: implement initStat
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardVisibilityManager.dispose();
    super.dispose();
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
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.03,
                left: MediaQuery.of(context).size.width * 0.03,
                bottom: MediaQuery.of(context).size.width * 0.04,
                top: MediaQuery.of(context).size.width * 0.02,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      inputFormatters: [
                        RegEx(type: InputFormatterType.name),
                      ],
                      controller: seek,
                      placeholder: 'Buscar usuario...',
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(
                          CupertinoIcons.search,
                          size: 20.0,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGrey, width: 1.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      onChanged: (val){
                        filterByUsers();
                              }))
                    ]))),
            if(filteredUsers.isNotEmpty)...[SliverList(
              delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                return CardUsers(
                  users: filteredUsers,
                  index: index,
                  onModifyUser: onModifyUser, query: seek.text,
                );
              }, childCount: filteredUsers.length)),]
          else ...[
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 200),
                  Center(
                      child: isLoadingUsers
                          ? const CircularProgressIndicator(
                        color: Colors.black,
                      )
                          : Text(
                        "No se han encontrado usuarios",
                        style: TextStyle(
                            color: AppColors3.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize:
                            MediaQuery.of(context).size.width *
                                0.06),
                            ))
                ]))
              ]
            ])),
        Visibility(
          visible: blurr,
          child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Center(
              child: MOdifyUser(
                  kBoardVisibility: keyboardVisibilityManager.visibleKeyboard,
                  onShowBlurr: onShowBlurr, name: name),
                  ))))
    ]);
  }
}
//