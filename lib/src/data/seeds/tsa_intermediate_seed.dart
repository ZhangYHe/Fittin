import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';

import 'seed_utils.dart';

class TsaIntermediateSeed {
  static const templateId = 'tsa-intermediate-approach-2-0';
  static const instanceId = 'active-tsa-intermediate-instance';
  static const assetPath = 'assets/plans/tsa_intermediate_approach_2_0.json';

  static Future<PlanTemplate> loadTemplate() async {
    return loadTemplateAsset(
      assetPath: assetPath,
      expectedTemplateId: templateId,
    );
  }

  static List<TrainingState> buildStarterStates(PlanTemplate template) {
    return buildStarterStatesForTemplate(template);
  }
}
