import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/app_providers.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyDataAsync = ref.watch(historyDataProvider(24));

    return Scaffold(
      body: Container(
        color: AppColors.backgroundDark,
        child: SafeArea(
          child: historyDataAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading analytics: $err')),
            data: (historyData) {
              if (historyData.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.analytics_outlined, color: Colors.grey, size: 64),
                        const SizedBox(height: 16),
                        Text('No analytics data available',
                            style: GoogleFonts.inter(
                                fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        Text(
                          'Once sensor data is received in Firebase,\ntrends will appear here.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(
                        'Analytics',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                  ),

              // AQI Trend Line Chart
              SliverToBoxAdapter(
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AQI Trend (24h)',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 50,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.white.withValues(alpha: 0.05),
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 35,
                                  getTitlesWidget: (value, meta) => Text(
                                    '${value.toInt()}',
                                    style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: (historyData.length / 6).ceilToDouble(),
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= historyData.length) return const SizedBox();
                                    final hour = historyData[value.toInt()].timestamp.hour;
                                    return Text(
                                      '${hour}h',
                                      style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: historyData.asMap().entries.map((e) =>
                                    FlSpot(e.key.toDouble(), e.value.aqi.toDouble())).toList(),
                                isCurved: true,
                                color: AppColors.primary,
                                barWidth: 2.5,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.primary.withValues(alpha: 0.3),
                                      AppColors.primary.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            minY: 0,
                            maxY: 200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
              ),

              // PM2.5 & CO2 Bar Chart
              SliverToBoxAdapter(
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pollutant Levels',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'PM2.5 vs Temperature correlation',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: BarChart(
                          BarChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 20,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.white.withValues(alpha: 0.05),
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 35,
                                  getTitlesWidget: (value, meta) => Text(
                                    '${value.toInt()}',
                                    style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                    if (value.toInt() >= labels.length) return const SizedBox();
                                    return Text(
                                      labels[value.toInt()],
                                      style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(7, (i) {
                              final pm25 = 15.0 + (i * 5 % 30) + 5;
                              final temp = 20.0 + (i * 3 % 10);
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: pm25,
                                    color: AppColors.accent,
                                    width: 10,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  ),
                                  BarChartRodData(
                                    toY: temp,
                                    color: AppColors.primary,
                                    width: 10,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ChartLegend(color: AppColors.accent, label: 'PM2.5 (µg/m³)'),
                          const SizedBox(width: 20),
                          _ChartLegend(color: AppColors.primary, label: 'Temp (°C)'),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
              ),

              // Weather vs Pollution
              SliverToBoxAdapter(
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weather vs Pollution',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.white.withValues(alpha: 0.05),
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 35,
                                  getTitlesWidget: (value, meta) => Text(
                                    '${value.toInt()}',
                                    style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 4,
                                  getTitlesWidget: (value, meta) => Text(
                                    '${value.toInt()}h',
                                    style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                                  ),
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              // Humidity
                              LineChartBarData(
                                spots: List.generate(24, (i) =>
                                    FlSpot(i.toDouble(), 45 + 15 * (i % 6 / 3) + (i.isEven ? 3 : -2))),
                                isCurved: true,
                                color: AppColors.info,
                                barWidth: 2,
                                dotData: const FlDotData(show: false),
                              ),
                              // AQI normalized
                              LineChartBarData(
                                spots: List.generate(24, (i) =>
                                    FlSpot(i.toDouble(), 30 + 20 * (i % 8 / 4) + (i.isOdd ? 5 : -3))),
                                isCurved: true,
                                color: AppColors.warning,
                                barWidth: 2,
                                dotData: const FlDotData(show: false),
                                dashArray: [5, 3],
                              ),
                            ],
                            minY: 0,
                            maxY: 80,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ChartLegend(color: AppColors.info, label: 'Humidity (%)'),
                          const SizedBox(width: 20),
                          _ChartLegend(color: AppColors.warning, label: 'AQI Index'),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
              ),

                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 3, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
