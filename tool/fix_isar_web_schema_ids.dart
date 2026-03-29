import 'dart:io';

const _maxSafeJsInteger = 9007199254740991;
final _idPattern = RegExp(r'id: (-?\d{16,})');

void main(List<String> args) {
  final checkOnly = args.contains('--check');
  final files =
      Directory('lib/src/data/models')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.g.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  final changedFiles = <String>[];
  var replacementCount = 0;

  for (final file in files) {
    final original = file.readAsStringSync();
    var changed = false;

    final updated = original.replaceAllMapped(_idPattern, (match) {
      final value = int.parse(match.group(1)!);
      if (value.abs() <= _maxSafeJsInteger) {
        return match.group(0)!;
      }

      final normalized = value.toDouble().toInt();
      if (normalized == value) {
        return match.group(0)!;
      }

      changed = true;
      replacementCount += 1;
      return 'id: $normalized';
    });

    if (!changed) {
      continue;
    }

    changedFiles.add(file.path);
    if (!checkOnly) {
      file.writeAsStringSync(updated);
    }
  }

  if (checkOnly && changedFiles.isNotEmpty) {
    stderr.writeln(
      'Found $replacementCount unsafe Isar schema id literal(s) in:',
    );
    for (final path in changedFiles) {
      stderr.writeln(path);
    }
    exitCode = 1;
    return;
  }

  if (checkOnly) {
    stdout.writeln('All generated Isar schema ids are JavaScript-safe.');
    return;
  }

  stdout.writeln(
    'Normalized $replacementCount unsafe Isar schema id literal(s) in '
    '${changedFiles.length} file(s).',
  );
  for (final path in changedFiles) {
    stdout.writeln(path);
  }
}
