import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'today_screen.dart';
import 'calendar_screen.dart';
import 'statistics_screen.dart';
import 'supplement_list_screen.dart';
import 'reminders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    TodayScreen(),
    CalendarScreen(),
    StatisticsScreen(),
    SupplementListScreen(),
    RemindersScreen(),
  ];

  static const _items = <_NavItem>[
    _NavItem(CupertinoIcons.checkmark_circle,
        CupertinoIcons.checkmark_circle_fill, '今日'),
    _NavItem(
        CupertinoIcons.calendar, CupertinoIcons.calendar_circle_fill, '日历'),
    _NavItem(CupertinoIcons.chart_bar, CupertinoIcons.chart_bar_fill, '统计'),
    _NavItem(CupertinoIcons.capsule, CupertinoIcons.capsule, '补剂'),
    _NavItem(CupertinoIcons.bell, CupertinoIcons.bell_fill, '提醒'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xF7FFFFFF),
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 58,
            child: Row(
              children: List.generate(_items.length, _buildItem),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    final item = _items[index];
    final selected = index == _currentIndex;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: item.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _currentIndex = index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: Icon(
                  selected ? item.activeIcon : item.icon,
                  key: ValueKey(selected),
                  size: 23,
                  color: selected ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  height: 1,
                  fontWeight: FontWeight.w500,
                  color: selected ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem(this.icon, this.activeIcon, this.label);
}
