import 'package:flutter/material.dart';

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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02,
            vertical: MediaQuery.of(context).size.width * 0.037,
          ),
          labelText: 'Seleecione especie'
      ),
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