import 'package:airlink/features/profile/presentation/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/profile_model.dart';
import '../provider/profile_provider.dart';

class AirLinkCredentialsForm extends StatefulWidget {
  const AirLinkCredentialsForm({super.key});

  @override
  State<AirLinkCredentialsForm> createState() => _AirLinkCredentialsFormState();
}

class _AirLinkCredentialsFormState extends State<AirLinkCredentialsForm> {

  late Future _getProfileFuture;

  final _serverUrlController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _deviceProfileIdController = TextEditingController();
  final _gatewayProfileIdController = TextEditingController();
  final _defaultAccessTokenController = TextEditingController();

  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();

  _provisionGateway() async {
    if (_profileFormKey.currentState!.validate()) {
      //create profile model
      final profileModel = ProfileModel(
        airlinkServerUrl: _serverUrlController.text,
        email: _emailController.text,
        password: _passwordController.text,
        deviceProfileId: _deviceProfileIdController.text,
        gatewayProfileId: _gatewayProfileIdController.text,
        defaultAccessToken: _defaultAccessTokenController.text,
      );

      //get provider
      final profileProvider =
      Provider.of<ProfileProvider>(context, listen: false);

      // provision gateway
      profileProvider.provisionNewGateway(
          context: context, profileModel: profileModel);
    }
    _profileFormKey.currentState!.save();
  }

  Future<ProfileModel> _getProfile() async {
    return Provider.of<ProfileProvider>(context, listen: false)
        .getGatewayProfile();
  }

  @override
  void initState() {
    super.initState();
    _getProfileFuture = _getProfile();
  }

  @override
  void dispose() {
    super.dispose();
    _serverUrlController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _deviceProfileIdController.dispose();
    _gatewayProfileIdController.dispose();
    _defaultAccessTokenController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final profileModel = snapshot.data as ProfileModel;
              _serverUrlController.text = profileModel.airlinkServerUrl ?? '';
              _emailController.text = profileModel.email ?? '';
              _passwordController.text = profileModel.password ?? '';
              _deviceProfileIdController.text = profileModel.deviceProfileId ?? '';
              _gatewayProfileIdController.text = profileModel.gatewayProfileId ?? '';
              _defaultAccessTokenController.text = profileModel.defaultAccessToken ?? '';
            }
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _profileFormKey,
              child: ListView(
                children: [
                  Text(
                    'Device/Tenant Admin',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),
                  InputField(
                    controller: _serverUrlController,
                    keyboardType: TextInputType.url,
                    labelText: 'Server URL',
                    helperText: 'e.g. https://airlink.example.com',
                  ),
                  InputField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    labelText: 'Email',
                    helperText: 'Server login email',
                  ),
                  InputField(
                    controller: _passwordController,
                    keyboardType: TextInputType.url,
                    labelText: 'Password',
                    obscureText: true,
                    helperText: 'Server login password',
                  ),
                  InputField(
                    controller: _deviceProfileIdController,
                    labelText: 'Device profile ID',
                    helperText: 'e.g. 4aabfa70-a5cb-11ed-a661-4bb15f6c2dec',
                  ),
                  InputField(
                    controller: _gatewayProfileIdController,
                    labelText: 'Gateway profile ID',
                    helperText: 'e.g. 4034f6e0-5d81-11ec-a661-4bb15f6c2dec',
                  ),
                  InputField(
                    controller: _defaultAccessTokenController,
                    labelText: 'Default access token',
                    helperText: 'Embed this token in the firmware',
                    obscureText: true,
                  ),
                  FilledButton(
                    onPressed: () async {
                      _provisionGateway();
                    },
                    child: const Text('Provision Gateway'),
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),
                  Consumer<ProfileProvider>(
                      builder: (context, profileProvider, _) {
                        return Text(
                            'DEVICE_ID: ${profileProvider.gatewayDeviceId}');
                      }),
                  const SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
