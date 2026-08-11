import 'dart:io';

void main() {
  final dir = Directory('lib/src/admin');
  var filesCount = 0;
  var replacesCount = 0;

  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      if (content.contains('.withOpacity(')) {
        final newContent = content.replaceAll('.withOpacity(', '.withValues(alpha: ');
        entity.writeAsStringSync(newContent);
        filesCount++;
        replacesCount += RegExp(r'\.withValues\(alpha: ').allMatches(newContent).length - RegExp(r'\.withValues\(alpha: ').allMatches(content).length;
      }
    }
  }

  print('Replaced .withOpacity with .withValues in $filesCount files (estimated $replacesCount occurrences).');
}
