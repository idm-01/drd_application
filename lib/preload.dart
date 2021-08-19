import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:idm_ui/idm_io.dart';
import 'package:idm_ui/main.dart';

class PreloadPage extends StatefulWidget {
  PreloadPage({Key? key}) : super(key: key);

  @override
  _PreloadPageState createState() => _PreloadPageState();
}

class _PreloadPageState extends State<PreloadPage> {
  bool error = false;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      IdmIO.request({"request": "getMachineStatus"}).then((value) {
        if (value != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MyHomePage(),
            ),
          );
        } else {
          setState(() {
            error = true;
          });
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: error
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    size: 100,
                    color: Colors.red,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Ошибка соединения с IDM.",
                    style: TextStyle(fontSize: 24),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 10,
                    softWrap: true,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Связываюсь с IDM...",
                    style: TextStyle(fontSize: 24),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 10,
                    softWrap: true,
                  ),
                ],
              ),
      ),
    );
  }
}
