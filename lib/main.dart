import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OCR Weight Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const OCRCalculatorPage(),
    );
  }
}

class OCRCalculatorPage extends StatefulWidget {
  const OCRCalculatorPage({super.key});

  @override
  State<OCRCalculatorPage> createState() => _OCRCalculatorPageState();
}

class _OCRCalculatorPageState extends State<OCRCalculatorPage> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final List<double> _weights = [];

  double get totalWeight =>
      _weights.fold(0, (previous, element) => previous + element);

  Future<void> _scanImage() async {
    // این قسمت باید بعداً به دوربین وصل بشه
    // فعلاً یک مقدار تستی اضافه می‌کنیم
    setState(() {
      _weights.add(12.34); // تست
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OCR Weight Calculator")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _weights.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("وزن ${index + 1}: ${_weights[index]} کیلو"),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              "جمع کل: $totalWeight کیلو",
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanImage,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
