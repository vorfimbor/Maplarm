import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final Function(ThemeData) updateTheme;

  SettingsPage({required this.updateTheme});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _volume = 0.5;
  String _selectedLanguage = 'İngilizce';
  String _selectedTheme = 'Açık';
  String _selectedRingtone = 'Varsayılan Zil Sesi';
  List<String> _languages = ['İngilizce', 'Türkçe'];
  List<String> _themes = ['Açık', 'Koyu'];
  List<String> _ringtones = ['Varsayılan Zil Sesi', 'Zil Sesi 1', 'Zil Sesi 2'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Dil'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
              },
              items: _languages.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          ListTile(
            title: Text('Zil sesi'),
            subtitle: Text(_selectedRingtone),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Zil Sesi Seç'),
                    content: Container(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _ringtones.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_ringtones[index]),
                            onTap: () {
                              setState(() {
                                _selectedRingtone = _ringtones[index];
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
          ListTile(
            title: Text('Zil sesi yüksekliği'),
            subtitle: Slider(
              value: _volume,
              min: 0.0,
              max: 1.0,
              onChanged: (value) {
                setState(() {
                  _volume = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text('Tema'),
            trailing: DropdownButton<String>(
              value: _selectedTheme,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTheme = newValue!;
                  if (_selectedTheme == 'Açık') {
                    widget.updateTheme(ThemeData.light());
                  } else {
                    widget.updateTheme(ThemeData.dark());
                  }
                });
              },
              items: _themes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Telif Hakkı Ozan Can OZEV',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
