import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class CurrentLocation extends StatefulWidget {
  const CurrentLocation({Key? key}) : super(key: key);

  @override
  _CurrentLocationState createState() => _CurrentLocationState();
}

class _CurrentLocationState extends State<CurrentLocation> {
  var fromaddress;
  var add;
  Future<Position> _getGeoCostPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if Cost services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Cost services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the Cost services.
      await Geolocator.openLocationSettings();
      return Future.error('Cost services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Cost permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Cost permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  getCurrentAddress(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      //print(placemarks);
      Placemark place = placemarks[1];
      fromaddress =
          '${place.thoroughfare}, \n ${place.subLocality},\n ${place.locality},${place.administrativeArea}, \n ${place.country}, ${place.postalCode}';

      setState(() {
        add = fromaddress;
      });
      //print(fromaddress);
      return fromaddress;
      // print(place);

      // print(position.latitude);
      // print(position.longitude);
      // print(tolat);
      // print(tolong);
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(150.0),
              child: ElevatedButton(
                  onPressed: () async {
                    Position position = await _getGeoCostPosition();
                    var a = await getCurrentAddress(position);

                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Your current location'),
                        content: Text(a.toString()),
                        actions: <Widget>[
                          // TextButton(
                          //   onPressed: () async {
                          //     Position position = await _getGeoCostPosition();
                          //     getCurrentAddress(position);
                          //   },
                          //   child: const Text('Refresh'),
                          // ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'Cancel');
                            },
                            child: const Text('Back'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text("Location")),
            ),
          ),
          SizedBox(
            height: 20,
          ),

          //Text('$fromaddress')
        ],
      ),
    );
  }
}
