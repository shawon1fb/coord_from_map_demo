import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

abstract class GoogleMapExampleAppPage extends StatelessWidget {
  const GoogleMapExampleAppPage(this.leading, this.title);

  final Widget leading;
  final String title;
}

const CameraPosition _kInitialPosition =
    CameraPosition(target: LatLng(-33.852, 151.211), zoom: 11.0);

class MapClickPage extends GoogleMapExampleAppPage {
  MapClickPage() : super(const Icon(Icons.mouse), 'Map click');

  @override
  Widget build(BuildContext context) {
    return const _MapClickBody();
  }
}

class _MapClickBody extends StatefulWidget {
  const _MapClickBody();

  @override
  State<StatefulWidget> createState() => _MapClickBodyState();
}

class _MapClickBodyState extends State<_MapClickBody> {
  _MapClickBodyState();

  GoogleMapController? mapController;
  LatLng? _lastTap;
  LatLng? _lastLongPress;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId? selectedMarker;
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
        target: LatLng(_locationData.latitude??25.00, _locationData.longitude??90.98),
        //LatLng(37.43296265331129, -122.08832357078792),
        tilt: 50.440717697143555,
        zoom: 16.151926040649414);
    _goToTheLake(_kLake);
  }

  Completer<GoogleMapController> _controller = Completer();

  Future<void> _goToTheLake(CameraPosition _kLake) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
  }
  int _markerIdCounter = 1;

  void _remove(MarkerId markerId) {
    setState(() {
      if (markers.containsKey(markerId)) {
        markers.remove(markerId);
      }
    });
  }
  void _add(LatLng pos) {
    final int markerCount = markers.length;

    if (markerCount == 12) {
      return;
    }


    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position: pos,
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () {
        _onMarkerTapped(markerId);
      },
      onDragEnd: (LatLng position) {
        _onMarkerDragEnd(markerId, position);
      },
    );

    setState(() {
      markers[markerId] = marker;
    });
  }


  void _onMarkerTapped(MarkerId markerId) {
    final Marker? tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        final MarkerId? previousMarkerId = selectedMarker;
        if (previousMarkerId != null && markers.containsKey(previousMarkerId)) {
          final Marker resetOld = markers[previousMarkerId]!
              .copyWith(iconParam: BitmapDescriptor.defaultMarker);
          markers[previousMarkerId] = resetOld;
        }
        selectedMarker = markerId;
        final Marker newMarker = tappedMarker.copyWith(
          iconParam: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        );
        markers[markerId] = newMarker;
      });
    }
  }

  void _onMarkerDragEnd(MarkerId markerId, LatLng newPosition) async {
    final Marker? tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
                content: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 66),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Old position: ${tappedMarker.position}'),
                        Text('New position: $newPosition'),
                      ],
                    )));
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final GoogleMap googleMap = GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: _kInitialPosition,
      onTap: (LatLng pos) {
        _add(pos);
        setState(() {
          _lastTap = pos;
        });
      },
      markers: Set<Marker>.of(markers.values),
      onLongPress: (LatLng pos) {
        _add(pos);
        setState(() {
          _lastLongPress = pos;
        });
      },
    );

    final List<Widget> columnChildren = <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: SizedBox(
            width: 0.9.sw,
            height: 0.6.sh,
            child: googleMap,
          ),
        ),
      ),
    ];

    if (mapController != null) {
      final String lastTap = 'Tap:\n${_lastTap ?? ""}\n';
      final String lastLongPress = 'Long press:\n${_lastLongPress ?? ""}';
      columnChildren
          .add(Center(child: Text(lastTap, textAlign: TextAlign.center)));
      columnChildren.add(Center(
          child: Text(
        lastLongPress,
        textAlign: TextAlign.center,
      )));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: columnChildren,
    );
  }

  void onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);

    setState(() {
      mapController = controller;
    });
  }
}
