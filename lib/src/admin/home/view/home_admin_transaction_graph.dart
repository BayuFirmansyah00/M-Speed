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
  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminHomeProvider>();
    final graph = p.homeAdminModel.data?.transaksi ?? [];
    final label = p.homeAdminModel.data?.transaksiLabel ?? [];
    final nominal = p.homeAdminModel.data?.transaksiNominal ?? [];
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: SizedBox(
        height: 250,
        child: BarChart(
          BarChartData(
            barTouchData: BarTouchData(
              enabled: false,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => Colors.transparent,
                tooltipPadding: EdgeInsets.zero,
                tooltipMargin: 4,
                getTooltipItem: (
                  BarChartGroupData group,
                  int groupIndex,
                  BarChartRodData rod,
                  int rodIndex,
                ) {
                  return BarTooltipItem(
                    '${rod.toY.round()};\n${Utils.thousandSeparator(nominal[groupIndex] ?? 0)}',
                    TextStyle(color: Constant.greenColor, fontSize: 8),
                  );
                },
              ),
            ),
            barGroups: List.generate(
              graph.length,
              (i) => BarChartGroupData(
                x: i,
                showingTooltipIndicators: [0],
                barRods: [
                  BarChartRodData(
                    toY: (graph[i] ?? 0).toDouble(),
                    fromY: 0,
                    borderRadius: BorderRadius.circular(2),
                    color: Constant.greenColor,
                    width: 30,
                  ),
                ],
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40, // Adjust if necessary
                  getTitlesWidget: (value, meta) {
                    return Column(
                      children: [
                        Constant.xSizedBox4,
                        Flexible(
                          child: SizedBox(
                            width: 40,
                            child: Text(
                              label[value.toInt()] ?? '',
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 8, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 18, // Adjust if necessary
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 0, // Adjust if necessary
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '',
                      style: TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 0, // Adjust if necessary
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '',
                      style: TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            minY: 0,
            maxY: p.biggestTransactionGraphVal.toDouble() + 30,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Constant.textHintColor,
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(
              show: false,
              border: Border.all(color: Colors.black, width: 1),
            ),
          ),
        ),
      ),
    );
  }
}
