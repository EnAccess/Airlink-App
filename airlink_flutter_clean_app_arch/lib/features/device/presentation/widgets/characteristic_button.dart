import 'package:airlink/features/device/presentation/providers/device_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/characteristic_model.dart';

class CharacteristicButton extends StatefulWidget {
  const CharacteristicButton({
    super.key,
    required this.c,
  });

  final CharacteristicModel c;

  @override
  State<CharacteristicButton> createState() => _CharacteristicButtonState();
}

class _CharacteristicButtonState extends State<CharacteristicButton> {
  late String _value;

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);

    return FilledButton.tonal(
      onPressed: () async {
        String? value =
            await deviceProvider.read(context: context, c: widget.c);
        if (value == null) return;
        _value = value;
        _showCharacteristicDialog(widget.c);
      },
      child: Text(widget.c.descriptorName),
    );
  }

  void _showCharacteristicDialog(CharacteristicModel c) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(c.descriptorName),
            content: Text(_value),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        });
  }
}
