import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../core/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/history')) return 1;
    if (location.startsWith('/analytics')) return 2;
    if (location.startsWith('/prediction')) return 3;
    if (location.startsWith('/chatbot')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _NavItem(
                    icon: PhosphorIcons.chartLineUp(PhosphorIconsStyle.duotone),
                    label: 'Live',
                    isSelected: selectedIndex == 0,
                    onTap: () => context.go('/dashboard'),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.duotone),
                    label: 'History',
                    isSelected: selectedIndex == 1,
                    onTap: () => context.go('/history'),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: PhosphorIcons.chartBar(PhosphorIconsStyle.duotone),
                    label: 'Analytics',
                    isSelected: selectedIndex == 2,
                    onTap: () => context.go('/analytics'),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: PhosphorIcons.brain(PhosphorIconsStyle.duotone),
                    label: 'AI',
                    isSelected: selectedIndex == 3,
                    onTap: () => context.go('/prediction'),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: PhosphorIcons.chatCircleDots(PhosphorIconsStyle.duotone),
                    label: 'Chat',
                    isSelected: selectedIndex == 4,
                    onTap: () => context.go('/chatbot'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
