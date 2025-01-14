import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this for TextInputFormatter
import 'package:audioplayers/audioplayers.dart'; // For alarm sound

class SensorDataScreen extends StatefulWidget {
  const SensorDataScreen({super.key});

  @override
  State<SensorDataScreen> createState() => _SensorDataScreenState();
}

class _SensorDataScreenState extends State<SensorDataScreen> {
  late DatabaseReference _testRefSmoke;
  late DatabaseReference _testRefHumidity;
  late DatabaseReference _testRefTemp;

  dynamic smoke = 0;
  dynamic humidity = 0;
  dynamic temp = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // Set up Firebase Realtime Database listeners
    _testRefSmoke = FirebaseDatabase.instance.reference().child("air/smoke");
    _testRefSmoke.onValue.listen((event) {
      setState(() {
        smoke = event.snapshot.value as dynamic;
      });
      _checkThresholds();
    });

    _testRefHumidity =
        FirebaseDatabase.instance.reference().child("dht/humidity");
    _testRefHumidity.onValue.listen((event) {
      setState(() {
        humidity = event.snapshot.value as dynamic;
      });
      _checkThresholds();
    });

    _testRefTemp = FirebaseDatabase.instance.reference().child("dht/temp");
    _testRefTemp.onValue.listen((event) {
      setState(() {
        temp = event.snapshot.value as dynamic;
      });
      _checkThresholds();
    });
  }

  void _checkThresholds() {
    if (temp > 17 || humidity > 60 || smoke > 400) {
      _showAlert();
    }
  }

  Future<void> _showAlert() async {
    _audioPlayer.play(AssetSource('alarm.mp3')); // Play alarm sound
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Threshold Exceeded'),
        content: Text(
          'The following thresholds have been exceeded:\n' +
              (temp > 17 ? 'Temperature: $temp °C (Threshold: 17 °C)\n' : '') +
              (humidity > 60 ? 'Humidity: $humidity% (Threshold: 60%)\n' : '') +
              (smoke > 400 ? 'CO2: $smoke ppm (Threshold: 400 ppm)\n' : ''),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _audioPlayer.stop(); // Stop alarm sound
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Visualizing"),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(48, 105, 54, 1),
      ),
      backgroundColor: Color.fromRGBO(48, 105, 54, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Smoke Circular Progress Indicator
            _buildCircularProgressIndicator(
              label: "CO2. Conc",
              value: smoke.toDouble(),
              maxValue: 5000,
              // Max smoke value (adjust based on expected range)
              unit: "ppm",
              // Parts per million
              thresholds: [400],
              colors: [Colors.green, Colors.orange, Colors.red],
            ),
            const SizedBox(height: 30),

            // Humidity Circular Progress Indicator
            _buildCircularProgressIndicator(
              label: "Humidity",
              value: humidity.toDouble(),
              maxValue: 100,
              // Max humidity percentage (0-100%)
              unit: "%",
              thresholds: [60],
              colors: [Colors.green, Colors.orange, Colors.red],
            ),
            const SizedBox(height: 30),

            // Temperature Circular Progress Indicator
            _buildCircularProgressIndicator(
              label: "Temperature",
              value: temp.toDouble(),
              maxValue: 50,
              // Max temperature value (example, adjust based on range)
              unit: "°C",
              thresholds: [17],
              colors: [Colors.green, Colors.orange, Colors.red],
            ),
          ],
        ),
      ),
    );
  }

  // Circular Progress Indicator widget
  Widget _buildCircularProgressIndicator({
    required String label,
    required double value,
    required double maxValue,
    required String unit,
    required List<int> thresholds,
    required List<Color> colors,
  }) {
    Color getColor(double value) {
      if (value <= thresholds[0]) {
        return colors[0];
      } else if (value > thresholds[0] && value <= thresholds[0] * 1.5) {
        return colors[1];
      } else {
        return colors[2];
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          value: value / maxValue, // Normalize the value between 0 and 1
          strokeWidth: 8.0,
          valueColor: AlwaysStoppedAnimation<Color>(getColor(value)),
        ),
        const SizedBox(height: 10),
        Text(
          "$label: ${value.toStringAsFixed(3)} $unit",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
