import 'dart:io';
import 'dart:isolate';

Future<Directory?> resolvePackageRoot() async {
  final libUri = await Isolate.resolvePackageUri(
    Uri.parse('package:common_widget/app_bottom_spacing.dart'),
  );
  if (libUri == null) return null;

  final libFile = File(libUri.toFilePath());
  final libDir = libFile.parent;
  final packageRoot = libDir.parent;
  return packageRoot.existsSync() ? packageRoot : null;
}

Future<String> readTemplateFile({
  required Directory? packageRoot,
  required String relativePath,
  required String fallback,
}) async {
  if (packageRoot == null) return fallback;
  final file = File('${packageRoot.path}/$relativePath');
  if (!file.existsSync()) return fallback;
  return file.readAsString();
}

