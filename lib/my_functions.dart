import 'dart:math';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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