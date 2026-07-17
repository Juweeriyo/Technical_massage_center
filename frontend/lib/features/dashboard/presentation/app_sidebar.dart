import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import 'dashboard_layout.dart';

class AppSidebar extends StatelessWidget {
  final bool isCollapsed;
  final List<SidebarItemData> menuItems;

  const AppSidebar({
    super.key,
    required this.isCollapsed,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Container(
      color: AppColors.primary,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.spa,
                    color: Colors.white,
                    size: 30,
                  ),

                  if (!isCollapsed) ...[
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "CERAGEM",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final item in menuItems)
                    _SidebarItem(
                      item: item,
                      collapsed: isCollapsed,
                      selected: currentRoute == item.route,
                      onTap: () => context.go(item.route),
                    ),
                ],
              ),
            ),

            const Divider(color: Colors.white24),

            _SidebarItem(
              item: const SidebarItemData(
                icon: Icons.logout,
                title: "Logout",
                route: "/login",
              ),
              collapsed: isCollapsed,
              selected: false,
              onTap: () => context.go("/login"),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final SidebarItemData item;
  final bool collapsed;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.collapsed,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Material(
        color: selected
            ? Colors.white.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: Colors.white,
                ),

                if (!collapsed) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}