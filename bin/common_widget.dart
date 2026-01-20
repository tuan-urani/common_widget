import 'dart:io';
import 'dart:isolate';

/// Script này sẽ được đặt trong repo common_widget tại đường dẫn: bin/common_widget.dart
/// Khi người dùng chạy 'dart run common_widget', Dart sẽ thực thi file này.

void main(List<String> args) async {
  print('📦 Common Widget Sync Tool starting...');

  // 1. Xác định thư mục gốc của dự án đang chạy lệnh (Host Project)
  final hostRoot = Directory.current;
  final pubspecFile = File('${hostRoot.path}/pubspec.yaml');

  if (!pubspecFile.existsSync()) {
    print(
      '❌ Lỗi: Không tìm thấy pubspec.yaml. Hãy chạy lệnh này tại thư mục gốc của dự án Flutter.',
    );
    return;
  }

  // 2. Lấy tên của Host Project
  final pubspecContent = await pubspecFile.readAsString();
  final nameRegExp = RegExp(r'^name:\s+([a-zA-Z0-9_]+)', multiLine: true);
  final match = nameRegExp.firstMatch(pubspecContent);

  if (match == null) {
    print('❌ Lỗi: Không tìm thấy tên dự án trong pubspec.yaml');
    return;
  }

  final projectName = match.group(1)!;
  print('🚀 Đang xử lý cho project: $projectName');

  // 3. Xác định thư mục nguồn (Source - chính là thư mục lib của package common_widget này)
  // Sử dụng Isolate.resolvePackageUri để tìm đường dẫn thực tế của package:common_widget/
  // Cách này hoạt động chính xác ngay cả khi package nằm trong pub cache (khi dùng Git)
  final packageUri = await Isolate.resolvePackageUri(
    Uri.parse('package:common_widget/'),
  );

  if (packageUri == null) {
    print(
      '❌ Lỗi: Không thể xác định vị trí package common_widget trong pub cache.',
    );
    return;
  }

  final sourceDir = Directory(packageUri.toFilePath());

  if (!sourceDir.existsSync()) {
    print('❌ Lỗi: Không tìm thấy thư mục nguồn tại ${sourceDir.path}');
    return;
  }

  // 4. Xác định thư mục đích (Target)
  final targetDirPath = '${hostRoot.path}/lib/src/ui/widgets';
  final targetDir = Directory(targetDirPath);

  if (!targetDir.existsSync()) {
    targetDir.createSync(recursive: true);
  }

  print('📥 Đang sao chép code từ package vào $targetDirPath...');

  // 5. Thực hiện copy và replace import
  await _syncDirectory(sourceDir, targetDir, projectName);

  print(
    '✨ Hoàn tất! Toàn bộ widgets đã được đồng bộ và cập nhật import theo package "$projectName".',
  );
}

Future<void> _syncDirectory(
  Directory source,
  Directory destination,
  String projectName,
) async {
  await for (var entity in source.list(recursive: false)) {
    final name = entity.path.split(Platform.pathSeparator).last;

    if (entity is Directory) {
      final newDest = Directory('${destination.path}/$name');
      if (!newDest.existsSync()) newDest.createSync();
      await _syncDirectory(entity, newDest, projectName);
    } else if (entity is File) {
      final targetFile = File('${destination.path}/$name');

      if (name.endsWith('.dart')) {
        String content = await entity.readAsString();
        // Replace package:link_home/ bằng package:tên_dự_án/
        // Mặc định source code trong lib/ của package này dùng placeholder 'link_home'
        final updatedContent = content.replaceAll(
          'package:link_home/',
          'package:$projectName/',
        );
        await targetFile.writeAsString(updatedContent);
      } else {
        // Copy các file khác (svg, png...) nếu có
        await entity.copy(targetFile.path);
      }
    }
  }
}
