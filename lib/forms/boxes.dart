import 'package:flutter/material.dart';

import '../projectStyles/appColors.dart';

class Pet extends StatefulWidget {
  final Function(String?) onPet;
  const Pet({super.key, required this.onPet});

  @override
  State<Pet> createState() => _PetState();
}

class _PetState extends State<Pet> {
  String? selectedOpt;

  List<String> listPet = [
    'Perro',
    'Gato',
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10)
              ),
              borderSide: BorderSide(
                color: AppColors3.primaryColor,
                width: 1,
              )
          ),
          enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10)
              ),
              borderSide: BorderSide(
                color: AppColors3.primaryColor,
                width: 1,
              )
          ),
          focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10)
              ),
              borderSide: BorderSide(
                color: AppColors3.primaryColor,
                width: 1,
              )
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02,
            vertical: MediaQuery.of(context).size.width * 0.03,
          ),
          labelText: 'Seleccione especie'
      ),
      iconDisabledColor: AppColors3.primaryColor,
      iconEnabledColor: AppColors3.primaryColor,
      value: selectedOpt,
      items: listPet.map((edo) {
        return DropdownMenuItem(
          value: edo,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              edo,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedOpt = value;
          widget.onPet(selectedOpt);
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Por favor selecciona una opción';
        }
        return null;
      },
    );
  }
}

class ApptmType extends StatefulWidget {
  final Function(String?) onApptmType;
  const ApptmType({super.key, required this.onApptmType});

  @override
  State<ApptmType> createState() => _ApptmTypeState();
}

class _ApptmTypeState extends State<ApptmType> {
  String? selectedOpt;

  List<String> listApptmType = [
    'Consulta general',
    'Estética',
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10)
              ),
              borderSide: BorderSide(
                color: AppColors3.primaryColor,
                width: 1,
              )
          ),
          enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10)
              ),
              borderSide: BorderSide(
                color: AppColors3.primaryColor,
                width: 1,
              )
          ),
          focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10)
              ),
              borderSide: BorderSide(
                color: AppColors3.primaryColor,
                width: 1,
              )
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02,
            vertical: MediaQuery.of(context).size.width * 0.03,
          ),
          labelText: 'Seleccione tipo de cita'
      ),
      iconDisabledColor: AppColors3.primaryColor,
      iconEnabledColor: AppColors3.primaryColor,
      value: selectedOpt,
      items: listApptmType.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              type,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedOpt = value;
          widget.onApptmType(selectedOpt);
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Por favor selecciona una opción';
        }
        return null;
      },
    );
  }
}