import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showValidToast(String message){
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    webBgColor: "linear-gradient(deepPurpleAccent, deepPurpleAccent)",
    webPosition: "center",
    backgroundColor: Colors.deepPurpleAccent,
    textColor: Colors.white
  );
}

void showResponseToast(String message){
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    webBgColor: "linear-gradient(blueAccent, blueAccent)",
    webPosition: "center",
    backgroundColor: Colors.blueAccent,
    textColor: Colors.white
  );
}