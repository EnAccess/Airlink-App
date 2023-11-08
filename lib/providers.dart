import 'package:airlink/features/device/presentation/providers/device_provider.dart';
import 'package:airlink/service_locator.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'features/generate_token/presentation/providers/token_device_provider.dart';
import 'features/profile/presentation/provider/angaza_provider.dart';
import 'features/profile/presentation/provider/profile_provider.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => sl<ProfileProvider>()),
  ChangeNotifierProvider(create: (_) => sl<DeviceProvider>()),
  ChangeNotifierProvider(create: (_) => sl<TokenDeviceProvider>()),
  ChangeNotifierProvider(create: (_) => sl<AngazaProvider>()),
];