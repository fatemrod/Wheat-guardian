import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  _TablesScreenState createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  List<Map<String, dynamic>> _sensorData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSensorData();
  }

  Future<void> _fetchSensorData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('sensors') // Firestore collection name
          .get();

      final data = snapshot.docs.map((doc) {
        final timestamp = doc.id; // Use document ID as the timestamp
        final sensorData = doc.data();
        return {
          'timestamp': timestamp,
          'temperature': sensorData['temp'] ?? 'N/A',
          'humidity': sensorData['humidity'] ?? 'N/A',
          'carbon': sensorData['smoke'] ?? 'N/A', // Add carbon
        };
      }).toList();

      setState(() {
        _sensorData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(228, 200, 178, 1),
      appBar: AppBar(
        title: const Text('Sensor Data Table'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Timestamp')),
                    DataColumn(label: Text('Temperature (°C)')),
                    DataColumn(label: Text('Humidity (%)')),
                    DataColumn(label: Text('CO2. Conc (ppm)')),
                  ],
                  rows: _sensorData.map((data) {
                    return DataRow(
                      cells: [
                        DataCell(Text(data['timestamp'])),
                        DataCell(Text(data['temperature'].toString())),
                        DataCell(Text(data['humidity'].toString())),
                        DataCell(Text(data['carbon'].toString())),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}
