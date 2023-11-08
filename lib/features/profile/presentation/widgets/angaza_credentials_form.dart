import 'package:airlink/features/profile/data/models/angaza_user_model.dart';
import 'package:airlink/features/profile/presentation/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/angaza_provider.dart';

class AngazaCredentialsForm extends StatefulWidget {
  const AngazaCredentialsForm({super.key});

  @override
  State<AngazaCredentialsForm> createState() => _AngazaCredentialsFormState();
}

class _AngazaCredentialsFormState extends State<AngazaCredentialsForm> {
  late Future _getAngazaCredentialsFuture;
  late AngazaProvider _angazaProvider;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final GlobalKey<FormState> _angazaCredentialsFormKey = GlobalKey<FormState>();

  _saveCredentials() async {
    if (_angazaCredentialsFormKey.currentState!.validate()) {
      //create profile model
      final angazaUserModel = AngazaUserModel(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      // save credentials
      _angazaProvider.saveAngazaCredentialsToLocalStorage(
          context: context, angazaUserModel: angazaUserModel);
    }
    _angazaCredentialsFormKey.currentState!.save();
  }

  Future<void> _getAngazaCredentials() async {
    return _angazaProvider.getAngazaCredentialsFromLocalStorage(
        context: context);
  }

  @override
  void initState() {
    super.initState();
    _angazaProvider = Provider.of<AngazaProvider>(context, listen: false);
    _getAngazaCredentialsFuture = _getAngazaCredentials();
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getAngazaCredentialsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_angazaProvider.angazaUserModel != null) {
              final angazaUserModel = _angazaProvider.angazaUserModel;
              _usernameController.text = angazaUserModel!.username;
              _passwordController.text = angazaUserModel.password;
            }
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _angazaCredentialsFormKey,
              child: ListView(
                children: [
                  Text(
                    'Distributor API Access',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),
                  InputField(
                    controller: _usernameController,
                    labelText: 'Username',
                    helperText: 'Angaza Nexus API username',
                  ),
                  InputField(
                    controller: _passwordController,
                    keyboardType: TextInputType.url,
                    labelText: 'Password',
                    obscureText: true,
                    helperText: 'Angaza Nexus API password',
                  ),
                  FilledButton(
                    onPressed: () async {
                      _saveCredentials();
                    },
                    child: const Text('Save Credentials'),
                  ),
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
