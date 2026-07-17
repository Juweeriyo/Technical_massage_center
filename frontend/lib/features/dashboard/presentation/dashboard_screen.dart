import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 260,
            color: AppColors.primary,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CERAGEM',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 32),
                _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', isActive: true, onTap: () {}),
                _NavItem(icon: Icons.people_outline, label: 'Patients', onTap: () => context.go('/patients')),
                _NavItem(icon: Icons.calendar_today_outlined, label: 'Appointments', onTap: () => context.go('/appointments')),
                _NavItem(icon: Icons.favorite_outline, label: 'Treatments', onTap: () => context.go('/treatments')),
                _NavItem(icon: Icons.credit_card_outlined, label: 'Payments', onTap: () {}),
                const Spacer(),
                _NavItem(icon: Icons.logout_outlined, label: 'Logout', onTap: () => context.go('/login')),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Container(
              color: AppColors.lightGray,
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Role Dashboard', style: Theme.of(context).textTheme.displayLarge),
                  const SizedBox(height: 32),
                  
                  // Stats Grid
                  Row(
                    children: [
                      const Expanded(child: _StatCard(title: 'Total Patients', value: '1,245')),
                      const SizedBox(width: 24),
                      const Expanded(child: _StatCard(title: "Today's Appointments", value: '12')),
                      const SizedBox(width: 24),
                      const Expanded(child: _StatCard(title: 'Active Treatments', value: '8')),
                      const SizedBox(width: 24),
                      const Expanded(child: _StatCard(title: 'Unpaid Patients', value: '3')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, this.isActive = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.darkGray)),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.displayMedium),
        ],
      ),
    );
  }
}
