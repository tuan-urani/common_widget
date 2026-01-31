import 'package:flutter/material.dart';
import 'package:link_home/src/enums/bottom_navigation_page.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.currentPage,
    required this.onChanged,
    this.onCenterTap,
  });

  final BottomNavigationPage currentPage;
  final ValueChanged<BottomNavigationPage> onChanged;
  final VoidCallback? onCenterTap;

  @override
  Widget build(BuildContext context) {
    final tabs = BottomNavigationPage.values;
    final currentIndex = tabs.indexOf(currentPage);

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
                  onChanged: onChanged,
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
