import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/pr_dashboard_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/screens/advanced_analytics_screen.dart';
import 'package:fittin_v2/src/presentation/screens/exercise_deep_dive_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/chart_container.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/line_chart_painter.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';

class PRDashboardScreen extends ConsumerStatefulWidget {
  const PRDashboardScreen({super.key});

  @override
  ConsumerState<PRDashboardScreen> createState() => _PRDashboardScreenState();
}

class _PRDashboardScreenState extends ConsumerState<PRDashboardScreen> {
  PRMetricMode _metricMode = PRMetricMode.estimated;
  String _selectedLiftKey = 'squat';

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(prDashboardDataProvider);
    final strings = AppStrings.of(context, ref);

    return Scaffold(
      backgroundColor: Colors.black,
      body: dataAsync.when(
        data: (data) {
          _selectedLiftKey = _resolveSelectedLiftKey(data);
          return DashboardPageScaffold(
            children: [
              DashboardScreenHeader(
                eyebrow: strings.performance,
                title: strings.prDashboard,
                subtitle: strings.prDashboardSubtitle,
              ),
              const SizedBox(height: 24),
              _buildMetricToggle(strings),
              const SizedBox(height: 16),
              _buildQuickStats(context, strings, data),
              const SizedBox(height: 24),
              _buildMainChart(context, strings, data),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: DashboardSectionLabel(
                      label: strings.recentMilestones,
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('view-all-milestones'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MilestoneHistoryScreen(
                            milestones: data.allMilestones,
                          ),
                        ),
                      );
                    },
                    child: Text(strings.viewAllMilestones),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (data.recentMilestones.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(strings.noMilestonesYet),
                )
              else
                ...data.recentMilestones.map(
                  (milestone) => _MilestoneTile(
                    milestone: milestone,
                    locale: ref.watch(appLocaleProvider),
                    valueLabel: strings.milestoneValueLabel(
                      _localizedMilestoneLabel(strings, milestone.type),
                      milestone.value,
                    ),
                    onTap: () {
                      final summary = milestone.summary;
                      if (summary != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ExerciseDeepDiveScreen(summary: summary),
                          ),
                        );
                      }
                    },
                  ),
                ),
              const SizedBox(height: 40),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  String _resolveSelectedLiftKey(PRDashboardData data) {
    final available = {
      if (data.squat != null) 'squat',
      if (data.bench != null) 'bench',
      if (data.deadlift != null) 'deadlift',
    };
    if (available.contains(_selectedLiftKey)) {
      return _selectedLiftKey;
    }
    return available.firstOrNull ?? 'squat';
  }

  Widget _buildMetricToggle(AppStrings strings) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<PRMetricMode>(
        key: const ValueKey('pr-metric-toggle'),
        showSelectedIcon: false,
        expandedInsets: EdgeInsets.zero,
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        segments: [
          ButtonSegment(
            value: PRMetricMode.estimated,
            label: Text(
              strings.estimated1rmShort,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          ButtonSegment(
            value: PRMetricMode.actual,
            label: Text(
              strings.actualPrShort,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
        selected: {_metricMode},
        onSelectionChanged: (selection) {
          setState(() {
            _metricMode = selection.first;
          });
        },
      ),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    AppStrings strings,
    PRDashboardData data,
  ) {
    final cards = [
      _StrengthCard(
        key: const ValueKey('strength-card-squat'),
        summary: data.squat,
        label: strings.squatShort.toUpperCase(),
        metricMode: _metricMode,
        onTap: () => _navigateToDeepDive(context, data.squat),
      ),
      _StrengthCard(
        key: const ValueKey('strength-card-bench'),
        summary: data.bench,
        label: strings.benchShort.toUpperCase(),
        metricMode: _metricMode,
        onTap: () => _navigateToDeepDive(context, data.bench),
      ),
      _StrengthCard(
        key: const ValueKey('strength-card-deadlift'),
        summary: data.deadlift,
        label: strings.deadliftShort.toUpperCase(),
        metricMode: _metricMode,
        onTap: () => _navigateToDeepDive(context, data.deadlift),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 420) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i < cards.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
            const SizedBox(width: 12),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }

  void _navigateToDeepDive(
    BuildContext context,
    ExerciseProgressSummary? summary,
  ) {
    if (summary != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExerciseDeepDiveScreen(summary: summary),
        ),
      );
    }
  }

  Widget _buildMainChart(
    BuildContext context,
    AppStrings strings,
    PRDashboardData data,
  ) {
    final selectedSummary = switch (_selectedLiftKey) {
      'bench' => data.bench,
      'deadlift' => data.deadlift,
      _ => data.squat,
    };

    return ChartContainer(
      title: strings.strengthProgressionTitle,
      height: 260,
      headerAction: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                key: const ValueKey('chart-lift-toggle'),
                showSelectedIcon: false,
                expandedInsets: EdgeInsets.zero,
                style: ButtonStyle(
                  textStyle: WidgetStatePropertyAll(
                    Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                segments: [
                  ButtonSegment(
                    value: 'squat',
                    label: Text(
                      strings.squatShort,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ButtonSegment(
                    value: 'bench',
                    label: Text(
                      strings.benchShort,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ButtonSegment(
                    value: 'deadlift',
                    label: Text(
                      strings.deadliftShort,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                selected: {_selectedLiftKey},
                onSelectionChanged: (selection) {
                  setState(() {
                    _selectedLiftKey = selection.first;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (selectedSummary != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                selectedSummary.exerciseName,
                key: const ValueKey('selected-chart-lift-label'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdvancedAnalyticsScreen(),
              ),
            ),
            child: Text(
              strings.detailsCta,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      child: _LiftChart(
        summary: selectedSummary,
        metricMode: _metricMode,
        axisWeightLabelBuilder: strings.chartAxisWeight,
        localeCode: ref.watch(appLocaleProvider).code,
      ),
    );
  }
}

class _StrengthCard extends StatelessWidget {
  const _StrengthCard({
    super.key,
    this.summary,
    required this.label,
    required this.metricMode,
    this.onTap,
  });

  final ExerciseProgressSummary? summary;
  final String label;
  final PRMetricMode metricMode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final value = metricMode == PRMetricMode.actual
        ? summary?.bestActualOneRepMax
        : summary?.currentEstimatedOneRepMax;
    final change = metricMode == PRMetricMode.actual
        ? _actualPrDelta(summary)
        : summary?.recentChange;

    return DashboardSurfaceCard(
      onTap: onTap,
      radius: 24,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 144,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.55),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value?.toStringAsFixed(1) ?? '—',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 20,
              child: Align(
                alignment: Alignment.centerLeft,
                child: change == null
                    ? const SizedBox.shrink()
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.58),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double? _actualPrDelta(ExerciseProgressSummary? summary) {
    final history = summary?.actualHistory;
    if (history == null || history.length < 2) {
      return null;
    }
    return history.last.value - history[history.length - 2].value;
  }
}

class _LiftChart extends StatelessWidget {
  const _LiftChart({
    required this.summary,
    required this.metricMode,
    required this.axisWeightLabelBuilder,
    required this.localeCode,
  });

  final ExerciseProgressSummary? summary;
  final PRMetricMode metricMode;
  final String Function(String value) axisWeightLabelBuilder;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final history = metricMode == PRMetricMode.actual
        ? (summary?.actualHistory ?? const <ExercisePerformancePoint>[])
        : (summary?.estimatedHistory ?? const <ExercisePerformancePoint>[]);
    if (summary == null || history.isEmpty) {
      return const Center(child: Text('—'));
    }

    final recent = history.length > 8
        ? history.sublist(history.length - 8)
        : history;
    final minValue = recent
        .map((point) => point.value)
        .reduce((a, b) => a < b ? a : b);
    final maxValue = recent
        .map((point) => point.value)
        .reduce((a, b) => a > b ? a : b);
    final safeRange = (maxValue - minValue).abs() < 0.001
        ? 1.0
        : (maxValue - minValue);
    final chartMin = minValue - safeRange * 0.1;
    final chartMax = maxValue + safeRange * 0.1;
    final chartRange = (chartMax - chartMin).abs() < 0.001
        ? 1.0
        : (chartMax - chartMin);

    final dataset = LineChartDataset(
      points: [
        for (var index = 0; index < recent.length; index++)
          Offset(
            recent.length == 1 ? 0.5 : index / (recent.length - 1),
            (recent[index].value - chartMin) / chartRange,
          ),
      ],
      color: _liftColor(summary!.exerciseName),
      label: summary!.exerciseName,
    );

    final yAxisValues = [
      chartMin,
      chartMin + chartRange * 0.25,
      chartMin + chartRange * 0.5,
      chartMin + chartRange * 0.75,
      chartMax,
    ].reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 54,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final value in yAxisValues)
                      Text(
                        axisWeightLabelBuilder(value.toStringAsFixed(0)),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomPaint(
                  painter: LineChartPainter(
                    datasets: [dataset],
                    horizontalGridLines: 4,
                    verticalGridLines: recent.length > 1
                        ? recent.length - 1
                        : 1,
                  ),
                  size: Size.infinite,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final point in _selectTickPoints(recent))
              Text(
                _formatShortDate(point.completedAt, localeCode),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
          ],
        ),
      ],
    );
  }

  List<ExercisePerformancePoint> _selectTickPoints(
    List<ExercisePerformancePoint> points,
  ) {
    if (points.length <= 3) {
      return points;
    }
    return [points.first, points[points.length ~/ 2], points.last];
  }

  Color _liftColor(String exerciseName) {
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

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({
    required this.milestone,
    required this.locale,
    required this.valueLabel,
    this.onTap,
  });

  final PRMilestone milestone;
  final AppLocale locale;
  final String valueLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatShortDate(milestone.date, locale.code);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DashboardSurfaceCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        radius: 22,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Colors.amberAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.exerciseName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    valueLabel,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              dateLabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum MilestoneTimeFilter { all, days30, days90, days365 }

enum MilestoneTypeFilter { all, estimated, actual }

class MilestoneHistoryScreen extends ConsumerStatefulWidget {
  const MilestoneHistoryScreen({super.key, required this.milestones});

  final List<PRMilestone> milestones;

  @override
  ConsumerState<MilestoneHistoryScreen> createState() =>
      _MilestoneHistoryScreenState();
}

class _MilestoneHistoryScreenState
    extends ConsumerState<MilestoneHistoryScreen> {
  String? _exerciseFilter;
  MilestoneTypeFilter _typeFilter = MilestoneTypeFilter.all;
  MilestoneTimeFilter _timeFilter = MilestoneTimeFilter.all;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final locale = ref.watch(appLocaleProvider);
    final exerciseOptions =
        widget.milestones
            .map((milestone) => milestone.exerciseName)
            .toSet()
            .toList()
          ..sort();
    final filtered = widget.milestones.where(_matchesFilters).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: DashboardPageScaffold(
        children: [
          DashboardScreenHeader(
            eyebrow: strings.recentMilestones,
            title: strings.milestoneHistory,
            showBackButton: true,
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String?>(
            key: const ValueKey('milestone-lift-filter'),
            value: _exerciseFilter,
            decoration: InputDecoration(labelText: strings.liftFilter),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(strings.allExercises),
              ),
              for (final exerciseName in exerciseOptions)
                DropdownMenuItem<String?>(
                  value: exerciseName,
                  child: Text(exerciseName),
                ),
            ],
            onChanged: (value) => setState(() => _exerciseFilter = value),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<MilestoneTimeFilter>(
            key: const ValueKey('milestone-time-filter'),
            value: _timeFilter,
            decoration: InputDecoration(labelText: strings.timeRange),
            items: [
              DropdownMenuItem(
                value: MilestoneTimeFilter.all,
                child: Text(strings.allTime),
              ),
              DropdownMenuItem(
                value: MilestoneTimeFilter.days30,
                child: Text(strings.last30Days),
              ),
              DropdownMenuItem(
                value: MilestoneTimeFilter.days90,
                child: Text(strings.last90Days),
              ),
              DropdownMenuItem(
                value: MilestoneTimeFilter.days365,
                child: Text(strings.last365Days),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _timeFilter = value);
              }
            },
          ),
          const SizedBox(height: 16),
          SegmentedButton<MilestoneTypeFilter>(
            key: const ValueKey('milestone-type-filter'),
            segments: [
              ButtonSegment<MilestoneTypeFilter>(
                value: MilestoneTypeFilter.all,
                label: Text(strings.allTypes),
              ),
              ButtonSegment<MilestoneTypeFilter>(
                value: MilestoneTypeFilter.estimated,
                label: Text(strings.estimatedType),
              ),
              ButtonSegment<MilestoneTypeFilter>(
                value: MilestoneTypeFilter.actual,
                label: Text(strings.actualType),
              ),
            ],
            selected: {_typeFilter},
            onSelectionChanged: (selection) {
              setState(() {
                _typeFilter = selection.first;
              });
            },
          ),
          const SizedBox(height: 20),
          if (filtered.isEmpty)
            Text(
              widget.milestones.isEmpty
                  ? strings.noMilestonesYet
                  : strings.noFilteredMilestones,
            )
          else
            ...filtered.map(
              (milestone) => _MilestoneTile(
                milestone: milestone,
                locale: locale,
                valueLabel: strings.milestoneValueLabel(
                  _localizedMilestoneLabel(strings, milestone.type),
                  milestone.value,
                ),
                onTap: () {
                  final summary = milestone.summary;
                  if (summary != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ExerciseDeepDiveScreen(summary: summary),
                      ),
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  bool _matchesFilters(PRMilestone milestone) {
    if (_exerciseFilter != null && milestone.exerciseName != _exerciseFilter) {
      return false;
    }
    switch (_typeFilter) {
      case MilestoneTypeFilter.all:
        break;
      case MilestoneTypeFilter.estimated:
        if (milestone.type != PRMilestoneType.estimated) {
          return false;
        }
      case MilestoneTypeFilter.actual:
        if (milestone.type != PRMilestoneType.actual) {
          return false;
        }
    }
    final now = DateTime.now();
    final difference = now.difference(milestone.date).inDays;
    return switch (_timeFilter) {
      MilestoneTimeFilter.all => true,
      MilestoneTimeFilter.days30 => difference <= 30,
      MilestoneTimeFilter.days90 => difference <= 90,
      MilestoneTimeFilter.days365 => difference <= 365,
    };
  }
}

String _localizedMilestoneLabel(AppStrings strings, PRMilestoneType type) {
  return type == PRMilestoneType.actual
      ? strings.actualType
      : strings.estimatedType;
}

String _formatShortDate(DateTime date, String localeCode) {
  if (localeCode == 'zh') {
    return '${date.month}月${date.day}日';
  }
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}
