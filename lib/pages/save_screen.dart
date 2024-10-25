import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:map_to_print/pages/screen_point_to_latlng.dart';

// import 'package:map_to_print/pages/screen_point_to_latlng.dart';
import 'package:permission_handler/permission_handler.dart';
import '../misc/tile_providers_save.dart';
import '../my_functions.dart';
import '/misc/tile_providers.dart';
import '/widgets/drawer/menu_drawer.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui' as ui;
import 'package:flutter_map/src/layer/tile_layer/tile.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ScreenSave extends StatefulWidget {
  static const String route = '/ScreenSave';

  const ScreenSave({super.key});

  @override
  ScreenSaveState createState() => ScreenSaveState();
}

class ScreenSaveState extends State<ScreenSave> {
  static const double pointSize = 65;
  static const double pointY = 350;
  bool isFixed = false;
  bool isFixedCurcularProgress = false;

  LatLng? latLngFixed;

  final mapController = MapController();

  LatLng? latLng;

  Map<String, dynamic> args = {};


  Future<void> _captureAndSave() async {
    //todo refactor
    if (isFixed) {
      mapController.move(latLngFixed!, mapController.camera.zoom);
      setState(() {
        latLng = latLngFixed;
      });

      // isFixedCircularProgress = true;

      await Future.delayed(const Duration(milliseconds: 100), () {});

      // isFixedCircularProgress = false;
      isFixed = false;
      setState(() {});
    }

    List<ui.Image> list = <ui.Image>[];
    var listTiles = <Tile>[];

    double height = 256;

    List<int> xX = [];
    List<int> yY = [];

    double minX = 0;
    double minY = 0;
    double maxX = 0;
    double maxY = 0;

//todo избавиться от глобальной переменной
    ch.length;
    for (var i = 0; i < ch.length; i++) {
      xX.add(ch[i].positionCoordinates.x);
      yY.add(ch[i].positionCoordinates.y);

      // list.add(ch[i].tileImage.imageInfo!.imageFirstCanvas);
      listTiles.add(ch[i]);
    }




    xX.sort();
    minX = xX.first * height.toDouble();
    maxX = xX.last * height.toDouble();

    yY.sort();

    minY = yY.first * height.toDouble();
    maxY = yY.last * height.toDouble();

    final recorder = ui.PictureRecorder();

    final canvas = Canvas(recorder);

    double scaleToAll = 2;
    canvas.scale(scaleToAll);

    //todo отдельный метод для отрисовки тайлов на канвасе
    await drawTilesOnCanvas(
        listTiles: listTiles,
        canvas: canvas,
        height: height,
        minX: minX,
        minY: minY);

    // canvas.scale(1);
    // canvas.

    var pP = mapController.camera.project(latLng!);

    // var listPointsToBlueRectangle = createRectangleNew(pP, 210, 297);
    var listPointsToBlueRectangle =
        createRectangleNew(pP, globalHeightWidht[1], globalHeightWidht[0]);

    var rightTopPointToBlue = listPointsToBlueRectangle[0];
    var leftBottomPointToBlue = listPointsToBlueRectangle[2];

    Paint blueBorderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;

    //рисую синий прямоугольник
    canvas.drawRect(
      Rect.fromPoints(
          ui.Offset((rightTopPointToBlue.x - minX).toDouble(),
              (rightTopPointToBlue.y - minY).toDouble()),
          ui.Offset((leftBottomPointToBlue.x - minX).toDouble(),
              (leftBottomPointToBlue.y - minY).toDouble())),
      blueBorderPaint,
    );

    // canvas.scale(0.7);

    final ui.Picture pictureFirstCanvas = recorder.endRecording();

    int widthAllSumTiles = (((maxX - minX))).toInt();
    int heightAllSumTiles = (((maxY - minY))).toInt();

    //перестраховка если 0
    if (widthAllSumTiles == 0) widthAllSumTiles = height.toInt();
    if (heightAllSumTiles == 0) widthAllSumTiles = height.toInt();

    final imageFirstCanvas = await pictureFirstCanvas.toImage(
        (widthAllSumTiles * scaleToAll).toInt(),
        (heightAllSumTiles * scaleToAll).toInt());

    final recorder2 = ui.PictureRecorder();
    final canvas2 = Canvas(recorder2);


    var topOffsetBlue =
        ((rightTopPointToBlue.y - minY) * scaleToAll).toDouble();
    var leftOffsetBlue = ((leftBottomPointToBlue.x - minX) * scaleToAll).toDouble();


    canvas2.drawImage(
        imageFirstCanvas, ui.Offset(-leftOffsetBlue, -topOffsetBlue), Paint());

    final picture1 = recorder2.endRecording();

    var bottomOffsetBlue =
    ((maxY - leftBottomPointToBlue.y) * scaleToAll).toDouble();
    var rightOffsetBlue =
    ((maxX - rightTopPointToBlue.x) * scaleToAll).toDouble();

    int finalWidth =  (widthAllSumTiles*scaleToAll-rightOffsetBlue-leftOffsetBlue).toInt();
    int finalHeight = (heightAllSumTiles*scaleToAll-bottomOffsetBlue-topOffsetBlue).toInt();

   final image2 = await picture1.toImage(finalWidth, finalHeight);
    // final image2 = await picture1.toImage(4000, 4000);

    ByteData? byteData =
        await image2.toByteData(format: ui.ImageByteFormat.png);
    // await imageFirstCanvas.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    await saveAndShowSnack(pngBytes);
  }

  Future<void> drawTilesOnCanvas(
      {required List<Tile> listTiles,
      required Canvas canvas,
      required double height,
      required double minX,
      required double minY}) async {
    for (var tile in listTiles) {
      ui.Image? img;
      // Tile tile = listTiles[listImages.indexOf(img)];
//todo избавиться от imageInfo!
      if (tile.tileImage.imageInfo?.image == null) {
        // tile.tileImage.imageProvider
        //     .resolve(ImageConfiguration())
        //     .addListener(ImageStreamListener((imageInfo, b) {
        //
        // }));

        img = await loadImage(tile.tileImage.imageProvider);
        print(
            'load image height:${img.height} ${tile.tileImage.imageProvider} ');
        canvas.drawImage(
          img,
          Offset(tile.positionCoordinates.x * height - minX,
              tile.positionCoordinates.y * height - minY),
          Paint(),
        );
      } else {
        img = tile.tileImage.imageInfo!.image;

        canvas.drawImage(
          img,
          Offset(tile.positionCoordinates.x * height - minX,
              tile.positionCoordinates.y * height - minY),
          Paint(),
        );
        print(
            'draw without download image height:${img.height} ${tile.tileImage.imageProvider} ');
      }

      // Определяем размеры рамки//
      double imageWidth = img!.width.toDouble(); // Ширина изображения
      double imageHeight = img!.height.toDouble(); // Высота изображения

      // Рисуем красную рамку вокруг изображения
      Paint borderPaintRed = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4; // Ширина рамки

      canvas.drawRect(
        Rect.fromLTWH(
          tile.positionCoordinates.x * height - minX,
          tile.positionCoordinates.y * height - minY,
          imageWidth,
          imageHeight,
        ),
        borderPaintRed,
      );
    }
  }

  Future<void> saveAndShowSnack(Uint8List pngBytes) async {
    // Получение пути для сохранения
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = File('${directory.path}/canvas_image.png');
    await imagePath.writeAsBytes(pngBytes);

    // Сохранение в галерею
    final result = await ImageGallerySaver.saveFile(imagePath.path);
    print('Image saved to gallery: $result');

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        padding: EdgeInsets.all(20),
        content: Text('Изображение успешно сохранено!'),
        duration: Duration(seconds: 15),
        showCloseIcon: true,

        behavior: SnackBarBehavior.floating,
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

            if (true) {
              launchUrl(Uri.parse(result["filePath"]));
            }
          },
        ),
      ),
    );
  }

  List<LatLng> listApex = [];
  double my_zoom = 16;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // updatePoint(context);

      args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      latLng = args["center"] ?? LatLng(33, 33);
      mapController.move(latLng ?? LatLng(33, 33), 18);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saving Screen'),
        centerTitle: true,
        actions: [
          ElevatedButton(
            onPressed: _captureAndSave,
            child: Row(
              children: [
                Text('Save'),
                SizedBox(
                  width: 10,
                ),
                Icon(Icons.save),
                if (isFixed && isFixedCurcularProgress)
                  CircularProgressIndicator(),
              ],
            ),
          ),
        ],
      ),
      // drawer: const MenuDrawer(ScreenPointToLatLngPage.route),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
                // onPositionChanged: (_, __) => updatePoint(context),
                // initialCenter: const LatLng(55.386, 39.030),
                initialCenter: const LatLng(55.386, 39.030),
                initialZoom: my_zoom,
                minZoom: my_zoom,
                maxZoom: my_zoom),
            children: [
              openStreetMapTileLayerSave,

            ],
          ),
          Container(color: Colors.red,),

          // Positioned(
          //   top: pointY - pointSize / 2,
          //   left: _getPointX(context) - pointSize / 2,
          //   child: const IgnorePointer(
          //     child: Icon(
          //       Icons.center_focus_strong_outlined,
          //       size: pointSize,
          //       color: Colors.black,
          //     ),
          //   ),
          // ),
          // // project
          // Positioned(
          //   top: pointY + pointSize / 2 + 6,
          //   left: 0,
          //   right: 0,
          //   child: IgnorePointer(
          //     child: Text(
          //       '(${latLng?.latitude.toStringAsFixed(3)},${latLng?.longitude.toStringAsFixed(3)})',
          //       textAlign: TextAlign.center,
          //       style: const TextStyle(
          //         color: Colors.black,
          //         fontWeight: FontWeight.bold,
          //         fontSize: 16,
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }



  double _getPointX(BuildContext context) =>
      MediaQuery.sizeOf(context).width / 2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Future.delayed(Duration(seconds: 0), () {
      // var ppoint = mapController.camera.project(LatLng(55.386, 39.030));

      // listApex =createRectangle(ppoint,LatLng(51.5, 5.09),10,10).toList();

      for (var apex in listApex) {
        print(mapController.camera.project(apex));
      }
    });
  }


}
