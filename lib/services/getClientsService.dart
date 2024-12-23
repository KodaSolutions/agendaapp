import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/clientModel.dart';

class DropdownDataManager {
  List<Client> clients = [];

  Future<void> fetchUser() async {
    try {
      var response = await http.get(
          Uri.parse('https://agendapp-cvp-75a51cfa88cd.herokuapp.com/api/clientsAll'));
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map<String, dynamic> && jsonResponse['clients'] is List) {
          clients = List.from(jsonResponse['clients'])
              .map((clientJson) => Client.fromJson(clientJson as Map<String, dynamic>))
              .toList();
          print('Clientes cargados: $clients');
        } else {
          print('La respuesta no contiene una lista de clientes.');
        }
      } else {
        print('Error al cargar los clientes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al realizar la solicitud: $e');
    }
  }


  List<Client> getSuggestions(String query) {
    return clients.where((client) {
      final clientLower = client.name.toLowerCase();
      final queryLower = query.toLowerCase();
      return clientLower.contains(queryLower);
    }).toList();
  }
}

class ClientsAutocomplete extends StatefulWidget {
  @override
  _ClientsAutocompleteState createState() => _ClientsAutocompleteState();
}

class _ClientsAutocompleteState extends State<ClientsAutocomplete> {
  final dropdownDataManager = DropdownDataManager();

  @override
  void initState() {
    super.initState();
    dropdownDataManager.fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Client>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<Client>.empty();
        }
        return dropdownDataManager.getSuggestions(textEditingValue.text);
      },
      displayStringForOption: (Client option) => option.name,
      onSelected: (Client selection) {
      },
    );
  }
}
