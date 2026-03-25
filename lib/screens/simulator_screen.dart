import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/planet_widget.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen>
    with TickerProviderStateMixin {
  // Auto-orbit for the satellite
  late final AnimationController _orbitCtrl;

  // Pulse / breathe
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  // Slow auto-rotation of planet surface
  late final AnimationController _autoRotateCtrl;

  // User-controlled drag offset
  double _dragRotation = 0.0;

  // Combined rotation = auto + drag
  double get _totalRotation =>
      _autoRotateCtrl.value * 2 * 3.14159265 + _dragRotation;

  // Animated stats (simulated oscillation)
  late final AnimationController _statsCtrl;
  late final Animation<double> _tempAnim;
  late final Animation<double> _co2Anim;
  late final Animation<double> _iceAnim;

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

    // Slow auto surface rotation — one full turn every 30 s
    _autoRotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // Stats oscillate gently to feel "live"
    _statsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _tempAnim = Tween<double>(begin: 14.6, end: 15.2).animate(
      CurvedAnimation(parent: _statsCtrl, curve: Curves.easeInOut),
    );
    _co2Anim = Tween<double>(begin: 419.0, end: 421.5).animate(
      CurvedAnimation(parent: _statsCtrl, curve: Curves.easeInOut),
    );
    _iceAnim = Tween<double>(begin: 10.2, end: 9.8).animate(
      CurvedAnimation(parent: _statsCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _pulseCtrl.dispose();
    _autoRotateCtrl.dispose();
    _statsCtrl.dispose();
    super.dispose();
  }

  // ── Drag handlers ──────────────────────────────────────────────────────────
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    // Map screen pixels → radians (full screen width ≈ 2π)
    final screenWidth = MediaQuery.of(context).size.width;
    final delta = details.delta.dx / screenWidth * 2 * 3.14159265 * 1.5;
    setState(() {
      _dragRotation += delta;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails _) {}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Planet = 60% of screen width
    final planetSize = size.width * 0.60;

    return Scaffold(
      backgroundColor: AppColors.heroDeep,
      body: Stack(
        children: [
          // ── Star field background ──────────────────────────
          const _StarField(),

          // ── Draggable planet ──────────────────────────────
          GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // Title
                  Text(
                    'Planet Simulator',
                    style: AppTextStyles.display.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Drag to rotate · Live data',
                    style: AppTextStyles.heroSub,
                  ),
                  const SizedBox(height: 40),

                  // Planet — driven by combined auto + drag rotation
                  AnimatedBuilder(
                    animation: Listenable.merge(
                        [_autoRotateCtrl, _pulseCtrl]),
                    builder: (context, _) {
                      return PlanetWidget(
                        size: planetSize,
                        orbitCtrl: _orbitCtrl,
                        pulse: _pulse,
                        rotationAngle: _totalRotation,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Drag hint chip
                  _DragHintChip(),
                ],
              ),
            ),
          ),

          // ── Glassmorphic stat cards (bottom) ──────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _statsCtrl,
              builder: (context, _) {
                return _StatCardsRow(
                  temp: _tempAnim.value,
                  co2: _co2Anim.value,
                  ice: _iceAnim.value,
                );
              },
            ),
          ),

          // ── Custom back button ─────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
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
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Glassmorphic stat cards row
// ──────────────────────────────────────────────────────────────────────────────
class _StatCardsRow extends StatelessWidget {
  final double temp;
  final double co2;
  final double ice;

  const _StatCardsRow({
    required this.temp,
    required this.co2,
    required this.ice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.heroDeep,
            AppColors.heroDeep.withValues(alpha: 0),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              Expanded(
                child: _GlassCard(
                  emoji: '🌡️',
                  label: 'Global Temp',
                  value: '${temp.toStringAsFixed(1)}°C',
                  trend: '+0.18°/dec',
                  trendColor: const Color(0xFFFF7A59),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GlassCard(
                  emoji: '💨',
                  label: 'CO₂ Level',
                  value: '${co2.toStringAsFixed(1)} ppm',
                  trend: '+2.4 ppm/yr',
                  trendColor: const Color(0xFFFFB347),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GlassCard(
                  emoji: '🧊',
                  label: 'Ice Cover',
                  value: '${ice.toStringAsFixed(1)}%',
                  trend: '−0.13%/yr',
                  trendColor: const Color(0xFF7EC8E3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final String trend;
  final Color trendColor;

  const _GlassCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.trend,
    required this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
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
              Text(
                value,
                style: AppTextStyles.cardTitle.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Drag hint chip
// ──────────────────────────────────────────────────────────────────────────────
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
          const Icon(CupertinoIcons.hand_draw,
              size: 14, color: Colors.white54),
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

// ──────────────────────────────────────────────────────────────────────────────
// Procedural star field painted on the background
// ──────────────────────────────────────────────────────────────────────────────
class _StarField extends StatelessWidget {
  const _StarField();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(painter: _StarPainter()),
    );
  }
}

class _StarPainter extends CustomPainter {
  // Fixed star positions as fractions of canvas size
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
    final paint = Paint()..color = Colors.white;
    for (final s in _stars) {
      final x = s[0] * size.width;
      final y = s[1] * size.height;
      // Alternate tiny sizes for depth effect
      final r = (s[0] * 31 % 3 == 0) ? 1.4 : 0.8;
      paint.color =
          Colors.white.withValues(alpha: 0.3 + (s[1] * 7 % 5) * 0.1);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) => false;
}
