import 'package:fittin_v2/src/domain/models/training_plan.dart';

const double kilogramsPerPound = 0.45359237;
const double defaultKgBarWeight = 20;
const double defaultLbBarWeight = 45;
const List<double> kilogramPlateDenominations = [25, 20, 15, 10, 5, 2.5, 1.25];
const List<double> poundPlateDenominations = [45, 35, 25, 10, 5, 2.5];

double convertWeight(double value, String fromUnit, String toUnit) {
  if (fromUnit == toUnit) {
    return value;
  }
  if (fromUnit == LoadUnits.lbs && toUnit == LoadUnits.kg) {
    return value * kilogramsPerPound;
  }
  if (fromUnit == LoadUnits.kg && toUnit == LoadUnits.lbs) {
    return value / kilogramsPerPound;
  }
  return value;
}

double roundWeightForDisplay(double value, {int fallbackDecimals = 1}) {
  return value.truncateToDouble() == value
      ? value
      : double.parse(value.toStringAsFixed(fallbackDecimals));
}

PlateBreakdownResult computePlateBreakdown({
  required double totalWeight,
  required String unit,
  required double barWeight,
}) {
  final supportedUnit = unit == LoadUnits.lbs ? LoadUnits.lbs : LoadUnits.kg;
  final platePool = supportedUnit == LoadUnits.lbs
      ? poundPlateDenominations
      : kilogramPlateDenominations;
  final remainingLoad = totalWeight - barWeight;
  if (remainingLoad < 0) {
    return PlateBreakdownResult(
      unit: supportedUnit,
      barWeight: barWeight,
      exact: false,
      platesPerSide: const [],
      unresolvedWeight: totalWeight,
    );
  }
  final perSide = remainingLoad / 2;
  var unresolved = perSide;
  final plates = <PlateCount>[];
  for (final plate in platePool) {
    final count = (unresolved / plate).floor();
    if (count <= 0) {
      continue;
    }
    plates.add(PlateCount(weight: plate, count: count));
    unresolved -= plate * count;
  }
  final epsilon = supportedUnit == LoadUnits.lbs ? 0.05 : 0.025;
  final exact = unresolved.abs() <= epsilon;
  return PlateBreakdownResult(
    unit: supportedUnit,
    barWeight: barWeight,
    exact: exact,
    platesPerSide: plates,
    unresolvedWeight: exact ? 0 : unresolved * 2,
  );
}

class PlateBreakdownResult {
  const PlateBreakdownResult({
    required this.unit,
    required this.barWeight,
    required this.exact,
    required this.platesPerSide,
    required this.unresolvedWeight,
  });

  final String unit;
  final double barWeight;
  final bool exact;
  final List<PlateCount> platesPerSide;
  final double unresolvedWeight;
}

class PlateCount {
  const PlateCount({required this.weight, required this.count});

  final double weight;
  final int count;
}
