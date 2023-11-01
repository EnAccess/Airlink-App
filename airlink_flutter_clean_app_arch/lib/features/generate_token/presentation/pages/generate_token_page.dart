import 'package:airlink/features/generate_token/data/models/token_device_model.dart';
import 'package:airlink/features/generate_token/presentation/providers/token_device_provider.dart';
import 'package:airlink/features/generate_token/presentation/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/enums/enums.dart';
import '../../../../core/widgets/snackbars.dart';

class GenerateTokenPage extends StatefulWidget {
  const GenerateTokenPage({super.key});

  @override
  State<GenerateTokenPage> createState() => _GenerateTokenPageState();
}

class _GenerateTokenPageState extends State<GenerateTokenPage> {
  final _creditController = TextEditingController();

  final _tokenFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _creditController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _tokenFormKey,
        child: Consumer<TokenDeviceProvider>(
            builder: (context, tokenDeviceProvider, _) {
          return Column(
            children: [
              const Expanded(child: SearchField()),
              tokenDeviceProvider.token == null
                  ? const SizedBox.shrink()
                  : SizedBox(
                      height: 70.0,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Consumer<TokenDeviceProvider>(
                            builder: (context, tokenDeviceProvider, child) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(tokenDeviceProvider.token ?? ''),
                                  IconButton(
                                    onPressed: () {
                                      if (tokenDeviceProvider.token == null) {
                                        Snackbar.show(
                                            context: context,
                                            type: SnackbarType.error,
                                            message: 'No token generated');
                                        return;
                                      } else {
                                        Clipboard.setData(ClipboardData(
                                            text: tokenDeviceProvider.token!));
                                      }
                                    },
                                    icon: const Icon(Icons.copy),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
              const SizedBox(
                height: 16,
              ),
              tokenDeviceProvider.selectedDevice == null
                  ? const SizedBox.shrink()
                  : Row(
                      children: [
                        Expanded(
                          child: tokenDeviceProvider.selectedDevice == null
                              ? const SizedBox.shrink()
                              : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    'Enter credit (days) for ${tokenDeviceProvider.selectedDevice!.name}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ),
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        SizedBox(
                          width: 100.0,
                          child: TextFormField(
                            controller: _creditController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              hintText: 'Days',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Credit is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: tokenDeviceProvider.selectedDevice == null
                          ? null
                          : () {
                              //check if form is valid
                              if (_tokenFormKey.currentState!.validate()) {
                                try {
                                  //get selected device
                                  final selectedDevice =
                                      Provider.of<TokenDeviceProvider>(context,
                                              listen: false)
                                          .selectedDevice;

                                  if (selectedDevice == null) {
                                    Snackbar.show(
                                        context: context,
                                        type: SnackbarType.error,
                                        message: 'Please select a device');
                                    return;
                                  }

                                  final tokenDeviceModel = TokenDeviceModel(
                                    deviceUuid: selectedDevice.entityId,
                                    numberOfDays:
                                        int.parse(_creditController.text),
                                    paygType: selectedDevice.paygType,
                                    angazaUnitNumber: selectedDevice.angazaUnitNumber,
                                  );

                                  Provider.of<TokenDeviceProvider>(context,
                                          listen: false)
                                      .generateTokenDevice(
                                          context: context,
                                          tokenDeviceModel: tokenDeviceModel);
                                } catch (e) {
                                  Snackbar.show(
                                      context: context,
                                      type: SnackbarType.error,
                                      message: 'Failed to generate token');
                                }
                              }
                            },
                      child: const Text('Generate Token'),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
