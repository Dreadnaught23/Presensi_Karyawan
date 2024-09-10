import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:location/location.dart';
import 'package:presensi/models/save-presensi-response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:http/http.dart' as myHttp;

class SimpanPage extends StatefulWidget {
  const SimpanPage({super.key});

  @override
  State<SimpanPage> createState() => _SimpanPageState();
}

class _SimpanPageState extends State<SimpanPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _token;
  bool _isSaving = false;

  @override
  void initState() {

  super.initState();
  _token = _prefs.then((SharedPreferences prefs){
  return prefs.getString("token") ?? "";
    });
  }

  // Future<LocationData?> _lokasiSekarang() async{
  //   bool serviceEnable;
  //   PermissionStatus permissionGranted;

  //   Location location = Location();

  //   serviceEnable = await location.serviceEnabled();
  //   if(!serviceEnable){
  //     serviceEnable = await location.requestService();
  //       if(!serviceEnable){
  //       return null;
  //     }
  //   }
    
  //   permissionGranted = await location.hasPermission();
  //   if(permissionGranted == PermissionStatus.denied){
  //     permissionGranted = await location.requestPermission();
  //     if(permissionGranted != PermissionStatus.granted){
  //       return null;
  //     }
  //   }
  //   return await location.getLocation();
  // }

  Future<Position?> _currentLocation() async{
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    } 

    return await Geolocator.getCurrentPosition();
  }

  

  Future<bool> savePresensi(double latitude, double longitude) async {
    SavePresensiResponseModel? savePresensiResponseModel;
    Map<String, String> body = {
      "latitude": latitude.toString(),
      "longitude": longitude.toString()
    };

    Map<String, String> headers = {
      'Authorization': 'Bearer ' + await _token
    };
    try{
    var response = await myHttp.post(Uri.parse("http://127.0.0.1:8000/api/save-presensi"),//Save Presensi Http
    body: body,
    headers: headers,
    );
    if(response.statusCode == 200){
      var jsonResponse = json.decode(response.body);
      if(jsonResponse != null && jsonResponse is Map<String, dynamic>){
        savePresensiResponseModel = SavePresensiResponseModel.fromJson(jsonResponse);
        if(savePresensiResponseModel.success){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil Simpan Presensi')));
        return true;
      }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(savePresensiResponseModel.message))); 
        return false;
      }
    }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Response tidak valid!')));
        return false;
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal Simpan Presensi!')));
      return false;
    }
  }catch(e){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Anda Sudah Melakukan Presensi Hari Ini!!')));
    return false;
    }
  }

    // try{
    // if(savePresensiResponseModel.success){
    //   savePresensiResponseModel = SavePresensiResponseModel.fromJson(jsonResponse);

    //   if(savePresensiResponseModel.data.pulang != null){
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(savePresensiResponseModel.message)));
    //   }else{
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sukses Simpan Presensi!')));
    //   Navigator.pop(context);
    //   }  
    // }else{
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal Simpan Presensi!')));
    // }
    // }catch(e){
    //   print("Error: $e");
    // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Presensi"),
      ),
      body: FutureBuilder<Position?>(
        future: _currentLocation(),
        builder: (BuildContext context,AsyncSnapshot<Position?> snapshot) {
          if(snapshot.hasData){
            final Position currentPosition = snapshot.data!;
            return SafeArea(
            child: Column(
              children: [
                Container(
                  height: 300,
                  child: SfMaps(
                    layers: [MapTileLayer(
                      initialFocalLatLng: MapLatLng(currentPosition.latitude, currentPosition.longitude),
                      initialZoomLevel: 15,
                      initialMarkersCount: 1,
                      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      markerBuilder: (BuildContext context,int index){
                        return MapMarker(latitude: currentPosition.latitude,
                                         longitude: currentPosition.longitude,
                        child: Icon(Icons.location_on,color: Colors.red,),);
                      },
                      )],),
                ),
                SizedBox(height: 20),
                ElevatedButton(onPressed: _isSaving 
                ? null
                : () async{
                  setState(() {
                    _isSaving = true;
                  });
                  bool success = await savePresensi(currentPosition.latitude, currentPosition.longitude);
                  if(success){
                    Navigator.pop(context);
                  }

                  setState(() {
                    _isSaving = false;
                  });
                },
                child: _isSaving ? CircularProgressIndicator(color: Colors.white) : Text("Simpan Presensi"),
                ),
              ],
            ),
          );
        }else{
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
      ),
    );
  }
}