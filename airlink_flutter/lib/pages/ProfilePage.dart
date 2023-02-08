import 'package:airlink/constants/constants.dart';
import 'package:airlink/services/AirLinkServer.dart';
import 'package:airlink/widgets/AlertWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import '../models/api_response/server_response.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = const FlutterSecureStorage();

  final serverUrlController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final deviceProfileIdController = TextEditingController();
  final gatewayProfileIdController = TextEditingController();

  String _androidDeviceId = '';

  @override
  void initState() {
    super.initState();
    initGetDeviceId();
    init();
  }

  Future init() async {
    final serverUrl = await storage.read(key: 'serverUrl');
    final email = await storage.read(key: 'email');
    final password = await storage.read(key: 'password');
    final deviceProfileId = await storage.read(key: 'deviceProfileId');
    final gatewayProfileId = await storage.read(key: 'gatewayProfileId');

    setState(() {
      serverUrlController.text = serverUrl ?? '';
      emailController.text = email ?? '';
      passwordController.text = password ?? '';
      deviceProfileIdController.text = deviceProfileId ?? '';
      gatewayProfileIdController.text = gatewayProfileId ?? '';
    });
  }

  Future<void> initGetDeviceId() async {
    late String? androidDeviceId;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    androidDeviceId = androidInfo.androidId;

    await storage.write(key: 'androidDeviceId', value: androidDeviceId);

    setState(() {
      _androidDeviceId = androidDeviceId!;
    });
  }

  bool loading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildServerUrlField() {
    return TextFormField(
      controller: serverUrlController,
      decoration: const InputDecoration(
        labelText: 'AirLink Server URL',
        border: OutlineInputBorder(),
        hintText: 'Base URL',
        isDense: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Server URL is required';
        }
        return null;
      },
      keyboardType: TextInputType.url,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: emailController,
      decoration: const InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
        hintText: 'user@email.com',
        isDense: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }
        if (!RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      decoration: const InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        return null;
      },
    );
  }

  Widget _buildDeviceProfileIdField() {
    return TextFormField(
      controller: deviceProfileIdController,
      decoration: const InputDecoration(
        labelText: 'Device profile ID',
        border: OutlineInputBorder(),
        hintText: '6e459af0-3d47-12ec-9d49-c736588b5cd59',
        isDense: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Device profile ID is required';
        }
        return null;
      },
    );
  }

  Widget _buildGatewayProfileIdField() {
    return TextFormField(
      controller: gatewayProfileIdController,
      decoration: const InputDecoration(
        labelText: 'Gateway profile ID',
        border: OutlineInputBorder(),
        hintText: 'daf5dba0-ef75-31ec-cd39-c7457fe45399',
        isDense: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Gateway profile ID is required';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 15,
        ),
        padding: const EdgeInsets.all(15.0));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(
              height: 8.0,
            ),
            _buildServerUrlField(),
            const SizedBox(
              height: 15.0,
            ),
            _buildEmailField(),
            const SizedBox(
              height: 15.0,
            ),
            _buildPasswordField(),
            const SizedBox(
              height: 15.0,
            ),
            _buildDeviceProfileIdField(),
            const SizedBox(
              height: 15.0,
            ),
            _buildGatewayProfileIdField(),
            const SizedBox(
              height: 15.0,
            ),
            ElevatedButton(
              style: style,
              onPressed: () => _saveDetails(),
              child: const Text('Save'),
            ),
            const SizedBox(
              height: 15.0,
            ),
            ElevatedButton(
              style: style,
              onPressed: () => _provisionGateway(),
              child: const Text('Provision Gateway'),
            ),
            const SizedBox(
              height: 20,
            ),
            Text('DEVICE ID: ${_androidDeviceId.toUpperCase()}'),
          ],
        ),
      ),
    );
  }

  _saveDetails() async {
    if (_formKey.currentState!.validate()) {
      // Save data to secure storage
      await storage.write(key: 'serverUrl', value: serverUrlController.text);
      await storage.write(key: 'email', value: emailController.text);
      await storage.write(key: 'password', value: passwordController.text);
      await storage.write(
          key: 'deviceProfileId', value: deviceProfileIdController.text);
      await storage.write(
          key: 'gatewayProfileId', value: gatewayProfileIdController.text);

      AlertWidgets.showAlert(
          context, AlertStatus.success, 'Success!', 'Data saved.');
    }
    _formKey.currentState!.save();
  }

  _provisionGateway() async {
    //show loading dialog
    AlertWidgets.showLoading(
        context, 'Provisioning', 'Provisioning gateway, please wait...');

    if (_formKey.currentState!.validate()) {
      String jwtEmail = await storage.read(key: 'email') ?? '';
      String jwtPassword = await storage.read(key: 'password') ?? '';

      //jwt login
      await AirLinkServer().jwtLoginRequest(jwtEmail, jwtPassword);

      //provision gateway
      http.Response response = await AirLinkServer().provisionDevice(
          'DEVICE_ID: ${_androidDeviceId.toUpperCase()}', 'gateway');

      try {
        final serverResponse = serverResponseFromJson(response.body);
        AlertWidgets.hideLoading(context);
        AlertWidgets.showAlert(
            context, AlertStatus.error, 'Error!', serverResponse.message);
      } catch (e) {
        AlertWidgets.hideLoading(context);
        AlertWidgets.showAlert(context, AlertStatus.success, 'Success!',
            'Gateway provisioned successfully');
      }
    }
    _formKey.currentState!.save();
  }
}
