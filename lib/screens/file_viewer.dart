import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FileViewer extends StatelessWidget {
  final String fileUrl;
  const FileViewer({super.key, required this.fileUrl});

  Future<void> _openFile() async {
    final uri = Uri.parse(fileUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Không mở được file: $fileUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xem tài liệu')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.open_in_new),
          onPressed: _openFile,
          label: const Text('Mở file'),
        ),
      ),
    );
  }
}
