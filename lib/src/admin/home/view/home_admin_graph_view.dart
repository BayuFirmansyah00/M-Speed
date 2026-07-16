import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/home/provider/admin_home_provider.dart';
import 'package:provider/provider.dart';

class HomeAdminGraphView extends StatefulWidget {
  const HomeAdminGraphView({super.key});

  @override
  State<HomeAdminGraphView> createState() => _HomeAdminGraphViewState();
}

class _HomeAdminGraphViewState extends State<HomeAdminGraphView> {
  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminHomeProvider>();
    final graph = p.homeAdminModel.data?.pembelian ?? [];

    Widget bottomTitleWidgets(double value, TitleMeta meta) {
      const style = TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w500,
        color: Color(0xffB0BAC9),
      );
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final idx = value.toInt();
      return SideTitleWidget(
        meta: meta,
        space: 2,
        child: Text(idx >= 0 && idx < 12 ? months[idx] : '', style: style),
      );
    }

    LineChartData mainData() {
      final maxY = p.biggestGraphVal.toDouble();
      return LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xffF0F2F5),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: 1,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false, reservedSize: 0),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: maxY,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xff1A1A2E),
            getTooltipItems: (spots) => spots
                .map((spot) => LineTooltipItem(
                      '${spot.y.toInt()} pcs',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ))
                .toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              graph.length,
              (i) => FlSpot(i.toDouble(), (graph[i] ?? 0).toDouble()),
            ),
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xffF58B2B),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 3.5,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: const Color(0xffF58B2B),
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xffFF9900).withOpacity(0.18),
                  const Color(0xffFF7A00).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Trend Pembelian',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xffB0BAC9),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => showAvg = !showAvg),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: showAvg
                      ? Constant.primaryColor.withOpacity(0.12)
                      : const Color(0xffF5F6FA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: showAvg
                        ? Constant.primaryColor.withOpacity(0.35)
                        : const Color(0xffE4E6EF),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Rata-rata',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: showAvg ? Constant.primaryColor : const Color(0xff8A93A3),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 4),
            child: LineChart(mainData()),
          ),
        ),
      ],
    );
  }
}