import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'وزن‌خوان (OCR)',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const OcrSumPage(),
    );
  }
}

class OcrSumPage extends StatefulWidget {
  const OcrSumPage({super.key});
  @override
  State<OcrSumPage> createState() => _OcrSumPageState();
}

class _OcrSumPageState extends State<OcrSumPage> {
  final _picker = ImagePicker();
  final _recognizer = TextRecognizer();
  final List<double> _weights = [];

  double get _total => _weights.fold(0.0, (p, e) => p + e);

  Future<void> _scan() async {
    try {
      final XFile? shot = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (shot == null) return;

      final input = InputImage.fromFilePath(shot.path);
      final result = await _recognizer.processImage(input);

      final fullText = result.text;

      // همه اعداد (صحیح یا اعشاری) رو پیدا می‌کنه
      final regex = RegExp(r'(?:(?<!\d)-)?\d+(?:[.,]\d+)?');
      final matches = regex
          .allMatches(fullText)
          .map((m) => m.group(0)!)
          .map((s) => s.replaceAll(',', '.'))
          .map((s) => double.tryParse(s))
          .whereType<double>()
          .toList();

      if (matches.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('عدد واضحی پیدا نشد. دوباره امتحان کن.')),
        );
        return;
      }

      setState(() {
        _weights.addAll(matches);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا: $e')),
      );
    }
  }

  void _removeAt(int i) {
    setState(() => _weights.removeAt(i));
  }

  void _addManual() async {
    final c = TextEditingController();
    final v = await showDialog<double?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('افزودن دستی وزن'),
        content: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: 'مثلاً 18.57'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('انصراف')),
          TextButton(
            onPressed: () {
              final s = c.text.trim().replaceAll(',', '.');
              Navigator.pop(ctx, double.tryParse(s));
            },
            child: const Text('اضافه کن'),
          ),
        ],
      ),
    );
    if (v != null) setState(() => _weights.add(v));
  }

  @override
  void dispose() {
    _recognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('وزن‌خوان (OCR)')),
      body: Column(
        children: [
          Expanded(
            child: _weights.isEmpty
                ? const Center(child: Text('هنوز عددی اضافه نشده'))
                : ListView.separated(
                    itemCount: _weights.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) => ListTile(
                      leading: CircleAvatar(child: Text('${i + 1}')),
                      title: Text('${_weights[i]} کیلو'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _removeAt(i),
                      ),
                    ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'جمع کل: ${_total.toStringAsFixed(2)} کیلو',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _addManual,
                  icon: const Icon(Icons.add),
                  label: const Text('دستی'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _scan,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('اسکن'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
