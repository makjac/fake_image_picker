import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const FakeImagePickerDemoApp());
}

/// Demo application showing how [ImagePicker] is used together with
/// [fake_image_picker] in widget tests.
class FakeImagePickerDemoApp extends StatelessWidget {
  /// Creates the demo app.
  const FakeImagePickerDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fake_image_picker demo',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const DemoHomePage(),
    );
  }
}

/// Home page of the demo with buttons triggering every supported picker flow.
class DemoHomePage extends StatefulWidget {
  /// Creates the home page.
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  final ImagePicker _picker = ImagePicker();
  String _result = 'No media selected yet.';

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source);
      _setResult(image);
    } on Exception catch (e) {
      setState(() => _result = 'Error: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final video = await _picker.pickVideo(source: ImageSource.gallery);
      _setResult(video);
    } on Exception catch (e) {
      setState(() => _result = 'Error: $e');
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final images = await _picker.pickMultiImage();
      if (images.isEmpty) {
        setState(() => _result = 'User cancelled multi-image picker.');
      } else {
        setState(() {
          _result =
              'Picked ${images.length} images:\n'
              '${images.map((f) => '${f.name} (${f.mimeType})').join('\n')}';
        });
      }
    } on Exception catch (e) {
      setState(() => _result = 'Error: $e');
    }
  }

  void _setResult(XFile? file) {
    if (file == null) {
      setState(() => _result = 'User cancelled the picker.');
    } else {
      setState(() {
        _result =
            'Path: ${file.path}\n'
            'Name: ${file.name}\n'
            'Mime type: ${file.mimeType}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('fake_image_picker demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tap a button to simulate an image_picker flow. '
              'When this app is tested, fake_image_picker supplies the results.',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: const Text('Pick image from gallery'),
            ),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.camera),
              child: const Text('Take a photo'),
            ),
            ElevatedButton(
              onPressed: _pickVideo,
              child: const Text('Pick video from gallery'),
            ),
            ElevatedButton(
              onPressed: _pickMultipleImages,
              child: const Text('Pick multiple images'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Result:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_result),
          ],
        ),
      ),
    );
  }
}
