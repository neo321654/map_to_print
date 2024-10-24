import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
// import 'package:flutter_map/flutter_map.dart/';

import 'package:latlong2/latlong.dart';

TileLayer get openStreetMapTileLayerSave {

  int countTiles = 0;
  return TileLayer(
  isSave:true,
  // key: UniqueKey(),


  // tileBounds: LatLngBounds.fromPoints([
      //   LatLng(51.5, -0.09),
      //   LatLng(48.8566, 2.3522),
      // ]),
      // tileBounds: ,
      // tileBuilder: ((context, widget, tileImage) {
      //   // var ct = context as Element;
      //
      //   return Stack(
      //     children: [
      //       widget,
      //       Text('${tileImage.coordinates}'),
      //       Align(
      //         alignment: Alignment.center,
      //
      //         child: Text('${(tileImage.coordinates) * 256}'),
      //
      //       ),
      //     ],
      //   );
      // }),
      tileBuilder: (context, widget, tileImage){
        tileImage.addListener((){
          countTiles++;
          print(countTiles);
          print(tileImage);
        });
          return Center(child: widget,);
      },
      tileDisplay: TileDisplay.fadeIn(),
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
      // userAgentPackageName: 'dev.fleaflet.flutter_map.example',
      // Use the recommended flutter_map_cancellable_tile_provider package to
      // support the cancellation of loading tiles.
      tileProvider: CancellableNetworkTileProvider(),
    );
}

