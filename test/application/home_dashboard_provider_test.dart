import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/home_dashboard_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  test(
    'resolveHomeDisplayName prefers custom name then auth metadata then email',
    () {
      expect(
        resolveHomeDisplayName(
          customDisplayName: 'Alex',
          authUser: const AuthUser(
            id: '1',
            email: 'athlete@test.dev',
            displayName: 'Cloud Name',
          ),
          fallbackName: 'Athlete',
        ),
        'Alex',
      );
      expect(
        resolveHomeDisplayName(
          customDisplayName: null,
          authUser: const AuthUser(
            id: '1',
            email: 'athlete@test.dev',
            displayName: 'Cloud Name',
          ),
          fallbackName: 'Athlete',
        ),
        'Cloud Name',
      );
      expect(
        resolveHomeDisplayName(
          customDisplayName: null,
          authUser: const AuthUser(id: '1', email: 'athlete@test.dev'),
          fallbackName: 'Athlete',
        ),
        'athlete',
      );
    },
  );

  test('resolveGreetingPeriod maps hour ranges correctly', () {
    expect(
      resolveGreetingPeriod(DateTime(2026, 3, 28, 7)),
      HomeGreetingPeriod.morning,
    );
    expect(
      resolveGreetingPeriod(DateTime(2026, 3, 28, 14)),
      HomeGreetingPeriod.afternoon,
    );
    expect(
      resolveGreetingPeriod(DateTime(2026, 3, 28, 20)),
      HomeGreetingPeriod.evening,
    );
    expect(
      resolveGreetingPeriod(DateTime(2026, 3, 28, 2)),
      HomeGreetingPeriod.night,
    );
  });

  test(
    'homeDashboardDataProvider computes progress and unread milestone state',
    () async {
      final repository = InMemoryDatabaseRepository();
      await repository.saveHomeDisplayName('Alex');
      await repository.saveHomeMilestonesLastSeenAt(DateTime(2026, 3, 20));

      final container = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          authStateProvider.overrideWith(
            (ref) => Stream.value(
              const AuthUser(id: 'user-1', email: 'alex@test.dev'),
            ),
          ),
          todayWorkoutSummaryProvider.overrideWith(
            (ref) async => const TodayWorkoutSummary(
              instanceId: 'instance-1',
              workoutId: 'day-3',
              workoutName: 'Bench Peak',
              dayLabel: 'Day 3',
              currentWeekNumber: 2,
              currentDayNumber: 3,
              cycleWeekCount: 8,
              workoutsPerWeek: 4,
              primaryExerciseId: 'bench',
              primaryExerciseName: 'Bench Press',
              estimatedDurationMinutes: 80,
              exerciseCount: 5,
            ),
          ),
          progressAnalyticsOverviewProvider.overrideWith(
            (ref) async => ProgressAnalyticsOverview(
              completedWorkoutCount: 4,
              recentTrainingDays: 4,
              recentVolume: 1000,
              exerciseSummaries: [
                _summary(
                  id: 'squat',
                  name: 'Competition Squat',
                  estimated: [
                    _point(DateTime(2026, 3, 10), 120),
                    _point(DateTime(2026, 3, 24), 125),
                  ],
                ),
              ],
              highlightExerciseId: 'squat',
            ),
          ),
          homeDateTimeProvider.overrideWithValue(DateTime(2026, 3, 28, 9)),
        ],
      );
      addTearDown(container.dispose);

      final authUser = await container.read(authStateProvider.future);
      expect(authUser?.id, 'user-1');

      final data = await container.read(homeDashboardDataProvider.future);

      expect(data.displayName, 'Alex');
      expect(data.greetingPeriod, HomeGreetingPeriod.morning);
      expect(data.weekProgress, 0.5);
      expect(data.cycleProgress, 0.1875);
      expect(data.hasUnreadMilestones, isTrue);
    },
  );
}

ExercisePerformancePoint _point(DateTime completedAt, double value) {
  return ExercisePerformancePoint(
    completedAt: completedAt,
    weight: value,
    reps: 5,
    value: value,
    isActual: false,
  );
}

ExerciseProgressSummary _summary({
  required String id,
  required String name,
  required List<ExercisePerformancePoint> estimated,
}) {
  return ExerciseProgressSummary(
    exerciseId: id,
    exerciseName: name,
    encounterCount: estimated.length,
    currentEstimatedOneRepMax: estimated.last.value,
    bestEstimatedOneRepMax: estimated.last.value,
    currentActualOneRepMax: null,
    bestActualOneRepMax: null,
    recentChange: estimated.length < 2
        ? null
        : estimated.last.value - estimated.first.value,
    totalVolume: 0,
    lastCompletedAt: estimated.last.completedAt,
    isStagnating: false,
    personalRecords: const [],
    estimatedHistory: estimated,
    actualHistory: const [],
  );
}
