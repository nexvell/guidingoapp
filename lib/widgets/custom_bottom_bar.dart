import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Navigation item configuration for bottom bar
class CustomBottomBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const CustomBottomBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

/// Custom bottom navigation bar with EXACTLY 4 tabs: Home, Esame, Progresso, Impostazioni
class CustomBottomBar extends StatefulWidget {
  final String currentRoute;
  final Function(String route)? onNavigate;
  final bool showLabels;
  final double elevation;

  const CustomBottomBar({
    super.key,
    required this.currentRoute,
    this.onNavigate,
    this.showLabels = true,
    this.elevation = 8.0,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _selectedIndex = 0;

  // EXACT 4-tab structure: Home, Esame, Progresso, Impostazioni
  static const List<CustomBottomBarItem> _navigationItems = [
    CustomBottomBarItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      route: '/home-screen',
    ),
    CustomBottomBarItem(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
      label: 'Esame',
      route: '/official-exam-screen',
    ),
    CustomBottomBarItem(
      icon: Icons.trending_up_outlined,
      activeIcon: Icons.trending_up_rounded,
      label: 'Progresso',
      route: '/progress-screen',
    ),
    CustomBottomBarItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Impostazioni',
      route: '/settings-screen',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _updateSelectedIndex();
  }

  @override
  void didUpdateWidget(CustomBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      _updateSelectedIndex();
    }
  }

  void _updateSelectedIndex() {
    final index = _navigationItems.indexWhere(
      (item) => item.route == widget.currentRoute,
    );
    if (index != -1 && index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (index == _selectedIndex) return;

    HapticFeedback.selectionClick();

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    setState(() {
      _selectedIndex = index;
    });

    final route = _navigationItems[index].route;

    // CRITICAL FIX: Home tab ALWAYS resets navigation stack to Home root
    if (index == 0 && route == '/home-screen') {
      // Reset entire navigation stack and go to Home root
      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (Route<dynamic> route) => false,
      );
    } else if (widget.onNavigate != null) {
      widget.onNavigate!(route);
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: widget.elevation,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: widget.showLabels ? 72 : 64,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navigationItems.length,
              (index) => _buildNavigationItem(
                context,
                _navigationItems[index],
                index,
                theme.brightness == Brightness.dark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    CustomBottomBarItem item,
    int index,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: ScaleTransition(
        scale: isSelected ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleTap(index),
            borderRadius: BorderRadius.circular(12),
            splashColor: colorScheme.primary.withValues(alpha: 0.1),
            highlightColor: colorScheme.primary.withValues(alpha: 0.05),
            child: Container(
              constraints: const BoxConstraints(minWidth: 64, minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: 24,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (widget.showLabels) ...[
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        letterSpacing: 0.4,
                        height: 1.33,
                      ),
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
