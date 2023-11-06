import 'package:airlink/features/device/presentation/widgets/payg_token_input_form.dart';
import 'package:flutter/material.dart';

class InputPayGTokenDialog extends StatelessWidget {
  const InputPayGTokenDialog({super.key, required this.ctx});

  final BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaygTokenInputForm(ctx: ctx),
          ],
        ),
      ),
    );
  }
}
