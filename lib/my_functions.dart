import 'dart:math';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_to_print/pages/screen_point_to_latlng.dart';

LatLng getCenterPoint(List<LatLng> points) {
  // Проверяем, что список содержит ровно 4 координаты
  if (points.length != 4) {
    throw Exception('Список должен содержать ровно 4 координаты');
  }

  double totalLatitude = 0;
  double totalLongitude = 0;

  // Суммируем широты и долготы
  for (LatLng point in points) {
    totalLatitude += point.latitude;
    totalLongitude += point.longitude;
  }

  // Вычисляем средние значения
  double centerLatitude = totalLatitude / points.length;
  double centerLongitude = totalLongitude / points.length;

  return LatLng(centerLatitude, centerLongitude);
}



List<LatLng> createRectangle(LatLng center, double width, double height) {
  // Вычисляем координаты углов прямоугольника
  LatLng topLeft = LatLng(center.latitude + height / 2, center.longitude - width / 2);
  LatLng topRight = LatLng(center.latitude + height / 2, center.longitude + width / 2);
  LatLng bottomRight = LatLng(center.latitude - height / 2, center.longitude + width / 2);
  LatLng bottomLeft = LatLng(center.latitude - height / 2, center.longitude - width / 2);

  // Возвращаем список точек в порядке обхода
  return [topLeft, topRight,bottomRight,  bottomLeft,];
  // return [topLeft, topRight,  bottomLeft,bottomRight,topRight, topLeft,bottomRight,bottomLeft,topLeft];
}
List<Point> createRectangleNew(Point<double> center, double width, double height) {
  // Вычисляем координаты углов прямоугольника
  Point topLeft = Point(center.x + height / 2, center.y - width / 2);
  Point topRight = Point(center.x + height / 2, center.y + width / 2);
  Point bottomRight = Point(center.x - height / 2, center.y + width / 2);
  Point bottomLeft = Point(center.x- height / 2, center.y - width / 2);

  // Возвращаем список точек в порядке обхода
  return [topLeft, topRight,bottomRight,  bottomLeft,];
  // return [topLeft, topRight,  bottomLeft,bottomRight,topRight, topLeft,bottomRight,bottomLeft,topLeft];
}



List<LatLng> calculateApexFromCenter({
  required LatLng latLng,
  required double width,
  required double height,
  required double meterInCm,
  bool landscape = true,
}) {
  const dst = Distance();

  List<LatLng> listLatLng = [];

  if (landscape) {
    double temp = width;
    width = height;
    height = temp;
  }

  LatLng tempLL = dst.offset(latLng, height * meterInCm / 2, 0);
  LatLng tempLL1 = dst.offset(tempLL, width * meterInCm / 2, 270);
  listLatLng.add(tempLL1);
  tempLL1 = dst.offset(tempLL1, height * meterInCm, 180);
  listLatLng.add(tempLL1);
  tempLL1 = dst.offset(tempLL1, width * meterInCm, 90);
  listLatLng.add(tempLL1);
  tempLL1 = dst.offset(tempLL1, height * meterInCm, 0);
  listLatLng.add(tempLL1);

  return listLatLng;
}

List<LatLng> getNewApex({
  required LatLng? latLng,
  required MapCamera camera,
  double width = 21.0,
  double height = 29.7,
  double meterInCm = 100,
}) {


  List<LatLng> listApex = [];
  if (latLng != null) {
    listApex = calculateApexFromCenter(
        latLng: latLng, width: width, height: height, meterInCm: meterInCm);
//todo удалить потом

    globalListApex = listApex;
    return listApex;
  }
  //todo удалить потом

  globalListApex = listApex;

  return listApex;
}
//todo удалить потом
