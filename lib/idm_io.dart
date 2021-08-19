import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class IdmIO {
  // Default: ttyUSB0
  static final String _serialPort = "/dev/ttyUSB0";

  // Request serial data via Linux commands... yeah...
  static Future<Map<String, dynamic>?> request(
      Map<String, dynamic> data) async {
    // Configure serial port
    var pr = await Process.run(
      "idmiohandler/idmiohandler",
      [_serialPort, jsonEncode(data)],
    );

    if (pr.exitCode != 0) {
      return null;
    }

    return jsonDecode(pr.stdout);
  }
}
