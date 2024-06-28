import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'alarm_helper.dart';
import 'notification_helper.dart';
import 'location_service.dart';
import 'settings_page.dart';
import 'set_alarm_page.dart';
import 'alarm_list_page.dart';
import 'ringing_page.dart';
import 'edit_alarm_page.dart'; // EditAlarmPage'i içe aktar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.initialize();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeData _themeData = ThemeData.light();

  void _updateTheme(ThemeData theme) {
    setState(() {
      _themeData = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maplarm',
      theme: _themeData,
      home: AlarmListPage(updateTheme: _updateTheme),
      routes: {
        '/set_alarm': (context) => SetAlarmPage(),
        '/alarm_list': (context) => AlarmListPage(updateTheme: _updateTheme),
        '/ringing': (context) => RingingPage(locationName: 'London Eye'),
      },
    );
  }
}

class AlarmListPage extends StatefulWidget {
  final Function(ThemeData) updateTheme;
  AlarmListPage({required this.updateTheme});

  @override
  _AlarmListPageState createState() => _AlarmListPageState();
}

class _AlarmListPageState extends State<AlarmListPage> {
  List<Map<String, dynamic>> _alarms = [];
  Position? _targetLocation;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
    LocationService.trackLocation((position) {
      if (_targetLocation != null) {
        double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          _targetLocation!.latitude,
          _targetLocation!.longitude,
        );
        if (distance < 100) { // 100 meters threshold
          NotificationHelper.showNotification("Arrived at target location");
        }
      }
    });
  }

  Future<void> _loadAlarms() async {
    try {
      final data = await AlarmHelper.instance.queryAllRows();
      setState(() {
        _alarms = data;
      });
    } catch (e) {
      print('Error loading alarms: $e');
    }
  }

  Future<void> _addAlarm(DateTime alarmTime, String alarmName) async {
    try {
      final id = await AlarmHelper.instance.insert({
        AlarmHelper.columnHour: alarmTime.hour,
        AlarmHelper.columnMinute: alarmTime.minute,
        AlarmHelper.columnName: alarmName,
      });
      AlarmHelper.scheduleAlarm(alarmTime, id);
      _loadAlarms();
    } catch (e) {
      print('Error adding alarm: $e');
    }
  }

  Future<void> _deleteAlarm(int id) async {
    try {
      await AlarmHelper.instance.delete(id);
      AlarmHelper.cancelAlarm(id);
      _loadAlarms();
    } catch (e) {
      print('Error deleting alarm: $e');
    }
  }

  Future<void> _editAlarm(int id, DateTime alarmTime, String alarmName) async {
    try {
      final updatedAlarm = {
        AlarmHelper.columnId: id,
        AlarmHelper.columnHour: alarmTime.hour,
        AlarmHelper.columnMinute: alarmTime.minute,
        AlarmHelper.columnName: alarmName,
        AlarmHelper.columnIsActive: 1,
      };
      await AlarmHelper.instance.update(updatedAlarm);
      await AlarmHelper.scheduleAlarm(alarmTime, id);
      _loadAlarms();
    } catch (e) {
      print('Error editing alarm: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maplarm'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: AlarmHelper.instance.queryAllRows(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No alarms found'));
          } else {
            final alarms = snapshot.data!;
            return ListView.builder(
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(alarm[AlarmHelper.columnName] ?? '${alarm[AlarmHelper.columnHour]}:${alarm[AlarmHelper.columnMinute]}'),
                    subtitle: Text('${alarm[AlarmHelper.columnHour]}:${alarm[AlarmHelper.columnMinute]}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditAlarmPage(
                                  id: alarm[AlarmHelper.columnId],
                                  initialTime: TimeOfDay(
                                    hour: alarm[AlarmHelper.columnHour],
                                    minute: alarm[AlarmHelper.columnMinute],
                                  ),
                                  initialName: alarm[AlarmHelper.columnName],
                                ),
                              ),
                            );
                            if (result != null) {
                              await _editAlarm(result['id'], result['time'], result['name']);
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _deleteAlarm(alarm[AlarmHelper.columnId]);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                final now = DateTime.now();
                final alarmTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
                final alarmNameController = TextEditingController();

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Add Alarm'),
                      content: TextField(
                        controller: alarmNameController,
                        decoration: InputDecoration(labelText: 'Alarm Name'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await _addAlarm(alarmTime, alarmNameController.text);
                            Navigator.of(context).pop();
                          },
                          child: Text('Save'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: Icon(Icons.add),
            heroTag: null,
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(updateTheme: widget.updateTheme),
                ),
              );
            },
            child: Icon(Icons.settings),
            heroTag: null,
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () async {
              Position position = await LocationService.getCurrentPosition();
              setState(() {
                _targetLocation = position;
              });
              Navigator.pushNamed(context, '/set_alarm');
            },
            child: Icon(Icons.location_on),
            heroTag: null,
          ),
        ],
      ),
    );
  }
}
