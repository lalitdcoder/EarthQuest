// lib/screens/simulator_screen.dart
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/action_toggle.dart';
import '../models/earth_metrics.dart';
import '../providers/earth_state_notifier.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/planet_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class SimulatorScreen extends ConsumerStatefulWidget {
  const SimulatorScreen({super.key});

  @override
  ConsumerState<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends ConsumerState<SimulatorScreen>
    with TickerProviderStateMixin {

  // ── Planet animation controllers ─────────────────────────────────────────
  late final AnimationController _orbitCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;
  late final AnimationController _autoRotateCtrl;
  double _dragRotation = 0.0;
  double get _totalRotation =>
      _autoRotateCtrl.value * 2 * 3.14159265 + _dragRotation;

  // ── Action panel sheet controller ────────────────────────────────────────
  late final DraggableScrollableController _sheetCtrl;

  @override
  void initState() {
    super.initState();

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _autoRotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _sheetCtrl = DraggableScrollableController();
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _pulseCtrl.dispose();
    _autoRotateCtrl.dispose();
    _sheetCtrl.dispose();
    super.dispose();
  }

  // ── Drag ─────────────────────────────────────────────────────────────────

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final delta = details.delta.dx / screenWidth * 2 * 3.14159265 * 1.5;
    setState(() => _dragRotation += delta);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size    = MediaQuery.of(context).size;
    final topPad  = MediaQuery.of(context).padding.top;
    // Planet occupies 55% of screen width
    final planetSize = size.width * 0.55;

    // Watch only the metrics so stat cards rebuild independently
    final metrics = ref.watch(earthStateProvider.select((s) => s.metrics));
    final activeIds = ref.watch(
      earthStateProvider.select((s) => s.activeActionIds),
    );

    return Scaffold(
      backgroundColor: AppColors.heroDeep,
      body: Stack(
        children: [
          // ── Star-field background ────────────────────────────
          const _StarField(),

          // ── Draggable planet + header ─────────────────────
          GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            child: SizedBox.expand(
              child: Column(
                children: [
                  SizedBox(height: topPad + 56),

                  // Title row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Planet Simulator',
                          style: AppTextStyles.display.copyWith(fontSize: 22),
                        ),
                        if (activeIds.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _ActiveBadge(count: activeIds.length),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Drag to rotate · Toggle actions below',
                    style: AppTextStyles.heroSub,
                  ),
                  const SizedBox(height: 32),

                  // Planet
                  AnimatedBuilder(
                    animation: Listenable.merge([_autoRotateCtrl, _pulseCtrl]),
                    builder: (_, __) => PlanetWidget(
                      size: planetSize,
                      orbitCtrl: _orbitCtrl,
                      pulse: _pulse,
                      rotationAngle: _totalRotation,
                      healthScore: metrics.healthScore,
                    ),
                  ),

                  const SizedBox(height: 16),
                  _DragHintChip(),
                ],
              ),
            ),
          ),

          // ── Stat cards (reads live Riverpod metrics) ─────────
          Positioned(
            left: 0,
            right: 0,
            // Float above the sheet's min extent (28% of screen = 0.28)
            bottom: size.height * 0.28 + 8,
            child: _StatCardsRow(metrics: metrics),
          ),

          // ── Back button ──────────────────────────────────────
          Positioned(
            top: topPad + 8,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    CupertinoIcons.chevron_back,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          // ── Glassmorphic Action Panel (DraggableScrollableSheet) ──
          DraggableScrollableSheet(
            controller: _sheetCtrl,
            initialChildSize: 0.28,
            minChildSize: 0.13,
            maxChildSize: 0.52,
            snap: true,
            snapSizes: const [0.13, 0.28, 0.52],
            builder: (context, scrollCtrl) => _ActionPanel(
              scrollController: scrollCtrl,
              activeIds: activeIds,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Active actions badge
// ─────────────────────────────────────────────────────────────────────────────
class _ActiveBadge extends StatelessWidget {
  final int count;
  const _ActiveBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Text(
        '$count active',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.success,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat cards row — AnimatedSwitcher slot-machine value effect
// ─────────────────────────────────────────────────────────────────────────────
class _StatCardsRow extends StatelessWidget {
  final EarthMetrics metrics;
  const _StatCardsRow({required this.metrics});

  @override
  Widget build(BuildContext context) {
    // Map the fraction-based ice to a display percentage (0–100%)
    final iceDisplay = (metrics.ice * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _GlassCard(
              emoji: '🌡️',
              label: 'Global Temp',
              valueKey: metrics.temp.toStringAsFixed(1),
              value: '${metrics.temp.toStringAsFixed(1)}°C',
              trend: _trend(metrics.temp, EarthMetrics.initial.temp, '°C'),
              trendUp: metrics.temp >= EarthMetrics.initial.temp,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _GlassCard(
              emoji: '💨',
              label: 'CO₂ Level',
              valueKey: metrics.co2.toStringAsFixed(1),
              value: '${metrics.co2.toStringAsFixed(1)} ppm',
              trend: _trend(metrics.co2, EarthMetrics.initial.co2, ' ppm'),
              trendUp: metrics.co2 >= EarthMetrics.initial.co2,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _GlassCard(
              emoji: '🧊',
              label: 'Ice Cover',
              valueKey: iceDisplay,
              value: '$iceDisplay%',
              trend: _trend(
                metrics.ice * 100,
                EarthMetrics.initial.ice * 100,
                '%',
              ),
              trendUp: metrics.ice <= EarthMetrics.initial.ice,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a compact trend label like "−5.0 ppm" or "+0.3°C".
  static String _trend(double current, double baseline, String unit) {
    final delta = current - baseline;
    final sign = delta >= 0 ? '+' : '';
    return '$sign${delta.toStringAsFixed(1)}$unit';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual glass stat card with AnimatedSwitcher digit-slot effect
// ─────────────────────────────────────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final String emoji;
  final String label;
  /// Unique key for AnimatedSwitcher — changes when value changes.
  final String valueKey;
  final String value;
  final String trend;
  /// true = value went up (bad for temp/co2, good for ice in reverse).
  final bool trendUp;

  const _GlassCard({
    required this.emoji,
    required this.label,
    required this.valueKey,
    required this.value,
    required this.trend,
    required this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    // For temp + co2: increasing is bad (red). For ice: decreasing is bad (red).
    final isBad = trendUp;
    final trendColor = isBad
        ? const Color(0xFFFF7A59)   // warm-red (worse)
        : AppColors.success;        // forest-green (better)

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardLight.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.cardMeta.copyWith(
                  color: Colors.white60,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),

              // ── Slot-machine value ──────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 380),
                transitionBuilder: (child, anim) {
                  // Slide up + fade — "digit rolls up into view"
                  final offset = Tween<Offset>(
                    begin: const Offset(0, 0.6),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeOutCubic,
                  ));
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: Text(
                  value,
                  key: ValueKey(valueKey),
                  style: AppTextStyles.cardTitle.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // ── Trend chip (also slot-machine animated) ─────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 380),
                child: Container(
                  key: ValueKey('trend_$valueKey'),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trend,
                    style: AppTextStyles.cardMeta.copyWith(
                      color: trendColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glassmorphic Action Panel
// ─────────────────────────────────────────────────────────────────────────────
class _ActionPanel extends ConsumerWidget {
  final ScrollController scrollController;
  final Set<String> activeIds;

  const _ActionPanel({
    required this.scrollController,
    required this.activeIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.heroDeep.withValues(alpha: 0.72),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Drag handle ──────────────────────────────────
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 14),
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Header ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    Text(
                      'Action Panel',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '· tap to toggle',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white38,
                      ),
                    ),
                    const Spacer(),
                    if (activeIds.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          for (final a in kSimulatorActions) {
                            if (activeIds.contains(a.id)) {
                              ref
                                  .read(earthStateProvider.notifier)
                                  .removeAction(a);
                            }
                          }
                        },
                        child: Text(
                          'Reset all',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFF7A59)
                                .withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Scrollable toggle list ────────────────────────
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: kSimulatorActions.length,
                  itemBuilder: (context, i) {
                    final action = kSimulatorActions[i];
                    final isOn = activeIds.contains(action.id);
                    return _ToggleChip(
                      action: action,
                      isOn: isOn,
                      onToggle: () {
                        HapticFeedback.lightImpact();
                        final notifier =
                            ref.read(earthStateProvider.notifier);
                        if (isOn) {
                          notifier.removeAction(action);
                        } else {
                          notifier.applyAction(action);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual toggle chip
// ─────────────────────────────────────────────────────────────────────────────
class _ToggleChip extends StatefulWidget {
  final ActionToggle action;
  final bool isOn;
  final VoidCallback onToggle;

  const _ToggleChip({
    required this.action,
    required this.isOn,
    required this.onToggle,
  });

  @override
  State<_ToggleChip> createState() => _ToggleChipState();
}

class _ToggleChipState extends State<_ToggleChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOn = widget.isOn;
    final activeColor = AppColors.success;
    final borderColor = isOn
        ? activeColor.withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.12);
    final bgColor = isOn
        ? activeColor.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.05);

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onToggle();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _pressScale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          width: 130,
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: isOn ? 1.0 : 0.5),
            boxShadow: isOn
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.22),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Top row: emoji + toggle pip ─────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.action.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOn
                          ? activeColor
                          : Colors.white.withValues(alpha: 0.2),
                      boxShadow: isOn
                          ? [
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.5),
                                blurRadius: 6,
                              )
                            ]
                          : [],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Label ────────────────────────────────────────
              Text(
                widget.action.label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOn ? Colors.white : Colors.white70,
                  height: 1.3,
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 4),

              // ── Subtitle / delta hint ─────────────────────────
              Text(
                widget.action.subtitle,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isOn
                      ? activeColor.withValues(alpha: 0.9)
                      : Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Drag hint chip
// ─────────────────────────────────────────────────────────────────────────────
class _DragHintChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(CupertinoIcons.hand_draw, size: 14, color: Colors.white54),
          const SizedBox(width: 6),
          Text(
            'Drag to rotate',
            style: AppTextStyles.cardMeta.copyWith(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Star field (unchanged)
// ─────────────────────────────────────────────────────────────────────────────
class _StarField extends ConsumerWidget {
  const _StarField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthScore = ref.watch(earthStateProvider.select((s) => s.metrics.healthScore));
    // Smog opacity: 0 when health >= 70, maxes at 0.35 when health = 0
    final smogOpacity = healthScore >= 70.0
        ? 0.0
        : ((70.0 - healthScore) / 70.0 * 0.35).clamp(0.0, 0.35);

    return SizedBox.expand(
      child: CustomPaint(
        painter: _StarPainter(smogOpacity: smogOpacity),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final double smogOpacity;
  _StarPainter({this.smogOpacity = 0.0});

  static const _stars = [
    [0.05, 0.08], [0.15, 0.22], [0.28, 0.05], [0.42, 0.18],
    [0.61, 0.03], [0.74, 0.14], [0.88, 0.09], [0.93, 0.26],
    [0.08, 0.40], [0.20, 0.55], [0.35, 0.48], [0.50, 0.62],
    [0.65, 0.44], [0.80, 0.58], [0.92, 0.42], [0.12, 0.72],
    [0.30, 0.80], [0.47, 0.76], [0.60, 0.88], [0.78, 0.82],
    [0.90, 0.70], [0.03, 0.90], [0.22, 0.95], [0.55, 0.93],
    [0.70, 0.97], [0.85, 0.91], [0.38, 0.33], [0.52, 0.28],
    [0.66, 0.20], [0.82, 0.36],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Draw smog background if health is low
    if (smogOpacity > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFE07B39).withValues(alpha: smogOpacity),
      );
    }

    for (final s in _stars) {
      final x = s[0] * size.width;
      final y = s[1] * size.height;
      final r = (s[0] * 31 % 3 == 0) ? 1.4 : 0.8;
      
      // Stars appear dimmer/tinted through smog
      final starAlpha = (0.3 + (s[1] * 7 % 5) * 0.1) * (1 - smogOpacity * 0.5);
      paint.color = Colors.white.withValues(alpha: starAlpha);
      
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.smogOpacity != smogOpacity;
}
