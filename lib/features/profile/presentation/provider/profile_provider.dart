import 'dart:developer';

import 'package:airlink/features/profile/data/models/profile_model.dart';
import 'package:airlink/features/profile/domain/usecases/get_profile.dart';
import 'package:airlink/features/profile/domain/usecases/provision_gateway.dart';
import 'package:airlink/features/profile/domain/usecases/usecase.dart';
import 'package:flutter/material.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/enums/enums.dart';
import '../../../../core/widgets/snackbars.dart';
import '../../domain/usecases/get_gateway_device_id.dart';

class ProfileProvider extends ChangeNotifier {
  final ProvisionGateway provisionGateway;
  final GetProfile getProfile;
  final GetGatewayDeviceId getGatewayDeviceId;

  ProfileProvider({
    required this.provisionGateway,
    required this.getProfile,
    required this.getGatewayDeviceId,
  });

  String _gatewayDeviceId = '';

  String get gatewayDeviceId => _gatewayDeviceId.toUpperCase();

  void provisionNewGateway(
      {required BuildContext context,
      required ProfileModel profileModel}) async {

    //show loading
    Snackbar.show(
        context: context,
        message: 'Provisioning gateway...',
        type: SnackbarType.loading,
        timeoutInSeconds: 120
    );

    final result = await provisionGateway(profileModel);

    result.fold((failure) {

      //hide loading
      Snackbar.hide(context: context);

      if (failure is ServerFailure) {
        Snackbar.show(
            context: context,
            type: SnackbarType.error,
            message: failure.message);
      } else {
        log(failure.toString());
        Snackbar.show(
            context: context,
            type: SnackbarType.error,
            message: failure.toString());
      }
    },
        (_) => Snackbar.show(
            context: context,
            type: SnackbarType.success,
            message: 'Gateway Provisioned Successfully'));
  }

  Future<ProfileModel> getGatewayProfile() async {
    //get gateway id
    await getGatewayId();

    //get profile
    final result = await getProfile(NoParams());

    return result.fold((failure) {
      throw failure;
    }, (profile) {
      return ProfileModel.fromEntity(profile);
    });
  }

  Future getGatewayId() async {
    final result = await getGatewayDeviceId(NoParams());

    return result.fold((failure) {
      throw failure;
    }, (deviceId) {
      _gatewayDeviceId = deviceId;
      notifyListeners();
    });
  }
}
