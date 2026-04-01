import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/sync_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';

import '../support/fake_today_workout_gateway.dart';
import '../support/in_memory_database_repository.dart';

class _TrackingSyncController extends SyncController {
  _TrackingSyncController(super.ref);

  int recoveryCalls = 0;

  @override
  Future<void> synchronizeWithRecovery({bool hydrate = false}) async {
    recoveryCalls += 1;
  }
}

void main() {
  test(
    'active session auto-restores persisted drafts on provider init',
    () async {
      final repository = InMemoryDatabaseRepository();
      final gateway = FakeTodayWorkoutGateway();
      final persistedDraft = fakeWorkoutSessionState.copyWith(
        exercises: [
          fakeWorkoutSessionState.exercises.first.copyWith(
            sets: [
              fakeWorkoutSessionState.exercises.first.sets.first.copyWith(
                completedReps: 6,
                isCompleted: true,
              ),
              fakeWorkoutSessionState.exercises.first.sets[1],
            ],
          ),
          fakeWorkoutSessionState.exercises[1],
        ],
      );

      await repository.saveInstance(
        StoredTrainingInstance(
          instanceId: fakeWorkoutSessionState.instanceId,
          templateId: fakeWorkoutSessionState.templateId,
          currentWorkoutIndex: 0,
          states: const [],
        ),
      );
      await repository.saveActiveInstanceId(fakeWorkoutSessionState.instanceId);
      await repository.saveActiveSessionDraft(persistedDraft);

      final container = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          todayWorkoutGatewayProvider.overrideWithValue(gateway),
        ],
      );
      addTearDown(container.dispose);

      container.read(activeSessionProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(gateway.sessionLoadCount, 0);
      expect(
        container
            .read(activeSessionProvider)
            .activeWorkout
            ?.exercises
            .first
            .sets
            .first
            .completedReps,
        6,
      );
      expect(
        container
            .read(activeSessionProvider)
            .activeWorkout
            ?.exercises
            .first
            .sets
            .first
            .isCompleted,
        true,
      );
    },
  );

  test('active session hydrates and persists drafts', () async {
    final repository = InMemoryDatabaseRepository();
    final gateway = FakeTodayWorkoutGateway();

    await repository.saveInstance(
      StoredTrainingInstance(
        instanceId: fakeWorkoutSessionState.instanceId,
        templateId: fakeWorkoutSessionState.templateId,
        currentWorkoutIndex: 0,
        states: const [],
      ),
    );
    await repository.saveActiveInstanceId(fakeWorkoutSessionState.instanceId);
    await repository.saveActiveSessionDraft(
      fakeWorkoutSessionState.copyWith(
        exercises: [
          fakeWorkoutSessionState.exercises.first.copyWith(
            sets: [
              fakeWorkoutSessionState.exercises.first.sets.first.copyWith(
                completedReps: 7,
              ),
              fakeWorkoutSessionState.exercises.first.sets[1],
            ],
          ),
          fakeWorkoutSessionState.exercises[1],
        ],
      ),
    );

    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        todayWorkoutGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);

    await container.read(activeSessionProvider.notifier).startOrResumeSession();

    expect(gateway.sessionLoadCount, 0);
    expect(
      container
          .read(activeSessionProvider)
          .activeWorkout
          ?.exercises
          .first
          .sets
          .first
          .completedReps,
      7,
    );

    container.read(activeSessionProvider.notifier).updateReps(0, 8);
    final savedDraft = await repository.fetchActiveSessionDraft(
      fakeWorkoutSessionState.instanceId,
    );
    expect(savedDraft?.exercises.first.sets.first.completedReps, 8);
  });

  test('active session supports set jumping, unit switching, and performed rpe', () async {
    final repository = InMemoryDatabaseRepository();
    final gateway = FakeTodayWorkoutGateway();
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        todayWorkoutGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);

    await container.read(activeSessionProvider.notifier).startOrResumeSession();

    final notifier = container.read(activeSessionProvider.notifier);
    notifier.selectSet(1);
    notifier.switchExerciseDisplayUnit('lbs');
    notifier.updateWeightFromDisplayUnit(1, 225, displayUnit: 'lbs');
    notifier.updateCompletedRpe(1, 7.5);

    final workout = container.read(activeSessionProvider).activeWorkout!;
    final set = workout.exercises.first.sets[1];

    expect(workout.exercises.first.currentSetIndex, 1);
    expect(workout.exercises.first.displayLoadUnit, 'lbs');
    expect(set.completedRpe, 7.5);
    expect(set.weight, closeTo(102.058, 0.001));
  });

  test('concluding a signed-in workout triggers auto sync recovery', () async {
    final repository = InMemoryDatabaseRepository();
    final gateway = FakeTodayWorkoutGateway();
    _TrackingSyncController? tracker;
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        todayWorkoutGatewayProvider.overrideWithValue(gateway),
        currentUserIdProvider.overrideWithValue('signed-in-user'),
        syncControllerProvider.overrideWith((ref) {
          tracker = _TrackingSyncController(ref);
          return tracker!;
        }),
      ],
    );
    addTearDown(container.dispose);

    container.read(syncControllerProvider.notifier);
    await container.read(activeSessionProvider.notifier).startOrResumeSession();
    final success = await container.read(activeSessionProvider.notifier).concludeSession();
    await Future<void>.delayed(Duration.zero);

    expect(success, true);
    expect(gateway.concludedSession, isNotNull);
    expect(tracker?.recoveryCalls, 1);
  });

  test('concluding a signed-out workout does not trigger auto sync', () async {
    final repository = InMemoryDatabaseRepository();
    final gateway = FakeTodayWorkoutGateway();
    _TrackingSyncController? tracker;
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        todayWorkoutGatewayProvider.overrideWithValue(gateway),
        currentUserIdProvider.overrideWithValue(null),
        syncControllerProvider.overrideWith((ref) {
          tracker = _TrackingSyncController(ref);
          return tracker!;
        }),
      ],
    );
    addTearDown(container.dispose);

    container.read(syncControllerProvider.notifier);
    await container.read(activeSessionProvider.notifier).startOrResumeSession();
    final success = await container.read(activeSessionProvider.notifier).concludeSession();
    await Future<void>.delayed(Duration.zero);

    expect(success, true);
    expect(tracker?.recoveryCalls, 0);
  });
}
