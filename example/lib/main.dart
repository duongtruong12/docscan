import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:docscan/docscan.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _imagePath;

  @override
  void initState() {
    super.initState();
  }

  Future<void> getImageFromCamera() async {
    if (Platform.isAndroid) {
      PermissionStatus status = await Permission.camera.request();
      if (status.isPermanentlyDenied) {
        openAppSettings();
      }
      // print('status: $status');
      bool isCameraGranted = await Permission.camera.request().isGranted;
      print('isCameraGranted: $isCameraGranted');
      if (!isCameraGranted) {
        isCameraGranted =
            await Permission.camera.request() == PermissionStatus.granted;
      }
      if (!isCameraGranted) {
        // Have not permission to camera
        return;
      }
    }
    try {
      //Make sure to await the call to detectEdge.
      List<String>? imgPaths = await DocScan.scanDocument();
      print('success: $imgPaths');
      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;
      if (imgPaths == null || imgPaths.isEmpty) {
        return;
      }
      setState(() {
        _imagePath = imgPaths[0];
      });
    } catch (e) {
      print(e);
    }
  }
  // ok

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.amberAccent,
          title: const Text(
            'DocScan',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: getImageFromCamera,
                  child: Text('Scan Document'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.amberAccent,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Cropped image path:'),
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
                child: Text(
                  _imagePath.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Visibility(
                visible: _imagePath != null,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(
                      File(_imagePath ?? ''),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
