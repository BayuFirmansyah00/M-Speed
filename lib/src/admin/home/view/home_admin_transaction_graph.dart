import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/admin/home/provider/admin_home_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class HomeAdminTransactionGraph extends StatefulWidget {
  @override
  State<HomeAdminTransactionGraph> createState() =>
      _HomeAdminTransactionGraphState();
}

class _HomeAdminTransactionGraphState extends State<HomeAdminTransactionGraph> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminHomeProvider>();
    final graph = p.homeAdminModel.data?.transaksi ?? [];
    final label = p.homeAdminModel.data?.transaksiLabel ?? [];
    final nominal = p.homeAdminModel.data?.transaksiNominal ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Text(
            'Trend Transaksi',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xffB0BAC9),
            ),
          ),
        ),
        SizedBox(
          height: 240,
          child: BarChart(
            BarChartData(
              barTouchData: BarTouchData(
                enabled: true,
                touchCallback: (event, response) {
                  if (response != null &&
                      response.spot != null &&
                      event is FlTapUpEvent) {
                    setState(() {
                      _touchedIndex = response.spot!.touchedBarGroupIndex;
                    });
                  } else if (event is FlTapUpEvent) {
                    setState(() => _touchedIndex = null);
                  }
                },
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => const Color(0xff1A1A2E),
                  tooltipPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  tooltipMargin: 6,
                  getTooltipItem: (
                    BarChartGroupData group,
                    int groupIndex,
                    BarChartRodData rod,
                    int rodIndex,
                  ) {
                    return BarTooltipItem(
                      '${rod.toY.round()} trx\n',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                      children: [
                        TextSpan(
                          text: Utils.thousandSeparator(
                              nominal[groupIndex] ?? 0),
                          style: const TextStyle(
                            color: Color(0xff4ADE80),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              barGroups: List.generate(
                graph.length,
                (i) {
                  final isTouched = i == _touchedIndex;
                  return BarChartGroupData(
                    x: i,
                    showingTooltipIndicators: isTouched ? [0] : [],
                    barRods: [
                      BarChartRodData(
                        toY: (graph[i] ?? 0).toDouble(),
                        fromY: 0,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isTouched
                              ? [
                                  const Color(0xff4ADE80),
                                  const Color(0xff1ABC62),
                                ]
                              : [
                                  const Color(0xff6EE7A7),
                                  const Color(0xff1ABC62),
                                ],
                        ),
                        width: 22,
                      ),
                    ],
                  );
                },
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 34,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      return Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: SizedBox(
                          width: 38,
                          child: Text(
                            idx < label.length ? (label[idx] ?? '') : '',
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                              color: Color(0xffB0BAC9),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: Color(0xffB0BAC9),
                      ),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              minY: 0,
              maxY: p.biggestTransactionGraphVal.toDouble() + 30,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: const Color(0xffF0F2F5),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}