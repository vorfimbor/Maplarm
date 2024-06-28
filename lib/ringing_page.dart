import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RingingPage extends StatelessWidget {
  final String locationName;

  RingingPage({required this.locationName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Napalarm'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(51.5033640, -0.1276250), // Example coordinates
                zoom: 14.0,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You are near $locationName!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Stop the alarm
                  },
                  child: Text('Slide to Stop'),
                  style: ElevatedButton.styleFrom(primary: Colors.red, padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
