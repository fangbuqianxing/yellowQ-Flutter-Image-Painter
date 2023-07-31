import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_painter/image_painter.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

import 'dutch_text_delegate.dart';

void main() async {

  await setupWindow();
  runApp(ExampleApp());
}

Future<void> setupWindow() async {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      // center: true,
      // backgroundColor: Colors.transparent,
      // skipTaskbar: false,
      titleBarStyle:
      Platform.isMacOS || Platform.isWindows ? TitleBarStyle.hidden : TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(windowOptions,);
  }
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Image Painter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ImagePainterExample(),
    );
  }
}

class ImagePainterExample extends StatefulWidget {
  @override
  _ImagePainterExampleState createState() => _ImagePainterExampleState();
}

class _ImagePainterExampleState extends State<ImagePainterExample> {
  final _imageKey = GlobalKey<ImagePainterState>();
  final _key = GlobalKey<ScaffoldState>();

  void saveImage() async {
    final image = await _imageKey.currentState?.exportImage();
    if (image == null) return;
    final directory = (await getApplicationDocumentsDirectory()).path;
    await Directory('$directory/sample').create(recursive: true);
    final fullPath =
        '$directory/sample/${DateTime.now().millisecondsSinceEpoch}.png';
    final imgFile = File('$fullPath');
    imgFile.writeAsBytesSync(image);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey[700],
        padding: const EdgeInsets.only(left: 10),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Image Exported successfully.",
                style: TextStyle(color: Colors.white)),
            TextButton(
              onPressed: () => OpenFile.open("$fullPath"),
              child: Text(
                "Open",
                style: TextStyle(
                  color: Colors.blue[200],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      // appBar: AppBar(
      //   toolbarHeight: 40,
      //   elevation: 0.5,
      //   centerTitle: false,
      //   leadingWidth: 24,
      //   title: const Text(""),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.save_alt),
      //       onPressed: saveImage,
      //     )
      //   ],
      // ),
      extendBodyBehindAppBar: true,
      body: ImagePainter.asset(
        "assets/sample.jpg",
        key: _imageKey,
        scalable: true,
        initialStrokeWidth: 3,
        textDelegate: DutchTextDelegate(),
        colors: [Color(0xFFE84025),
          Color(0xFF56B2F9),
          Color(0xFF8CE948),
          Color(0xFFFBEB4F),
          Color(0xFF676767),
          Color(0xFFFFFFFF),],
        initialColor: Color(0xFFE84025),
        initialPaintMode: PaintMode.rect,
        brushIcon: Image.asset('assets/icon_brush_size_asset.png', width: 28, height: 28,),
        undoIcon: Image.asset('assets/icon_undo_asset.png', width: 28, height: 28,),
      ),
    );
  }
}
