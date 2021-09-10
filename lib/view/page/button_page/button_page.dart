import 'package:flutter/material.dart';
import 'package:flutter_google_map_coord/view/page/basic_map/basic_map.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class ButtonPage extends StatefulWidget {
  const ButtonPage({Key? key}) : super(key: key);

  @override
  _ButtonPageState createState() => _ButtonPageState();
}

class _ButtonPageState extends State<ButtonPage> {
  getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    CameraPosition _kLake = CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(
            _locationData.latitude ?? 25.00, _locationData.longitude ?? 90.98),
        //LatLng(37.43296265331129, -122.08832357078792),
        tilt: 50.440717697143555,
        zoom: 16.151926040649414);
    kLake = _kLake;

    buttontext= "my coordinates:=> ${kLake?.target}";
    setState(() {});
  }

  CameraPosition? kLake;

  String buttontext="please wait...";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Center(
            child: InkWell(
              onTap: () {
                if (kLake != null)
                  Get.to(BasicMapPage(
                    kGooglePlex: kLake!,
                  ));
                else{

                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text("$buttontext"),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
