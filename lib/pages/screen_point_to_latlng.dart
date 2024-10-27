import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:map_to_print/pages/save_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import '../my_functions.dart';
import '/misc/tile_providers.dart';
import '/widgets/drawer/menu_drawer.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:latlong2/latlong.dart';
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
  static const double pointY = 350;
  bool isFixed = false;
  LatLng? latLngFixed;
  final mapController = MapController();
  double zoomToPrint = 12;

  LatLng? latLng;

  List<LatLng> listApex = [];

  double meterInCm = 100;

  bool landscape = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      updatePoint(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: const MenuDrawer('/screen_point_to_latlng'),
      floatingActionButton: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(width: 25),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FloatingActionButton(
                // backgroundColor: (meterInCm == 100) ? Colors.greenAccent : null,
                heroTag: 'rotate',
                onPressed: () {
                  rotatePolygon();
                },
                child: const Icon(Icons.screen_rotation_alt),
              ),
              const SizedBox(height: 5),
              FloatingActionButton(
                backgroundColor: (meterInCm == 100) ? Colors.greenAccent : null,
                heroTag: '100',
                onPressed: () {
                  setPrintScale(100);
                },
                child: const Text('100 m'),
              ),
            ],
          ),
          const SizedBox(width: 5),
          FloatingActionButton(
            backgroundColor: (meterInCm == 250) ? Colors.greenAccent : null,
            heroTag: '250',
            onPressed: () {
              setPrintScale(250);
            },
            child: const Text('250 m'),
          ),
          const SizedBox(width: 5),
          FloatingActionButton(
            backgroundColor: (meterInCm == 500) ? Colors.greenAccent : null,
            heroTag: '500',
            onPressed: () {
              setPrintScale(500);
            },
            child: const Text('500 m'),
          ),
          const SizedBox(width: 5),
          FloatingActionButton(
            backgroundColor: (meterInCm == 1000) ? Colors.greenAccent : null,
            heroTag: '1000',
            onPressed: () {
              setPrintScale(1000);
            },
            child: const Text('1 km'),
          ),
          const Spacer(),
          FloatingActionButton(
            heroTag: 'fix',
            onPressed: () {
              setState(() {
                isFixed = !isFixed;
                if (isFixed) {
                  latLngFixed =
                      LatLng(latLng?.latitude ?? 33, latLng?.longitude ?? 44);
                }
                zoomToPrint = getZoomToPrint(meterInCm: meterInCm);

                listApex = getNewApex(
                    latLng: latLng,
                    camera: mapController.camera,
                    meterInCm: meterInCm,landscape: landscape);
              });
            },
            child: Text(isFixed ? 'Unfix' : 'Fix'),
          ),
        ],
      ),
      appBar: AppBar(
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return ScreenSave(
                  latLng: isFixed ? latLngFixed! : latLng!,
                  zoomToPrint: zoomToPrint,
                );
              }));

              // Navigator.pushNamed(
              //   context,
              //   ScreenSave.route,
              //   arguments: <String, dynamic>{
              //     'center': isFixed ? latLngFixed : latLng,
              //     'meterInCm': meterInCm,
              //     'country': 'Germany',
              //   },
              // );
            },
            child: const Icon(Icons.save),
          ),
        ],
        title: const Text('Map to print'),
        centerTitle: true,
      ),
      // drawer: const MenuDrawer(ScreenPointToLatLngPage.route),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
                onPositionChanged: (camera, hasGesture) => updatePoint(context),
                initialCenter: const LatLng(55.386, 39.030),
                initialZoom: 13,
                minZoom: 1,
                maxZoom: 18),
            children: [
              openStreetMapTileLayer,
              if (listApex.isNotEmpty)
                PolygonLayer(
                  // hitNotifier: _hitNotifier,
                  // simplificationTolerance: 0,
                  // polygons: [..._polygonsRaw, ...?_hoverGons],
                  polygons: [
                    Polygon(
                      color: Colors.orange.withAlpha(95),
                      points: listApex,
                      borderColor: Colors.orange,
                      borderStrokeWidth: 1,
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
              const Scalebar(
                textStyle: TextStyle(color: Colors.black, fontSize: 14),
                padding: EdgeInsets.only(right: 10, left: 10, bottom: 80),
                alignment: Alignment.center,
                length: ScalebarLength.xl,
              ),
              const Scalebar(
                textStyle: TextStyle(color: Colors.black, fontSize: 14),
                padding: EdgeInsets.only(right: 10, left: 10, bottom: 80),
                alignment: Alignment.topCenter,
                length: ScalebarLength.l,
              ),
            ],
          ),
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

    setState(() {
      latLng = mapController.camera.pointToLatLng(p);
      if (!isFixed) {
        zoomToPrint = getZoomToPrint(meterInCm: meterInCm);
        listApex = getNewApex(
            latLng: latLng, camera: mapController.camera, meterInCm: meterInCm,landscape: landscape);
      }
    });
  }

  double getZoomToPrint({required double meterInCm}) {
    double newZoom = 1;
    switch (meterInCm) {
      case 100:
        newZoom = 16;
      case 250:
        newZoom = 14;
      case 500:
        newZoom = 13;
      case 1000:
        newZoom = 12;
    }

    return newZoom;
  }

  double _getPointX(BuildContext context) =>
      MediaQuery.sizeOf(context).width / 2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Future.delayed(const Duration(seconds: 0), () {
      setState(() {
        zoomToPrint = getZoomToPrint(meterInCm: meterInCm);

        listApex = getNewApex(
            latLng: latLng, camera: mapController.camera, meterInCm: meterInCm,landscape: landscape);
      });
    });
  }

  //
  void setPrintScale(double newMeterInCm) {
    setState(() {
      meterInCm = newMeterInCm;
      zoomToPrint = getZoomToPrint(meterInCm: meterInCm);

      listApex = getNewApex(
          latLng: latLng, camera: mapController.camera, meterInCm: meterInCm,landscape: landscape);
    });
  }
  void rotatePolygon() {
    setState(() {
      // meterInCm = newMeterInCm;
      // zoomToPrint = getZoomToPrint(meterInCm: meterInCm);

      landscape=!landscape;
      listApex = getNewApex(
          latLng: latLng, camera: mapController.camera, meterInCm: meterInCm,landscape:landscape);
    });
  }

}
