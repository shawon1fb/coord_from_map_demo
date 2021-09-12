import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BasicMapPage extends StatefulWidget {
  const BasicMapPage({
    Key? key,
    required this.kGooglePlex,
  }) : super(key: key);
  final CameraPosition kGooglePlex;

  @override
  _BasicMapPageState createState() => _BasicMapPageState();
}

class _BasicMapPageState extends State<BasicMapPage> {
  Completer<GoogleMapController> _controller = Completer();

  //  final CameraPosition _kGooglePlex = CameraPosition(
  //   target: LatLng(37.42796133580664, -122.085749655962),
  //   zoom: 14.4746,
  // );
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  // static final CameraPosition _kLake = CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(37.43296265331129, -122.08832357078792),
  //     tilt: 59.440717697143555,
  //     zoom: 19.151926040649414);
  //
  //
  void _add(LatLng pos) {
    final int markerCount = markers.length;

    if (markerCount == 12) {
      return;
    }
    int _markerIdCounter = 1;

    final String markerIdVal = 'my location $_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position: pos,
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),

    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _add(widget.kGooglePlex.target);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: Text("basic map"),),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: widget.kGooglePlex,
        markers: Set<Marker>.of(markers.values),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: Text('To the lake!'),
      //   icon: Icon(Icons.directions_boat),
      // ),
    );
  }

  // Future<void> _goToTheLake() async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  // }
}
