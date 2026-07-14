import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/seller/home/provider/seller_home_provider.dart';
import 'package:provider/provider.dart';

class HomeSellerGraphView extends StatefulWidget {
  const HomeSellerGraphView({super.key});

  @override
  State<HomeSellerGraphView> createState() => _HomeSellerGraphViewState();
}

class _HomeSellerGraphViewState extends State<HomeSellerGraphView> {
  bool showAvg = false;
  List<Color> gradientColors = [
    Color(0xff05C283),
    Color(0xff05C283),
  ];
  @override
  Widget build(BuildContext context) {
    final p = context.watch<SellerHomeProvider>();
    final graph = p.homeSellerModel?.data?.chartPenjualan ?? [];
    Widget bottomTitleWidgets(double value, TitleMeta meta) {
      const style = TextStyle(fontSize: 12);
      Widget text;
      switch (value.toInt()) {
        case 0:
          text = const Text('Jan', style: style);
          break;
        case 1:
          text = const Text('Feb', style: style);
          break;
        case 2:
          text = const Text('Mar', style: style);
          break;
        case 3:
          text = const Text('Apr', style: style);
          break;
        case 4:
          text = const Text('Mei', style: style);
          break;
        case 5:
          text = const Text('Jun', style: style);
          break;
        case 6:
          text = const Text('Jul', style: style);
          break;
        case 7:
          text = const Text('Agu', style: style);
          break;
        case 8:
          text = const Text('Sep', style: style);
          break;
        case 9:
          text = const Text('Okt', style: style);
          break;
        case 10:
          text = const Text('Nov', style: style);
          break;
        case 11:
          text = const Text('Des', style: style);
          break;
        default:
          text = const Text('', style: style);
          break;
      }

      return SideTitleWidget(
        meta: meta,
        child: text,
      );
    }

    Widget leftTitleWidgets(double value, TitleMeta meta) {
      const style = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      );
      String text;
      switch (value.toInt()) {
        case 1:
          text = '10K';
          break;
        case 3:
          text = '30k';
          break;
        case 5:
          text = '50k';
          break;
        default:
          return Container();
      }

      return Text(text, style: style, textAlign: TextAlign.left);
    }

    LineChartData mainData() {
      return LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Color(0xffF58B2B),
              strokeWidth: 0,
            );
          },
          getDrawingVerticalLine: (value) {
            return const FlLine(
              color: Color(0xffF58B2B),
              strokeWidth: 0,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              interval: 1,
              getTitlesWidget: leftTitleWidgets,
              reservedSize: 0,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
          border: Border.all(color: const Color(0xff37434d)),
        ),
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: p.biggestGraphVal.toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(graph.length,
                (i) => FlSpot(i.toDouble(), (graph[i] ?? 0).toDouble())),
            isCurved: true,
            color: Color(0xffF58B2B),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xffFF99005).withOpacity(0.32),
                  Color(0xffFF7A000).withOpacity(0.01),
                ],
              ),
            ),
          ),
          // LineChartBarData(
          //   spots: const [
          //     FlSpot(0, 1),
          //     FlSpot(2.6, 0),
          //     FlSpot(4.9, 3),
          //     FlSpot(6.8, 1.1),
          //     FlSpot(8, 2),
          //     FlSpot(9.5, 1),
          //     FlSpot(11, 2),
          //   ],
          //   isCurved: true,
          //   color: Color(0xffF58B2B),
          //   barWidth: 2.5,
          //   isStrokeCapRound: true,
          //   dotData: FlDotData(show: true),
          //   belowBarData: BarAreaData(
          //     show: true,
          //     gradient: LinearGradient(
          //       begin: Alignment.topCenter,
          //       end: Alignment.bottomCenter,
          //       colors: [
          //         Color(0xffFF99005).withOpacity(0.32),
          //         Color(0xffFF7A000).withOpacity(0.01),
          //       ],
          //     ),
          //   ),
          // )
        ],
      );
    }

    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(mainData()),
          ),
        ),
        SizedBox(
          width: 60,
          height: 34,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'avg',
              style: TextStyle(
                fontSize: 12,
                color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
