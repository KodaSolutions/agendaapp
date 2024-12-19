import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alphabet_list_view/alphabet_list_view.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../forms/clientForm.dart';
import '../../../main.dart';
import '../../models/clientModel.dart';
import '../../projectStyles/appColors.dart';
import '../../services/angedaDatabase/databaseService.dart';
import '../../services/clienteService.dart';
import '../../utils/PopUpTabs/deleteClientDialog.dart';
import '../../utils/showToast.dart';
import '../../utils/toastWidget.dart';
import 'clientInfo.dart';
import 'package:http/http.dart' as http;

class Person {
  String name;
  String tag;

  Person(this.name) : tag = name.isNotEmpty ? name[0].toUpperCase() : '#';
}
class DropdownDataManager {
  List<Client> clients = [];
  Future<List<Client>> fetchUser() async {
    List<Client> nombresClientes = [];
    final dbService = DatabaseService();
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;
      if (isConnected) {
        var response = await http.get(
          Uri.parse('https://beauteapp-dd0175830cc2.herokuapp.com/api/clientsAll'),
        );
        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse is Map<String, dynamic> && jsonResponse['clients'] is List) {
            nombresClientes = List<Client>.from(
              jsonResponse['clients'].map((clientJson) => Client.fromJson(clientJson as Map<String, dynamic>)),
            );
            List<Map<String, dynamic>> clientsToSave = jsonResponse['clients']
                .map<Map<String, dynamic>>((clientJson) => clientJson as Map<String, dynamic>)
                .toList();
            await dbService.insertClient(clientsToSave);
            print('Datos de clientes sincronizados correctamente');
          } else {
            print('La respuesta no contiene una lista de clientes');
          }
        } else {
          print('Error al cargar los clientes desde la API: ${response.statusCode}');
        }
      } else {
        print('Sin conexión a internet, cargando datos locales');
        List<Map<String, dynamic>> localClients = await dbService.getClients();
        nombresClientes = localClients.map((clientMap) => Client.fromJson(clientMap)).toList();
      }
    } catch (e) {
      print('Error al realizar la solicitud o cargar datos locales: $e');
    }
    clients = nombresClientes;
    return nombresClientes;
  }
}


class ClientDetails extends StatefulWidget {
  final bool docLog;
  final void Function(
    bool,
  ) onHideBtnsBottom;
  final void Function(
    bool,
  ) onShowBlur;

  const ClientDetails({super.key, required this.onHideBtnsBottom, required this.docLog, required this.onShowBlur});

  @override
  State<ClientDetails> createState() => _ClientDetailsState();
}

class _ClientDetailsState extends State<ClientDetails> with RouteAware, SingleTickerProviderStateMixin{

  late AnimationController aniController;
  final FocusNode focusNode = FocusNode();
  final dropdownDataManager = DropdownDataManager();
  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  late bool isDocLog;
  bool visibleKeyboard = false;
  bool platform = false;
  double previousOffset = 0;
  List<Client> clients = [];
  final TextEditingController searchController = TextEditingController();
  List<Client> filteredClients = [];
  late List<AlphabetListViewItemGroup> _alphabetizedData;
  late ScrollController scrollController;
  double progress = 0;
  double maxOffset = 0;
  double avance = 0;
  double sumAvance = 0;
  double scaleValue = 0;
  int letterCherlper = 0;

  @override
  void didPopNext() {
    super.didPopNext();
    getNombres();
  }
  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
          setState(() {
            visibleKeyboard = visible;
            widget.onHideBtnsBottom(visibleKeyboard);
          });
        });
  }

  void hideKeyBoard() {
    if (visibleKeyboard) {
      FocusScope.of(context).unfocus();
    }
  }

  void _onFinishedAddClient(int initScreen, bool forShowBtnAfterAddclient) {
    setState(() {
    });
  }

  void _onHideBtnsBottom(bool hideBtnsBottom) {
    setState(() {
    });
  }

  Future<void> getNombres() async {
    List<String> fetchedNames = (await dropdownDataManager.fetchUser()).cast<String>();
    setState(() {
      clients = fetchedNames.cast<Client>();
      _alphabetizedData = _createAlphabetizedData(clients);
    });
  }
  Future<void> fetchAndPrintClientDetails() async {
    await dropdownDataManager.fetchUser();

    for (var client in dropdownDataManager.clients) {
      print('ID: ${client.id}, Nombre: ${client.name}, Email: ${client.email}, Número: ${client.number}');
    }
  }

  Future<void> addClient() async {
    return showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return ClientForm(
              onHideBtnsBottom: _onHideBtnsBottom,
              onFinishedAddClient: _onFinishedAddClient);
        }).then((_) {
      widget.onShowBlur(false);
    });
  }

  @override
  void initState() {
    super.initState();
    aniController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    scrollController = ScrollController();
    scrollController.addListener(onScroll);
    _alphabetizedData = _createAlphabetizedData(clients);
    keyboardVisibilityController = KeyboardVisibilityController();
    Platform.isIOS ? platform = false : platform = true;
    checkKeyboardVisibility();
    isDocLog = widget.docLog;
    searchController.addListener(onSearchChanged);
    dropdownDataManager.fetchUser().then((fetchedClients) {
      setState(() {
        clients = fetchedClients;
        filteredClients = clients;
        _alphabetizedData = _createAlphabetizedData(filteredClients);
      });
    });
    getNombres();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
    maxOffset = (MediaQuery.of(context).size.width - MediaQuery.of(context).size.width * 0.265)/2;
    avance = maxOffset/100;
  }

  @override
  void dispose() {
    aniController.dispose();
    routeObserver.unsubscribe(this);
    keyboardVisibilitySubscription.cancel();
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }
  void onScroll(){
    double currentOffset = scrollController.offset;
    double velocity = (currentOffset - previousOffset).abs();
    double velocityThreshold = 18.0;

    if (currentOffset > previousOffset && velocity > velocityThreshold) {
      setState(() {
        hideKeyBoard();
      });
    } else if (velocity <= velocityThreshold) {
      setState(() {
      });
    }
    previousOffset = currentOffset;
  }
  void onSearchChanged() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredClients = clients.where((client) {
        return client.name.toLowerCase().contains(query) || client.number.toString().contains(query);
      }).toList();
      _alphabetizedData = _createAlphabetizedData(filteredClients);
    });
  }
  TextSpan highlightOccurrences(String source, String query, TextStyle baseStyle) {
    if (query.isEmpty) {
      return TextSpan(
        text: source,
        style: baseStyle,
      );
    }
    var matches = <TextSpan>[];
    String lowerSource = source.toLowerCase();
    String lowerQuery = query.toLowerCase();
    int start = 0;
    int index;

    while ((index = lowerSource.indexOf(lowerQuery, start)) != -1) {
      if (index > start) {
        matches.add(TextSpan(
          text: source.substring(start, index),
          style: baseStyle,
        ));
      }
      matches.add(TextSpan(
        text: source.substring(index, index + query.length),
        style: baseStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors3.primaryColor,
        ),
      ));
      start = index + query.length;
    }

    if (start < source.length) {
      matches.add(TextSpan(
        text: source.substring(start),
        style: baseStyle,
      ));
    }

    return TextSpan(children: matches);
  }

  List<AlphabetListViewItemGroup> _createAlphabetizedData(List<Client> clients){
    final Map<String, List<Client>> data = {};
    String query = searchController.text;

    for(Client client in clients){
      final String tag = client.name[0].toUpperCase();
      if (!data.containsKey(tag)) {
        data[tag] = [];
      }
      data[tag]!.add(client);
    }

    data.forEach((key, value) {
      value.sort((a, b) => a.name.compareTo(b.name));
    });

    letterCherlper = data['C']?.length ?? 0;
    final sortedKeys = data.keys.toList()..sort();
    final clientService = ClientService();
    final List<AlphabetListViewItemGroup> groups = sortedKeys.map((key) {
      return AlphabetListViewItemGroup(
        tag: key,
        children: data[key]!.map((client) {
          return Dismissible(
            onUpdate: (details){
              setState(() {
                progress = details.progress;
                progress = details.progress * 100;
                aniController.value = progress;
                sumAvance = avance * progress;
                scaleValue = 0.6 + (progress/100) * 1.1;
              });
            },
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.005,
                  right: MediaQuery.of(context).size.width * 0.02,
                  top: MediaQuery.of(context).size.width * 0.02,
                  bottom: MediaQuery.of(context).size.width * 0.02,
              ),
              color: AppColors3.redDelete,
              alignment: Alignment.centerRight,
              child: AnimatedBuilder(
                animation: aniController,
                child: const Icon(Icons.delete, color: AppColors3.whiteColor),
                builder: (aniController, iconToMove){
                  return Transform.translate(
                      offset: Offset(-sumAvance, 0),
                      child: Transform.scale(scale: scaleValue, child: Icon(Icons.delete, color: AppColors3.whiteColor, size: MediaQuery.of(context).size.width * 0.06,)));
                }
              )
            ),
            confirmDismiss: (direction) async {
              widget.onShowBlur(true);
              bool shouldDelete = await showDeleteConfirmationDialog(context, () async {
                await clientService.deleteClient(client.id);
                if(mounted){
                  showOverlay(
                    context,
                    const CustomToast(
                      message: 'Cliente eliminado correctamente',
                    ),
                  );
                }
              });
              if (shouldDelete) {
                setState(() {
                  clients.remove(client);
                });
                widget.onShowBlur(false);
                return true;
              } else {
                widget.onShowBlur(false);
                return false;
              }
            },
            child: Visibility(
              visible: client.id != 1,
              child: ListTile(
              onTap: () {
                Navigator.push(context,
                  CupertinoPageRoute(
                    builder: (context) => ClientInfo(
                      docLog: isDocLog,
                      id: client.id,
                      name: client.name,
                      phone: client.number,
                      email: client.email,
                    ),
                  ),
                );
              },
              title: Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                child: RichText(
                  text: highlightOccurrences(client.name, query,
                    TextStyle(
                      overflow: TextOverflow.ellipsis,
                      color: AppColors3.primaryColorMoreStrong,
                      fontSize: MediaQuery.of(context).size.width * 0.055,
                    ),
                  ),
                ),
              ),
              subtitle: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: highlightOccurrences(
                            client.number.toString(),
                            query,
                            TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: AppColors3.primaryColorMoreStrong.withOpacity(0.5),
                              fontSize: MediaQuery.of(context).size.width * 0.045,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          client.email,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors3.primaryColorMoreStrong.withOpacity(0.5),
                            fontSize: MediaQuery.of(context).size.width * 0.045,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    thickness: 2,
                  ),
                ],
              ),
            ),)
          );
        }).toList(),
      );
    }).toList();
    return groups;
  }
//
  @override
  Widget build(BuildContext context) {
    final AlphabetListViewOptions options = AlphabetListViewOptions(
      listOptions: ListOptions(
        listHeaderBuilder: (context, symbol) {
          return  Visibility(
            visible: symbol == 'C' && letterCherlper == 1 ? false : true,
            child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.only(left: 6.0, top: 6, bottom: 6),
            decoration: BoxDecoration(
              color: AppColors3.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              symbol,
              style: const TextStyle(color: AppColors3.whiteColor, fontSize: 20),
            ),
          ),);
        },
      ),
      scrollbarOptions: ScrollbarOptions(
        jumpToSymbolsWithNoEntries: true,
        symbolBuilder: (context, symbol, state) {
          final color = switch (state) {
            AlphabetScrollbarItemState.active => AppColors3.whiteColor,
            AlphabetScrollbarItemState.deactivated => AppColors3.primaryColor,
            _ => AppColors3.primaryColor.withOpacity(0.6),
          };

          return Container(
            padding: const EdgeInsets.only(left: 4, top: 2, bottom: 2),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(100),
              ),
              color: state == AlphabetScrollbarItemState.active
                  ? AppColors3.primaryColor.withOpacity(0.5)
                  : null,
            ),
            child: Center(
              child: FittedBox(
                child: Text(
                  symbol,
                  style: TextStyle(color: color, fontSize: 30),
                ),
              ),
            ),
          );
        },
      ),
      overlayOptions: OverlayOptions(
        overlayBuilder: (context, symbol) {
          return Container(
            alignment: Alignment.center,
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors3.blackColor.withOpacity(0.4),
            ),
            child: Text(
              symbol,
              style: const TextStyle(color: AppColors3.whiteColor, fontSize: 100),
            ),
          );
        },
      ),
    );

    return Container(
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                    padding: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.045,
                    ),
                    child: SizedBox(
                      height: 37,
                      child: TextFormField(
                        controller: searchController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Buscar...',
                          hintStyle: TextStyle(
                            color: AppColors3.primaryColorMoreStrong.withOpacity(0.3)
                          ),
                          prefixIcon: Icon(Icons.search, color: AppColors3.primaryColorMoreStrong.withOpacity(0.3)),
                          disabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors3.primaryColorMoreStrong, width: 2.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors3.primaryColorMoreStrong.withOpacity(0.5), width: 2.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors3.primaryColorMoreStrong, width: 2.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors3.primaryColorMoreStrong),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.025,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      widget.onShowBlur(true);
                      addClient();
                    });
                  },
                  icon: Icon(
                    Icons.person_add_alt_1_rounded,
                    size: MediaQuery.of(context).size.width * 0.11,
                    color: AppColors3.primaryColorMoreStrong.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: getNombres,
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                child: AlphabetListView(
                  scrollController: scrollController,
                  items: _alphabetizedData,
                  options: options,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}