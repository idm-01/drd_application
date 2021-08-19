import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:idm_ui/idm_io.dart';
import 'package:idm_ui/preload.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IDMUI',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: PreloadPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _loading = false;
  late Map<String, dynamic>? json;
  int _currentIndex = 0;
  String req = "getCurrentMetrics";

  void _sendRequest() async {
    setState(() {
      _loading = true;
    });

    json = await IdmIO.request({"request": req});

    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _sendRequest();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Мониторинг ледохода"),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MyHomePage(),
                ),
              ),
              icon: Icon(Icons.restart_alt),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          iconSize: 30,
          currentIndex: _currentIndex,
          onTap: (i) {
            setState(() {
              _currentIndex = i;
              _loading = true;
            });

            switch (_currentIndex) {
              case 0:
                req = "getCurrentMetrics";
                break;
              case 1:
                req = "getHistory";
                break;
            }

            _sendRequest();
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome),
              label: "Последние данные",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: "История измерений",
            )
          ],
        ),
        body: _currentIndex == 0
            ? (_loading
                ? CircularProgressIndicator()
                : Padding(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Здравствуйте!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                          ),
                        ),
                        Text(
                          "Последние данные, полученные с IDM:",
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(height: 50),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Заполненность\nльдом",
                                      style: TextStyle(fontSize: 24),
                                      textAlign: TextAlign.center),
                                  Text(
                                    json!["data"]["percentage"].toString(),
                                    style: TextStyle(
                                        fontSize: 72,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text("%", style: TextStyle(fontSize: 36))
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Миссия",
                                      style: TextStyle(fontSize: 24),
                                      textAlign: TextAlign.center),
                                  Text(
                                    json!["data"]["mission"].toString(),
                                    style: TextStyle(
                                        fontSize: 54,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Геопозиция",
                                      style: TextStyle(fontSize: 24),
                                      textAlign: TextAlign.center),
                                  QrImage(
                                    data:
                                        'https://www.google.com/maps/search/?api=1&query=${json!["data"]["latitude"]},${json!["data"]["longitude"]}',
                                    version: QrVersions.auto,
                                    embeddedImage: AssetImage("maps.png"),
                                    embeddedImageStyle: QrEmbeddedImageStyle(
                                        size: Size(54, 75)),
                                    errorCorrectionLevel: QrErrorCorrectLevel.Q,
                                    size: 180.0,
                                  ),
                                  Text(
                                    "Google Maps",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    padding: EdgeInsets.all(20),
                  ))
            : (_loading
                ? CircularProgressIndicator()
                : Padding(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "История измерений",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                          ),
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: json!["data"].length,
                            itemBuilder: (context, i) {
                              return Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    QrImage(
                                      data:
                                          'https://www.google.com/maps/search/?api=1&query=${json!["data"][i]["latitude"]},${json!["data"][i]["longitude"]}',
                                      version: QrVersions.auto,
                                      errorCorrectionLevel:
                                          QrErrorCorrectLevel.L,
                                      size: 120.0,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Миссия: ${json!["data"][i]["mission"]}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 28)),
                                        Text(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                    json!["data"][i]["date"] *
                                                        1000)
                                                .toString(),
                                            style: TextStyle(fontSize: 18),
                                            textAlign: TextAlign.center),
                                        SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                                'Широта:\n${json!["data"][i]["latitude"]}',
                                                style: TextStyle(fontSize: 20),
                                                textAlign: TextAlign.center),
                                            Text(
                                                'Долгота:\n${json!["data"][i]["longitude"]}',
                                                style: TextStyle(fontSize: 20),
                                                textAlign: TextAlign.center),
                                            Text(
                                                '${json!["data"][i]["percentage"]}%',
                                                style: TextStyle(
                                                    fontSize: 48,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center),
                                          ],
                                        ),
                                      ],
                                    ))
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                    padding: EdgeInsets.all(20),
                  )));
  }
}
