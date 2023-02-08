
import 'dart:async';
import 'dart:ui';

import 'package:airlink/pages/HomePage.dart';
import 'package:airlink/provider/device_provider.dart';
import 'package:airlink/services/BackgroudService.dart';
import 'package:airlink/services/BackgroudTasks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import 'constants/enums.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == BackgroundTask.postAdvertisementData.name) {
      if (kDebugMode) {
        print("Background task called: $taskName");
      }

      BackgroundService backgroundService = BackgroundService();
      await backgroundService.postAdvertisementData();
    }

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  await dotenv.load(fileName: ".env");

  //method to run background tasks
  runBackgroundTasks();

  //run app
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => DeviceProvider())
    ],
    child: const AirLinkApp(),
  ));
}

runBackgroundTasks() async {
  //run background task for posting advert data
  await BackgroundTasks.postAdvertData();
}

const String _title = 'AirLink';

class AirLinkApp extends StatelessWidget {
  const AirLinkApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: HomePage(title: _title,),
    );
  }
}

