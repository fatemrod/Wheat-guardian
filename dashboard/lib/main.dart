import 'package:dashboard/table_screen.dart';
import 'package:flutter/material.dart';
import 'data_visualizing.dart';
import 'graph_screens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sensor Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const IntroScreen(),
    );
  }
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(5, 82, 16, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconButton(
              context,
              icon: Icons.bar_chart,
              label: 'Graphs',
              color: Colors.indigo,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SensorScatterPlotPage()),
              ),
            ),
            const SizedBox(height: 20),
            _buildIconButton(
              context,
              icon: Icons.table_chart,
              label: 'Tables',
              color: Colors.teal,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TablesScreen()),
              ),
            ),
            const SizedBox(height: 20),
            _buildIconButton(
              context,
              icon: Icons.live_tv,
              label: 'Real-Time Visualization',
              color: Colors.deepOrange,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SensorDataScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context,
      {required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 10,
      ),
      icon: Icon(icon, size: 30),
      label: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      onPressed: onPressed,
    );
  }
}