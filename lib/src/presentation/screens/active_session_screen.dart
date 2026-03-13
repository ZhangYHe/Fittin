import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/localization/plan_text.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';

class ActiveSessionScreen extends ConsumerWidget {
  const ActiveSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(activeSessionProvider);
    final template = ref.watch(activeTemplateProvider).valueOrNull;
    final locale = ref.watch(appLocaleProvider);
    final strings = AppStrings.of(context, ref);
    final notifier = ref.read(activeSessionProvider.notifier);
    final theme = Theme.of(context);
    final workout = sessionState.activeWorkout;

    if (sessionState.isLoading && workout == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (workout == null) {
      return Scaffold(
        body: Center(
          child: Text(
            sessionState.errorMessage ?? strings.noActiveWorkoutSession,
            style: theme.textTheme.bodyLarge,
          ),
        ),
      );
    }

    final localizedWorkout = template?.findWorkoutById(workout.workoutId);
    final displayWorkoutName = localizedWorkout == null
        ? workout.workoutName
        : localizedWorkoutName(localizedWorkout, locale);
    final displayDayLabel = localizedWorkout == null
        ? workout.dayLabel
        : localizedWorkoutDayLabel(localizedWorkout, locale);

    String localizedExercise(ExerciseSessionState exercise) {
      if (template == null) return exercise.exerciseName;
      try {
        return localizedExerciseName(
          template.findExerciseById(exercise.id),
          locale,
        );
      } on StateError {
        return exercise.exerciseName;
      }
    }

    final currentExercise = workout.exercises[workout.currentExerciseIndex];
    final currentExerciseName = localizedExercise(currentExercise);
    final currentSetIndex = currentExercise.sets.indexWhere(
      (set) => !set.isCompleted,
    );
    final resolvedSetIndex = currentSetIndex == -1
        ? currentExercise.sets.length - 1
        : currentSetIndex;
    final currentSet = currentExercise.sets[resolvedSetIndex];
    final completedSetCount = currentExercise.sets
        .where((set) => set.isCompleted)
        .length;
    final totalSetCount = currentExercise.sets.length;

    return DashboardPageScaffold(
      bottomPadding: 180,
      children: [
        DashboardScreenHeader(
          eyebrow: displayDayLabel,
          title: displayWorkoutName,
          subtitle: strings.isChinese
              ? '当前聚焦动作与当前组控制台'
              : 'Focused workout console for the current lift and set',
          trailing: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ),
        const SizedBox(height: 24),
        DashboardSurfaceCard(
          highlight: true,
          radius: 32,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    child: const Icon(Icons.fitness_center_rounded, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentExerciseName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          strings.isChinese
                              ? '第 ${resolvedSetIndex + 1} 组 / 共 $totalSetCount 组'
                              : 'Set ${resolvedSetIndex + 1} / $totalSetCount',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.66),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                strings.isChinese
                    ? '已完成 $completedSetCount 组 · 上次 ${_formatSetPreview(currentSet)}'
                    : '$completedSetCount sets done · Current ${_formatSetPreview(currentSet)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.58),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _HeroMetric(
                      label: strings.isChinese ? '层级' : 'Tier',
                      value: currentExercise.tier,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HeroMetric(
                      label: strings.isChinese ? '方案' : 'Scheme',
                      value: currentExercise.stageId.replaceAll('t', 'T'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HeroMetric(
                      label: strings.isChinese ? '目标' : 'Target',
                      value:
                          '${_formatWeight(currentSet.targetWeight)} · ${currentSet.targetReps}${currentSet.isAmrap ? '+' : ''}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        DashboardSectionLabel(
          label: strings.isChinese ? '动作切换' : 'Exercise Rail',
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 74,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: workout.exercises.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final exercise = workout.exercises[index];
              final localizedName = localizedExercise(exercise);
              final isActive = index == workout.currentExerciseIndex;
              final done = exercise.sets.where((set) => set.isCompleted).length;
              return _ExerciseRailChip(
                name: localizedName,
                tier: exercise.tier,
                completed: done,
                active: isActive,
                onTap: () => notifier.selectExercise(index),
              );
            },
          ),
        ),
        const SizedBox(height: 28),
        DashboardSectionLabel(
          label: strings.isChinese ? '当前训练组' : 'Current Set',
        ),
        const SizedBox(height: 12),
        DashboardSurfaceCard(
          highlight: true,
          radius: 34,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          child: Column(
            children: [
              Row(
                children: [
                  _QuickAdjustButton(
                    icon: Icons.remove_rounded,
                    onTap: currentSet.completedReps > 0
                        ? () => notifier.updateReps(
                            resolvedSetIndex,
                            currentSet.completedReps - 1,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.94),
                            Colors.white.withValues(alpha: 0.72),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.24,
                            ),
                            blurRadius: 40,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center_rounded,
                            color: Colors.black.withValues(alpha: 0.72),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '+1',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            strings.isChinese ? '次数' : 'REPS',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.black.withValues(alpha: 0.78),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _QuickAdjustButton(
                    icon: Icons.replay_rounded,
                    onTap: () => notifier.updateReps(resolvedSetIndex, 0),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => notifier.updateReps(
                  resolvedSetIndex,
                  currentSet.completedReps + 1,
                ),
                child: DashboardControlTile(
                  label: strings.isChinese ? '当前次数' : 'Current Reps',
                  value: '${currentSet.completedReps}',
                  accent: true,
                  trailing: Text(
                    currentSet.isAmrap ? 'AMRAP' : '${currentSet.targetReps}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => notifier.updateWeight(
                        resolvedSetIndex,
                        currentSet.weight - 2.5 < 0
                            ? 0
                            : currentSet.weight - 2.5,
                      ),
                      child: DashboardControlTile(
                        label: strings.isChinese ? '重量' : 'Weight',
                        value: _formatWeight(currentSet.weight),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => notifier.updateWeight(
                        resolvedSetIndex,
                        currentSet.weight + 2.5,
                      ),
                      child: DashboardControlTile(
                        label: strings.isChinese ? '目标' : 'Target',
                        value: _formatWeight(currentSet.targetWeight),
                        trailing: Text(
                          currentSet.isCompleted ? 'DONE' : '+2.5',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        DashboardSectionLabel(label: strings.isChinese ? '组进度' : 'Set Log'),
        const SizedBox(height: 10),
        DashboardSurfaceCard(
          radius: 28,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              for (var i = 0; i < currentExercise.sets.length; i++) ...[
                _SetProgressDot(
                  index: i,
                  set: currentExercise.sets[i],
                  active: i == resolvedSetIndex,
                  onTap: () {
                    if (i < currentExercise.sets.length) {
                      // bring tapped set into focus through exercise state only
                      if (i != resolvedSetIndex) {
                        final target = currentExercise.sets[i];
                        notifier.updateReps(i, target.completedReps);
                      }
                    }
                  },
                ),
                if (i != currentExercise.sets.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 28),
        PremiumPrimaryButton(
          label: sessionState.isLoading
              ? strings.saving
              : strings.concludeWorkout,
          icon: Icons.check_circle_outline_rounded,
          loading: sessionState.isLoading,
          onPressed: () async {
            final success = await notifier.concludeSession();
            if (!context.mounted) return;
            if (success) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(strings.workoutSaved)));
              Navigator.of(context).pop();
            } else {
              final latestState = ref.read(activeSessionProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    latestState.errorMessage ?? 'Unable to conclude workout.',
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

String _formatWeight(double value) {
  return value.truncateToDouble() == value
      ? '${value.toStringAsFixed(0)} kg'
      : '${value.toStringAsFixed(1)} kg';
}

String _formatSetPreview(SessionSetState set) {
  return '${_formatWeight(set.weight)} x ${set.completedReps}';
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DashboardControlTile(label: label, value: value);
  }
}

class _ExerciseRailChip extends StatelessWidget {
  const _ExerciseRailChip({
    required this.name,
    required this.tier,
    required this.completed,
    required this.active,
    required this.onTap,
  });

  final String name;
  final String tier;
  final int completed;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 220,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: active
              ? Colors.white.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: active
                ? Colors.white.withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active
                    ? Colors.black.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '$completed',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: active ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$tier $name',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.black : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAdjustButton extends StatelessWidget {
  const _QuickAdjustButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 74,
        height: 74,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(
          icon,
          size: 32,
          color: Colors.white.withValues(alpha: 0.86),
        ),
      ),
    );
  }
}

class _SetProgressDot extends StatelessWidget {
  const _SetProgressDot({
    required this.index,
    required this.set,
    required this.active,
    required this.onTap,
  });

  final int index;
  final SessionSetState set;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: active ? 20 : 16,
            height: active ? 20 : 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: set.isCompleted
                  ? Colors.white
                  : active
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              border: Border.all(
                color: set.isCompleted
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.32),
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.34),
                        blurRadius: 18,
                        offset: const Offset(0, 0),
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${index + 1}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
