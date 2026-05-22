import 'package:flutter/material.dart';

class InvoiceDocumentViewer extends StatelessWidget {
  final String url;

  const InvoiceDocumentViewer({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document')),
      body: Center(
        child: Text('Document viewer placeholder: $url'),
      ),
    );
  }
}

