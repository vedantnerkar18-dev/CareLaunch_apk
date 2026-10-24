import 'package:flutter_test/flutter_test.dart';
import 'package:carelaunch/logic/fuzzy_engine.dart';
import 'package:carelaunch/models/severity_level.dart';

void main() {
  const engine = FuzzyEngine();

  SeverityLevel levelForRaw(int raw) =>
      engine.classify(engine.normalize(raw, 13)).level;

  test('all lowest answers give level 1', () {
    expect(levelForRaw(13), SeverityLevel.level1);
  });

  test('all middle answers give level 2', () {
    expect(levelForRaw(26), SeverityLevel.level2);
  });

  test('all highest answers give level 3', () {
    expect(levelForRaw(39), SeverityLevel.level3);
  });
}