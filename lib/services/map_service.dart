import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class GuidlyMap extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final List<Marker> markers;

  const GuidlyMap({
    Key? key,
    required this.center,
    this.zoom = 13.0,
    this.markers = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: center,
        zoom: zoom,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.guidly.app',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
