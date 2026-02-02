import 'dart:io';

Future<String?> readProjectName(File pubspecFile) async {
  final pubspecContent = await pubspecFile.readAsString();
  final nameRegExp = RegExp(r'^name:\s+([a-zA-Z0-9_]+)', multiLine: true);
  final match = nameRegExp.firstMatch(pubspecContent);
  return match?.group(1);
}
