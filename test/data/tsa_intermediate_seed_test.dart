import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/data/seeds/tsa_intermediate_seed.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'tsa intermediate asset seeds an 8-week four-day built-in plan',
    () async {
      final template = await TsaIntermediateSeed.loadTemplate();
      final workouts = template.workouts;

      expect(template.id, TsaIntermediateSeed.templateId);
      expect(template.engineFamily, 'periodized_tm');
      expect(template.requiredTrainingMaxKeys, ['squat', 'bench', 'deadlift']);
      expect(template.engineConfig['cycleLengthWeeks'], 8);
      expect(workouts.length, 4);

      for (final workout in workouts) {
        expect(workout.exercises.length, 5);
        for (final exercise in workout.exercises) {
          expect(exercise.stages.length, 8);
        }
      }

      expect(
        workouts.first.exercises.map((exercise) => exercise.name).toList(),
        [
          'Competition Squat',
          'Bench Press',
          'Close Grip Bench Press',
          'Chest Supported Row',
          'Band Pull-Aparts',
        ],
      );

      final closeGripBench = workouts.first.exercises[2];
      expect(closeGripBench.trainingMaxLift, 'bench');
      expect(closeGripBench.equipmentType, EquipmentTypes.barbell);
      expect(closeGripBench.stages.first.sets.first.targetRpe, 7.0);
    },
  );
}
