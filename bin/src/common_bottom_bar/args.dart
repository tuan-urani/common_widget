class ParsedArgs {
  const ParsedArgs({
    required this.showHelp,
    required this.typeRaw,
    required this.tabsRaw,
  });

  final bool showHelp;
  final String? typeRaw;
  final String? tabsRaw;
}

ParsedArgs parseArgs(List<String> args) {
  if (args.isEmpty) {
    return const ParsedArgs(showHelp: true, typeRaw: null, tabsRaw: null);
  }

  String? typeRaw;
  String? tabsRaw;
  var showHelp = false;

  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--help' || a == '-h') {
      showHelp = true;
      continue;
    }
    if (a.startsWith('--type=')) {
      typeRaw = a.substring('--type='.length);
      continue;
    }
    if (a == '--type' && i + 1 < args.length) {
      typeRaw = args[i + 1];
      i++;
      continue;
    }
    if (a.startsWith('--tabs=')) {
      tabsRaw = a.substring('--tabs='.length);
      continue;
    }
    if (a == '--tabs' && i + 1 < args.length) {
      tabsRaw = args[i + 1];
      i++;
      continue;
    }
  }

  return ParsedArgs(showHelp: showHelp, typeRaw: typeRaw, tabsRaw: tabsRaw);
}

String usage() {
  return [
    'Tạo code bottom bar vào thư mục Project/lib/src/... ',
    '',
    'Cú pháp:',
    '  dart run common_widget:common_bottom_bar --type <standard|top-notch> --tabs <t1,t2,t3>',
    '',
    'Ví dụ:',
    '  dart run common_widget:common_bottom_bar --type standard --tabs home,user,settings',
    '  dart run common_widget:common_bottom_bar --type top-notch --tabs home,calendar,settings',
    '',
    'Ghi chú:',
    '- Nếu chạy ngay trong repo common_widget thì có thể dùng: dart run common_bottom_bar ...',
    '- tabs là danh sách tên tab, sẽ được dùng làm enum value (snake_case).',
  ].join('\n');
}

enum BottomBarType { standard, topNotch }

BottomBarType? parseType(String? raw) {
  final v = raw?.trim().toLowerCase();
  if (v == null || v.isEmpty) return null;
  if (v == 'standard') return BottomBarType.standard;
  if (v == 'top-notch' || v == 'top_notch' || v == 'topnotch') {
    return BottomBarType.topNotch;
  }
  return null;
}

List<String> parseTabs(String? raw) {
  final v = raw?.trim();
  if (v == null || v.isEmpty) return const [];

  final tabs = v
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .map(_normalizeEnumValue)
      .where((e) => e.isNotEmpty)
      .toList();

  final unique = <String>[];
  for (final t in tabs) {
    if (!unique.contains(t)) unique.add(t);
  }
  return unique;
}

String _normalizeEnumValue(String input) {
  final s = input.trim().toLowerCase().replaceAll('-', '_');
  final buf = StringBuffer();
  for (final rune in s.runes) {
    final c = String.fromCharCode(rune);
    final isValid =
        RegExp(r'^[a-z0-9_]$').hasMatch(c) && !(buf.isEmpty && c == '_');
    if (isValid) buf.write(c);
  }
  var out = buf.toString();
  out = out.replaceAll(RegExp(r'_+'), '_');
  out = out.replaceAll(RegExp(r'^_+|_+$'), '');
  if (out.isEmpty) return '';
  if (RegExp(r'^[0-9]').hasMatch(out)) return 'tab_$out';
  return out;
}
