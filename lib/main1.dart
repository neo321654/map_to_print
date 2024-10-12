import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:io';

class ImageOnCanvasExample extends StatefulWidget {
  @override
  _ImageOnCanvasExampleState createState() => _ImageOnCanvasExampleState();
}

class _ImageOnCanvasExampleState extends State<ImageOnCanvasExample> {
  Future<void> _captureAndSave() async {
    // Создание PictureRecorder для рисования на Canvas
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Загружаем изображение
    final img = await _loadImage('assets/ProjectIcon.png'); // Укажите путь к вашему PNG изображению

    // Рисуем изображение на Canvas
    canvas.drawImage(img, Offset(0, 0), Paint());

    // Завершение записи и создание изображения
    final picture = recorder.endRecording();
    final image = await picture.toImage(300, 300); // Укажите нужные размеры
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Получение пути для сохранения
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = File('${directory.path}/canvas_image.png');
    await imagePath.writeAsBytes(pngBytes);

    // Сохранение в галерею
    final result = await ImageGallerySaver.saveFile(imagePath.path);
    print('Image saved to gallery: $result');
  }

  Future<ui.Image> _loadImage(String path) async {
    final data = await DefaultAssetBundle.of(context).load(path);
    final bytes = data.buffer.asUint8List();

    return await decodeImageFromList(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Draw Image on Canvas'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _captureAndSave,
          ),
        ],
      ),
      body: Center(
        child: Text('Press the save button to capture the image!'),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: ImageOnCanvasExample()));
}