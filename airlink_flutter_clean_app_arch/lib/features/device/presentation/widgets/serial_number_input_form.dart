import 'package:airlink/core/utils/helper_functions.dart';
import 'package:airlink/features/device/presentation/providers/device_provider.dart';
import 'package:airlink/features/device/presentation/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/provisioned_device_model.dart';
import 'barcode_scanner_dialog.dart';

class SerialNumberInputForm extends StatefulWidget {
  const SerialNumberInputForm({
    super.key,
    required this.serialNumberController,
    required this.ctx,
  });

  final TextEditingController serialNumberController;
  final BuildContext ctx;

  @override
  State<SerialNumberInputForm> createState() => _SerialNumberInputFormState();
}

class _SerialNumberInputFormState extends State<SerialNumberInputForm> {
  final _provisioningFormKey = GlobalKey<FormState>();
  final _productCodeController = TextEditingController();

  // Define the list of items for the dropdown
  final List<String> items = ['AirLink', 'Angaza', 'Solaris'];

  String _selectedItem = 'AirLink';

  @override
  void dispose() {
    super.dispose();
    widget.serialNumberController.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Device serial number',
              ),
              IconButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                },
                icon: const Icon(
                  Icons.close,
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 4.0,
        ),
        const Divider(
          height: 1.0,
        ),
        const SizedBox(
          height: 16.0,
        ),
        Form(
          key: _provisioningFormKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InputField(
                        controller: widget.serialNumberController,
                        keyboardType: TextInputType.number,
                        labelText: 'Serial Number',
                        suffixIcon: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.barcode_reader),
                            onPressed: () =>
                                _showBarcodeDialog(context: widget.ctx),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Serial number is required';
                          } else if (value.length < 5 || value.length > 10) {
                            return 'Must be 5-10 characters long';
                          } else if (!isInteger(int.parse(value))) {
                            return 'Must be an integer';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: InputField(
                        controller: _productCodeController,
                        labelText: 'Product code',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Product code is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    SizedBox(
                      width: 110,
                      height: 50,
                      child: DropdownButton<String>(
                        hint: const Text('PayG Type'),
                        value: _selectedItem,
                        items: items.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (String? selectedItem) {
                          setState(() {
                            _selectedItem = selectedItem!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Cancel',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          //if the input is valid
                          if (_provisioningFormKey.currentState!.validate()) {
                            //dismiss the dialog
                            Navigator.of(context).pop();

                            //get device secret
                            final deviceSecret = generateDeviceSecret();

                            final provisionedDeviceModel =
                                ProvisionedDeviceModel(
                              deviceSerialNumber:
                                  int.parse(widget.serialNumberController.text),
                              type: _selectedItem,
                              deviceSecret: deviceSecret,
                              productCode: _productCodeController.text,
                            );

                            //provision device
                            Provider.of<DeviceProvider>(widget.ctx,
                                    listen: false)
                                .provision(
                              context: widget.ctx,
                              provisionedDeviceModel: provisionedDeviceModel,
                            );
                          }
                        },
                        child: const FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Provision',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showBarcodeDialog({required BuildContext context}) {
    //dismiss previous dialog
    Navigator.pop(context);

    //show dialog to scan barcode
    showDialog(
      context: context,
      builder: (context) => BarcodeScannerDialog(
        ctx: widget.ctx,
      ),
    );
  }
}
