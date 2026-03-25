import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LessonDetailScreen extends StatefulWidget {
  final LessonModel lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final ScrollController _scrollCtrl = ScrollController();
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final max = _scrollCtrl.position.maxScrollExtent;
    if (max <= 0) return;
    final progress = (_scrollCtrl.offset / max).clamp(0.0, 1.0);
    if ((progress - _scrollProgress).abs() > 0.002) {
      setState(() => _scrollProgress = progress);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Main scrollable content ───────────────────────
          CustomScrollView(
            controller: _scrollCtrl,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Flexible hero app bar ─────────────────────
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                stretch: true,
                automaticallyImplyLeading: false,
                backgroundColor: AppColors.heroDeep,
                // Extra space so the progress bar doesn't overlap title
                toolbarHeight: 56,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.chevron_back,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                ),
                actions: [
                  // "Bookmark" action chip
                  Container(
                    margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.bookmark,
                            size: 14, color: AppColors.accent),
                        const SizedBox(width: 5),
                        Text(
                          'Save',
                          style: AppTextStyles.cardMeta.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.fadeTitle,
                  ],
                  background: _HeroBackground(lesson: widget.lesson),
                ),
              ),

              // ── Meta pill row ─────────────────────────────
              SliverToBoxAdapter(
                child: _MetaRow(lesson: widget.lesson),
              ),

              // ── Description block ─────────────────────────
              SliverToBoxAdapter(
                child: _ContentBlock(
                  child: Text(
                    widget.lesson.description,
                    style: AppTextStyles.lessonTitle.copyWith(
                      height: 1.65,
                      color: AppColors.textMid,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              // ── Content sections ──────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Text('Chapters', style: AppTextStyles.sectionTitle),
                ),
              ),

              ...widget.lesson.sections.asMap().entries.map((entry) {
                final i = entry.key;
                final section = entry.value;
                return SliverToBoxAdapter(
                  child: _SectionBlock(
                    index: i + 1,
                    section: section,
                  ),
                );
              }),

              // ── Key facts block ───────────────────────────
              SliverToBoxAdapter(
                child: _KeyFactsBlock(facts: widget.lesson.keyFacts),
              ),

              // ── Start lesson CTA ──────────────────────────
              SliverToBoxAdapter(
                child: _StartButton(lesson: widget.lesson),
              ),

              // Bottom safe area padding
              SliverToBoxAdapter(
                child: SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 32),
              ),
            ],
          ),

          // ── Persistent progress bar (under status bar) ────
          Positioned(
            top: topPad,
            left: 0,
            right: 0,
            child: _ProgressBar(progress: _scrollProgress),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Progress bar pinned under status bar
// ──────────────────────────────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final double progress;
  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 120),
      builder: (_, value, __) {
        return LinearProgressIndicator(
          value: value,
          minHeight: 3,
          backgroundColor: Colors.transparent,
          valueColor:
              const AlwaysStoppedAnimation<Color>(AppColors.success),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// SliverAppBar hero background
// ──────────────────────────────────────────────────────────────────────────────
class _HeroBackground extends StatelessWidget {
  final LessonModel lesson;
  const _HeroBackground({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A1E10),
            AppColors.heroDeep,
            Color(0xFF1A3A2A),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Big emoji
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: lesson.iconBg.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: lesson.iconBg.withValues(alpha: 0.4),
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child:
                      Text(lesson.emoji, style: const TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 16),
              Text(lesson.title, style: AppTextStyles.display),
              const SizedBox(height: 6),
              Row(
                children: [
                  _HeroPill(lesson.meta.split('·').first.trim(), AppColors.accent),
                  const SizedBox(width: 8),
                  _HeroPill(lesson.meta.split('·').last.trim(),
                      AppColors.success.withValues(alpha: 0.9)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String label;
  final Color color;
  const _HeroPill(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Text(
        label,
        style: AppTextStyles.cardMeta.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Meta row (sections count, difficulty)
// ──────────────────────────────────────────────────────────────────────────────
class _MetaRow extends StatelessWidget {
  final LessonModel lesson;
  const _MetaRow({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        children: [
          _MetaTile(
              emoji: '📖',
              label: '${lesson.sections.length} chapters'),
          const SizedBox(width: 10),
          _MetaTile(
              emoji: '⏱',
              label: lesson.meta.split('·').first.trim()),
          const SizedBox(width: 10),
          _MetaTile(emoji: '🏅', label: 'Earn 50 XP'),
        ],
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  final String emoji;
  final String label;
  const _MetaTile({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.cardMeta, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Reusable bordered content block
// ──────────────────────────────────────────────────────────────────────────────
class _ContentBlock extends StatelessWidget {
  final Widget child;
  const _ContentBlock({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: child,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Individual chapter section card
// ──────────────────────────────────────────────────────────────────────────────
class _SectionBlock extends StatefulWidget {
  final int index;
  final LessonSection section;
  const _SectionBlock({required this.index, required this.section});

  @override
  State<_SectionBlock> createState() => _SectionBlockState();
}

class _SectionBlockState extends State<_SectionBlock>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _heightFactor = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    // First section open by default
    if (widget.index == 1) {
      _expanded = true;
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          // Header (always visible) — tap to expand
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Index badge
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _expanded
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.border.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index}',
                        style: AppTextStyles.cardMeta.copyWith(
                          color: _expanded
                              ? AppColors.success
                              : AppColors.textMid,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Emoji + heading
                  if (widget.section.emoji != null) ...[
                    Text(widget.section.emoji!,
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      widget.section.heading,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                    ),
                  ),
                  // Chevron
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 280),
                    child: const Icon(
                      CupertinoIcons.chevron_down,
                      size: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable body
          SizeTransition(
            sizeFactor: _heightFactor,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 0.5,
                    color: AppColors.border,
                    margin: const EdgeInsets.only(bottom: 14),
                  ),
                  Text(
                    widget.section.body,
                    style: AppTextStyles.lessonMeta.copyWith(
                      fontSize: 13,
                      height: 1.7,
                      color: AppColors.textMid,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Key facts block
// ──────────────────────────────────────────────────────────────────────────────
class _KeyFactsBlock extends StatelessWidget {
  final List<String> facts;
  const _KeyFactsBlock({required this.facts});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.learnTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.success.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text('Key Facts', style: AppTextStyles.sectionTitle),
            ],
          ),
          const SizedBox(height: 12),
          ...facts.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(f,
                        style: AppTextStyles.lessonMeta.copyWith(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textDark,
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Start lesson CTA button
// ──────────────────────────────────────────────────────────────────────────────
class _StartButton extends StatelessWidget {
  final LessonModel lesson;
  const _StartButton({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(lesson.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(
                'Start Lesson',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(CupertinoIcons.arrow_right,
                  size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
