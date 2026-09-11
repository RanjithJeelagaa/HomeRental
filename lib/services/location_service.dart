import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';

class LocationService {
  // Get the current device location
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Pick a location on the map (returns LatLng)
  Future<LatLng?> pickLocationOnMap(
    BuildContext context, {
    LatLng? initialPosition,
  }) async {
    LatLng? pickedLocation;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Pick Location')),
          body: GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  initialPosition ??
                  const LatLng(37.42796133580664, -122.085749655962),
              zoom: 14.0,
            ),
            onTap: (latLng) {
              pickedLocation = latLng;
              Navigator.of(context).pop();
            },
            markers: pickedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('picked'),
                      position: pickedLocation!,
                    ),
                  }
                : {},
          ),
        ),
      ),
    );
    return pickedLocation;
  }

  // Get address from coordinates
  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      latitude,
      longitude,
    );
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    }
    return "Unknown location";
  }
}
