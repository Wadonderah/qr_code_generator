import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const QRCodeGenerator(),
    );
  }
}

class QRCodeGenerator extends StatefulWidget {
  const QRCodeGenerator({super.key});

  @override
  State<QRCodeGenerator> createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  String url = 'https://example.com';
  double size = 256;
  Color backgroundColor = Colors.white;
  Color foregroundColor = Colors.black;
  final TextEditingController _urlController =
      TextEditingController(text: 'https://example.com');
  final ScreenshotController screenshotController = ScreenshotController();

  Future<String?> _getSaveLocation() async {
    final FileSaveLocation? result = await getSaveLocation(
      suggestedName: 'qr_code.png',
      acceptedTypeGroups: <XTypeGroup>[
        const XTypeGroup(
          label: 'PNG images',
          extensions: <String>['png'],
        ),
      ],
    );
    return result?.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('URL',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  hintText: 'Enter URL',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    url = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Size',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Slider(
                value: size,
                min: 100,
                max: 400,
                divisions: 30,
                label: size.round().toString(),
                onChanged: (value) {
                  setState(() {
                    size = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Background Color',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Pick a background color'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: backgroundColor,
                            onColorChanged: (Color color) {
                              setState(() {
                                backgroundColor = color;
                              });
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Done'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Foreground Color',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Pick a foreground color'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: foregroundColor,
                            onColorChanged: (Color color) {
                              setState(() {
                                foregroundColor = color;
                              });
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Done'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: foregroundColor,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Screenshot(
                  controller: screenshotController,
                  child: Container(
                    color: backgroundColor,
                    child: QrImageView(
                      data: url,
                      version: QrVersions.auto,
                      size: size,
                      backgroundColor: backgroundColor,
                      foregroundColor: foregroundColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  final Uint8List? imageBytes =
                      await screenshotController.capture();
                  if (imageBytes != null) {
                    if (kIsWeb) {
                      final XFile file = XFile.fromData(
                        imageBytes,
                        mimeType: 'image/png',
                        name: 'qr_code.png',
                      );
                      await file.saveTo('qr_code.png');
                    } else {
                      final String? filePath = await _getSaveLocation();
                      if (filePath != null) {
                        final File file = File(filePath);
                        await file.writeAsBytes(imageBytes);
                      }
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('QR Code saved successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Download QR Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
