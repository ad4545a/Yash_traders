import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class PremiumRateCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final double rate;
  final double change;
  final double mcxRate;
  final bool isGold;
  final double? high;
  final double? low;

  const PremiumRateCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rate,
    required this.change,
    required this.mcxRate,
    required this.isGold,
    this.high,
    this.low,
  });

  @override
  State<PremiumRateCard> createState() => _PremiumRateCardState();
}

class _PremiumRateCardState extends State<PremiumRateCard> {
  Color? _priceColor;
  Timer? _timer;

  @override
  void didUpdateWidget(PremiumRateCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rate != oldWidget.rate) {
      if (widget.rate > oldWidget.rate) {
        _priceColor = const Color(0xFF10B981); // Green
      } else if (widget.rate < oldWidget.rate) {
        _priceColor = const Color(0xFFEF4444); // Red
      }
      
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _priceColor = null;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color goldColor = Theme.of(context).colorScheme.secondary;
    final NumberFormat currencyFormat = NumberFormat('#,##,###');
    
    // Calculate premium (difference between rate and MCX)
    final double premium = widget.rate - widget.mcxRate;
    final bool isPositive = widget.change >= 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: goldColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Product Name (Left) | Premium (Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Product Name with Live Change Indicator
              Row(
                children: [
                  Text(
                    widget.title.split(' (')[0], // "Gold 24K" or "Silver"
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  if (widget.change != 0) ...[
                    const SizedBox(width: 6),
                    Icon(
                      isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      size: 20,
                    ),
                    Text(
                      '₹${widget.change.abs().toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ],
              ),
              // Premium
              Text(
                'Prem: ${premium.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: premium >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          

          const SizedBox(height: 12),

          // Middle Row: MCX (Left) | Final Price (Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // MCX Price & High/Low
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MCX: ₹${currencyFormat.format(widget.mcxRate.toInt())}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // High / Low (real data from Firebase)
                  if (widget.high != null && widget.low != null)
                    Text(
                      'H: ₹${currencyFormat.format(widget.high!.toInt())} L: ₹${currencyFormat.format(widget.low!.toInt())}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
              // Final Price (HERO)
              Text(
                '₹${currencyFormat.format(widget.rate.toInt())}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: _priceColor ?? goldColor,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}