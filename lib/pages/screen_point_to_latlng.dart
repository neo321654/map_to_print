import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:permission_handler/permission_handler.dart';
import '/misc/tile_providers.dart';
import '/widgets/drawer/menu_drawer.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui' as ui;
import 'package:flutter_map/src/layer/tile_layer/tile.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';



class ScreenPointToLatLngPage extends StatefulWidget {
  static const String route = '/screen_point_to_latlng';

  const ScreenPointToLatLngPage({super.key});

  @override
  PointToLatlngPage createState() => PointToLatlngPage();
}

class PointToLatlngPage extends State<ScreenPointToLatLngPage> {
  static const double pointSize = 65;
  static const double pointY = 250;

  final mapController = MapController();

  LatLng? latLng;

  Future<void> _captureAndSave() async {

    var list = <ui.Image>[];
    var listE = <Tile>[];

    double height=256;

    List<int> xX = [];
    List<int> yY = [];


    double minX = 0;
    double minY = 0;
    double maxX = 0;
    double maxY = 0;

    ch.length;
    for(var i=0;i<ch.length;i++){

      xX.add(ch[i].positionCoordinates.x);
      yY.add(ch[i].positionCoordinates.y);


      list.add(ch[i].tileImage.imageInfo!.image);
      listE.add(ch[i]);

    }

    xX.sort();
    minX = xX.first*height.toDouble();
    maxX = xX.last*height.toDouble();

    yY.sort();
    minY = yY.first*height.toDouble();
    maxY = yY.last*height.toDouble();






    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

// Предполагается, что list содержит изображения, а listE содержит информацию о позициях
    for (var img in list) {
      var ee = listE[list.indexOf(img)];

      // Рисуем изображение
      canvas.drawImage(
        img,
        Offset(ee.positionCoordinates.x * height - minX, ee.positionCoordinates.y * height - minY),
        Paint(),
      );

      // Определяем размеры рамки
      double imageWidth = img.width.toDouble(); // Ширина изображения
      double imageHeight = img.height.toDouble(); // Высота изображения

      // Рисуем красную рамку вокруг изображения
      Paint borderPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4; // Ширина рамки

      canvas.drawRect(
        Rect.fromLTWH(
          ee.positionCoordinates.x * height - minX,
          ee.positionCoordinates.y * height - minY,
          imageWidth,
          imageHeight,
        ),
        borderPaint,
      );
    }
    canvas.drawCircle(ui.Offset((pP.x-minX).toDouble(), (pP.y-minY).toDouble()), 15, Paint()..color = Colors.green);

    final picture = recorder.endRecording();

    int width = (((maxX - minX)*2)).toInt();
    int height2 = (((maxY - minY)*2)).toInt();
    if(width == 0)width=height.toInt();
    if(height2 == 0)width=height.toInt();

    pP;

    final image = await picture.toImage(width, height2);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

// Получение пути для сохранения
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = File('${directory.path}/canvas_image.png');
    await imagePath.writeAsBytes(pngBytes);

// Сохранение в галерею
    final result = await ImageGallerySaver.saveFile(imagePath.path);
    print('Image saved to gallery: $result');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Изображение успешно сохранено!'),
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Открыть',
          onPressed: () async {

            Future<void> requestStoragePermission() async {
              var status = await Permission.manageExternalStorage.status;
              if (!status.isGranted) {
                await Permission.manageExternalStorage.request();
              }
            }

            requestStoragePermission();


            // Открываем изображение в галерее
            final pathToOpen = Uri.tryParse('file:/${imagePath.path}')??Uri.base;
            launchUrl(pathToOpen,mode:  LaunchMode.externalApplication);
            // if (await canLaunchUrl(pathToOpen)) {
            if (true) {
              // final result = await OpenFile.open(imagePath.path);


              final result = await OpenFile.open(imagePath.path);
              if (result.type != ResultType.error) {
                print('Не удалось открыть изображение: ${result.message}');
                launchUrl(pathToOpen,mode:  LaunchMode.externalApplication);
              }

              launchUrl(pathToOpen,mode:  LaunchMode.externalApplication);

              // await launchUrl(pathToOpen,mode:  LaunchMode.externalApplication);
            } else {
              print('Не удалось открыть изображение.');
            }
          },
        ),
      ),
    );











  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => updatePoint(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen Point 🡒 Lat/Lng'),actions: [
        IconButton(
          icon: Icon(Icons.save),
          onPressed: _captureAndSave,
        ),
      ],),
      drawer: const MenuDrawer(ScreenPointToLatLngPage.route),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              onPositionChanged: (_, __) => updatePoint(context),
              initialCenter: const LatLng(51.5, -0.09),
              initialZoom: 4,
              minZoom: 3,
            ),
            children: [
              openStreetMapTileLayer,
              if (latLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: pointSize,
                      height: pointSize,
                      point: latLng!,
                      child: const Icon(
                        Icons.circle,
                        size: 10,
                        color: Colors.red,
                      ),
                    )
                  ],
                ),
            ],
          ),
          Positioned(
            top: pointY - pointSize / 2,
            left: _getPointX(context) - pointSize / 2,
            child: const IgnorePointer(
              child: Icon(
                Icons.center_focus_strong_outlined,
                size: pointSize,
                color: Colors.black,
              ),
            ),
          ),
          // project
          Positioned(
            top: pointY + pointSize / 2 + 6,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Text(
                '(${latLng?.latitude.toStringAsFixed(3)},${latLng?.longitude.toStringAsFixed(3)})',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void updatePoint(BuildContext context) {

    var p = Point(_getPointX(context), pointY);

    var s =mapController.camera.pointToLatLng(p);
    var ww =mapController.camera.getPixelWorldBounds(5);


    setState(() => latLng =
      mapController.camera.pointToLatLng(p));

    var ww1 =mapController.camera.getNewPixelOrigin(latLng!);
    // var qww1 =mapController.camera.;




  }

  double _getPointX(BuildContext context) =>
      MediaQuery.sizeOf(context).width / 2;
}
