import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Uploader',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  XFile _imageFile;
  final String uploadUrl = 'Enter URL Here';
  final ImagePicker _picker = ImagePicker();

  Future<int> uploadImage(filepath, url) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('file', filepath));
    var res = await request.send();
    return res.statusCode;
  }

  Future<void> retriveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFile = response.file;
      });
    } else {
      print('Retrieve error: ' + response.exception.code);
    }
  }

  Widget _previewImage() {
    if (_imageFile != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
                height: MediaQuery.of(context).size.height * 0.60,
                width: MediaQuery.of(context).size.width * 0.85,
                child: Image.file(
                  File(
                    _imageFile.path,
                  ),
                  fit: BoxFit.fill,
                )),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                var res = await uploadImage(_imageFile.path, uploadUrl);
                print('$res');
                if (res == 200) {
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Success!!'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: const <Widget>[
                              Text(
                                  'You have successfully uploaded the file to the server.'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Upload Image'),
            )
          ],
        ),
      );
    } else {
      return const Text(
        'You have not picked any image yet.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      );
    }
  }

  void _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      print("Image picker error " + e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image To Server'),
        centerTitle: true,
      ),
      body: Center(
          child: FutureBuilder<void>(
        future: retriveLostData(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Text('Picked an image');
            case ConnectionState.done:
              return _previewImage();
            default:
              return const Text('Picked an image');
          }
        },
      )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickImage,
        tooltip: 'Pick Image from gallery',
        icon: Icon(Icons.photo_library),
        label: Text('Choose')
      ),
    );
  }
}
