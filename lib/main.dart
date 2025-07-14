import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(SmartFishFarmApp());

class SmartFishFarmApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Fish Farm',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    WaterQualityScreen(),
    FeedingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Fish Farm Management'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.water),
            label: 'Water Quality',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.set_meal),
            label: 'Feeding',
          ),
        ],
      ),
    );
  }
}

class WaterQualityScreen extends StatefulWidget {
  @override
  _WaterQualityScreenState createState() => _WaterQualityScreenState();
}

class _WaterQualityScreenState extends State<WaterQualityScreen> {
  double temperature = 0.0;
  double ph = 0.0;
  double turbidity = 0.0;

  Future<void> fetchSensorData() async {
    final url = Uri.parse('http://192.168.1.100/sensor'); // Replace with your Arduino IP
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temperature = data['temperature'];
          ph = data['ph'];
          turbidity = data['turbidity'];
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSensorData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchSensorData,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          SensorCard(label: 'Temperature', value: '$temperature °C'),
          SensorCard(label: 'pH Level', value: '$ph'),
          SensorCard(label: 'Turbidity', value: '$turbidity NTU'),
        ],
      ),
    );
  }
}

class FeedingScreen extends StatelessWidget {
  Future<void> feedFish() async {
    final url = Uri.parse('http://192.168.1.100/feed'); // Replace with your Arduino IP
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        print('Feeding successful');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: feedFish,
        child: Text('Feed Now'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          textStyle: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class SensorCard extends StatelessWidget {
  final String label;
  final String value;

  SensorCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}

