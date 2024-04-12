import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gg_map_api/location.dart';
import 'package:gg_map_api/service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String _address = '402 Tùng Thiện Vương';
  LatLng? currentPostion;
  // static const CameraPosition _kGooglePlex = CameraPosition(
  //   target: LatLng(10.744757, 106.656691),
  //   zoom: 14.4746,
  // );
  //
  // static const CameraPosition _kLake = CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(37.43296265331129, -122.08832357078792),
  //     tilt: 59.440717697143555,
  //     zoom: 19.151926040649414);
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

  Future<void> _goToNewLocation(String address) async {
    final GoogleMapController controller = await _controller.future;
    Location? location = await MapService().getCurrentPoint(address);
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          // bearing: 192.8334901395799,
          target: LatLng(location!.lat, location!.lng),
          tilt: 59.440717697143555,
          zoom: 19.151926040649414,
        ),
      ),
    );
  }

  void _getUserLocation() async {
    var position = await GeolocatorPlatform.instance.getCurrentPosition(
        locationSettings:
        const LocationSettings(accuracy: LocationAccuracy.high));

    setState(() {
      currentPostion = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              width: MediaQuery.of(context).size.width,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () async {
                      setState(() {
                        _address = _searchController.text;
                      });
                      //await _goToNewLocation(_searchController.text);
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<Location?>(
                future: mapService.getCurrentPoint(_address),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _goToNewLocation(_address);
                    return GoogleMap(
                      mapType: MapType.normal,
                      markers: <Marker>{
                        _createMarker(snapshot.data!.lat, snapshot.data!.lng)
                      },
                      initialCameraPosition: CameraPosition(
                        target: LatLng(snapshot.data!.lat, snapshot.data!.lng),
                        zoom: 16.4746,
                      ),
                      onMapCreated: (GoogleMapController controller) async {
                        _controller.complete(controller);
                      },
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: Colors.white,
        onPressed: () async {

        },
        child: const Icon(
          Icons.location_on,
          color: Colors.red,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}