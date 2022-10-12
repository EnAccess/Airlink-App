
import 'dart:async';
import 'dart:ui';

import 'package:airlink/pages/HomePage.dart';
import 'package:airlink/provider/device_provider.dart';
import 'package:airlink/services/AirLinkServer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //start background service
  await initializeService();

  //run app
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => DeviceProvider())
    ],
    child: const AirLinkApp(),
  ));
}

Future<void> initializeService() async {
  final backgroundService = FlutterBackgroundService();
  await backgroundService.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: false,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  backgroundService.startService();
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch
bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    print('FLUTTER BACKGROUND FETCH');
  }

  return true;
}

void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  //set notification title and content
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "AirLink App",
      content: "Posting advert data to AirLink server.",
    );
  }

  //background functions that run periodically after a specified time
  Timer.periodic(const Duration(minutes: 15), (timer) async {

    final backgroundService = FlutterBackgroundService();
    if (!(await backgroundService.isRunning())) timer.cancel();

    await AirLinkServer().postAdvertData();
  });
}

const String _title = 'AirLink';

class AirLinkApp extends StatelessWidget {
  const AirLinkApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: HomePage(),
    );
  }
}

