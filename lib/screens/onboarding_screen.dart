// lib/screens/onboarding_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/earth_state_notifier.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Slide data model
// ─────────────────────────────────────────────────────────────────────────────
class _SlideData {
  final String emoji;
  final String tag;
  final String title;
  final String subtitle;
  final String lowLabel;
  final String highLabel;
  /// Gradient lerped from (muted terracotta) → (deep earthy-brown)
  final Color colorLow;
  final Color colorHigh;

  const _SlideData({
    required this.emoji,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.lowLabel,
    required this.highLabel,
    required this.colorLow,
    required this.colorHigh,
  });
}

const _slides = [
  _SlideData(
    emoji: '🌍',
    tag: 'AWARENESS',
    title: 'How aware are you of\nclimate change?',
    subtitle: 'Drag to show us where you stand.',
    lowLabel: 'Just heard\nabout it',
    highLabel: 'Deeply\ninformed',
    colorLow:  Color(0xFFB87A5A),   // muted terracotta
    colorHigh: Color(0xFF2E1A0E),   // deep earthy brown
  ),
  _SlideData(
    emoji: '🌱',
    tag: 'HABITS',
    title: 'How eco-conscious are\nyour daily habits?',
    subtitle: 'No judgment — be honest with yourself.',
    lowLabel: 'Rarely\nthink about it',
    highLabel: 'Live by\nthe planet',
    colorLow:  Color(0xFFB5855C),
    colorHigh: Color(0xFF1A3A1F),   // deep forest
  ),
  _SlideData(
    emoji: '🔥',
    tag: 'COMMITMENT',
    title: 'How ready are you to\nchange the world?',
    subtitle: 'Your quest begins with a single step.',
    lowLabel: 'Just\nexploring',
    highLabel: 'All in,\nlet\'s go!',
    colorLow:  Color(0xFFBF7B50),
    colorHigh: Color(0xFF3A1A06),   // ember-brown
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Earth rank derivation
// ─────────────────────────────────────────────────────────────────────────────
/// Maps the average of three slider answers (0–1) to a rank tier.
String _deriveRank(List<double> answers) {
  final avg = answers.fold(0.0, (a, b) => a + b) / answers.length;
  if (avg < 0.25) return 'Seedling';
  if (avg < 0.50) return 'Wayfinder';
  if (avg < 0.75) return 'Steward';
  return 'Guardian';
}

const _rankEmojis = {
  'Seedling':  '🌱',
  'Wayfinder': '🧭',
  'Steward':   '🌳',
  'Guardian':  '🛡️',
};

const _rankSubs = {
  'Seedling':  'Every giant tree starts as a tiny seed.',
  'Wayfinder': 'You navigate with heart and curiosity.',
  'Steward':   'You protect what the Earth entrusts to you.',
  'Guardian':  'You stand watch so others may flourish.',
};

// ─────────────────────────────────────────────────────────────────────────────
// Custom page physics — heavier, more deliberate feel
// ─────────────────────────────────────────────────────────────────────────────
class _EarthPagePhysics extends PageScrollPhysics {
  const _EarthPagePhysics({super.parent});

  @override
  _EarthPagePhysics applyTo(ScrollPhysics? ancestor) =>
      _EarthPagePhysics(parent: buildParent(ancestor));

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 120,
        stiffness: 100,
        damping: 30,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────────
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;

  // One slider value per slide, all start at 0.5
  final List<double> _answers = [0.5, 0.5, 0.5];

  // For per-slide bg morph
  final List<double> _bgValues = [0.5, 0.5, 0.5];

  // Result screen state
  bool _showResult = false;
  String _rank = '';

  late final AnimationController _orbitCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final AnimationController _resultRevealCtrl;
  late final Animation<double> _resultFade;
  late final Animation<double> _resultScale;

  @override
  void initState() {
    super.initState();
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _resultRevealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _resultFade  = CurvedAnimation(parent: _resultRevealCtrl, curve: Curves.easeOut);
    _resultScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _resultRevealCtrl, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _pulseCtrl.dispose();
    _resultRevealCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  bool get _isLastSlide => _currentPage == _slides.length - 1;

  void _onSliderChanged(int page, double val) {
    setState(() {
      _answers[page] = val;
      _bgValues[page] = val;
    });
    HapticFeedback.lightImpact();
  }

  void _onSliderSettled(int page, double val) {
    setState(() {
      _answers[page] = val;
      _bgValues[page] = val;
    });
    HapticFeedback.mediumImpact();
  }

  void _advance() {
    if (_isLastSlide) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    HapticFeedback.heavyImpact();
    final rank = _deriveRank(_answers);
    await ref.read(earthStateProvider.notifier).setEarthRank(rank);
    setState(() {
      _rank = rank;
      _showResult = true;
    });
    _resultRevealCtrl.forward();
  }

  void _enterApp() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final fade  = CurvedAnimation(parent: animation, curve: Curves.easeOut);
          final scale = Tween<double>(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(scale: scale, child: child),
          );
        },
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_showResult) {
      return _ResultScreen(
      rank: _rank,
      fade: _resultFade,
      scale: _resultScale,
      pulseAnim: _pulseAnim,
      orbitCtrl: _orbitCtrl,
      onEnter: _enterApp,
    );
    }

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        physics: const _EarthPagePhysics(),
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemCount: _slides.length,
        itemBuilder: (context, index) {
          final slide = _slides[index];
          return _SlidePage(
            slide: slide,
            sliderValue: _answers[index],
            bgValue: _bgValues[index],
            pageIndex: index,
            totalPages: _slides.length,
            currentPage: _currentPage,
            isLast: index == _slides.length - 1,
            pulseAnim: _pulseAnim,
            orbitCtrl: _orbitCtrl,
            onSliderChanged: (v) => _onSliderChanged(index, v),
            onSliderSettled: (v) => _onSliderSettled(index, v),
            onAdvance: _advance,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual slide page
// ─────────────────────────────────────────────────────────────────────────────
class _SlidePage extends StatelessWidget {
  final _SlideData slide;
  final double sliderValue;
  final double bgValue;
  final int pageIndex;
  final int totalPages;
  final int currentPage;
  final bool isLast;
  final Animation<double> pulseAnim;
  final AnimationController orbitCtrl;
  final ValueChanged<double> onSliderChanged;
  final ValueChanged<double> onSliderSettled;
  final VoidCallback onAdvance;

  const _SlidePage({
    required this.slide,
    required this.sliderValue,
    required this.bgValue,
    required this.pageIndex,
    required this.totalPages,
    required this.currentPage,
    required this.isLast,
    required this.pulseAnim,
    required this.orbitCtrl,
    required this.onSliderChanged,
    required this.onSliderSettled,
    required this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: bgValue, end: bgValue),
      duration: const Duration(milliseconds: 220),
      builder: (context, t, child) {
        final bg = Color.lerp(slide.colorLow, slide.colorHigh, t)!;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                bg,
                Color.lerp(bg, Colors.black, 0.3)!,
              ],
            ),
          ),
          child: child,
        );
      },
      // We rebuild separately as the tween needs to follow the live value.
      child: _SlideContent(
        slide: slide,
        sliderValue: sliderValue,
        bgValue: bgValue,
        pageIndex: pageIndex,
        totalPages: totalPages,
        currentPage: currentPage,
        isLast: isLast,
        pulseAnim: pulseAnim,
        orbitCtrl: orbitCtrl,
        onSliderChanged: onSliderChanged,
        onSliderSettled: onSliderSettled,
        onAdvance: onAdvance,
        topPad: topPad,
        bottomPad: bottomPad,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Content inside each slide (rebuilt on every drag to keep bg in sync)
// ─────────────────────────────────────────────────────────────────────────────
class _SlideContent extends StatelessWidget {
  final _SlideData slide;
  final double sliderValue;
  final double bgValue;
  final int pageIndex;
  final int totalPages;
  final int currentPage;
  final bool isLast;
  final Animation<double> pulseAnim;
  final AnimationController orbitCtrl;
  final ValueChanged<double> onSliderChanged;
  final ValueChanged<double> onSliderSettled;
  final VoidCallback onAdvance;
  final double topPad;
  final double bottomPad;

  const _SlideContent({
    required this.slide,
    required this.sliderValue,
    required this.bgValue,
    required this.pageIndex,
    required this.totalPages,
    required this.currentPage,
    required this.isLast,
    required this.pulseAnim,
    required this.orbitCtrl,
    required this.onSliderChanged,
    required this.onSliderSettled,
    required this.onAdvance,
    required this.topPad,
    required this.bottomPad,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = bgValue > 0.45;
    final textMain = isDark ? Colors.white : const Color(0xFF1E1206);
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : const Color(0xFF6B5040);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // ── Top bar: skip ────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${pageIndex + 1} of $totalPages',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: textSub,
                              letterSpacing: 0.4,
                            ),
                          ),
                          if (!isLast)
                            GestureDetector(
                              onTap: onAdvance,
                              child: Text(
                                'Skip',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textSub,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // ── Mini planet ──────────────────────────────────────
                    const SizedBox(height: 8),
                    _MiniPlanet(
                      size: 130,
                      orbitCtrl: orbitCtrl,
                      pulseAnim: pulseAnim,
                      tint: bgValue,
                    ),

                    const SizedBox(height: 28),

                    // ── Tag ─────────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        slide.tag,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: textMain.withValues(alpha: 0.8),
                          letterSpacing: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Title ────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: textMain,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Subtitle ─────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        slide.subtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: textSub,
                          height: 1.45,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // ── Custom slider ────────────────────────────────────
                    _EarthSlider(
                      value: sliderValue,
                      colorLow: slide.colorLow,
                      colorHigh: slide.colorHigh,
                      lowLabel: slide.lowLabel,
                      highLabel: slide.highLabel,
                      textColor: textMain,
                      onChanged: onSliderChanged,
                      onSettled: onSliderSettled,
                    ),

                    const Spacer(),

                    // ── CTA Button ───────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.fromLTRB(32, 0, 32, bottomPad + 12),
                      child: _CtaButton(
                        label: isLast ? 'Reveal my Earth Rank  →' : 'Continue  →',
                        sliderValue: sliderValue,
                        colorLow: slide.colorLow,
                        colorHigh: slide.colorHigh,
                        onTap: onAdvance,
                      ),
                    ),

                    // ── Page dots ────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(totalPages, (i) {
                          final active = i == currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: active ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom draggable slider (zero Material widgets)
// ─────────────────────────────────────────────────────────────────────────────
class _EarthSlider extends StatefulWidget {
  final double value;
  final Color colorLow;
  final Color colorHigh;
  final String lowLabel;
  final String highLabel;
  final Color textColor;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onSettled;

  const _EarthSlider({
    required this.value,
    required this.colorLow,
    required this.colorHigh,
    required this.lowLabel,
    required this.highLabel,
    required this.textColor,
    required this.onChanged,
    required this.onSettled,
  });

  @override
  State<_EarthSlider> createState() => _EarthSliderState();
}

class _EarthSliderState extends State<_EarthSlider>
    with SingleTickerProviderStateMixin {
  double _localValue = 0.5;
  bool _dragging = false;
  late AnimationController _thumbPulse;
  late Animation<double> _thumbScale;

  @override
  void initState() {
    super.initState();
    _localValue = widget.value;
    _thumbPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _thumbScale = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _thumbPulse, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_EarthSlider old) {
    super.didUpdateWidget(old);
    _localValue = widget.value;
  }

  @override
  void dispose() {
    _thumbPulse.dispose();
    super.dispose();
  }

  void _updateFromDrag(double localX, double trackWidth) {
    final clamped = (localX / trackWidth).clamp(0.0, 1.0);
    setState(() => _localValue = clamped);
    widget.onChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    const trackH = 10.0;
    const thumbR = 18.0;
    const labelH = 36.0;
    const totalH = thumbR * 2 + trackH + labelH + 8;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        height: totalH,
        child: LayoutBuilder(builder: (context, constraints) {
          final trackWidth = constraints.maxWidth;
          final thumbX = _localValue * trackWidth;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (_) {
              setState(() => _dragging = true);
              _thumbPulse.forward();
              HapticFeedback.lightImpact();
            },
            onHorizontalDragUpdate: (d) {
              final box = context.findRenderObject() as RenderBox;
              final localX = box.globalToLocal(d.globalPosition).dx;
              _updateFromDrag(localX.clamp(0, trackWidth), trackWidth);
            },
            onHorizontalDragEnd: (_) {
              setState(() => _dragging = false);
              _thumbPulse.reverse();
              widget.onSettled(_localValue);
            },
            onTapDown: (d) {
              final box = context.findRenderObject() as RenderBox;
              final localX = box.globalToLocal(d.globalPosition).dx;
              _updateFromDrag(localX.clamp(0, trackWidth), trackWidth);
              _thumbPulse.forward().then((_) => _thumbPulse.reverse());
              widget.onSettled(_localValue);
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Track background ──────────────────────────
                Positioned(
                  top: thumbR - trackH / 2,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: trackH,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(trackH / 2),
                    ),
                  ),
                ),

                // ── Filled portion ────────────────────────────
                Positioned(
                  top: thumbR - trackH / 2,
                  left: 0,
                  width: thumbX,
                  child: Container(
                    height: trackH,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(trackH / 2),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.5),
                          Colors.white.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Thumb ─────────────────────────────────────
                Positioned(
                  top: 0,
                  left: thumbX - thumbR,
                  child: ScaleTransition(
                    scale: _thumbScale,
                    child: Container(
                      width: thumbR * 2,
                      height: thumbR * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                          if (_dragging)
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.35),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '⟺',
                          style: TextStyle(
                            fontSize: 15,
                            color: widget.colorHigh.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Tick marks ────────────────────────────────
                ...List.generate(5, (i) {
                  final frac = i / 4.0;
                  final x = frac * trackWidth;
                  return Positioned(
                    top: thumbR - trackH / 2 - 4,
                    left: x - 1,
                    child: Container(
                      width: 2,
                      height: trackH + 8,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  );
                }),

                // ── Labels ────────────────────────────────────
                Positioned(
                  top: thumbR * 2 + 10,
                  left: 0,
                  width: trackWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: trackWidth * 0.38,
                        child: Text(
                          widget.lowLabel,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: widget.textColor.withValues(alpha: 0.6),
                            height: 1.4,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: trackWidth * 0.38,
                        child: Text(
                          widget.highLabel,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CTA button — bg interpolates with slider
// ─────────────────────────────────────────────────────────────────────────────
class _CtaButton extends StatefulWidget {
  final String label;
  final double sliderValue;
  final Color colorLow;
  final Color colorHigh;
  final VoidCallback onTap;

  const _CtaButton({
    required this.label,
    required this.sliderValue,
    required this.colorLow,
    required this.colorHigh,
    required this.onTap,
  });

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: widget.sliderValue, end: widget.sliderValue),
          duration: const Duration(milliseconds: 200),
          builder: (_, t, __) {
            final btnColor = Color.lerp(
              Colors.white.withValues(alpha: 0.9),
              Colors.white,
              t,
            )!;
            final txtColor = Color.lerp(widget.colorLow, widget.colorHigh, t)!;
            return Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: btnColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: txtColor,
                  letterSpacing: 0.1,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mini planet (no external deps, self-contained)
// ─────────────────────────────────────────────────────────────────────────────
class _MiniPlanet extends StatelessWidget {
  final double size;
  final AnimationController orbitCtrl;
  final Animation<double> pulseAnim;
  final double tint; // 0–1 slider position

  const _MiniPlanet({
    required this.size,
    required this.orbitCtrl,
    required this.pulseAnim,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final s = size / 130.0;
    final planetD = 78.0 * s;
    final orbitRx = 52.0 * s;
    final orbitRy = 18.0 * s;
    final dotSize = 8.0 * s;

    // Planet colour interpolates from ocean-blue → dark-olive as slider moves
    final planetColor = Color.lerp(
      const Color(0xFF3E7FDF),
      const Color(0xFF2D4A1E),
      tint,
    )!;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow
          ScaleTransition(
            scale: pulseAnim,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),

          // Ring
          Opacity(
            opacity: 0.5,
            child: Container(
              width: 110 * s,
              height: 34 * s,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.55),
                  width: 4 * s,
                ),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),

          // Planet body
          ScaleTransition(
            scale: pulseAnim,
            child: Container(
              width: planetD,
              height: planetD,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.35, -0.35),
                  radius: 0.9,
                  colors: [
                    Color.lerp(const Color(0xFF6BA3FF), planetColor, tint * 0.6)!,
                    planetColor,
                    Color.lerp(planetColor, Colors.black, 0.3)!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: planetColor.withValues(alpha: 0.45),
                    blurRadius: 18 * s,
                    spreadRadius: 2 * s,
                  ),
                ],
              ),
              child: ClipOval(
                child: Stack(
                  children: [
                    Positioned(
                      top: 18 * s, left: 15 * s,
                      child: Opacity(
                        opacity: 0.55,
                        child: Container(
                          width: 22 * s, height: 14 * s,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(6 * s),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 18 * s, right: 12 * s,
                      child: Opacity(
                        opacity: 0.4,
                        child: Container(
                          width: 16 * s, height: 10 * s,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(5 * s),
                          ),
                        ),
                      ),
                    ),
                    // Specular
                    Positioned(
                      top: 9 * s, left: 12 * s,
                      child: Opacity(
                        opacity: 0.3,
                        child: Container(
                          width: 20 * s, height: 12 * s,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12 * s),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Orbit dot
          AnimatedBuilder(
            animation: orbitCtrl,
            builder: (_, __) {
              final angle = orbitCtrl.value * 2 * math.pi;
              return Transform.translate(
                offset: Offset(
                  orbitRx * math.cos(angle),
                  orbitRy * math.sin(angle),
                ),
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.85),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 6 * s,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Result reveal screen
// ─────────────────────────────────────────────────────────────────────────────
class _ResultScreen extends StatelessWidget {
  final String rank;
  final Animation<double> fade;
  final Animation<double> scale;
  final Animation<double> pulseAnim;
  final AnimationController orbitCtrl;
  final VoidCallback onEnter;

  const _ResultScreen({
    required this.rank,
    required this.fade,
    required this.scale,
    required this.pulseAnim,
    required this.orbitCtrl,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = _rankEmojis[rank] ?? '🌍';
    final sub = _rankSubs[rank] ?? '';
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A2E1A), Color(0xFF0D1A0D)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: scale,
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // ── Title ──────────────────────────────────
                  Text(
                    'YOUR EARTH RANK',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success.withValues(alpha: 0.8),
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Large planet globe ─────────────────────
                  _MiniPlanet(
                    size: 200,
                    orbitCtrl: orbitCtrl,
                    pulseAnim: pulseAnim,
                    tint: 0.75,
                  ),

                  const SizedBox(height: 36),

                  // ── Rank badge ────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 20),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 52)),
                        const SizedBox(height: 12),
                        Text(
                          rank,
                          style: GoogleFonts.inter(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sub,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.6),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Enter app ─────────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(32, 0, 32, bottomPad + 24),
                    child: _EnterButton(onTap: onEnter),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EnterButton extends StatefulWidget {
  final VoidCallback onTap;
  const _EnterButton({required this.onTap});

  @override
  State<_EnterButton> createState() => _EnterButtonState();
}

class _EnterButtonState extends State<_EnterButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.success, const Color(0xFF1A5C33)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Begin My Quest',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              const Text('🌍', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
