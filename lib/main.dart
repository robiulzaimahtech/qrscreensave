import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share/share.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey globalKey = GlobalKey();
  String qrData = "https://www.example.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Code Generator"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RepaintBoundary(
              key: globalKey,
              child: QrImageView(
                backgroundColor: Colors.white,
                data: qrData,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => saveQRCode(),
              child: Text("Save  QR Code"),
            ),
            ElevatedButton(
              onPressed: () => shareQRCode(context),
              child: Text(" Share QR Code"),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> shareQRCode(BuildContext context) async {
    RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Save the QR code image to a temporary file
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/qr_code.png');
    await file.writeAsBytes(pngBytes);

    // Share the QR code image using the share package
    Share.shareFiles([file.path], text: "Check out my QR code!");
  }

  Future<void> saveQRCode() async {
    try {
      RenderRepaintBoundary boundary =
      globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save image to gallery
      final result = await ImageGallerySaver.saveImage(Uint8List.fromList(pngBytes));

      if (result != null && result is Map) {
        // Extract the file path from the result
        final filePath = result['filePath'] as String?;

        if (filePath != null) {
          // Share the saved image
        //  Share.shareFiles([filePath]);
          print("Image saved to gallery and shared: $filePath");
        } else {
          print("Error: File path is null.");
        }
      } else {
        print("Error: Unexpected result format.");
      }
    } catch (e) {
      print("Error saving and sharing QR code: $e");
    }
  }
}


// class MyHomePage extends StatelessWidget {
//   final GlobalKey globalKey = GlobalKey();
//   final String qrData = "https://www.example.com";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("QR Code Generator"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             RepaintBoundary(
//               key: globalKey,
//               child: QrImageView(
//                  backgroundColor: Colors.white,
//                 data: qrData,
//              //   version: QrVersions.auto,
//                 size: 500.0,
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => shareQRCode(context),
//               child: Text("Share QR Code"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> shareQRCode(BuildContext context) async {
//     RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
//     ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//     ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     Uint8List pngBytes = byteData!.buffer.asUint8List();
//
//     // Save the QR code image to a temporary file
//     final tempDir = await getTemporaryDirectory();
//     final file = File('${tempDir.path}/qr_code.png');
//     await file.writeAsBytes(pngBytes);
//
//     // Share the QR code image using the share package
//     Share.shareFiles([file.path], text: "Check out my QR code!");
//   }
// }
