import 'dart:ui';
import 'package:agenda_app/usersConfig/apmntList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../regEx.dart';
import '../../kboardVisibilityManager.dart';
import '../projectStyles/appColors.dart';

class NewAppointments extends StatefulWidget {

  const NewAppointments({super.key});

  @override
  State<NewAppointments> createState() => _NewAppointmentsState();
}

class _NewAppointmentsState extends State<NewAppointments> with SingleTickerProviderStateMixin {

  //ListenerremoverOL listenerremoverOL = ListenerremoverOL();
  //ListenerQuery listenerQuery = ListenerQuery();
  //ListenerOnDateChanged listenerOnDateChanged = ListenerOnDateChanged();
  late AnimationController animationController;
  late Animation<double> opacidad;
  late String formattedDate;
  late KeyboardVisibilityManager keyboardVisibilityManager;
  //
  double? screenWidth;
  double? screenHeight;
  double optSize = 0;
  bool showBlurr = false;
  int blurShowed = 0;
  int selectedPage = 0;
  //
  TextEditingController seekController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  FocusNode seekNode = FocusNode();
  FocusNode dateNode = FocusNode();
  PageController pageController = PageController();
  String longDate = '';

  List<Map<String, dynamic>> tickets = [];

  void onOptnSize(double optSize){
    setState(() {
      this.optSize = optSize;
    });
  }

  void onFilterProducts (){
    //listenerQuery.setChange(seekController.text);
  }

  void onDateChanged(){
    //listenerOnDateChanged.setChange(true, dateController.text, dateController.text);
  }

  void _onDateToAppointmentForm(
      String dateToAppointmentForm, bool showCalendar) {
    setState(() {
      animationController.reverse().then((_){
        showBlurr = showCalendar;
        animationController.reset();
      });
      DateTime parsedDate = DateTime.parse(dateToAppointmentForm);
      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      longDate = DateFormat("d 'de' MMMM 'de' y", 'es_ES').format(parsedDate);
      dateController.text = formattedDate;
      onDateChanged();
    });
  }

  void _onShowBlurr(int showBlurr) {
    setState(() {
      blurShowed = showBlurr;
      if (blurShowed == 0) {
        this.showBlurr = false;
      } else {
        this.showBlurr = true;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  void filterSales(text){
    setState(() {
      //listenerQuery.setChange(seekController.text);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    opacidad = Tween(begin: 0.0, end:  1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
    animationController.addListener((){
      setState(() {
      });
    });
    keyboardVisibilityManager = KeyboardVisibilityManager();
    DateTime now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    dateController.text = formatter.format(now);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardVisibilityManager.dispose();
    super.dispose();
  }
  bool isLoading = false;

  void removerOverL(){
    //listenerremoverOL.setChange(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors3.bgColor,
                leadingWidth: MediaQuery.of(context).size.width,
                pinned: true,
                leading: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        CupertinoIcons.back,
                        size: MediaQuery.of(context).size.width * 0.08,
                        color: AppColors3.primaryColor,
                      ),
                    ),
                    Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Citas recibidas',
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.085,
                                fontWeight: FontWeight.bold,
                                color: AppColors3.primaryColor,
                              ),
                            )
                          ],
                        )),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: PageView(
                  children: [
                    ApmntList(onShowBlur: _onShowBlurr, onOptnSize: onOptnSize)
                  ],
                ),
              ),
            ],
          ),
          Visibility(
              visible: showBlurr,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                child: GestureDetector(
                  onTap: () {
                    removerOverL();
                    setState(() {
                      showBlurr = false;
                      blurShowed = 0;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: AppColors3.blackColor.withOpacity(0.1),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }
}
