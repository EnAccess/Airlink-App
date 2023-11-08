import 'package:airlink/features/device/presentation/providers/device_provider.dart';
import 'package:airlink/features/device/presentation/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class PaygTokenInputForm extends StatefulWidget {
  const PaygTokenInputForm({super.key, required this.ctx});

  final BuildContext ctx;

  @override
  State<PaygTokenInputForm> createState() => _PaygTokenInputFormState();
}

class _PaygTokenInputFormState extends State<PaygTokenInputForm> {
  final _tokenFormKey = GlobalKey<FormState>();

  final TextEditingController _payGTokenController = TextEditingController();


  @override
  void dispose() {
    super.dispose();
    _payGTokenController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transfer PayG Token',
              ),
              IconButton(
                onPressed: () async {
                  Navigator.of(context).pop();
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
          key: _tokenFormKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InputField(
                        controller: _payGTokenController,
                        keyboardType: TextInputType.phone,
                        labelText: 'PayG Token',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'PayG Token is required';
                          } else if (value.length < 16) {
                            return 'Must be 16 characters long';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0,),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
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
                          if (_tokenFormKey.currentState!.validate()) {
                            //close the dialog
                            Navigator.of(context).pop();

                            _transferToken(widget.ctx);
                          }
                        },
                        child: const FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Transfer',
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

  void _transferToken(BuildContext ctx) {
    //transfer the token
    Provider.of<DeviceProvider>(ctx, listen: false).transferToken(
      context: ctx,
      paygToken: _payGTokenController.text,
    );
  }
}
