import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast(
  String mgs, {
  Color backgroundColor = Colors.black87,
  Color textColor = Colors.white,
}) =>
    Fluttertoast.showToast(
      msg: mgs,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 16.0,
    );
