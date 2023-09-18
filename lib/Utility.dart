import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:convert';

class Utility {
  static ClipOval imageFromBase64String(String base64String) {
    return ClipOval(
      child: SizedBox.fromSize(
        size: const Size.fromRadius(30), // Image radius
        child: Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }
}
