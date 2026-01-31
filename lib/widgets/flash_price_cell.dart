import 'dart:async';
import 'package:flutter/material.dart';

class FlashPriceCell extends StatefulWidget {
  final double price;
  final bool isDark;
  final TextStyle? style;

  const FlashPriceCell({
    super.key, 
    required this.price,
    required this.isDark,
    this.style,
  });

  @override
  State<FlashPriceCell> createState() => _FlashPriceCellState();
}

class _FlashPriceCellState extends State<FlashPriceCell> {
  Color _backgroundColor = Colors.transparent;
  Timer? _flashTimer;

  @override
  void didUpdateWidget(FlashPriceCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.price != oldWidget.price) {
      _triggerFlash(widget.price, oldWidget.price);
    }
  }

  void _triggerFlash(double newPrice, double oldPrice) {
    Color flashColor;
    
    // Determine Flash Color
    if (newPrice > oldPrice) {
      // UP -> Green
      flashColor = widget.isDark ? Colors.greenAccent : const Color(0xFFE6F4EA);
    } else if (newPrice < oldPrice) {
      // DOWN -> Red
      flashColor = widget.isDark ? Colors.redAccent : const Color(0xFFFDECEA);
    } else {
      return; 
    }

    // Set Flash
    setState(() => _backgroundColor = flashColor);

    // Reset after 500ms
    _flashTimer?.cancel();
    _flashTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _backgroundColor = Colors.transparent);
      }
    });
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If flashing (bg not transparent), force BLACK text.
    // Otherwise, use provided style color or default to black.
    final Color textColor = _backgroundColor != Colors.transparent 
        ? Colors.black 
        : (widget.style?.color ?? Colors.black);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), // Reduced padding for compact tables
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.price.toStringAsFixed(0),
        style: (widget.style ?? const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)).copyWith(color: textColor),
      ),
    );
  }
}
