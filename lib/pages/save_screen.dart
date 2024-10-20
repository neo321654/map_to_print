import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
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

   Map<String,dynamic> args = {};

  Future<void> _captureAndSave() async {
    if (isFixed) {
      mapController.move(latLngFixed!, mapController.camera.zoom);
      // mapController.camera.
      setState(() {
        latLng = latLngFixed;
      });

      isFixedCurcularProgress = true;

      await Future.delayed(Duration(seconds: 2), () {});

      isFixedCurcularProgress = false;
      isFixed = false;
      setState(() {});
    }

    var list = <ui.Image>[];
    var listE = <Tile>[];

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

      list.add(ch[i].tileImage.imageInfo!.image);
      listE.add(ch[i]);
    }

    xX.sort();
    minX = xX.first * height.toDouble();
    maxX = xX.last * height.toDouble();

    yY.sort();
    minY = yY.first * height.toDouble();
    maxY = yY.last * height.toDouble();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    int wwwWith = 0;
    int hhhHeigth = 0;

// Предполагается, что list содержит изображения, а listE содержит информацию о позициях
    for (var img in list) {
      var ee = listE[list.indexOf(img)];

      wwwWith+=height.toInt();
      hhhHeigth += height.toInt();

      // Рисуем изображение
      canvas.drawImage(
        img,
        Offset(ee.positionCoordinates.x * height - minX,
            ee.positionCoordinates.y * height - minY),
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

    var pP = mapController.camera.project(latLng!);

    // var list111 =  createRectangle(LatLng(5.8, -59),10,10);
    // var list111 =  createRectangle(latLng??LatLng(5.8, -59),10,10);

    double coeficient = 3;
    double wA4 = 210*coeficient;
    double hA4 = 297*coeficient;

    var list111 = createRectangleNew(pP, wA4, hA4);

    var p1 = list111[0];
    var p2 = list111[2];

    Paint borderPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawRect(
      Rect.fromPoints(
          ui.Offset((p1.x - minX).toDouble(), (p1.y - minY).toDouble()),
          ui.Offset((p2.x - minX).toDouble(), (p2.y - minY).toDouble())),
      borderPaint,
    );


    final picture = recorder.endRecording();

    int width = (((maxX - minX) * 2)).toInt();
    int height2 = (((maxY - minY) * 2)).toInt();
    if (width == 0) width = height.toInt();
    if (height2 == 0) width = height.toInt();



    final image = await picture.toImage(width, height2);

    final recorder1 = ui.PictureRecorder();
    final canvas1 = Canvas(recorder1);

    Rect.fromPoints(
        ui.Offset((p1.x - minX).toDouble(), (p1.y - minY).toDouble()),
        ui.Offset((p2.x - minX).toDouble(), (p2.y - minY).toDouble()));

    var of1 = (p1.x - minX).toDouble();
    var of2 = (p1.y - minY).toDouble();
    var of3 = (p2.x - minX).toDouble();
    var of4 = (p2.y - minY).toDouble();

    // canvas1.drawImage(image, ui.Offset((-(p1.x - minX).toDouble()), -((p1.y - minY).toDouble())), Paint());
    canvas1.drawImage(image, ui.Offset(-of3, -of2), Paint());

    final picture1 = recorder1.endRecording();


    // final image2 = await picture1.toImage(210, 297);
    final image2 = await picture1.toImage( hA4.toInt(),wA4.toInt(),);
    // final image2 = await picture1.toImage( 900,900,);

    ByteData? byteData =
        await image2.toByteData(format: ui.ImageByteFormat.png);
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
        padding: EdgeInsets.all(20),
        content: Text('Изображение успешно сохранено!'),
        duration: Duration(seconds: 10),
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
            // final pathToOpen = Uri.tryParse('file:/${imagePath.path}')??Uri.base;
            // launchUrl(pathToOpen,mode:  LaunchMode.externalApplication);
            // if (await canLaunchUrl(pathToOpen)) {
            if (true) {
              // final result = await OpenFile.open(imagePath.path);
              // const types = {
              //   ".png":  "image/png",
              // };

              // OpenFile.open("/sdcard/example.txt");

              // await  OpenFile.open("content://media/external/images/media/36");
              // OpenFile.open("file://data/user/0/com.example.map_to_print/app_flutter/canvas_image.png");
              // final result = await OpenFile.open(imagePath.path);
              // if (result.type != ResultType.error) {
              //   print('Не удалось открыть изображение: ${result.message}');
              // "filePath" -> "content://media/external/images/media/40"
              launchUrl(Uri.parse(result["filePath"]));
              // }

              // launchUrl(pathToOpen,mode:  LaunchMode.externalApplication);

              // await launchUrl(pathToOpen,mode:  LaunchMode.externalApplication);
            } else {
              print('Не удалось открыть изображение.');
            }
          },
        ),
      ),
    );
  }

  List<LatLng> listApex = [];

  @override
  void initState() {
    super.initState();


    WidgetsBinding.instance.addPostFrameCallback((_) {

      updatePoint(context);

        args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        latLng =  args["center"]??LatLng(33,33);
        mapController.move(latLng??LatLng(33,33), 18);
        setState(() {

        });



    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isFixed = !isFixed;
            if (isFixed) latLngFixed = latLng;
            drawRect();
          });
        },
        isExtended: true,
        child: Text(isFixed ? 'Unfix' : 'Fix'),
      ),
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
                onPositionChanged: (_, __) => updatePoint(context),
                // initialCenter: const LatLng(55.386, 39.030),
                initialCenter: LatLng(55.386, 39.030),
                initialZoom: 18,
                minZoom: 8,
                maxZoom: 18),
            children: [
              openStreetMapTileLayerSave,
              if (listApex.isNotEmpty)
                PolygonLayer(
                  // hitNotifier: _hitNotifier,
                  // simplificationTolerance: 0,
                  // polygons: [..._polygonsRaw, ...?_hoverGons],
                  polygons: [
                    Polygon(
                      color: Colors.orange.withAlpha(95),

                      // points: const [
                      //   LatLng(51.5, -0.09),
                      //   LatLng(53.3498, -6.2603),
                      //   LatLng(48.8566, 2.3522),
                      //   LatLng(78.8566, 10.3522),
                      // ],
                      points: listApex,
                      // points: ()sync*{yield  LatLng(51.5, -0.09); }().toList(),
                      // label: '(51.5, -0.09)(53.3498, -6.2603)' ,
                      // label: '(51.5, -0.09)(53.3498, -6.2603)(48.8566, 2.3522)',
                      // label: '(51.5, -0.09)(53.3498, -6.2603)(48.8566, 2.3522)',
                      // labelStyle: const TextStyle(
                      //     color: Colors.black,
                      //     fontSize: 6,
                      //     fontWeight: FontWeight.bold),
                      // labelPlacement: PolygonLabelPlacement.polylabel,
                      borderColor: Colors.orange,
                      borderStrokeWidth: 2,

                      hitValue: (
                        title: 'Basic Unfilled Polygon',
                        subtitle: 'Nothing really special here...',
                      ),
                    ),
                  ],
                ),
              if (latLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: pointSize,
                      height: pointSize,
                      point: latLng!,
                      child: const Icon(
                        Icons.circle,
                        size: 5,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
            ],
          ),
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


      setState(() => latLng = mapController.camera.pointToLatLng(p));

      if (!isFixed) {
        drawRect();
      }


  }

  double _getPointX(BuildContext context) =>
      MediaQuery.sizeOf(context).width / 2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Future.delayed(Duration(seconds: 0), () {
      // var ppoint = mapController.camera.project(LatLng(55.386, 39.030));
      drawRect();

      // listApex =createRectangle(ppoint,LatLng(51.5, 5.09),10,10).toList();

      for (var apex in listApex) {
        print(mapController.camera.project(apex));
      }
    });
  }

  void drawRect() {
    if (latLng != null) {
      var ppoint = mapController.camera.project(latLng!);
      // var ppoint = mapController.camera.project(LatLng(55.386, 9.030));

      var pppp = createRectangleNew(ppoint, 210, 297);
      listApex.clear();
      for (Point pnew in pppp) {
        listApex.add(mapController.camera.unproject(pnew));
      }
      setState(() {});
    }
  }
}
