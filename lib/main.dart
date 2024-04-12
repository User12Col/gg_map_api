import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gg_map_api/map.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
    initializeMapRenderer();
  }

  BuildContext mContext;
  runApp(
    ScreenUtilInit(
      builder: (context, widget) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MapSample(),
        );
      },
    ),
  );
}
