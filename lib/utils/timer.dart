import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../projectStyles/appColors.dart';

class TimerFly extends StatefulWidget {
  final String? hour;
  final void Function(bool, TextEditingController, int) onTimeChoose;

  TimerFly({super.key, required this.onTimeChoose, this.hour});

  @override
  State<TimerFly> createState() => _TimerFlyState();
}

class _TimerFlyState extends State<TimerFly> {
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minsController;
  late FixedExtentScrollController amPmController;
  final timeController = TextEditingController();
  int previousMinsIndex = 0; // Almacena el índice anterior para los minutos


  int selectedIndexHours = 0;
  int selectedIndexMins = 0;
  int selectedIndexAmPm = 0;
  int hour = 0;
  int minuts = 0;

  // 0 = AM, 1 = PM
  bool _isTimerShow = false;
  double? smallestDimension;
  double? diameterRatio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    smallestDimension = MediaQuery.of(context).size.shortestSide;
    diameterRatio = (smallestDimension! * 0.0028);
  }
  @override
  void initState() {
    super.initState();
    if (widget.hour != null) {
      final timeParts = widget.hour!.split(' ');
      final time = timeParts[0].split(':');
      final period = timeParts[1];
      selectedIndexHours = (int.parse(time[0]) % 12);
      int rawMinutes = int.parse(time[1]);
      selectedIndexMins = (rawMinutes / 20).round() * 20;
      if (selectedIndexMins >= 60) {
        selectedIndexMins = 0;
        selectedIndexHours = (selectedIndexHours + 1) % 12;
      }

      selectedIndexAmPm = (period.toUpperCase() == 'PM') ? 0 : 1;
      previousMinsIndex = selectedIndexMins ~/ 20;

    }

    hourController = FixedExtentScrollController(initialItem: selectedIndexHours);
    minsController = FixedExtentScrollController(initialItem: selectedIndexMins ~/ 30);
    amPmController = FixedExtentScrollController(initialItem: selectedIndexAmPm);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
            children: [
              Expanded(
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Divider(
                              color: Colors.grey,
                            ),
                            Divider(
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(color: AppColors3.primaryColorMoreStrong.withOpacity(0.1), width: 2)
                        ),
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.width * 0.02
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ///hrs
                              Flexible(
                                  child: ListWheelScrollView.useDelegate(
                                      controller: hourController,
                                      perspective: 0.001,
                                      diameterRatio: 0.96,
                                      physics: const FixedExtentScrollPhysics(),
                                      itemExtent: MediaQuery.of(context).size.width * 0.18,
                                      onSelectedItemChanged: (value) {
                                        setState(() {
                                          selectedIndexHours = value;
                                        });
                                      },
                                      childDelegate: ListWheelChildLoopingListDelegate(
                                          children: List.generate(12, (index) {
                                            final Color colorforhours = index == selectedIndexHours
                                                ? AppColors3.primaryColor
                                                : Colors.grey;

                                            return Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: index != selectedIndexHours
                                                        ? MediaQuery.of(context).size.width * 0.04
                                                        : MediaQuery.of(context).size.width * 0.0),
                                                child: Center(
                                                    child: Text(index == 0 ? '12' : index.toString(),
                                                        style: TextStyle(
                                                          fontSize: index == selectedIndexHours
                                                              ? MediaQuery.of(context).size.width * 0.11
                                                              : MediaQuery.of(context).size.width * 0.12,
                                                          color: colorforhours,
                                                        ))));
                                          })))),
                              Flexible(
                                  child: Text(
                                      ':',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.125,
                                        color: AppColors3.primaryColor,
                                      ))),
                              Flexible(
                                child: ListWheelScrollView.useDelegate(
                                  onSelectedItemChanged: (value) {
                                    setState(() {
                                      int newMinsValue = value * 30;

                                      if (value == 0 && previousMinsIndex == 1) {  //valores entre (0 y 30)
                                        if (selectedIndexHours == 11) {
                                          selectedIndexHours = 0;
                                          hourController.animateToItem(
                                            selectedIndexHours,
                                            duration: const Duration(milliseconds: 500),
                                            curve: Curves.easeInOut,
                                          );
                                        } else {
                                          selectedIndexHours = (selectedIndexHours + 1) % 12;
                                          hourController.animateToItem(
                                            selectedIndexHours,
                                            duration: const Duration(milliseconds: 500),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      }
                                      previousMinsIndex = value;
                                      selectedIndexMins = newMinsValue;
                                    });
                                  },
                                  controller: minsController,
                                  perspective: 0.0011,
                                  diameterRatio: 0.96,
                                  physics: const FixedExtentScrollPhysics(),
                                  itemExtent: MediaQuery.of(context).size.width * 0.18,
                                  childDelegate: ListWheelChildLoopingListDelegate(
                                    children: List.generate(2, (index) {
                                      final int minute = index * 30;  // Cambiado de 20 a 30
                                      final Color colorformins = minute == selectedIndexMins
                                          ? AppColors3.primaryColor
                                          : Colors.grey;

                                      return Center(
                                        child: Text(
                                          minute < 10 ? '0$minute' : minute.toString(),
                                          style: TextStyle(
                                            fontSize: minute == selectedIndexMins
                                                ? MediaQuery.of(context).size.width * 0.11
                                                : MediaQuery.of(context).size.width * 0.12,
                                            color: colorformins,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),

                              ///am/pm
                              Flexible(
                                  child: ListWheelScrollView.useDelegate(
                                      controller: amPmController,
                                      onSelectedItemChanged: (value) {
                                        setState(() {
                                          selectedIndexAmPm = value;
                                        });
                                      },
                                      perspective: 0.001,
                                      diameterRatio: 0.96,
                                      physics: const FixedExtentScrollPhysics(),
                                      itemExtent: MediaQuery.of(context).size.width * 0.18,
                                      childDelegate: ListWheelChildBuilderDelegate(
                                          childCount: 2,
                                          builder: (context, index) {
                                            final Color colorforitems = index == selectedIndexAmPm
                                                ? AppColors3.primaryColor
                                                : Colors.grey;
                                            final String text = index == 0 ? 'p.m.' : 'a.m.';
                                            return Center(
                                                child: Text(text,
                                                    style: TextStyle(
                                                        fontSize: index == selectedIndexAmPm
                                                            ? MediaQuery.of(context).size.width *
                                                            0.11
                                                            : MediaQuery.of(context).size.width *
                                                            0.12,
                                                        color: colorforitems)));
                                          })))
                            ]),
                      )
                    ],
                  )
              ),
            ElevatedButton(
                      onPressed: () {
                        DateTime now = DateTime.now();
                        selectedIndexAmPm == 1
                            ? selectedIndexHours == 0
                            ? hour = 24
                            : hour = selectedIndexHours
                            : selectedIndexAmPm == 0
                            ? selectedIndexHours == 0
                            ? hour = 12
                            : hour = selectedIndexHours + 12
                            : null;

                        DateTime fullTime = DateTime(
                            now.year, now.month, now.day, hour, selectedIndexMins);
                        String formattedTime = DateFormat('HH:mm:ss').format(fullTime);
                        setState(() {
                          timeController.text = formattedTime;
                        });

                        widget.onTimeChoose(
                          _isTimerShow,
                          timeController,
                          selectedIndexAmPm,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        surfaceTintColor: Colors.white,
                        splashFactory: InkRipple.splashFactory,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(color: AppColors3.primaryColor, width: 2),
                        ),
                        backgroundColor: AppColors3.primaryColor,
                      ),
                      child: const Text(
                        'Guardar',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ))
            ]);
  }
}
