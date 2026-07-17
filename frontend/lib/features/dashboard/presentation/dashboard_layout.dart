import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'app_header.dart';
import 'app_sidebar.dart';

class DashboardLayout extends StatefulWidget {
  final String title;
  final Widget child;
  final List<SidebarItemData> menuItems;

  const DashboardLayout({
    super.key,
    required this.title,
    required this.child,
    required this.menuItems,
  });

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  bool isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isCollapsed ? 80 : 250,
            child: AppSidebar(
              isCollapsed: isCollapsed,
              menuItems: widget.menuItems,
            ),
          ),

          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: widget.title,
                  isCollapsed: isCollapsed,
                  onMenuPressed: () {
                    setState(() {
                      isCollapsed = !isCollapsed;
                    });
                  },
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarItemData {
  final IconData icon;
  final String title;
  final String route;

  const SidebarItemData({
    required this.icon,
    required this.title,
    required this.route,
  });
}