import 'package:airlink/core/utils/enums/enums.dart';
import 'package:airlink/core/widgets/snackbars.dart';
import 'package:airlink/features/generate_token/data/models/device_suggestion_model.dart';
import 'package:airlink/features/generate_token/domain/usecases/generate_token.dart';
import 'package:flutter/cupertino.dart';

import '../../data/models/token_device_model.dart';
import '../../domain/usecases/get_device_suggestion.dart';

class TokenDeviceProvider extends ChangeNotifier {
  final GenerateToken generateToken;
  final GetDeviceSuggestion getDeviceSuggestion;

  TokenDeviceProvider({
    required this.generateToken,
    required this.getDeviceSuggestion,
  });

  String? _token;

  List<DeviceSuggestionModel> _suggestions = [];

  DeviceSuggestionModel? _selectedDevice;

  String? get token => _token;

  List<DeviceSuggestionModel> get suggestions => _suggestions;

  DeviceSuggestionModel? get selectedDevice => _selectedDevice;

  //return suggestions that payg_type is not empty
  List<DeviceSuggestionModel> get filteredSuggestions =>
      _suggestions
          .where((element) => element.paygType.isNotEmpty)
          .toList();

  Future<void> generateTokenDevice(
      {required BuildContext context,
      required TokenDeviceModel tokenDeviceModel}) async {

    //show loading
    Snackbar.show(
        context: context,
        message: 'Generating token...',
        type: SnackbarType.loading,
        timeoutInSeconds: 120);


    final result = await generateToken(tokenDeviceModel);
    result.fold(
      (failure) {

        //hide loading
        Snackbar.hide(context: context);

        Snackbar.show(
            context: context,
            type: SnackbarType.error,
            message: failure.toString());
      },
      (token) {
        setToken(token);

        //hide loading
        Snackbar.hide(context: context);
      },
    );
  }

  Future<void> getDeviceSuggestions(
      {required BuildContext context, required String deviceName}) async {
    final result = await getDeviceSuggestion(deviceName);
    result.fold(
      (failure) {
        Snackbar.show(
            context: context,
            type: SnackbarType.error,
            message: failure.toString());
      },
      (deviceSuggestions) {
        _suggestions = deviceSuggestions
            .map((d) => DeviceSuggestionModel.fromEntity(d))
            .toList();
        notifyListeners();
      },
    );
  }

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void clearToken() {
    _token = null;
    notifyListeners();
  }

  void setSelectedDevice(DeviceSuggestionModel device) {
    _selectedDevice = device;
    notifyListeners();
  }

  void clearSelectedDevice() {
    _selectedDevice = null;
    notifyListeners();
  }
}
