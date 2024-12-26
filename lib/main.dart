import 'package:agenda_app/projectStyles/appColors.dart';
import 'package:agenda_app/services/angedaDatabase/databaseHelpers.dart';
import 'package:agenda_app/views/login.dart';
import 'package:flutter/material.dart';
//
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  print('Iniciando configuración de Firebase...');
  await Firebase.initializeApp();
  print('Firebase inicializado');

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Agregar listener para cuando la app está en background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Solicitar permisos con más detalle
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
    criticalAlert: true,
    announcement: true,
  );
  print('Estado de permisos detallado:');
  print('- Alert: ${settings.alert}');
  print('- Badge: ${settings.badge}');
  print('- Sound: ${settings.sound}');
  //print('- Provisional: ${settings.provisional}');

  // Configurar todos los listeners posibles
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('💬 MENSAJE EN PRIMER PLANO RECIBIDO:');
    print('- Título: ${message.notification?.title}');
    print('- Cuerpo: ${message.notification?.body}');
    print('- Data: ${message.data}');
    print('- Mensaje completo: ${message.toMap()}');
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('🔔 APP ABIERTA DESDE NOTIFICACIÓN:');
    print('- Título: ${message.notification?.title}');
    print('- Cuerpo: ${message.notification?.body}');
    print('- Data: ${message.data}');
  });

  try {
    String? fcmToken = await messaging.getToken();
    print('📱 FCM Token obtenido: $fcmToken');

    // Escuchar renovaciones de token
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('🔄 Token FCM renovado: $newToken');
    });
  } catch (e) {
    print('❌ Error al obtener token FCM: $e');
  }

  runApp(const MyApp());
}

// Handler para mensajes en background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📨 Mensaje recibido en background:');
  print('- Título: ${message.notification?.title}');
  print('- Cuerpo: ${message.notification?.body}');
  print('- Data: ${message.data}');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    bool isDocLog = false;
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors3.primaryColor),
        useMaterial3: true,
      ),
      routes: {
        '/login': (context) => const Login(),
      },
      debugShowCheckedModeBanner: false,
      ///pendiente unificacion
      home: SplashScreen(),
      navigatorObservers: [routeObserver],
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ]);
  }
}
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool isConnected = false;
  late DatabaseHelpers dbHelpers;
  @override
  void initState() {
    super.initState();
    dbHelpers = DatabaseHelpers(context);
    dbHelpers.verifyDatabase();
    dbHelpers.checkConnectionAndLoginStatus(isConnected);
  }
  void goToLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Login()));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors3.primaryColor,
            ),
            SizedBox(height: 20),
            Text('Cargando...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
//
