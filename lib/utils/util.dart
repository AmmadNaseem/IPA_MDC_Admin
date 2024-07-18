import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';

class Utils {
  // =========FOR FIELD FOCUS CHANGE==========
  static void fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  //=========FOR SNACKBAR=========
  static snackBar(String message, BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // =========FOR Success FLUSHBAR=========
  static void flushBarSuccessMessage(String message, BuildContext context) {
    showFlushbar(
      context: context,
      flushbar: Flushbar(
        forwardAnimationCurve: Curves.decelerate,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(15),
        borderRadius: BorderRadius.circular(10),
        reverseAnimationCurve: Curves.easeOut,
        flushbarPosition: FlushbarPosition.TOP,
        positionOffset: 20,
        icon: const Icon(
          Icons.check_circle,
          size: 28,
          color: Colors.white,
        ),
        titleColor: Colors.white,
        backgroundColor: Colors.green,
        messageColor: Colors.white,
        message: message,
        duration: const Duration(seconds: 4),
      )..show(context),
    );
  }

// =========FOR ERROR FLUSHBAR=========
  static void flushBarErrorMessage(String message, BuildContext context) {
    showFlushbar(
      context: context,
      flushbar: Flushbar(
        forwardAnimationCurve: Curves.decelerate,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(15),
        borderRadius: BorderRadius.circular(10),
        reverseAnimationCurve: Curves.easeOut,
        flushbarPosition: FlushbarPosition.TOP,
        positionOffset: 20,
        icon: const Icon(
          Icons.error,
          size: 28,
          color: Colors.white,
        ),
        titleColor: Colors.white,
        backgroundColor: Colors.red,
        messageColor: Colors.white,
        message: message,
        duration: const Duration(seconds: 4),
      )..show(context),
    );
  }

  // =========FOR INFO FLUSHBAR=========
  static void flushBarInfoMessage(String message, BuildContext context) {
    showFlushbar(
      context: context,
      flushbar: Flushbar(
        forwardAnimationCurve: Curves.decelerate,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(15),
        borderRadius: BorderRadius.circular(10),
        reverseAnimationCurve: Curves.easeOut,
        flushbarPosition: FlushbarPosition.TOP,
        positionOffset: 20,
        icon: const Icon(
          Icons.info,
        ),
        titleColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        messageColor: Colors.white,
        message: message,
        duration: const Duration(seconds: 4),
      )..show(context),
    );
  }

  //===============Info for no matching found
  static void flushBarNoMatchFoundMessage(
      String message, BuildContext context) {
    showFlushbar(
      context: context,
      flushbar: Flushbar(
        mainButton: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
        forwardAnimationCurve: Curves.decelerate,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(15),
        borderRadius: BorderRadius.circular(10),
        reverseAnimationCurve: Curves.easeOut,
        flushbarPosition: FlushbarPosition.TOP,
        positionOffset: 20,
        icon: const Icon(
          Icons.info,
          size: 28,
          color: Colors.white,
        ),
        titleColor: Colors.white,
        backgroundColor: Colors.red,
        messageColor: Colors.white,
        message: message,
        duration: const Duration(seconds: 30),
      )..show(context),
    );
  }
}
