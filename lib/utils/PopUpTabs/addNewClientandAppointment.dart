import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../regEx.dart';
import '../../projectStyles/appColors.dart';

class AddClientAndAppointment extends StatefulWidget {
  final String clientNamefromAppointmetForm;
  final VoidCallback onConfirm;
  final void Function(
    String,
    String,
    int,
      bool,
  ) onSendDataToAppointmentForm;

  const AddClientAndAppointment(
      {super.key,
      required this.clientNamefromAppointmetForm,
      required this.onConfirm,
      required this.onSendDataToAppointmentForm});

  @override
  State<AddClientAndAppointment> createState() =>
      _AddClientAndAppointmentState();
}

class _AddClientAndAppointmentState extends State<AddClientAndAppointment> {
  final TextEditingController _clientNamefromAppointmetForm =
      TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  //errores
  bool nameError = false;
  bool celError = false;
  bool emailError = false;
  //

  @override
  void initState() {
    super.initState();
    _clientNamefromAppointmetForm.text = widget.clientNamefromAppointmetForm;
  }

  void onSendDataToAppointmentForm() {
    setState(() {
        emailController.text.isEmpty ? emailError = true : emailError = false;
        numberController.text.isEmpty || numberController.text.length < 10 ? celError = true : celError = false;
      if(emailError == false && celError == false && emailController.text.isNotEmpty && numberController.text.isNotEmpty){
        widget.onSendDataToAppointmentForm(
          _clientNamefromAppointmetForm.text,
          emailController.text,
          int.parse(numberController.text),
          false,
        );
        print(_clientNamefromAppointmetForm.text);
        print(emailController.text);
        print('${int.parse(numberController.text)}');
        Navigator.of(context).pop(true);
      }else {
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.02,
          right: MediaQuery.of(context).size.width * 0.02,
          bottom: MediaQuery.of(context).size.width * 0.04,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nuevo cliente',
                  style: TextStyle(
                    color: AppColors3.primaryColor,
                    fontSize: MediaQuery.of(context).size.width * 0.075,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: AppColors3.primaryColor,
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.035,
                  bottom: MediaQuery.of(context).size.width * 0.02),
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width * 0.02,
                horizontal: MediaQuery.of(context).size.width * 0.02,
              ),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: AppColors3.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Nombre del cliente:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextFormField(
              controller: _clientNamefromAppointmetForm,
              inputFormatters: [
                RegEx(type: InputFormatterType.alphanumeric),
              ],
              decoration: InputDecoration(
                error: nameError ? const Text('Agregar nombre', style: TextStyle(
                  color: Colors.red,
                ),) : null,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.03),
                hintText: 'Nombre completo',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                        color: AppColors3.primaryColor)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: AppColors3.primaryColor)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: AppColors3.primaryColor, width: 1.5),),
              ),
              onTap: () {},
            ),
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.035,
                  bottom: MediaQuery.of(context).size.width * 0.02),
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width * 0.02,
                horizontal: MediaQuery.of(context).size.width * 0.02,
              ),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: AppColors3.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'No. Celular:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextFormField(
              controller: numberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                RegEx(type: InputFormatterType.numeric),
              ],
              decoration: InputDecoration(
                error: celError && numberController.text.isEmpty? const Text('Agregar número', style: TextStyle(
                  color: Colors.red,
                ),) : celError && numberController.text.length < 10 ? const Text('El número debe tener 10 digitos', style: TextStyle(
                  color: Colors.red,
                ),) : null,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.03),
                hintText: 'No. Celular',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                        color: AppColors3.primaryColor)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: AppColors3.primaryColor)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: AppColors3.primaryColor, width: 1.5),),
              ),
              onTap: () {},
            ),
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.035,
                  bottom: MediaQuery.of(context).size.width * 0.02),
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width * 0.02,
                horizontal: MediaQuery.of(context).size.width * 0.02,
              ),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: AppColors3.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Correo electrónico:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.width * 0.05),
              child: TextFormField(
                controller: emailController,
                inputFormatters: [
                  RegEx(type: InputFormatterType.email),
                ],
                decoration: InputDecoration(
                  error: emailError ? const Text('Agregar correo', style: TextStyle(color: Colors.red),) : null,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.03),
                  hintText: 'Correo electrónico',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                          color: AppColors3.primaryColor)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: AppColors3.primaryColor)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: AppColors3.primaryColor, width: 1.5),),
                ),
                onTap: () {},
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onSendDataToAppointmentForm();
              },
              style: ElevatedButton.styleFrom(
                surfaceTintColor: Colors.white,
                splashFactory: InkRipple.splashFactory,
                minimumSize: const Size(0, 0),
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.02,
                    horizontal: MediaQuery.of(context).size.width * 0.02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: const BorderSide(color: AppColors3.primaryColor, width: 2),
                ),
                backgroundColor: Colors.white,
              ),
              child: Text(
                textAlign: TextAlign.center,
                'Agregar cliente y crear cita',
                style: TextStyle(
                  color: AppColors3.primaryColor,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                ),
              ),
            ),
          ],
        ),
      );
  }
}
