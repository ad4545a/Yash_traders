import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PremiumRtgsCard extends StatelessWidget {
  final double gold24k;
  final double gold22k;
  final double silver;

  const PremiumRtgsCard({
    super.key,
    required this.gold24k,
    required this.gold22k,
    required this.silver,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color goldColor = Theme.of(context).colorScheme.secondary;
    final NumberFormat currencyFormat = NumberFormat('#,##,###');

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
            ? [const Color(0xFF2A2416), const Color(0xFF1A1510)]
            : [Theme.of(context).cardTheme.color!, Theme.of(context).cardTheme.color!.withOpacity(0.9)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: goldColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: goldColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with bank icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: goldColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.account_balance,
                  color: goldColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RTGS RATES',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? goldColor : Theme.of(context).colorScheme.onBackground,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'Bank Transfer Rates',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Gold 24K Row
          _buildRateRow(
            context,
            'Gold 99.50',
            gold24k,
            currencyFormat,
            Icons.diamond,
          ),
          
          const SizedBox(height: 12),
          
          
          
          const SizedBox(height: 12),
          
          // Silver Row
          _buildRateRow(
            context,
            'Silver',
            silver,
            currencyFormat,
            Icons.circle_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildRateRow(
    BuildContext context,
    String label,
    double rate,
    NumberFormat format,
    IconData icon,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color goldColor = Theme.of(context).colorScheme.secondary;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark 
          ? Colors.black.withOpacity(0.3)
          : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: goldColor.withOpacity(0.7),
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
          Text(
            '₹${format.format(rate.toInt())}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: goldColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}