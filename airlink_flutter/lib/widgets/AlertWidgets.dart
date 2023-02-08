import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import '../constants/constants.dart';

class AlertWidgets {
  /// Shows a loading dialog with a circular progress indicator. Do not forget to dismiss it on your function.
  static showLoading(BuildContext context, String title, String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 6.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 8.0),
                  child: Text(title, style: Theme.of(context).textTheme.headline6),
                ),
                const SizedBox(
                  height: 4.0,
                ),
                const Divider(
                  height: 1.0,
                  color: Colors.grey,
                ),
                const SizedBox(
                  height: 24.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: CircularProgressIndicator(),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          message,
                          style: Theme.of(context).textTheme.bodyText2
                              ?.copyWith(fontWeight: FontWeight.w400, fontSize: 16.0),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static showAlert(
      BuildContext context, AlertStatus alertStatus, String title, String message, [Function? callbackFunction]) {

    late Color primaryColor;
    late IconData icon;
    late String errorTitle;
    bool barrierDismissible = true;

    switch (alertStatus) {
      case AlertStatus.info:
        primaryColor = Colors.blueAccent;
        icon = LineIcons.infoCircle;
        errorTitle = 'Info';
        break;
      case AlertStatus.success:
        primaryColor = Colors.green.shade500;
        icon = LineIcons.checkCircle;
        errorTitle = 'Success';
        break;
      case AlertStatus.warning:
        primaryColor = Colors.deepOrangeAccent;
        icon = LineIcons.exclamationCircle;
        errorTitle = 'Warning';
        break;
      case AlertStatus.error:
        primaryColor = Colors.redAccent;
        icon = LineIcons.timesCircle;
        errorTitle = 'Error';
        break;
      case AlertStatus.loading:
        // TODO: Handle this case.
        break;
    }

    showDialog(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 24.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            children: [
                              // Icon(
                              //   icon,
                              //   color: primaryColor,
                              //   size: 60,
                              // ),
                              // const SizedBox(height: 4.0,),
                              Text(title.toUpperCase(), style: Theme.of(context).textTheme.headline5?.copyWith(
                                color: primaryColor,
                              ),),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          message,
                          style: Theme.of(context).textTheme.bodyText2
                              ?.copyWith(fontWeight: FontWeight.w400,fontSize: 16.0),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32.0),
                        SizedBox(
                          width: 125.0,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all<Color>(primaryColor),
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              if (callbackFunction != null) {
                                await callbackFunction();
                              }
                            },
                            child:  const Text('Ok'),
                          ),
                        ),
                        const SizedBox(height: 32.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ///Hide a loading dialog.
  static hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  } // Hide loading dialog
}
