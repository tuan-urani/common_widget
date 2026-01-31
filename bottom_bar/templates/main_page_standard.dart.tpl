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
