import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HTMLPage extends StatefulWidget {
  const HTMLPage({Key? key, required this.file}) : super(key: key);
  final String file;

  @override
  State<HTMLPage> createState() => _HTMLPageState();
}

class _HTMLPageState extends State<HTMLPage> {
  WebViewController? _webViewController;

  void initState() {
    _webViewController = WebViewController()
      ..loadRequest(Uri.parse(widget.file))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: WebViewWidget(controller: _webViewController!),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(150, 40),
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: Colors.blue.shade800),
                  padding: EdgeInsets.symmetric(vertical: 5),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
                child: Text('문서 닫기'),
              )
            ),
          ],
        )
    );
  }
}
