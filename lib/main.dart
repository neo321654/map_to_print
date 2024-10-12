import 'package:flutter/material.dart';
import '/pages/animated_map_controller.dart';
import '/pages/bundled_offline_map.dart';
import '/pages/cancellable_tile_provider.dart';
import '/pages/circle.dart';
import '/pages/custom_crs/custom_crs.dart';
import '/pages/debouncing_tile_update_transformer.dart';
import '/pages/epsg3413_crs.dart';
import '/pages/epsg4326_crs.dart';
import '/pages/fallback_url_page.dart';
import '/pages/home.dart';
import '/pages/interactive_test_page.dart';
import '/pages/latlng_to_screen_point.dart';
import '/pages/many_circles.dart';
import '/pages/many_markers.dart';
import '/pages/map_controller.dart';
import '/pages/map_inside_listview.dart';
import '/pages/markers.dart';
import '/pages/overlay_image.dart';
import '/pages/plugin_zoombuttons.dart';
import '/pages/polygon.dart';
import '/pages/polygon_perf_stress.dart';
import '/pages/polyline.dart';
import '/pages/polyline_perf_stress.dart';
import '/pages/reset_tile_layer.dart';
import '/pages/retina.dart';
import '/pages/scalebar.dart';
import '/pages/screen_point_to_latlng.dart';
import '/pages/secondary_tap.dart';
import '/pages/sliding_map.dart';
import '/pages/tile_builder.dart';
import '/pages/tile_loading_error_handle.dart';
import '/pages/wms_tile_layer.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_map Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF8dea88),
      ),
      // home: const HomePage(),
      // home: const PolygonPage(),
      home: const ScreenPointToLatLngPage(),
      // home: const ScreenPointToLatLngPage(),
      routes: <String, WidgetBuilder>{
        CancellableTileProviderPage.route: (context) =>
            const CancellableTileProviderPage(),
        PolylinePage.route: (context) => const PolylinePage(),
        PolylinePerfStressPage.route: (context) =>
            const PolylinePerfStressPage(),
        MapControllerPage.route: (context) => const MapControllerPage(),
        AnimatedMapControllerPage.route: (context) =>
            const AnimatedMapControllerPage(),
        MarkerPage.route: (context) => const MarkerPage(),
        ScaleBarPage.route: (context) => const ScaleBarPage(),
        PluginZoomButtons.route: (context) => const PluginZoomButtons(),
        BundledOfflineMapPage.route: (context) => const BundledOfflineMapPage(),
        ManyCirclesPage.route: (context) => const ManyCirclesPage(),
        CirclePage.route: (context) => const CirclePage(),
        OverlayImagePage.route: (context) => const OverlayImagePage(),
        PolygonPage.route: (context) => const PolygonPage(),
        PolygonPerfStressPage.route: (context) => const PolygonPerfStressPage(),
        SlidingMapPage.route: (_) => const SlidingMapPage(),
        WMSLayerPage.route: (context) => const WMSLayerPage(),
        CustomCrsPage.route: (context) => const CustomCrsPage(),
        TileLoadingErrorHandle.route: (context) =>
            const TileLoadingErrorHandle(),
        TileBuilderPage.route: (context) => const TileBuilderPage(),
        InteractiveFlagsPage.route: (context) => const InteractiveFlagsPage(),
        ManyMarkersPage.route: (context) => const ManyMarkersPage(),
        MapInsideListViewPage.route: (context) => const MapInsideListViewPage(),
        ResetTileLayerPage.route: (context) => const ResetTileLayerPage(),
        EPSG4326Page.route: (context) => const EPSG4326Page(),
        EPSG3413Page.route: (context) => const EPSG3413Page(),
        ScreenPointToLatLngPage.route: (context) =>
            const ScreenPointToLatLngPage(),
        LatLngToScreenPointPage.route: (context) =>
            const LatLngToScreenPointPage(),
        FallbackUrlPage.route: (context) => const FallbackUrlPage(),
        SecondaryTapPage.route: (context) => const SecondaryTapPage(),
        RetinaPage.route: (context) => const RetinaPage(),
        DebouncingTileUpdateTransformerPage.route: (context) =>
            const DebouncingTileUpdateTransformerPage(),
      },
    );
  }
}
