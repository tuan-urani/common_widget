String tabLabel(String enumValue) {
  final words = enumValue
      .split('_')
      .where((e) => e.isNotEmpty)
      .map(
        (w) =>
            w.length <= 1
                ? w.toUpperCase()
                : '${w[0].toUpperCase()}${w.substring(1)}',
      )
      .toList();
  if (words.isEmpty) return enumValue;
  return words.join(' ');
}

String pascalCase(String enumValue) {
  final parts = enumValue.split('_').where((e) => e.isNotEmpty);
  final buf = StringBuffer();
  for (final p in parts) {
    if (p.length == 1) {
      buf.write(p.toUpperCase());
    } else {
      buf.write('${p[0].toUpperCase()}${p.substring(1)}');
    }
  }
  final out = buf.toString();
  return out.isEmpty ? 'Tab' : out;
}
