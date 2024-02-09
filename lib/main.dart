import 'package:charts_test/high_chart.dart';
import 'package:charts_test/maps_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ExampleChart());
  }
}

class ExampleChart extends StatefulWidget {
  const ExampleChart({Key? key}) : super(key: key);

  @override
  _ExampleChartState createState() => _ExampleChartState();
}

class _ExampleChartState extends State<ExampleChart> {
  Map<String, dynamic> _topology = {};
  var _isLoading = false;

  Future<void> _fetchTopology() async {
    setState(() {
      _isLoading = true;
    });
    final response = await Dio().get(
      'https://code.highcharts.com/mapdata/custom/europe.topo.json',
    );

    setState(() {
      _isLoading = false;
      _topology = response.data;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTopology();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('High Charts Example App'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HighChart(
              loader: SizedBox(
                width: 200,
                child: LinearProgressIndicator(),
              ),
              size: Size(400, 400),
              data: chartData,
              scripts: [
                "https://code.highcharts.com/highcharts.js",
                'https://code.highcharts.com/modules/networkgraph.js',
                'https://code.highcharts.com/modules/exporting.js',
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            const HighChart(
              loader: SizedBox(
                width: 200,
                child: LinearProgressIndicator(),
              ),
              size: Size(400, 400),
              data: solarEmploymentGroth,
              scripts: [
                "https://code.highcharts.com/highcharts.js",
                'https://code.highcharts.com/modules/networkgraph.js',
                'https://code.highcharts.com/modules/exporting.js',
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            const HighChart(
              loader: SizedBox(
                width: 200,
                child: LinearProgressIndicator(),
              ),
              size: Size(400, 400),
              data: supplyAndDemandData,
              scripts: [
                "https://code.highcharts.com/highcharts.js",
                'https://code.highcharts.com/modules/networkgraph.js',
                'https://code.highcharts.com/modules/exporting.js',
                'https://code.highcharts.com/modules/export-data.js',
                'https://code.highcharts.com/modules/accessibility.js',
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            const HighChart(
              loader: SizedBox(
                width: 200,
                child: LinearProgressIndicator(),
              ),
              size: Size(400, 400),
              data: bubbleChart,
              scripts: [
                'https://code.highcharts.com/highcharts.js',
                'https://code.highcharts.com/highcharts-more.js',
                'https://code.highcharts.com/modules/exporting.js',
                'https://code.highcharts.com/modules/export-data.js',
                'https://code.highcharts.com/modules/accessibility.js',
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            if (!_isLoading) ...{
              HighChart.map(
                loader: const SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(),
                ),
                size: const Size(400, 400),
                data: mapExample2(_topology),
                scripts: const [
                  'https://code.highcharts.com/maps/highmaps.js',
                ],
              ),
            },
            const SizedBox(
              height: 12,
            ),
            const HighChart.map(
              loader: SizedBox(
                width: 200,
                child: LinearProgressIndicator(),
              ),
              size: Size(800, 800),
              data: mapExampleData,
              scripts: [
                'https://code.highcharts.com/maps/highmaps.js',
              ],
            ),
          ],
        ),
      ),
    );
  }
}
