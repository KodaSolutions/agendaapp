import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../projectStyles/appColors.dart';

class TitleContainer extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry alignment;
  final BoxDecoration? decoration;
  final Widget? child;

  const TitleContainer({
    super.key,
    this.padding,
    this.margin,
    this.alignment = Alignment.centerLeft,
    this.decoration,
    this.child,
  });

  @override
  Widget build(BuildContext context) {

    const BoxDecoration defaultDecoration = BoxDecoration(
      color: AppColors3.primaryColor,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    );

    final EdgeInsetsGeometry defaultPadding = EdgeInsets.symmetric(
      vertical: MediaQuery.of(context).size.width * 0.02,
      horizontal: MediaQuery.of(context).size.width * 0.02,
    );

    final EdgeInsetsGeometry defaultMargin = EdgeInsets.symmetric(
      horizontal: MediaQuery.of(context).size.width * 0.025,
    );

    return Container(
      padding: padding ?? defaultPadding,
      margin: margin ?? defaultMargin,
      alignment: alignment,
      decoration: decoration ?? defaultDecoration,
      child: child,
    );
  }
}

class FieldsPading extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Widget child;

  const FieldsPading({
    super.key,
    this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry defaultPadding = EdgeInsets.symmetric(
      vertical: MediaQuery.of(context).size.width * 0.02,
      horizontal: MediaQuery.of(context).size.width * 0.02,
    );

    return Padding(
      padding: padding ?? defaultPadding,
      child: child,
    );
  }
}

class CalendarContainer extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BoxDecoration? decoration;
  final Widget? child;

  const CalendarContainer({
    super.key,
    this.margin,
    this.padding,
    this.width,
    this.height,
    this.decoration,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final BoxDecoration defaultDecoration = BoxDecoration(
      border: Border.all(color: AppColors3.blackColor.withOpacity(0.5), width: 0.5),
      color: AppColors3.whiteColor,
      borderRadius: BorderRadius.circular(15),
    );

    final EdgeInsetsGeometry defaultMargin = EdgeInsets.symmetric(
      horizontal: MediaQuery.of(context).size.width * 0.023,
    );

    final double defaultWidth = MediaQuery.of(context).size.width;
    final double defaultHeight = MediaQuery.of(context).size.height * 0.4;

    final EdgeInsetsGeometry defaultPadding = EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.04,
        right: MediaQuery.of(context).size.width * 0.04,
        bottom: MediaQuery.of(context).size.width * 0.04);

    return Container(
      margin: margin ?? defaultMargin,
      padding: padding ?? defaultPadding,
      width: width ?? defaultWidth,
      height: height ?? defaultHeight,
      decoration: decoration ?? defaultDecoration,
      child: child,
    );
  }
}

class DoctorsMenu extends StatefulWidget {
  final Function(bool, TextEditingController, int, int) onAssignedDoctor;
  final int optSelectedToRecieve;
  final List<Map<String, dynamic>> doctors;
  final Function (double?)? onAjustSize;

  const DoctorsMenu({
    super.key,
    required this.onAssignedDoctor,
    required this.optSelectedToRecieve,
    required this.doctors, this.onAjustSize,
  });

  @override
  State<DoctorsMenu> createState() => _DoctorsMenuState();
}

class _DoctorsMenuState extends State<DoctorsMenu> {
  final TextEditingController drSelected = TextEditingController();
  int? optSelectedToSend;
  int? optSelected;
  final GlobalKey _columnKey = GlobalKey();
  List<GlobalKey> _listColumsKey = [];


  @override
  void initState() {
    super.initState();
    optSelected = widget.optSelectedToRecieve;
    print('stuels : ${widget.doctors}');
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    for (int i = 0; i < widget.doctors.length; i++) {
      _listColumsKey.add(GlobalKey());
    }
    if(widget.doctors.isNotEmpty){
      WidgetsBinding.instance.addPostFrameCallback((_){
        widget.onAjustSize!(_listColumsKey.first.currentContext?.size!.height);
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors3.primaryColor, width: 1),
        color: AppColors3.whiteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        key: _columnKey,
        children: widget.doctors.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> doctor = entry.value;
          return Column(
            key: _listColumsKey[index],
            children: [
              InkWell(
                splashColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    drSelected.text = doctor['name'];
                    widget.onAssignedDoctor(
                      true,
                      drSelected,
                      optSelectedToSend = index + 1,
                      int.parse(doctor['id'],),
                    );
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.02),
                  decoration: BoxDecoration(
                    color: optSelected == index + 1 || optSelectedToSend == index + 1
                        ? AppColors3.primaryColor
                        : AppColors3.whiteColor,
                    borderRadius: BorderRadius.vertical(
                      top: index == 0 ? const Radius.circular(10) : Radius.zero,
                      bottom: index == widget.doctors.length - 1
                          ? const Radius.circular(10)
                          : Radius.zero,
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02),
                        child: SvgPicture.asset('assets/icons/docVector2.svg',
                          width: MediaQuery.of(context).size.width * 0.06,
                          height: MediaQuery.of(context).size.width * 0.06,
                          colorFilter: optSelected == index + 1 || optSelectedToSend == index + 1
                              ? const ColorFilter.mode(AppColors3.bgColor, BlendMode.srcIn) : const ColorFilter.mode(AppColors3.primaryColor, BlendMode.srcIn),
                        ),
                      ),
                      Text(
                        doctor['name'],
                        style: TextStyle(
                          color: optSelected == index + 1 || optSelectedToSend == index + 1
                              ? AppColors3.whiteColor
                              : AppColors3.primaryColor,
                          fontSize: MediaQuery.of(context).size.width * 0.054,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Divider
              if (index != widget.doctors.length - 1)
                Container(
                  color: AppColors3.primaryColor.withOpacity(0.5),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.0009,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}


class FieldsToWrite extends StatelessWidget {
  final String labelText;
  final Icon? suffixIcon;
  final Icon? preffixIcon;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool? eneabled;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function()? onEdComplete;
  final void Function(PointerDownEvent)? onTapOutside;
  final List<TextInputFormatter>? inputFormatters;
  final String? initVal;
  final InputDecoration? inputdecoration;

  const FieldsToWrite({
    super.key,
    required this.labelText,
    this.suffixIcon,
    this.fillColor,
    this.contentPadding,
    this.controller,
    required this.readOnly,
    this.focusNode,
    this.onChanged,
    this.onTap,
    this.eneabled,
    this.onEdComplete,
    this.textInputAction,
    this.onTapOutside,
    this.inputFormatters,
    this.preffixIcon,
    this.initVal, this.inputdecoration,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry defaultContentPadding = EdgeInsets.symmetric(
      horizontal: MediaQuery.of(context).size.width * 0.03,
    );
    final InputDecoration defaultInputD = InputDecoration(
      hintText: labelText,
      suffixIcon: suffixIcon,
      contentPadding: contentPadding ?? defaultContentPadding,
      prefixIcon: preffixIcon,
      filled: fillColor != null,
      fillColor: fillColor ?? AppColors3.whiteColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
    ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: AppColors3.primaryColor, // Cambia este color al que prefieras
          width: 1.0, // El grosor del borde
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
        focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: AppColors3.primaryColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
      )
    );

    return TextFormField(
      initialValue: initVal,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      onEditingComplete: onEdComplete,
      enabled: eneabled,
      focusNode: focusNode,
      controller: controller,
      readOnly: readOnly,
      decoration: inputdecoration  ?? defaultInputD,
      onChanged: onChanged,
      onTap: onTap,
      onTapOutside: onTapOutside,
    );
  }
}
