import 'dart:io';
import 'dart:isolate';

void main(List<String> args) async {
  final parsed = _parseArgs(args);
  if (parsed.showHelp) {
    stdout.writeln(_usage());
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

  final projectName = await _readProjectName(pubspecFile);
  if (projectName == null) {
    stderr.writeln('Không tìm thấy trường name: trong pubspec.yaml');
    exitCode = 2;
    return;
  }

  final tabs = _parseTabs(parsed.tabsRaw);
  if (tabs.isEmpty) {
    stderr.writeln('tabs không hợp lệ. Ví dụ: --tabs home,user,settings');
    exitCode = 2;
    return;
  }

  final type = _parseType(parsed.typeRaw);
  if (type == null) {
    stderr.writeln('type không hợp lệ. Chỉ hỗ trợ: standard | top-notch');
    exitCode = 2;
    return;
  }

  final enumsDir = Directory('${hostRoot.path}/lib/src/enums');
  if (!enumsDir.existsSync()) {
    enumsDir.createSync(recursive: true);
  }

  final routingDir = Directory('${hostRoot.path}/lib/src/ui/routing');
  if (!routingDir.existsSync()) {
    routingDir.createSync(recursive: true);
  }

  final mainUiDir = Directory('${hostRoot.path}/lib/src/ui/main');
  if (!mainUiDir.existsSync()) {
    mainUiDir.createSync(recursive: true);
  }

  final componentsDir = Directory('${mainUiDir.path}/components');
  if (!componentsDir.existsSync()) {
    componentsDir.createSync(recursive: true);
  }

  final blocDir = Directory('${mainUiDir.path}/bloc');
  if (!blocDir.existsSync()) {
    blocDir.createSync(recursive: true);
  }

  final bindingDir = Directory('${mainUiDir.path}/binding');
  if (!bindingDir.existsSync()) {
    bindingDir.createSync(recursive: true);
  }

  final packageRoot = await _resolvePackageRoot();

  final bottomNavigationPageTemplate = await _readTemplateFile(
    packageRoot: packageRoot,
    relativePath: 'bottom_bar/templates/bottom_navigation_page.dart.tpl',
    fallback: _fallbackBottomNavigationPageTemplate,
  );

  final bottomNavigationPagePath =
      '${enumsDir.path}/bottom_navigation_page.dart';
  final bottomNavigationPageFile = File(bottomNavigationPagePath);
  await bottomNavigationPageFile.writeAsString(
    _renderBottomNavigationPageFromTemplate(
      template: bottomNavigationPageTemplate,
      projectName: projectName,
      tabs: tabs,
    ),
  );

  final bottomNavTemplate = await _readTemplateFile(
    packageRoot: packageRoot,
    relativePath:
        type == _BottomBarType.topNotch
            ? 'bottom_bar/templates/app_bottom_navigation_bar_top_notch.dart.tpl'
            : 'bottom_bar/templates/app_bottom_navigation_bar_standard.dart.tpl',
    fallback:
        type == _BottomBarType.topNotch
            ? _fallbackAppBottomNavigationBarTopNotchTemplate
            : _fallbackAppBottomNavigationBarStandardTemplate,
  );

  final bottomNavPath = '${componentsDir.path}/app_bottom_navigation_bar.dart';
  final bottomNavFile = File(bottomNavPath);
  await bottomNavFile.writeAsString(
    _applyDynamicPackagePrefix(bottomNavTemplate, projectName),
  );

  final initialPage = tabs.first;

  final mainEventTemplate = await _readTemplateFile(
    packageRoot: packageRoot,
    relativePath: 'bottom_bar/templates/main_event.dart.tpl',
    fallback: _fallbackMainEventTemplate,
  );
  await File('${blocDir.path}/main_event.dart').writeAsString(
    _applyDynamicPackagePrefix(
      mainEventTemplate.replaceAll('__INITIAL_PAGE__', initialPage),
      projectName,
    ),
  );

  final mainStateTemplate = await _readTemplateFile(
    packageRoot: packageRoot,
    relativePath: 'bottom_bar/templates/main_state.dart.tpl',
    fallback: _fallbackMainStateTemplate,
  );
  await File('${blocDir.path}/main_state.dart').writeAsString(
    _applyDynamicPackagePrefix(
      mainStateTemplate.replaceAll('__INITIAL_PAGE__', initialPage),
      projectName,
    ),
  );

  final mainBlocTemplate = await _readTemplateFile(
    packageRoot: packageRoot,
    relativePath: 'bottom_bar/templates/main_bloc.dart.tpl',
    fallback: _fallbackMainBlocTemplate,
  );
  await File('${blocDir.path}/main_bloc.dart').writeAsString(
    _renderMainBlocFromTemplate(
      template: mainBlocTemplate,
      projectName: projectName,
      tabs: tabs,
    ),
  );

  final mainBindingTemplate = await _readTemplateFile(
    packageRoot: packageRoot,
    relativePath: 'bottom_bar/templates/main_binding.dart.tpl',
    fallback: _fallbackMainBindingTemplate,
  );
  await File('${bindingDir.path}/main_binding.dart').writeAsString(
    _applyDynamicPackagePrefix(mainBindingTemplate, projectName),
  );

  final mainPageTemplate = await _readTemplateFile(
    packageRoot: packageRoot,
    relativePath: 'bottom_bar/templates/main_page.dart.tpl',
    fallback: _fallbackMainPageTemplate,
  );

  final mainPagePath = '${mainUiDir.path}/main_page.dart';
  final mainPageFile = File(mainPagePath);
  await mainPageFile.writeAsString(
    _renderMainPageFromTemplate(
      template: mainPageTemplate,
      projectName: projectName,
      tabs: tabs,
    ),
  );

  final commonRouterTemplate = await _readTemplateFile(
    packageRoot: packageRoot,
    relativePath: 'bottom_bar/routing/common_router.dart',
    fallback: _fallbackCommonRouterTemplate,
  );
  final commonRouterFile = File('${routingDir.path}/common_router.dart');
  await commonRouterFile.writeAsString(
    commonRouterTemplate.replaceAll('package:link_home/', 'package:$projectName/'),
  );

  final tabRouterTemplate = await _readTemplateFile(
    packageRoot: packageRoot,
    relativePath: 'bottom_bar/routing/template_router.dart',
    fallback: _fallbackTemplateRouterTemplate,
  );

  for (final tab in tabs) {
    final routerFileName = '${tab}_router.dart';
    final routerFile = File('${routingDir.path}/$routerFileName');
    final routerContent = _renderTabRouterFromTemplate(
      template: tabRouterTemplate,
      projectName: projectName,
      tab: tab,
    );
    await routerFile.writeAsString(routerContent);
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

String _usage() {
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

Future<String?> _readProjectName(File pubspecFile) async {
  final pubspecContent = await pubspecFile.readAsString();
  final nameRegExp = RegExp(r'^name:\s+([a-zA-Z0-9_]+)', multiLine: true);
  final match = nameRegExp.firstMatch(pubspecContent);
  return match?.group(1);
}

class _ParsedArgs {
  const _ParsedArgs({
    required this.showHelp,
    required this.typeRaw,
    required this.tabsRaw,
  });

  final bool showHelp;
  final String? typeRaw;
  final String? tabsRaw;
}

_ParsedArgs _parseArgs(List<String> args) {
  if (args.isEmpty) {
    return const _ParsedArgs(showHelp: true, typeRaw: null, tabsRaw: null);
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

  return _ParsedArgs(showHelp: showHelp, typeRaw: typeRaw, tabsRaw: tabsRaw);
}

enum _BottomBarType { standard, topNotch }

_BottomBarType? _parseType(String? raw) {
  final v = raw?.trim().toLowerCase();
  if (v == null || v.isEmpty) return null;
  if (v == 'standard') return _BottomBarType.standard;
  if (v == 'top-notch' || v == 'top_notch' || v == 'topnotch') {
    return _BottomBarType.topNotch;
  }
  return null;
}

List<String> _parseTabs(String? raw) {
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

String _tabLabel(String enumValue) {
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

String _applyDynamicPackagePrefix(String content, String projectName) {
  return content.replaceAll('package:link_home/', 'package:$projectName/');
}

String _renderBottomNavigationPageFromTemplate({
  required String template,
  required String projectName,
  required List<String> tabs,
}) {
  final enumValues = tabs.join(', ');
  final nameTabCases = tabs
      .map((t) => "      case BottomNavigationPage.$t:\n        return '${_tabLabel(t)}';")
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

  return _applyDynamicPackagePrefix(rendered, projectName);
}

String _renderMainPageFromTemplate({
  required String template,
  required String projectName,
  required List<String> tabs,
}) {
  final switchLines = StringBuffer()
    ..writeln('    final bloc = context.read<MainBloc>();')
    ..writeln('    switch (currentPage) {');

  for (var i = 0; i < tabs.length; i++) {
    final tab = tabs[i];
    final pascal = _pascalCase(tab);
    switchLines
      ..writeln('      // case BottomNavigationPage.$tab:')
      ..writeln('      //   // if (!Get.isRegistered<${pascal}Bloc>()) {')
      ..writeln('      //   //   ${pascal}Binding().dependencies();')
      ..writeln('      //   // }')
      ..writeln('      //   pages.putIfAbsent(')
      ..writeln('      //     currentPage,')
      ..writeln('      //     () => CupertinoTabView(')
      ..writeln('      //       navigatorKey: bloc.tabNavKeys[$i],')
      ..writeln('      //       onGenerateRoute: ${pascal}Router.onGenerateRoute,')
      ..writeln('      //     ),')
      ..writeln('      //   );')
      ..writeln('      //   break;');
  }

  switchLines.writeln('    }');

  final rendered = template.replaceAll(
    '__CREATE_PAGE_SWITCH__',
    switchLines.toString().trimRight(),
  );

  return _applyDynamicPackagePrefix(rendered, projectName);
}

String _renderMainBlocFromTemplate({
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

  return _applyDynamicPackagePrefix(rendered, projectName);
}

Future<Directory?> _resolvePackageRoot() async {
  final libUri = await Isolate.resolvePackageUri(
    Uri.parse('package:common_widget/app_bottom_spacing.dart'),
  );
  if (libUri == null) return null;

  final libFile = File(libUri.toFilePath());
  final libDir = libFile.parent;
  final packageRoot = libDir.parent;
  return packageRoot.existsSync() ? packageRoot : null;
}

Future<String> _readTemplateFile({
  required Directory? packageRoot,
  required String relativePath,
  required String fallback,
}) async {
  if (packageRoot == null) return fallback;
  final file = File('${packageRoot.path}/$relativePath');
  if (!file.existsSync()) return fallback;
  return file.readAsString();
}

String _renderTabRouterFromTemplate({
  required String template,
  required String projectName,
  required String tab,
}) {
  final className = '${_pascalCase(tab)}Router';

  return template
      .replaceAll('package:link_home/', 'package:$projectName/')
      .replaceAll('class SettingRouter', 'class $className');
}

String _pascalCase(String enumValue) {
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

const String _fallbackTemplateRouterTemplate = '''
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:link_home/src/ui/routing/common_router.dart';

class SettingRouter {
  static String currentRoute = '/';
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    currentRoute = settings.name ?? '/';
    switch (settings.name) {
      default:
        return CommonRouter.onGenerateRoute(settings);
    }
  }
}
''';

const String _fallbackCommonRouterTemplate = '''
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

/// Router chung chứa các page có thể được gọi từ các tab bottom bar
class CommonRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      default:
        return null;
    }
  }
}
''';

const String _fallbackMainEventTemplate = '''
import 'package:equatable/equatable.dart';
import 'package:link_home/src/enums/bottom_navigation_page.dart';

abstract class MainEvent extends Equatable {
  const MainEvent();

  @override
  List<Object?> get props => [];
}

class MainInitialized extends MainEvent {
  const MainInitialized();
}

class OnChangeTabEvent extends MainEvent {
  final BottomNavigationPage page;

  const OnChangeTabEvent(this.page);

  @override
  List<Object?> get props => [page];
}
''';

const String _fallbackMainStateTemplate = '''
import 'package:equatable/equatable.dart';
import 'package:link_home/src/enums/bottom_navigation_page.dart';

class MainState extends Equatable {
  final BottomNavigationPage currentPage;

  const MainState({this.currentPage = BottomNavigationPage.__INITIAL_PAGE__});

  MainState copyWith({BottomNavigationPage? currentPage}) {
    return MainState(currentPage: currentPage ?? this.currentPage);
  }

  @override
  List<Object?> get props => [currentPage];
}
''';

const String _fallbackMainBlocTemplate = '''
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_home/src/enums/bottom_navigation_page.dart';
import 'package:link_home/src/ui/main/bloc/main_event.dart';
import 'package:link_home/src/ui/main/bloc/main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  final List<GlobalKey<NavigatorState>> tabNavKeys = [
__TAB_NAV_KEYS__
  ];

  MainBloc() : super(const MainState()) {
    on<MainInitialized>(_onInitialized);
    on<OnChangeTabEvent>(_onChangeTab);
  }

  void _onInitialized(MainInitialized event, Emitter<MainState> emit) {
    emit(state.copyWith(currentPage: BottomNavigationPage.__INITIAL_PAGE__));
  }

  void _onChangeTab(OnChangeTabEvent event, Emitter<MainState> emit) {
    emit(state.copyWith(currentPage: event.page));
  }
}
''';

const String _fallbackMainBindingTemplate = '''
import 'package:get/get.dart';
import 'package:link_home/src/ui/main/bloc/main_bloc.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainBloc>(() => MainBloc());
  }
}
''';

const String _fallbackMainPageTemplate = '''
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:link_home/src/enums/bottom_navigation_page.dart';
import 'package:link_home/src/ui/main/bloc/main_bloc.dart';
import 'package:link_home/src/ui/main/bloc/main_event.dart';
import 'package:link_home/src/ui/main/bloc/main_state.dart';
import 'package:link_home/src/ui/main/components/app_bottom_navigation_bar.dart';
import 'package:link_home/src/utils/app_colors.dart';

Map<BottomNavigationPage, Widget> pages = {};

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => Get.find<MainBloc>()..add(const MainInitialized()),
      child: BlocBuilder<MainBloc, MainState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.transparent,
            extendBody: true,
            extendBodyBehindAppBar: true,
            body: BlocBuilder<MainBloc, MainState>(
              buildWhen:
                  (previous, current) =>
                      previous.currentPage != current.currentPage,
              builder: (context, state) {
                _createPage(state.currentPage, context);
                return IndexedStack(
                  sizing: StackFit.expand,
                  index: pages.keys.toList().indexOf(state.currentPage),
                  children: pages.values.toList(),
                );
              },
            ),
            bottomNavigationBar: const AppBottomNavigationBar(),
          );
        },
      ),
    );
  }

  void _createPage(BottomNavigationPage currentPage, BuildContext context) {
__CREATE_PAGE_SWITCH__
  }
}
''';

const String _fallbackBottomNavigationPageTemplate = '''
import 'package:flutter/material.dart';

enum BottomNavigationPage { __ENUM_VALUES__ }

extension BottomNavigationPageExtension on BottomNavigationPage {
  String get nameTab {
    switch (this) {
__NAME_TAB_CASES__
    }
  }

  IconData get activeIcon {
    switch (this) {
__ACTIVE_ICON_CASES__
    }
  }

  IconData get inactiveIcon {
    switch (this) {
__INACTIVE_ICON_CASES__
    }
  }

  IconData getIcon(bool isSelected) {
    return isSelected ? activeIcon : inactiveIcon;
  }
}
''';

const String _fallbackAppBottomNavigationBarStandardTemplate = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_home/src/enums/bottom_navigation_page.dart';
import 'package:link_home/src/ui/main/bloc/main_bloc.dart';
import 'package:link_home/src/ui/main/bloc/main_event.dart';
import 'package:link_home/src/ui/main/bloc/main_state.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      buildWhen:
          (previous, current) => previous.currentPage != current.currentPage,
      builder: (context, state) {
        final bloc = context.read<MainBloc>();
        final tabs = BottomNavigationPage.values;
        final currentIndex = tabs.indexOf(state.currentPage);

        return SizedBox(
          height: 72,
          child: Container(
            height: 72,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _buildItems(
                  tabs: tabs,
                  currentIndex: currentIndex,
                  onChanged: (page) => bloc.add(OnChangeTabEvent(page)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildItems({
    required List<BottomNavigationPage> tabs,
    required int currentIndex,
    required ValueChanged<BottomNavigationPage> onChanged,
  }) {
    return List.generate(tabs.length, (index) {
      final page = tabs[index];
      final isSelected = currentIndex == index;
      return Expanded(
        child: _TabItem(
          page: page,
          isSelected: isSelected,
          onTap: () => onChanged(page),
        ),
      );
    });
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.page,
    required this.isSelected,
    required this.onTap,
  });

  final BottomNavigationPage page;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.black : const Color(0xFF333333);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(page.getIcon(isSelected), size: 22, color: color),
          const SizedBox(height: 2),
          Text(
            page.nameTab,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
''';

const String _fallbackAppBottomNavigationBarTopNotchTemplate = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_home/src/enums/bottom_navigation_page.dart';
import 'package:link_home/src/ui/main/bloc/main_bloc.dart';
import 'package:link_home/src/ui/main/bloc/main_event.dart';
import 'package:link_home/src/ui/main/bloc/main_state.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    this.onCenterTap,
  });
  final VoidCallback? onCenterTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      buildWhen:
          (previous, current) => previous.currentPage != current.currentPage,
      builder: (context, state) {
        final bloc = context.read<MainBloc>();
        final tabs = BottomNavigationPage.values;
        final currentIndex = tabs.indexOf(state.currentPage);

        return SizedBox(
          height: 72,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 72,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _buildItemsWithGap(
                      tabs: tabs,
                      currentIndex: currentIndex,
                      onChanged: (page) => bloc.add(OnChangeTabEvent(page)),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: -28,
                child: Center(
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: FloatingActionButton(
                      onPressed: onCenterTap,
                      elevation: 2,
                      backgroundColor: const Color(0xFFEFF8DD),
                      shape: const CircleBorder(),
                      child: const Icon(Icons.add, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildItemsWithGap({
    required List<BottomNavigationPage> tabs,
    required int currentIndex,
    required ValueChanged<BottomNavigationPage> onChanged,
  }) {
    final gapIndex = tabs.length ~/ 2;
    final items = <Widget>[];
    for (var i = 0; i < tabs.length; i++) {
      if (i == gapIndex) {
        items.add(const SizedBox(width: 56));
      }
      final page = tabs[i];
      final isSelected = currentIndex == i;
      items.add(
        Expanded(
          child: _TabItem(
            page: page,
            isSelected: isSelected,
            onTap: () => onChanged(page),
          ),
        ),
      );
    }
    return items;
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.page,
    required this.isSelected,
    required this.onTap,
  });

  final BottomNavigationPage page;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.black : const Color(0xFF333333);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(page.getIcon(isSelected), size: 22, color: color),
          const SizedBox(height: 2),
          Text(
            page.nameTab,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
''';

const String _fallbackMainPageStandardTemplate = '''
import 'package:flutter/material.dart';
import 'package:link_home/src/enums/bottom_navigation_page.dart';
import 'package:link_home/src/ui/main/components/app_bottom_navigation_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  BottomNavigationPage _currentPage = BottomNavigationPage.__INITIAL_PAGE__;

  @override
  Widget build(BuildContext context) {
    final pages = <BottomNavigationPage, Widget>{
__PAGES_MAP_ENTRIES__
    };

    final tabsList = pages.keys.toList();
    final currentIndex = tabsList.indexOf(_currentPage);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: currentIndex < 0 ? 0 : currentIndex,
        children: pages.values.toList(),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentPage: _currentPage,
        onChanged: (page) => setState(() => _currentPage = page),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}
''';

const String _fallbackMainPageTopNotchTemplate = '''
import 'package:flutter/material.dart';
import 'package:link_home/src/enums/bottom_navigation_page.dart';
import 'package:link_home/src/ui/main/components/app_bottom_navigation_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  BottomNavigationPage _currentPage = BottomNavigationPage.__INITIAL_PAGE__;

  @override
  Widget build(BuildContext context) {
    final pages = <BottomNavigationPage, Widget>{
__PAGES_MAP_ENTRIES__
    };

    final tabsList = pages.keys.toList();
    final currentIndex = tabsList.indexOf(_currentPage);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: currentIndex < 0 ? 0 : currentIndex,
        children: pages.values.toList(),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentPage: _currentPage,
        onChanged: (page) => setState(() => _currentPage = page),
        onCenterTap: () {},
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}
''';
