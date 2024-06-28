import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SetAlarmPage extends StatefulWidget {
  @override
  _SetAlarmPageState createState() => _SetAlarmPageState();
}

class _SetAlarmPageState extends State<SetAlarmPage> {
  GoogleMapController? mapController;
  LatLng _center = const LatLng(45.521563, -122.677433);
  LatLng _lastMapPosition = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Alarm'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              onCameraMove: _onCameraMove,
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alarm rings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Checkbox(value: true, onChanged: (bool? value) {}),
                    Text('on entry'),
                    Checkbox(value: false, onChanged: (bool? value) {}),
                    Text('on exit'),
                  ],
                ),
                Row(
                  children: [
                    Text('Radius: '),
                    Expanded(
                      child: Slider(
                        value: 600.0,
                        min: 100.0,
                        max: 1000.0,
                        onChanged: (value) {},
                      ),
                    ),
                    Text('600 Meters'),
                  ],
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Alarm Name'),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(onPressed: () {}, child: Text('Save')),
                    ElevatedButton(onPressed: () {}, child: Text('Start')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
