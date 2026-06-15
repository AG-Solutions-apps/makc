import 'package:flutter/material.dart';

class Loader {

  static void showLoader(BuildContext context,String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // user cannot close
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Please wait..."),
              ],
            ),
          ),
        );
      },
    );
  }

  static void hideLoader(BuildContext context) {
    Navigator.pop(context);
  }
}