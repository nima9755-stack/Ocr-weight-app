import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const OCRWeightApp());
}

class OCRWeightApp extends StatelessWidget {
  const OCRWeightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OCR Weight Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const OCRHomePage(),
    );
  }
}

class OCRHomePage extends StatefulWidget {
  const OCRHomePage({super.key});

  @override
  State<OCRHomePage> createState() => _OCRHomePageState();
}

class _OCRHomePageState extends State<OCRHomePage> {
  final ImagePicker _picker = ImagePicker();
  final List<double> _weights = [];

  double get totalWeight =>
      _weights.fold(0, (previous, current) => previous + current);

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final inputImage = InputImage.fromFile(File(pickedFile.path));
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      double? number;
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final text = line.text.replaceAll(",", "."); // اعداد اعشاری
          final parsed = double.tryParse(text);
          if (parsed != null) {
            number = parsed;
            break;
          }
        }
      }

      textRecognizer.close();

      if (number != null) {
        setState(() {
          _weights.add(number!);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("عدد خوانده نشد")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OCR Weight Calculator")),
      body: Padding(
        padding: const EdgeInsets
