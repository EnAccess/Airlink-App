import 'package:flutter/material.dart';

import '../utils/enums/enums.dart';

class Snackbar {
  static show(
      {required BuildContext context,
      required SnackbarType type,
      required String message,
      int timeoutInSeconds = 4,}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  type == SnackbarType.loading
                      ? SizedBox(
                          height: 25.0,
                          width: 25.0,
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                            backgroundColor: Colors.blueAccent.shade400,
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 45.0,
              width: 45.0,
              child: IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                icon: const Icon(
                  Icons.close,
                ),
                iconSize: 18.0,
                color: Colors.white,
                splashRadius: 30.0,
              ),
            ),
          ],
        ),
        backgroundColor: _getBackgroundColor(type),
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        // behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.startToEnd,
        duration: type == SnackbarType.loading
            ? const Duration(seconds: 5)
            : Duration(seconds: timeoutInSeconds),
      ),
    );
  }

  static _getBackgroundColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Colors.green.shade800;
      case SnackbarType.error:
        return Colors.red.shade800;
      case SnackbarType.warning:
        return Colors.orange.shade800;
      case SnackbarType.info:
        return Colors.blue.shade800;
      default:
        return Colors.blue.shade800;
    }
  }

  static void hide({required BuildContext context}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }
}
