import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class HighChart extends StatefulWidget {
  const HighChart({
    Key? key,
    this.loader = const Center(child: CircularProgressIndicator()),
    required this.data,
    required this.size,
    this.scripts = const [],
    this.isMap = false,
  }) : super(key: key);

  const HighChart.map({
    Key? key,
    this.loader = const Center(child: CircularProgressIndicator()),
    required this.data,
    required this.size,
    this.scripts = const [],
  })  : isMap = true,
        super(key: key);

  final Widget loader;
  final String data;
  final Size size;
  final List<String> scripts;
  final bool isMap;

  @override
  _HighChartState createState() => _HighChartState();
}

class _HighChartState extends State<HighChart> {
  bool _isLoaded = false;

  late WebViewController _controller;

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    _controller = WebViewController.fromPlatformCreationParams(params);

    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
      AndroidWebViewController.enableDebugging(kDebugMode);
    }

    if (_controller.platform is WebKitWebViewController) {
      WebKitWebViewController webKitWebViewController = _controller.platform as WebKitWebViewController;
      webKitWebViewController.setInspectable(kDebugMode);
    }

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setBackgroundColor(Colors.transparent)
      ..loadHtmlString(_htmlContent())
      ..setNavigationDelegate(
        NavigationDelegate(onWebResourceError: (err) {
          debugPrint(err.toString());
        }, onPageFinished: ((url) {
          _loadData();
        }), onNavigationRequest: ((request) async {
          if (await canLaunchUrlString(request.url)) {
            try {
              launchUrlString(request.url);
            } catch (e) {
              debugPrint('High Chart Error ->$e');
            }
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        })),
      );
  }

  @override
  void didUpdateWidget(covariant HighChart oldWidget) {
    if (oldWidget.data != widget.data || oldWidget.size != widget.size || oldWidget.scripts != widget.scripts) {
      _controller.loadHtmlString(_htmlContent());
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size.height,
      width: widget.size.width,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          !_isLoaded ? widget.loader : const SizedBox.shrink(),
          WebViewWidget(controller: _controller),
        ],
      ),
    );
  }

  String _htmlContent() {
    String html = "";
    html +=
        '<!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=0"/> </head> <body><div style="height:100%;width:100%;" id="highChartsDiv"></div><script>function loadChart(a){ eval(a); return true;}</script>';
    for (String src in widget.scripts) {
      html += '<script async="false" src="$src"></script>';
    }
    html += '</body></html>';

    return html;
  }

  void _loadData() {
    if (mounted) {
      setState(() {
        _isLoaded = true;
      });
      if (widget.isMap) {
        _controller.runJavaScriptReturningResult("loadChart(`Highcharts.mapChart('highChartsDiv',${widget.data} )`);");
      } else {
        _controller.runJavaScriptReturningResult("loadChart(`Highcharts.chart('highChartsDiv',${widget.data} )`);");
      }
    }
  }
}
