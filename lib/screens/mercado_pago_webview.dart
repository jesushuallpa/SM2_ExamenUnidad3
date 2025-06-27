import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MercadoPagoWebView extends StatelessWidget {
  final String url;
  const MercadoPagoWebView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago con Mercado Pago')),
      body: WebViewWidget(
        controller:
            WebViewController()
              ..loadRequest(Uri.parse(url))
              ..setJavaScriptMode(JavaScriptMode.unrestricted),
      ),
    );
  }
}
