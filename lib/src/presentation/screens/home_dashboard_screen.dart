import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/home_dashboard_provider.dart';
import 'package:fittin_v2/src/application/pr_dashboard_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/screens/advanced_analytics_screen.dart';
import 'package:fittin_v2/src/presentation/screens/exercise_deep_dive_screen.dart';
import 'package:fittin_v2/src/presentation/screens/pr_dashboard_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/line_chart_painter.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/today_workout_hero_card.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  final PageController _pageController = PageController(viewportFraction: 1);
  int _selectedLiftPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final homeDataAsync = ref.watch(homeDashboardDataProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          children: [
            homeDataAsync.when(
              data: (data) => _GreetingHeader(
                data: data,
                strings: strings,
                onNotificationTap: () => _openMilestonesPanel(context, data),
              ),
              loading: () => _GreetingHeaderSkeleton(strings: strings),
              error: (_, __) => _GreetingHeaderSkeleton(strings: strings),
            ),
            const SizedBox(height: 32),
            const TodayWorkoutHeroCard(),
            const SizedBox(height: 32),
            Text(
              strings.atAGlance,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            homeDataAsync.when(
              data: (data) => _AtAGlanceSection(
                data: data,
                strings: strings,
                selectedLiftPage: _selectedLiftPage,
                pageController: _pageController,
                onLiftPageChanged: (value) {
                  setState(() {
                    _selectedLiftPage = value;
                  });
                },
              ),
              loading: () => const _HomeOverviewSkeleton(),
              error: (error, _) =>
                  _HomeOverviewError(message: error.toString()),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Future<void> _openMilestonesPanel(
    BuildContext context,
    HomeDashboardData data,
  ) async {
    final latestMilestoneAt = data.milestones.isEmpty
        ? null
        : data.milestones.first.date;
    await ref
        .read(homeDashboardControllerProvider)
        .markMilestonesSeen(latestMilestoneAt);
    if (!mounted) {
      return;
    }

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'milestones',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, _, __) {
        final strings = AppStrings.of(dialogContext, ref);
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 72, 24, 0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Material(
                  color: Colors.transparent,
                  child: DashboardSurfaceCard(
                    radius: 28,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.trainingMilestones,
                          style: Theme.of(dialogContext).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 14),
                        if (data.milestones.isEmpty)
                          Text(strings.noMilestoneNotifications)
                        else
                          for (final milestone in data.milestones)
                            _NotificationMilestoneTile(
                              strings: strings,
                              milestone: milestone,
                              onTap: () {
                                Navigator.of(dialogContext).pop();
                                final summary = milestone.summary;
                                if (summary != null) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ExerciseDeepDiveScreen(
                                        summary: summary,
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const PRDashboardScreen(),
                                  ),
                                );
                              },
                            ),
                        if (data.milestones.isNotEmpty)
                          const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            key: const ValueKey(
                              'open-pr-dashboard-from-notifications',
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PRDashboardScreen(),
                                ),
                              );
                            },
                            child: Text(strings.viewPrDashboard),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offsetTween = Tween<Offset>(
          begin: const Offset(0, -0.08),
          end: Offset.zero,
        );
        return SlideTransition(
          position: offsetTween.animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({
    required this.data,
    required this.strings,
    required this.onNotificationTap,
  });

  final HomeDashboardData data;
  final AppStrings strings;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.greetingForPeriod(data.greetingPeriod.name),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.displayName,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        IconButton(
          key: const ValueKey('home-notification-button'),
          onPressed: onNotificationTap,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_rounded, size: 28),
              if (data.hasUnreadMilestones)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GreetingHeaderSkeleton extends StatelessWidget {
  const _GreetingHeaderSkeleton({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.goodMorning,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 110,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
        const Icon(Icons.notifications_none_rounded, size: 28),
      ],
    );
  }
}

class _AtAGlanceSection extends StatelessWidget {
  const _AtAGlanceSection({
    required this.data,
    required this.strings,
    required this.selectedLiftPage,
    required this.pageController,
    required this.onLiftPageChanged,
  });

  final HomeDashboardData data;
  final AppStrings strings;
  final int selectedLiftPage;
  final PageController pageController;
  final ValueChanged<int> onLiftPageChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _ProgressRingsCard(data: data, strings: strings),
          _LiftSparklineCard(
            data: data,
            strings: strings,
            selectedLiftPage: selectedLiftPage,
            pageController: pageController,
            onLiftPageChanged: onLiftPageChanged,
          ),
        ];

        if (constraints.maxWidth < 380) {
          return Column(
            children: [cards[0], const SizedBox(height: 16), cards[1]],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: cards[0]),
            const SizedBox(width: 16),
            Expanded(flex: 5, child: cards[1]),
          ],
        );
      },
    );
  }
}

class _ProgressRingsCard extends StatelessWidget {
  const _ProgressRingsCard({required this.data, required this.strings});

  final HomeDashboardData data;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AdvancedAnalyticsScreen()),
        );
      },
      radius: 24,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      child: Column(
        children: [
          NestedProgressRings(
            outerProgress: data.cycleProgress,
            innerProgress: data.weekProgress,
            size: 126,
            centerLabel: strings.compactWeekDayLabel(
              data.todayWorkout.currentWeekNumber,
              data.todayWorkout.currentDayNumber,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            strings.weekProgress,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            strings.weekDayProgressLabel(
              data.todayWorkout.currentWeekNumber,
              data.todayWorkout.cycleWeekCount,
              data.todayWorkout.currentDayNumber,
              data.todayWorkout.workoutsPerWeek,
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${strings.cycleProgress} ${(data.cycleProgress * 100).round()}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.58),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiftSparklineCard extends StatelessWidget {
  const _LiftSparklineCard({
    required this.data,
    required this.strings,
    required this.selectedLiftPage,
    required this.pageController,
    required this.onLiftPageChanged,
  });

  final HomeDashboardData data;
  final AppStrings strings;
  final int selectedLiftPage;
  final PageController pageController;
  final ValueChanged<int> onLiftPageChanged;

  @override
  Widget build(BuildContext context) {
    final safeIndex = data.sparklineLifts.isEmpty
        ? 0
        : selectedLiftPage.clamp(0, data.sparklineLifts.length - 1);
    return DashboardSurfaceCard(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PRDashboardScreen()));
      },
      radius: 24,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: SizedBox(
        height: 256,
        child: data.sparklineLifts.isEmpty
            ? Center(
                child: Text(
                  strings.noStrengthTrendYet,
                  textAlign: TextAlign.center,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        strings.activity,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        data.sparklineLifts[safeIndex].currentEstimatedOneRepMax
                                ?.toStringAsFixed(1) ??
                            '—',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.sparklineLifts[safeIndex].exerciseName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      onPageChanged: onLiftPageChanged,
                      itemCount: data.sparklineLifts.length,
                      itemBuilder: (context, index) {
                        return _SparklinePane(
                          summary: data.sparklineLifts[index],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < data.sparklineLifts.length; i++) ...[
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: i == safeIndex ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: Colors.white.withValues(
                              alpha: i == safeIndex ? 0.95 : 0.25,
                            ),
                          ),
                        ),
                        if (i < data.sparklineLifts.length - 1)
                          const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _SparklinePane extends StatelessWidget {
  const _SparklinePane({required this.summary});

  final ExerciseProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final history = summary.estimatedHistory.length > 8
        ? summary.estimatedHistory.sublist(summary.estimatedHistory.length - 8)
        : summary.estimatedHistory;
    if (history.isEmpty) {
      return const Center(child: Text('—'));
    }
    final minValue = history.map((point) => point.value).reduce(math.min);
    final maxValue = history.map((point) => point.value).reduce(math.max);
    final range = (maxValue - minValue).abs() < 0.001
        ? 1.0
        : maxValue - minValue;
    final points = [
      for (var index = 0; index < history.length; index++)
        Offset(
          history.length == 1 ? 0.5 : index / (history.length - 1),
          (history[index].value - minValue) / range,
        ),
    ];

    return CustomPaint(
      painter: LineChartPainter(
        datasets: [
          LineChartDataset(
            points: points,
            color: _sparklineColor(summary.exerciseName),
            label: summary.exerciseName,
          ),
        ],
        horizontalGridLines: 3,
        verticalGridLines: points.length > 1 ? points.length - 1 : 1,
      ),
      child: const SizedBox.expand(),
    );
  }

  Color _sparklineColor(String exerciseName) {
    final lower = exerciseName.toLowerCase();
    if (lower.contains('bench')) {
      return Colors.blueAccent;
    }
    if (lower.contains('deadlift')) {
      return Colors.greenAccent;
    }
    return Colors.redAccent;
  }
}

class _NotificationMilestoneTile extends StatelessWidget {
  const _NotificationMilestoneTile({
    required this.strings,
    required this.milestone,
    required this.onTap,
  });

  final AppStrings strings;
  final PRMilestone milestone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.exerciseName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    strings.milestoneValueLabel(
                      milestone.type == PRMilestoneType.actual
                          ? strings.actualType
                          : strings.estimatedType,
                      milestone.value,
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strings.shortMonthDay(milestone.date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeOverviewSkeleton extends StatelessWidget {
  const _HomeOverviewSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget card() => Expanded(
      child: DashboardSurfaceCard(
        radius: 24,
        child: const SizedBox(height: 256),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 380) {
          return Column(
            children: [
              DashboardSurfaceCard(
                radius: 24,
                child: const SizedBox(height: 256),
              ),
              const SizedBox(height: 16),
              DashboardSurfaceCard(
                radius: 24,
                child: const SizedBox(height: 256),
              ),
            ],
          );
        }
        return Row(children: [card(), const SizedBox(width: 16), card()]);
      },
    );
  }
}

class _HomeOverviewError extends StatelessWidget {
  const _HomeOverviewError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(radius: 24, child: Text(message));
  }
}

class NestedProgressRings extends StatelessWidget {
  const NestedProgressRings({
    super.key,
    required this.outerProgress,
    required this.innerProgress,
    required this.size,
    required this.centerLabel,
  });

  final double outerProgress;
  final double innerProgress;
  final double size;
  final String centerLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NestedProgressRingsPainter(
          outerProgress: outerProgress,
          innerProgress: innerProgress,
          primaryColor: Theme.of(context).colorScheme.primary,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              centerLabel,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.88),
                height: 1.35,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NestedProgressRingsPainter extends CustomPainter {
  _NestedProgressRingsPainter({
    required this.outerProgress,
    required this.innerProgress,
    required this.primaryColor,
  });

  final double outerProgress;
  final double innerProgress;
  final Color primaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    _paintRing(
      canvas,
      center: center,
      radius: (size.width / 2) - 8,
      progress: outerProgress,
      strokeWidth: 12,
      color: primaryColor.withValues(alpha: 0.9),
    );
    _paintRing(
      canvas,
      center: center,
      radius: (size.width / 2) - 28,
      progress: innerProgress,
      strokeWidth: 10,
      color: Colors.white,
    );
  }

  void _paintRing(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required double progress,
    required double strokeWidth,
    required Color color,
  }) {
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) {
      return;
    }

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, glowPaint);

    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _NestedProgressRingsPainter oldDelegate) {
    return oldDelegate.outerProgress != outerProgress ||
        oldDelegate.innerProgress != innerProgress ||
        oldDelegate.primaryColor != primaryColor;
  }
}
