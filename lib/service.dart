import 'dart:convert';

import 'package:gg_map_api/point.dart';
import 'package:http/http.dart' as http;

class MapService{
  Future<Location?> getCurrentPoint(String address) async{
    try{
      final response = await http.Client().get(Uri.https('rsapi.goong.io', '/geocode', {'address':address, 'api_key':'bZHqTteyO4o1IzRpaaIj797VaVrubtVDQDXjz2h1'}));
      if(response.statusCode == 200){
        Map<String, dynamic> mapResponse = json.decode(response.body);
        final result = mapResponse['results'] as Map<String, dynamic>;
        final geometry = result['geometry'] as Map<String, dynamic>;
        final location = geometry['location'] as Map<String, dynamic>;
        final latLng = Location.fromJson(location);
        print('Lat is: ${latLng.lat}');
        return latLng;

      } else{
        return null;
      }
    } catch(e){
      print(e.toString());
    }
  }
}