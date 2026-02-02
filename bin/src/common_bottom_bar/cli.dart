import 'dart:io';

import 'args.dart';
import 'fallback_templates.dart';
import 'project.dart';
import 'renderers.dart';
import 'template_io.dart';

Future<void> runCommonBottomBar(List<String> args) async {
  final parsed = parseArgs(args);
  if (parsed.showHelp) {
    stdout.writeln(usage());
    return;
  }

  final hostRoot = Directory.current;
  final pubspecFile = File('${hostRoot.path}/pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    stderr.writeln(
      'Không tìm thấy pubspec.yaml. Hãy chạy lệnh tại thư mục gốc của dự án Flutter.',
    );
    exitCode = 2;
    return;
  }

  final projectName = await readProjectName(pubspecFile);
  if (projectName == null) {
    stderr.writeln('Không tìm thấy trường name: trong pubspec.yaml');
    exitCode = 2;
    return;
  }

  final tabs = parseTabs(parsed.tabsRaw);
  if (tabs.isEmpty) {
    stderr.writeln('tabs không hợp lệ. Ví dụ: --tabs home,user,settings');
    exitCode = 2;
    return;
  }

  final type = parseType(parsed.typeRaw);
  if (type == null) {
    stderr.writeln('type không hợp lệ. Chỉ hỗ trợ: standard | top-notch');
    exitCode = 2;
    return;
  }

  final enumsDir = Directory('${hostRoot.path}/lib/src/enums')
    ..createSync(recursive: true);
  final routingDir = Directory('${hostRoot.path}/lib/src/ui/routing')
    ..createSync(recursive: true);
  final mainUiDir = Directory('${hostRoot.path}/lib/src/ui/main')
    ..createSync(recursive: true);
  final componentsDir = Directory('${mainUiDir.path}/components')
    ..createSync(recursive: true);
  final blocDir = Directory('${mainUiDir.path}/bloc')..createSync(recursive: true);
  final bindingDir = Directory('${mainUiDir.path}/binding')
    ..createSync(recursive: true);

  final packageRoot = await resolvePackageRoot();

  final bottomNavigationPageTemplate = await readTemplateFile(
    packageRoot: packageRoot,
    relativePath: 'bottom_bar/templates/bottom_navigation_page.dart.tpl',
    fallback: fallbackBottomNavigationPageTemplate,
  );

  final bottomNavigationPagePath =
      '${enumsDir.path}/bottom_navigation_page.dart';
  await File(bottomNavigationPagePath).writeAsString(
    renderBottomNavigationPageFromTemplate(
      template: bottomNavigationPageTemplate,
      projectName: projectName,
      tabs: tabs,
    ),
  );

  final bottomNavTemplate = await readTemplateFile(
    packageRoot: packageRoot,
    relativePath:
        type == BottomBarType.topNotch
            ? 'bottom_bar/templates/app_bottom_navigation_bar_top_notch.dart.tpl'
            : 'bottom_bar/templates/app_bottom_navigation_bar_standard.dart.tpl',
    fallback:
        type == BottomBarType.topNotch
            ? fallbackAppBottomNavigationBarTopNotchTemplate
            : fallbackAppBottomNavigationBarStandardTemplate,
  );

  final bottomNavPath = '${componentsDir.path}/app_bottom_navigation_bar.dart';
  await File(bottomNavPath).writeAsString(
    applyDynamicPackagePrefix(bottomNavTemplate, projectName),
  );

  final initialPage = tabs.first;

  final mainEventTemplate = await readTemplateFile(
    packageRoot: packageRoot,
    relativePath: 'bottom_bar/templates/main_event.dart.tpl',
    fallback: fallbackMainEventTemplate,
  );
  await File('${blocDir.path}/main_event.dart').writeAsString(
    applyDynamicPackagePrefix(
      mainEventTemplate.replaceAll('__INITIAL_PAGE__', initialPage),
      projectName,
    ),
  );

  final mainStateTemplate = await readTemplateFile(
    packageRoot: packageRoot,
    relativePath: 'bottom_bar/templates/main_state.dart.tpl',
    fallback: fallbackMainStateTemplate,
  );
  await File('${blocDir.path}/main_state.dart').writeAsString(
    applyDynamicPackagePrefix(
      mainStateTemplate.replaceAll('__INITIAL_PAGE__', initialPage),
      projectName,
    ),
  );

  final mainBlocTemplate = await readTemplateFile(
    packageRoot: packageRoot,
    relativePath: 'bottom_bar/templates/main_bloc.dart.tpl',
    fallback: fallbackMainBlocTemplate,
  );
  await File('${blocDir.path}/main_bloc.dart').writeAsString(
    renderMainBlocFromTemplate(
      template: mainBlocTemplate,
      projectName: projectName,
      tabs: tabs,
    ),
  );

  final mainBindingTemplate = await readTemplateFile(
    packageRoot: packageRoot,
    relativePath: 'bottom_bar/templates/main_binding.dart.tpl',
    fallback: fallbackMainBindingTemplate,
  );
  await File('${bindingDir.path}/main_binding.dart').writeAsString(
    applyDynamicPackagePrefix(mainBindingTemplate, projectName),
  );

  final mainPageTemplate = await readTemplateFile(
    packageRoot: packageRoot,
    relativePath: 'bottom_bar/templates/main_page.dart.tpl',
    fallback: fallbackMainPageTemplate,
  );

  final mainPagePath = '${mainUiDir.path}/main_page.dart';
  await File(mainPagePath).writeAsString(
    renderMainPageFromTemplate(
      template: mainPageTemplate,
      projectName: projectName,
      tabs: tabs,
    ),
  );

  final commonRouterTemplate = await readTemplateFile(
    packageRoot: packageRoot,
    relativePath: 'bottom_bar/routing/common_router.dart',
    fallback: fallbackCommonRouterTemplate,
  );
  await File('${routingDir.path}/common_router.dart').writeAsString(
    commonRouterTemplate.replaceAll('package:link_home/', 'package:$projectName/'),
  );

  final tabRouterTemplate = await readTemplateFile(
    packageRoot: packageRoot,
    relativePath: 'bottom_bar/routing/template_router.dart',
    fallback: fallbackTemplateRouterTemplate,
  );

  for (final tab in tabs) {
    final routerFileName = '${tab}_router.dart';
    final routerFile = File('${routingDir.path}/$routerFileName');
    await routerFile.writeAsString(
      renderTabRouterFromTemplate(
        template: tabRouterTemplate,
        projectName: projectName,
        tab: tab,
      ),
    );
  }

  stdout.writeln('Đã tạo bottom bar:');
  stdout.writeln('- $bottomNavigationPagePath');
  stdout.writeln('- $bottomNavPath');
  stdout.writeln('- $mainPagePath');
  stdout.writeln('- ${blocDir.path}/main_bloc.dart');
  stdout.writeln('- ${blocDir.path}/main_event.dart');
  stdout.writeln('- ${blocDir.path}/main_state.dart');
  stdout.writeln('- ${bindingDir.path}/main_binding.dart');
  stdout.writeln('- ${routingDir.path}/common_router.dart');
  stdout.writeln('- ${routingDir.path}/*_router.dart');
}

