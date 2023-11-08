import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

import '../utils/enums/enums.dart';


class AppAlert extends StatelessWidget {
  const AppAlert(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.buttonText,
      required this.action});

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final AlertAction action;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 80.0,
          color: Colors.blueAccent,
          child: ListTile(
            leading: Container(
              height: 40.0,
              width: 40.0,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.redAccent,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(
                color: Colors.redAccent,
              ),
            ),
            trailing: SizedBox(
              width: 90.0,
              child: Builder(builder: (context) {
                return ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.redAccent),
                    textStyle: MaterialStateProperty.all<TextStyle?>(
                      TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.0,
                        foreground: Paint()..color = Colors.white,
                      ),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(
                      const Size.fromHeight(32.0),
                    ),
                  ),
                  onPressed: () {
                    _performAction(action, context);
                  },
                  child: Text(
                    buttonText,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }),
            ),
          ),
        ),
        const Divider(
          height: 0,
          color: Colors.white,
        ),
      ],
    );
  }

  void _performAction(AlertAction action, BuildContext context) {
    switch (action) {
      case AlertAction.bluetooth:
        AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
        break;
      case AlertAction.location:
        AppSettings.openAppSettings(type: AppSettingsType.location);
        break;
    }
  }
}
