import 'naming.dart';

String applyDynamicPackagePrefix(String content, String projectName) {
  return content.replaceAll('package:link_home/', 'package:$projectName/');
}

String renderBottomNavigationPageFromTemplate({
  required String template,
  required String projectName,
  required List<String> tabs,
}) {
  final enumValues = tabs.join(', ');
  final nameTabCases = tabs
      .map(
        (t) =>
            "      case BottomNavigationPage.$t:\n        return '${tabLabel(t)}';",
      )
      .join('\n');
  final activeIconCases = tabs
      .map((t) => '      case BottomNavigationPage.$t:\n        return Icons.home;')
      .join('\n');
  final inactiveIconCases = tabs
      .map(
        (t) =>
            '      case BottomNavigationPage.$t:\n        return Icons.home_outlined;',
      )
      .join('\n');

  final rendered = template
      .replaceAll('__ENUM_VALUES__', enumValues)
      .replaceAll('__NAME_TAB_CASES__', nameTabCases)
      .replaceAll('__ACTIVE_ICON_CASES__', activeIconCases)
      .replaceAll('__INACTIVE_ICON_CASES__', inactiveIconCases);

  return applyDynamicPackagePrefix(rendered, projectName);
}

String renderMainPageFromTemplate({
  required String template,
  required String projectName,
  required List<String> tabs,
}) {
  final switchLines = StringBuffer()
    ..writeln('    final bloc = context.read<MainBloc>();')
    ..writeln('    switch (currentPage) {');

  for (var i = 0; i < tabs.length; i++) {
    final tab = tabs[i];
    final pascal = pascalCase(tab);
    switchLines
      ..writeln('       case BottomNavigationPage.$tab:')
      ..writeln('      //   // if (!Get.isRegistered<${pascal}Bloc>()) {')
      ..writeln('      //   //   ${pascal}Binding().dependencies();')
      ..writeln('      //   // }')
      ..writeln('         pages.putIfAbsent(')
      ..writeln('           currentPage,')
      ..writeln('           () => CupertinoTabView(')
      ..writeln('             navigatorKey: bloc.tabNavKeys[$i],')
      ..writeln('             // will replace by onGenerateRoute later')
      ..writeln('             builder: (_) => const SizedBox.shrink(),')
      ..writeln('      //       onGenerateRoute: ${pascal}Router.onGenerateRoute,')
      ..writeln('      //     ),')
      ..writeln('      //   );')
      ..writeln('         break;');
  }

  switchLines.writeln('    }');

  final rendered = template.replaceAll(
    '__CREATE_PAGE_SWITCH__',
    switchLines.toString().trimRight(),
  );

  return applyDynamicPackagePrefix(rendered, projectName);
}

String renderMainBlocFromTemplate({
  required String template,
  required String projectName,
  required List<String> tabs,
}) {
  final initialPage = tabs.first;
  final tabNavKeys = List.generate(
    tabs.length,
    (_) => '    GlobalKey<NavigatorState>(),',
  ).join('\n');

  final rendered = template
      .replaceAll('__INITIAL_PAGE__', initialPage)
      .replaceAll('__TAB_NAV_KEYS__', tabNavKeys);

  return applyDynamicPackagePrefix(rendered, projectName);
}

String renderTabRouterFromTemplate({
  required String template,
  required String projectName,
  required String tab,
}) {
  final className = '${pascalCase(tab)}Router';

  return template
      .replaceAll('package:link_home/', 'package:$projectName/')
      .replaceAll('class SettingRouter', 'class $className');
}

