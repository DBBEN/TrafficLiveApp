import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
    labelStyle: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w300,
    ),
    focusedBorder: OutlineInputBorder(
      //borderSide: BorderSide(color: Color(0xFF0D6B45), width: 2),
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    enabledBorder: OutlineInputBorder(
      //borderSide: BorderSide(color: Color(0xFF0D6B45), width: 2),
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    errorBorder: OutlineInputBorder(
      //borderSide: BorderSide(color: Color(0xFF0D6B45), width: 2),
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ));

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

void showSnackBar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      message,
      style: const TextStyle(fontSize: 14),
    ),
    backgroundColor: color,
    duration: const Duration(seconds: 2),
    action: SnackBarAction(
      label: "OK",
      onPressed: () {},
      textColor: Colors.white,
    ),
  ));
}
