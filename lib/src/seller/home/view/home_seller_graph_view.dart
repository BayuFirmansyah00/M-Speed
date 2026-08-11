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
  // M-SPEED Brand Colors
  static const Color _primaryBlue = Color(0xFF1565C0);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SellerHomeProvider>();
    final graph = p.homeSellerModel?.data?.chartPenjualan ?? [];

    // Check if data is empty or all zeros
    final bool hasData = graph.isNotEmpty && graph.any((v) => (v ?? 0) > 0);

    if (!hasData) {
      return _buildEmptyState();
    }

    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(
          right: 12,
          left: 4,
          top: 16,
          bottom: 8,
        ),
        child: LineChart(_buildMainData(p, graph)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 160,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 40,
              color: _textSecondary.withOpacity(0.4),
            ),
            const SizedBox(height: 8),
            const Text(
              'Belum ada data penjualan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Data akan muncul setelah transaksi tersedia',
              style: TextStyle(
                fontSize: 12,
                color: _textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 11,
      color: _textSecondary,
      fontWeight: FontWeight.w500,
    );
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final idx = value.toInt();
    final text = (idx >= 0 && idx < months.length) ? months[idx] : '';

    return SideTitleWidget(
      meta: meta,
      child: Text(text, style: style),
    );
  }

  LineChartData _buildMainData(SellerHomeProvider p, List<int?> graph) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        drawHorizontalLine: true,
        horizontalInterval: (p.biggestGraphVal > 0) ? (p.biggestGraphVal / 4).ceilToDouble().clamp(1, double.infinity) : 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: _border.withOpacity(0.5),
            strokeWidth: 0.8,
            dashArray: [4, 4],
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
            reservedSize: 28,
            interval: 1,
            getTitlesWidget: _bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: (p.biggestGraphVal > 0) ? (p.biggestGraphVal / 4).ceilToDouble().clamp(1, double.infinity) : 1,
            reservedSize: 36,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10, color: _textSecondary),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (graph.length - 1).toDouble().clamp(0, 11),
      minY: 0,
      maxY: p.biggestGraphVal.toDouble().clamp(1, double.infinity),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(graph.length,
              (i) => FlSpot(i.toDouble(), (graph[i] ?? 0).toDouble())),
          isCurved: true,
          color: _primaryBlue,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: _primaryBlue,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: _primaryBlue.withOpacity(0.08),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => _primaryBlue,
          tooltipBorderRadius: BorderRadius.circular(8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toInt()}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
