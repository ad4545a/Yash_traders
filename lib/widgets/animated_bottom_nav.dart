import 'package:flutter/material.dart';

class AnimatedBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const AnimatedBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, 0, Icons.info_outline, 'About'),
            _buildNavItem(context, 1, Icons.account_balance, 'Bank'),
            _buildNavItem(context, 2, Icons.currency_rupee, 'Live'),
            _buildNavItem(context, 3, Icons.phone, 'Contact'),
            _buildNavItem(context, 4, Icons.menu, 'Menu'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final bool isActive = selectedIndex == index;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Theme-Aware Colors
    final Color activeCircleColor = isDark ? Colors.white : Theme.of(context).primaryColor;
    final Color activeIconColor = isDark ? Theme.of(context).primaryColor : Colors.white;

    return Expanded(
      child: InkWell(
        onTap: () => onItemTapped(index),
        child: Container(
          height: 90,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with background circle animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 60 : 40,
                height: isActive ? 60 : 40,
                decoration: BoxDecoration(
                  color: isActive ? activeCircleColor : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: activeCircleColor.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  icon,
                  color: isActive ? activeIconColor : Colors.grey,
                  size: isActive ? 28 : 24,
                ),
              ),
              const SizedBox(height: 4),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: isActive ? 12 : 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}