import 'package:workmanager/workmanager.dart';

import '../constants/enums.dart';

class BackgroundTasks {
  ///After every 15mins, when connected to the network and battery not low,
  ///Gather all the advert data from the database and posts to server.
  static postAdvertData() async {
    await Workmanager().registerPeriodicTask(
      'postAdvertData',
      BackgroundTask.postAdvertisementData.name,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }
}
