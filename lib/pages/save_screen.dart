import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
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

  final LatLng latLng;
  final double zoomToPrint;

  const ScreenSave({
    super.key,
    required this.latLng,
    required this.zoomToPrint,
  });

  @override
  ScreenSaveState createState() => ScreenSaveState();
}

class ScreenSaveState extends State<ScreenSave> {
  static const double pointSize = 65;
  static const double pointY = 350;
  bool isFixed = false;
  bool isCircularProgress = true;
  LatLng? latLngFixed;
  final mapController = MapController();
  LatLng? latLng;
  List<String> listImagesString = [];
  final ScrollController _scrollController = ScrollController();
  bool isZoomInstalled = false;

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

    double scaleToAll = 1;
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

    // ui.Offset rightPoint = Offset((rightTopPointToBlue.x - minX).toDouble(),
    //     (rightTopPointToBlue.y - minY).toDouble());

    // ui.Offset leftOffset = ui.Offset(
    //     (leftBottomPointToBlue.x- minX).toDouble(),
    //     (leftBottomPointToBlue.y).toDouble());

    ui.Offset rightPoint = mapController.camera
        .project(globalListApex[0])
        .toOffset()
        .translate(-minX, -minY);
    ui.Offset leftOffset = mapController.camera
        .project(globalListApex[2])
        .toOffset()
        .translate(-minX, -minY);

    canvas.drawRect(
      Rect.fromPoints(rightPoint, leftOffset),
      blueBorderPaint,
    );
    canvas.drawCircle(rightPoint, 4, Paint()..color = Colors.red);
    canvas.drawCircle(leftOffset, 4, Paint()..color = Colors.green);

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
    var leftOffsetBlue =
        ((leftBottomPointToBlue.x - minX) * scaleToAll).toDouble();


    //сместил img влево и вверх
    canvas2.drawImage(
        imageFirstCanvas, ui.Offset(-leftOffsetBlue, -topOffsetBlue), Paint());
    // canvas2.drawImage(imageFirstCanvas, const ui.Offset(0, 0), Paint());

    final picture1 = recorder2.endRecording();

    var bottomOffsetBlue =
        ((maxY - leftBottomPointToBlue.y) * scaleToAll).toDouble();
    var rightOffsetBlue =
        ((maxX - rightTopPointToBlue.x) * scaleToAll).toDouble();

    int finalWidth =((maxX - minX) * scaleToAll).toInt();
    int finalHeight =((maxY - minY) * scaleToAll).toInt();

    // final image2 = await picture1.toImage(finalWidth, finalHeight);
    final image2 = await picture1.toImage(finalWidth,
    finalHeight);
    // final image2 = await picture1.toImage(4000, 4000);

    ByteData? byteData =
        await image2.toByteData(format: ui.ImageByteFormat.png);
    // await imageFirstCanvas.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    setState(() {
      isCircularProgress = false;
    });

    await saveAndShowSnack(pngBytes, context);
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
        try {
          img = await loadImage(tile.tileImage.imageProvider);
          setState(() {
            addStringToList(tile);
          });
          if (kDebugMode) {
            print(
                'load image height:${img.height} ${tile.tileImage.imageProvider} ');
          }
          canvas.drawImage(
            img,
            Offset(tile.positionCoordinates.x * height - minX,
                tile.positionCoordinates.y * height - minY),
            Paint(),
          );
        } catch (e) {
          showSnack(
              text: 'Произошла ошибка загрузки тайла',
              context: context,
              onPressed: () {});
        }
      } else {
        img = tile.tileImage.imageInfo!.image;

        canvas.drawImage(
          img,
          Offset(tile.positionCoordinates.x * height - minX,
              tile.positionCoordinates.y * height - minY),
          Paint(),
        );
        setState(() {
          addStringToList(tile, true);
        });
        if (kDebugMode) {
          print(
            'draw without download image height:${img.height} ${tile.tileImage.imageProvider} ');
        }
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

//start different resolutions
  void addStringToList(Tile tile, [bool fromCash = false]) {
    String coordinates = tile.positionCoordinates.toString();

    final String str = '$coordinates ${(fromCash) ? 'from cash!' : ''}';
    listImagesString.add(str);
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void initState() {
    super.initState();

    latLng = widget.latLng;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      // latLng = args["center"] ?? const LatLng(33, 33);

      // double meterInCm = args["meterInCm"] ?? 100;

      setState(() {
        isZoomInstalled = true;
//todo нужно передать настройки через контсруктор
//         zoomToPrint = 16;
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            mapController.move(widget.latLng, widget.zoomToPrint);
          });
        });
      });

      Future.delayed(const Duration(milliseconds: 1000), () {
        _captureAndSave();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saving Screen'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {

            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return ScreenSave(
                    latLng: widget.latLng,
                    zoomToPrint: widget.zoomToPrint,
                  );
                }));

          }, icon: const Icon(Icons.refresh),),
          if (isCircularProgress)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            )
        ],
      ),
      // drawer: const MenuDrawer(ScreenPointToLatLngPage.route),
      body: Stack(
        children: [
          FlutterMap(
            // key: UniqueKey(),
            mapController: mapController,
            options: MapOptions(
                // onPositionChanged: (_, __) => updatePoint(context),
                // initialCenter: const LatLng(55.386, 39.030),
                initialCenter: const LatLng(55.386, 39.030),
                initialZoom: widget.zoomToPrint,
                minZoom: widget.zoomToPrint,
                maxZoom: widget.zoomToPrint),
            children: [
              openStreetMapTileLayerSave,
            ],
          ),
          Container(
            color: Colors.blueAccent.withOpacity(0.3),
          ),
          SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 120),
              child: Center(
                child: Column(
                  children: listImagesString.asMap().entries.map((entry) {
                    return Container(
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        color: Colors.white38,
                        child: Text(
                          '${entry.key} ${entry.value}',
                          textAlign: TextAlign.center,
                        ));
                  }).toList(),
                ),
              ))
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
}
