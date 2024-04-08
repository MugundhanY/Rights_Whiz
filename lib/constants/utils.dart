import 'package:flutter/material.dart';

class Utils {
  Size getScreenSize() {
    return WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
  }

  showSnackBar({required BuildContext context, required String content}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.yellow.shade700,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          )),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(content),
        ],
      ),
    ));
  }
}

