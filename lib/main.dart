import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gg_map_api/location.dart';
import 'package:gg_map_api/service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
    initializeMapRenderer();
  }

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MapSample(),
  ));
}

Completer<AndroidMapRenderer?>? _initializedRendererCompleter;

Future<AndroidMapRenderer?> initializeMapRenderer() async {
  if (_initializedRendererCompleter != null) {
    return _initializedRendererCompleter!.future;
  }

  final Completer<AndroidMapRenderer?> completer =
      Completer<AndroidMapRenderer?>();
  _initializedRendererCompleter = completer;

  WidgetsFlutterBinding.ensureInitialized();

  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    unawaited(mapsImplementation
        .initializeWithRenderer(AndroidMapRenderer.latest)
        .then((AndroidMapRenderer initializedRenderer) =>
            completer.complete(initializedRenderer)));
  } else {
    completer.complete(null);
  }

  return completer.future;
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  BitmapDescriptor? _markerIcon;
  final MapService mapService = MapService();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(10.744757, 106.656691),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Marker _createMarker(double lat, double lng) {
    if (_markerIcon != null) {
      return Marker(
        markerId: const MarkerId('marker_1'),
        position: LatLng(lat, lng),
        icon: _markerIcon!,
      );
    } else {
      return Marker(
        markerId: MarkerId('marker_1'),
        position: LatLng(lat, lng),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Location?>(
        future: mapService.getCurrentPoint('Vĩnh Phú 29, Vĩnh Phú, Thuận An, Bình Dương'),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return GoogleMap(
              mapType: MapType.normal,
              markers: <Marker>{
                _createMarker(snapshot.data!.lat, snapshot.data!.lng)
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(snapshot.data!.lat, snapshot.data!.lng),
                zoom: 14.4746,
              ),
              onMapCreated: (GoogleMapController controller) async{
                _controller.complete(controller);
              },
            );
          } else{
            return Center(child: const CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('To the lake!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
