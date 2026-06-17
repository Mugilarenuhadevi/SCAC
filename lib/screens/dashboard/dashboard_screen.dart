import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/app_providers.dart';
import '../../models/air_quality_data.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reading = ref.watch(currentReadingProvider);
    final isNeutralizerActive = ref.watch(neutralizerActiveProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.getAqiColor(reading.aqi).withValues(alpha: 0.15),
              AppColors.backgroundDark,
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Air Quality',
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reading.location ?? 'Unknown Location',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      // Notification bell
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
              ),

              // AQI Hero Card
              SliverToBoxAdapter(
                child: _AqiHeroCard(reading: reading)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 100.ms)
                    .scale(begin: const Offset(0.95, 0.95)),
              ),

              // Neutralizer Control
              SliverToBoxAdapter(
                child: _NeutralizerControl(
                  isActive: isNeutralizerActive,
                  onToggle: () {
                    ref.read(neutralizerActiveProvider.notifier).state = !isNeutralizerActive;
                  },
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideX(begin: 0.1),
              ),

              // Sensor Grid
              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // History Trend Summary
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'History Trend',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.go('/history'),
                        child: Text(
                          'View All',
                          style: GoogleFonts.inter(color: AppColors.primary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _HistoryTrendSummaryList()
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 300.ms),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Analytics Summary
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Analytics Highlights',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _AnalyticsSummaryCard()
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 400.ms),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryTrendSummaryList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyDataAsync = ref.watch(historyDataProvider(6));
    
    return historyDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => const SizedBox(),
      data: (data) => SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: data.length > 6 ? 6 : data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final aqiColor = AppColors.getAqiColor(item.aqi);
            return GlassCard(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              padding: const EdgeInsets.all(12),
              borderRadius: 16,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('HH:mm').format(item.timestamp),
                    style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.aqi.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: aqiColor,
                    ),
                  ),
                  Text(
                    'AQI',
                    style: TextStyle(fontSize: 8, color: AppColors.textTertiary),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AnalyticsSummaryCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reading = ref.watch(currentReadingProvider);
    
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _PollutantMiniWidget(label: 'PM2.5', value: reading.pm25, unit: 'µg/m³', color: AppColors.accent),
              _PollutantMiniWidget(label: 'CO₂', value: reading.co2, unit: 'ppm', color: AppColors.primary),
              _PollutantMiniWidget(label: 'VOC', value: reading.voc * 1000, unit: 'ppb', color: AppColors.warning),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/analytics'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              foregroundColor: AppColors.primary,
              elevation: 0,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Detailed Analytics Overview'),
          ),
        ],
      ),
    );
  }
}

class _PollutantMiniWidget extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;

  const _PollutantMiniWidget({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(value < 10 ? 1 : 0),
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        Text(unit, style: TextStyle(fontSize: 9, color: AppColors.textTertiary)),
      ],
    );
  }
}

class _AqiHeroCard extends StatelessWidget {
  final AirQualityData reading;

  const _AqiHeroCard({required this.reading});

  @override
  Widget build(BuildContext context) {
    final aqiColor = AppColors.getAqiColor(reading.aqi);
    final dateFormatter = DateFormat('EEE, MMM dd, yyyy');
    final timeFormatter = DateFormat('hh:mm a');

    return AqiGlassCard(
      aqi: reading.aqi,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormatter.format(reading.timestamp),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    timeFormatter.format(reading.timestamp),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AQI',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reading.aqi}',
                    style: GoogleFonts.inter(
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      color: aqiColor,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: aqiColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppColors.getAqiLabel(reading.aqi),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: aqiColor,
                      ),
                    ),
                  ),
                ],
              ),
              // AQI circular gauge
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: _AqiGaugePainter(
                    value: reading.aqi / 300,
                    color: aqiColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // AQI scale bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(flex: 50, child: Container(color: AppColors.aqiGood)),
                  Expanded(flex: 50, child: Container(color: AppColors.aqiModerate)),
                  Expanded(flex: 50, child: Container(color: AppColors.aqiUnhealthySensitive)),
                  Expanded(flex: 50, child: Container(color: AppColors.aqiUnhealthy)),
                  Expanded(flex: 100, child: Container(color: AppColors.aqiVeryUnhealthy)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
              Text('100', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
              Text('200', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
              Text('300+', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AqiGaugePainter extends CustomPainter {
  final double value;
  final Color color;

  _AqiGaugePainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background arc
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 0.75,
      pi * 1.5,
      false,
      bgPaint,
    );

    // Value arc
    final valuePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = color
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 0.75,
      pi * 1.5 * value.clamp(0, 1),
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AqiGaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}

class _NeutralizerControl extends StatelessWidget {
  final bool isActive;
  final VoidCallback onToggle;

  const _NeutralizerControl({required this.isActive, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isActive ? AppColors.primary : AppColors.textTertiary).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.air,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Air Neutralizer',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isActive ? 'Active — cleaning air' : 'Tap to activate',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isActive ? AppColors.primary : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: (_) => onToggle(),
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textTertiary,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }
}

