import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class SensorScatterPlotPage extends StatefulWidget {
  const SensorScatterPlotPage({super.key});

  @override
  State<SensorScatterPlotPage> createState() => _SensorScatterPlotPageState();
}

class _SensorScatterPlotPageState extends State<SensorScatterPlotPage> {
  List<ScatterSpot> _tempPoints = [];
  List<ScatterSpot> _humidityPoints = [];
  List<ScatterSpot> _smokePoints = [];
  List<ScatterSpot> _tempHumidityPoints = [];
  List<ScatterSpot> _tempCO2Points = [];

  final double tempThreshold = 17.0;
  final double humidityThreshold = 60.0;
  final double smokeThreshold = 400.0;

  @override
  void initState() {
    super.initState();
    _fetchSensorData();
  }

  Future<void> _fetchSensorData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('sensors') // Collection name
          .get();

      List<ScatterSpot> tempPoints = [];
      List<ScatterSpot> humidityPoints = [];
      List<ScatterSpot> smokePoints = [];
      List<ScatterSpot> tempHumidityPoints = [];
      List<ScatterSpot> tempCO2Points = [];

      snapshot.docs.forEach((doc) {
        final timestamp =
            double.tryParse(doc.id) ?? 0; // Parse the doc ID as a timestamp
        final data = doc.data();

        final temp = data['temp'] as double;
        final humidity = (data['humidity'] as num).toDouble();
        final smoke = (data['smoke'] as num).toDouble();

        tempPoints.add(ScatterSpot(timestamp, temp));
        humidityPoints.add(ScatterSpot(timestamp, humidity));
        smokePoints.add(ScatterSpot(timestamp, smoke));
        tempHumidityPoints.add(ScatterSpot(temp, humidity));
        tempCO2Points.add(ScatterSpot(temp, smoke));
      });

      setState(() {
        _tempPoints = tempPoints;
        _humidityPoints = humidityPoints;
        _smokePoints = smokePoints;
        _tempHumidityPoints = tempHumidityPoints;
        _tempCO2Points = tempCO2Points;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Readings Scatter Plot'),
        backgroundColor: Colors.indigo,
      ),
      body: _tempPoints.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thresholds',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Temperature Threshold: $tempThreshold °C\n'
                      'Humidity Threshold: $humidityThreshold%\n'
                      'CO2 Concentration Threshold: $smokeThreshold ppm',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const Divider(thickness: 1),
              const SizedBox(height: 20),
              const Text(
                'Temperature',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildScatterPlot(_tempPoints, Colors.red, '°C'),
              const SizedBox(height: 20),
              const Text(
                'Humidity',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildScatterPlot(_humidityPoints, Colors.blue, '%'),
              const SizedBox(height: 20),
              const Text(
                'CO2 Concentration',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildScatterPlot(_smokePoints, Colors.grey, 'ppm'),
              const SizedBox(height: 20),
              const Text(
                'Temperature vs Humidity',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildTwoDimensionalScatterPlot(
                  _tempHumidityPoints, Colors.green, '°C', '%'),
              const SizedBox(height: 20),
              const Text(
                'Temperature vs CO2 Concentration',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildTwoDimensionalScatterPlot(
                  _tempCO2Points, Colors.orange, '°C', 'ppm'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScatterPlot(List<ScatterSpot> points, Color color, String unit) {
    return SizedBox(
      height: 200,
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: points,
          scatterTouchData: ScatterTouchData(
            enabled: true,
          ),
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Text(
                  DateTime.fromMillisecondsSinceEpoch(value.toInt())
                      .toString()
                      .split(' ')[1], // Display time
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Text(
                  value.toStringAsFixed(1) + unit,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(),
              bottom: BorderSide(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTwoDimensionalScatterPlot(
      List<ScatterSpot> points, Color color, String xUnit, String yUnit) {
    return SizedBox(
      height: 200,
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: points,
          scatterTouchData: ScatterTouchData(
            enabled: true,
          ),
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Text(
                  value.toStringAsFixed(1) + xUnit,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Text(
                  value.toStringAsFixed(1) + yUnit,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(),
              bottom: BorderSide(),
            ),
          ),
        ),
      ),
    );
  }
}
