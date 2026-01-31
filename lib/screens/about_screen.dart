import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color cardBg = Theme.of(context).cardTheme.color!;
    final Color primaryColor = Theme.of(context).primaryColor; // Emerald
    final Color goldColor = Theme.of(context).colorScheme.secondary; // Gold
    final Color textColor = Theme.of(context).colorScheme.onBackground;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // SECTION 1 — ABOUT YASH TRADERS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(color: primaryColor.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                   Text(
                    'ABOUT YASH TRADERS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? goldColor : primaryColor,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gold & Silver Wholesale Merchants',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white.withOpacity(0.9) : goldColor,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Yash Traders is engaged in the wholesale trade of gold and silver, supplying jewellers, retailers, and bullion traders with certified metals and accurate purity grades.\n\nWe specialize in high-purity gold and silver bullion with transparent pricing and consistent supply.\n\nOur operations focus on market-aligned rates, accuracy, and long-term trade partnerships.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white.withOpacity(0.9) : textColor.withOpacity(0.8),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SECTION 2 — OUR COMMITMENT
            _buildSectionHeader(context, 'OUR COMMITMENT'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
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
                  _buildChecklistRow(context, 'Certified & Tested Gold and Silver'),
                  _buildChecklistRow(context, 'Accurate Purity & Weight Assurance'),
                  _buildChecklistRow(context, 'Transparent Wholesale Pricing'),
                  _buildChecklistRow(context, 'Consistent Bulk Supply'),
                  _buildChecklistRow(context, 'Long-Term Trade Relationships', isLast: true),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SECTION 3 — WHOLESALE SERVICES
            _buildSectionHeader(context, 'WHOLESALE SERVICES'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildServiceCard(
                  context, 
                  title: 'Gold Supply (99.50 / 99.99)', 
                  desc: 'Wholesale supply of high-purity gold bullion for trade and manufacturing.',
                  icon: Icons.grid_goldenratio,
                ),
                _buildServiceCard(
                  context, 
                  title: 'Pure Silver Supply', 
                  desc: 'Bulk supply of pure silver for ornaments and commercial requirements.',
                  icon: Icons.diamond_outlined,
                ),
                _buildServiceCard(
                  context, 
                  title: 'Bullion Trading', 
                  desc: 'Gold and silver bullion trading at live market-linked rates.',
                  icon: Icons.candlestick_chart,
                ),
                 _buildServiceCard(
                  context, 
                  title: 'Live Rate Updates', 
                  desc: 'Real-time gold and silver price updates for wholesale customers.',
                  icon: Icons.trending_up,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // SECTION 4 — WHY TRADE WITH US
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F261F) : const Color(0xFFE8F5E9), // Very light green bg
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? goldColor.withOpacity(0.3) : primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stars, color: isDark ? goldColor : primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'WHY TRADE WITH US',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : primaryColor,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStarRow(context, 'Reliable Wholesale Partner'),
                  _buildStarRow(context, 'Market-Aligned Pricing'),
                  _buildStarRow(context, 'Accuracy in Purity and Weight'),
                  _buildStarRow(context, 'Experience in Bullion Trade'),
                  _buildStarRow(context, 'Strong Presence in Local Market'),
                ],
              ),
            ),
            
             const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final Color goldColor = Theme.of(context).colorScheme.secondary;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : goldColor,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistRow(BuildContext context, String text, {bool isLast = false}) {
    final Color textColor = Theme.of(context).colorScheme.onBackground;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color goldColor = Theme.of(context).colorScheme.secondary;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, color: isDark ? goldColor : primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white.withOpacity(0.9) : textColor.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, {required String title, required String desc, required IconData icon, bool isFullWidth = false}) {
    // 2-column calculation: Screen width - padding (32) - spacing (12) / 2
    final double cardWidth = isFullWidth 
        ? MediaQuery.of(context).size.width - 32 
        : (MediaQuery.of(context).size.width - 32 - 12) / 2;
        
    final Color cardBg = Theme.of(context).cardTheme.color!;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color goldColor = Theme.of(context).colorScheme.secondary;
    final Color textColor = Theme.of(context).colorScheme.onBackground;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? goldColor.withOpacity(0.2) : primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: isDark ? goldColor : primaryColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : textColor.withOpacity(0.7),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStarRow(BuildContext context, String text) {
    final Color textColor = Theme.of(context).colorScheme.onBackground;
    final Color goldColor = Theme.of(context).colorScheme.secondary;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check, color: goldColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white.withOpacity(0.9) : textColor.withOpacity(0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}