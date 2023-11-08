import 'package:airlink/features/device/presentation/widgets/serial_number_input_form.dart';
import 'package:flutter/material.dart';

class InputSerialNumberDialog extends StatefulWidget {
  const InputSerialNumberDialog({super.key, required this.ctx});

  final BuildContext ctx;

  @override
  State<InputSerialNumberDialog> createState() =>
      _InputSerialNumberDialogState();
}

class _InputSerialNumberDialogState extends State<InputSerialNumberDialog> {
  final TextEditingController _serialNumberController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SerialNumberInputForm(
                serialNumberController: _serialNumberController, ctx: widget.ctx,),
          ],
        ),
      ),
    );
  }
}
