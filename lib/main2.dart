import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/flutter_map.dart';

// import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as ll;
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:typed_data';
import 'dart:io';

class MapWithPolygon extends StatefulWidget {
  @override
  _MapWithPolygonState createState() => _MapWithPolygonState();
}

class _MapWithPolygonState extends State<MapWithPolygon> {
  List<ll.LatLng> polygonPoints = [
    ll.LatLng(51.5, -0.1),
    ll.LatLng(51.51, -0.1),
    ll.LatLng(51.51, -0.08),
    ll.LatLng(51.5, -0.08),
  ];

  Future<void> _captureAndSave() async {
    // Определите размеры канваса
    const double width = 800; // Укажите нужную ширину
    const double height = 600; // Укажите нужную высоту

    // Создание канваса для рисования
    final recorder = ui.PictureRecorder();
    final canvas =
        Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(width, height)));

    // Загрузка тайлов карты
    await _drawMapTiles(canvas);

    // Рисуем полигон на канвасе
    _drawPolygon(canvas);

    // Завершение записи и создание изображения
    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());

    // Получение байтов изображения
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Получение пути для сохранения
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = File('${directory.path}/map_with_polygon.png');
    await imagePath.writeAsBytes(pngBytes);

    // Сохранение в галерею
    final result = await ImageGallerySaver.saveFile(imagePath.path);
    print('Image saved to gallery: $result');
  }

  Future<void> _drawMapTiles(Canvas canvas) async {
    const String urlTemplate =
        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";

    // Пример для тайлов на уровне зума 10 (можно изменить)
    int zoom = 3;

    for (int x = 0; x < (1 << zoom); x++) {
      for (int y = 0; y < (1 << zoom); y++) {
        String url = urlTemplate
            .replaceAll("{s}", "a") // Используйте поддомены a/b/c
            .replaceAll("{z}", zoom.toString())
            .replaceAll("{x}", x.toString())
            .replaceAll("{y}", y.toString());

        // Загружаем изображение тайла
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final Uint8List bytes = response.bodyBytes;
          final ui.Codec codec = await ui.instantiateImageCodec(bytes);
          final ui.FrameInfo frameInfo = await codec.getNextFrame();
          final ui.Image tileImage = frameInfo.image;

          // Рисуем тайл на канвасе
          canvas.drawImage(tileImage, Offset(x * 256.0, y * 256.0), Paint());
        }
      }
    }
  }

  void _drawPolygon(Canvas canvas) {
    Paint paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 200
      ..style = PaintingStyle.fill;

    Path path = Path();

    path.moveTo(polygonPoints[0].longitude * 1000000,
        polygonPoints[0].latitude * 1000000);

    for (var point in polygonPoints) {
      path.lineTo(point.longitude * 1000000, point.latitude * 1000000);
    }

    path.close();

    canvas.drawPath(path, paint);

    Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 200;

    canvas.drawPath(path, borderPaint);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map with Polygon'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _captureAndSave,
          ),
        ],
      ),
      body: Center(),
    );
  }
}

void main() {
  runApp(MaterialApp(home: MapWithPolygon()));
}
