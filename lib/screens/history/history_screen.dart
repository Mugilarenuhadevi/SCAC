import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/app_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final historyDataAsync = ref.watch(historyDataProvider(24));
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final timeFormatter = DateFormat('HH:mm');

    return Scaffold(
      body: Container(
        color: AppColors.backgroundDark,
        child: SafeArea(
          child: historyDataAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.orange, size: 48),
                    const SizedBox(height: 16),
                    Text('Could not load data: $err',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            data: (historyData) {
              if (historyData.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history, color: Colors.grey, size: 64),
                        const SizedBox(height: 16),
                        Text('No records found in Firebase',
                            style: GoogleFonts.inter(
                                fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        Text(
                          'Check that your data is stored at:\nAirQuality/history',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'History',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms),

                // Date Picker Card
                GlassCard(
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dateFormatter.format(selectedDate),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppColors.primary,
                                    surface: AppColors.surfaceDark,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            ref.read(selectedDateProvider.notifier).state = picked;
                          }
                        },
                        child: Text(
                          'Change',
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                // Summary stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _StatCard(
                        label: 'Avg AQI',
                        value: _calculateAvg(historyData.map((d) => d.aqi.toDouble()).toList()),
                        color: AppColors.primary,
                      ),
                      _StatCard(
                        label: 'Max AQI',
                        value: historyData.isEmpty ? '0' : historyData.map((d) => d.aqi).reduce((a, b) => a > b ? a : b).toString(),
                        color: AppColors.warning,
                      ),
                      _StatCard(
                        label: 'Min AQI',
                        value: historyData.isEmpty ? '0' : historyData.map((d) => d.aqi).reduce((a, b) => a < b ? a : b).toString(),
                        color: AppColors.success,
                      ),
                    ].map((card) => Expanded(child: card)).toList(),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                const SizedBox(height: 8),

                // Records label
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text(
                    'Records (${historyData.length})',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                // Scrollable list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: historyData.length,
                    itemBuilder: (context, index) {
                      final data = historyData[index];
                      final aqiColor = AppColors.getAqiColor(data.aqi);
                      return GlassCard(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: aqiColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${data.aqi}',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: aqiColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    timeFormatter.format(data.timestamp),
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'PM2.5: ${data.pm25.toStringAsFixed(1)} | CO₂: ${data.co2.toStringAsFixed(0)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: aqiColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                AppColors.getAqiLabel(data.aqi).length > 10
                                    ? AppColors.getAqiLabel(data.aqi).split(' ').first
                                    : AppColors.getAqiLabel(data.aqi),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: aqiColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: (50 * (index % 10)).ms);
                    },
                  ),
                ),
               ],
             );
            },
          ),
        ),
      ),
    );
  }

  String _calculateAvg(List<double> values) {
    if (values.isEmpty) return '0';
    return (values.reduce((a, b) => a + b) / values.length).toStringAsFixed(0);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
