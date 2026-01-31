import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:url_launcher/url_launcher.dart';
import 'about_screen.dart';
import 'bank_details_screen.dart';
import 'contact_screen.dart';
import '../widgets/animated_bottom_nav.dart';
import '../services/theme_controller.dart';
import 'dart:async';
import '../widgets/flash_price_cell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _blinkController;
  
  Map<String, dynamic> _rates = {};
  String _tickerText = '';
  int _selectedIndex = 2; // Start with Live (Home) tab
  
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  Color get primaryColor => Theme.of(context).primaryColor;
  Color get bgColor => Theme.of(context).scaffoldBackgroundColor;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
       vsync: this, 
       duration: const Duration(milliseconds: 1000)
    )..repeat(reverse: true);
    
    _fetchRates();
    _fetchTicker();
  }
  
  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  void _fetchRates() {
    _database.child('live_rates').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final newData = event.snapshot.value as Map;
        setState(() {
          // Deep copy to ensure nested Maps trigger change detection
          _rates = {
            'gold': newData['gold'] != null 
              ? Map<String, dynamic>.from(newData['gold'] as Map)
              : {},
            'silver': newData['silver'] != null
              ? Map<String, dynamic>.from(newData['silver'] as Map)
              : {},
            'last_updated': newData['last_updated'],
            'usdinr': newData['usdinr'],
            'status': newData['status'],
          };

        });
      } else {
        debugPrint('⚠️ Firebase snapshot is null');
      }
    });
  }

  void _fetchTicker() {
    _database.child('admin_settings/ticker_text').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _tickerText = event.snapshot.value.toString();
        });
      }
    });
  }

  void _onItemTapped(int index) {
    if (index == 4) {
      // Menu - open drawer
      _scaffoldKey.currentState?.openDrawer();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
  
  bool _isMarketOpen() {
    final now = DateTime.now();
    // Close on Weekends (Saturday=6, Sunday=7)
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      return false;
    }
    final int minutes = now.hour * 60 + now.minute;
    // Open: 09:00 AM (540 min) to 11:30 PM (1410 min)
    return minutes >= 540 && minutes <= 1410;
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'About Us';
      case 1:
        return 'Bank Details';
      case 2:
        return 'Yash Traders';
      case 3:
        return 'Contact Us';
      default:
        return 'Yash Traders';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        toolbarHeight: 100, // Increased height to accommodate vertical logo
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E5642), // Lighter Emerald Highlight
                Theme.of(context).primaryColor, // Base Emerald
                const Color(0xFF051510), // Deep Dark Emerald
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        title: _selectedIndex == 2 
            ? Image.asset('assets/images/header_logo.png', height: 90)
            : Text(
                _getAppBarTitle(),
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
        centerTitle: true,
      ),
      drawer: _buildDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const AboutScreen(),
          const BankDetailsScreen(),
          _buildHomeContent(),
          const ContactScreen(),
          _buildHomeContent(), // Menu
        ],
      ),
      bottomNavigationBar: AnimatedBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 2 
          ? FloatingActionButton(
              onPressed: () => _openLink('tel:9411464754'),
              backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Theme.of(context).primaryColor,
              child: Icon(Icons.phone, color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor : Colors.white),
            )
          : null,
    );
  }

  Widget _buildHomeContent() {
    return Container(
      color: bgColor,
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
             // 1. Market Status Bar (New)
             _buildMarketStatus(context),
             
             // 2. Marquee
            Container(
              height: 24,
              width: double.infinity,
              color: isDark ? Colors.white10 : Colors.black12,
              child: Marquee(
                text: _tickerText.isNotEmpty
                    ? _tickerText
                    : 'YASH TRADERS – Excellence in Gold & Silver Wholesale Trade               यश ट्रेडर्स – सोना-चांदी के थोक व्यापारी',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                velocity: 30.0,
                blankSpace: 20,
              ),
            ),

            // 3. Market Snapshot (Chips)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Expanded(child: _buildSnapshotChip(context, 'INR / USD', (_rates['usdinr']?['price'] as num?)?.toDouble(), Icons.currency_rupee)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSnapshotChip(context, 'Gold Spot', (_rates['gold']?['spot_price'] as num?)?.toDouble(), Icons.monetization_on)), // Rounded spot
                  const SizedBox(width: 8),
                  Expanded(child: _buildSnapshotChip(context, 'Silver Spot', (_rates['silver']?['spot_price'] as num?)?.toDouble(), Icons.monetization_on_outlined)),
                ],
              ),
            ),

            Divider(height: 1, thickness: 0.5, color: isDark ? Colors.white.withOpacity(0.15) : null),

            // 4. Live Rate Table (Primary Focus)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LIVE WHOLESALE RATES',
                    style: TextStyle(
                      color: isDark ? Colors.white : primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Gold 99.50 Row
                   if (_rates['gold'] != null)
                    _buildLiveRateRow(
                      context,
                      title: 'Gold 99.50',
                      quality: 'Purity 99.50',
                      rate: _rates['gold']['rate_9950']?.toDouble() ?? 0.0,
                      mcx: _rates['gold']['mcx_price']?.toDouble() ?? 0.0,
                      high: _rates['gold']['high']?.toDouble(),
                      low: _rates['gold']['low']?.toDouble(),
                      isGold: true,
                    ),
                  const SizedBox(height: 12),
                  // Silver 99.99 Row
                  if (_rates['silver'] != null)
                    _buildLiveRateRow(
                      context,
                      title: 'Silver 99.99',
                      quality: 'Purity 99.99',
                      rate: _rates['silver']['rate_bars']?.toDouble() ?? 0.0,
                      mcx: _rates['silver']['mcx_price']?.toDouble() ?? 0.0,
                      high: _rates['silver']['high']?.toDouble(),
                      low: _rates['silver']['low']?.toDouble(),
                      isGold: false,
                    ),
                ],
              ),
            ),
            
            Divider(height: 24, thickness: 4, color: isDark ? Colors.white.withOpacity(0.15) : null),

            // 5. Futures / MCX Table
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'MCX / COMMODITY',
                    style: TextStyle(
                      color: isDark ? Colors.white : primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCompactTable(context, isFuture: true),
                ],
              ),
            ),
            
            Divider(height: 24, thickness: 1, color: isDark ? Colors.white.withOpacity(0.15) : null),

            // 6. RTGS / Online Payment Logic
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'RTGS (ONLINE PAYMENT) RATES',
                    style: TextStyle(
                      color: isDark ? Colors.white : primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                 _buildRtgsTable(context),
                ],
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMarketStatus(BuildContext context) {
      return StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 1)),
        builder: (context, snapshot) {
          final now = DateTime.now();
          final isOpen = _isMarketOpen();
          final timeString = DateFormat('hh:mm a').format(now);
          
          return Container(
             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
             color: Theme.of(context).cardTheme.color,
             child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 // Dot
                 FadeTransition(
                   opacity: isOpen ? _blinkController : const AlwaysStoppedAnimation(1.0),
                   child: Container(
                     width: 10,
                     height: 10,
                     decoration: BoxDecoration(
                       color: isOpen ? Colors.green : Colors.red,
                       shape: BoxShape.circle,
                       boxShadow: isOpen ? [
                          BoxShadow(color: Colors.green.withOpacity(0.6), blurRadius: 6, spreadRadius: 2)
                       ] : null,
                     ),
                   ),
                 ),
                 const SizedBox(width: 8),
                 // Text
                 Text(
                   isOpen ? 'LIVE' : 'MARKET CLOSED',
                   style: TextStyle(
                     fontWeight: FontWeight.bold,
                     color: isOpen ? Colors.green : Colors.red,
                     fontSize: 14,
                     letterSpacing: 1,
                   ),
                 ),
                 const SizedBox(width: 12),
                 // Time
                 Text(
                   timeString,
                   style: TextStyle(
                     fontSize: 14, 
                     fontWeight: FontWeight.w600,
                     color: isDark ? Colors.white70 : Colors.black87
                   ),
                 ),
               ],
             ),
          );
        },
      );
  }

  Widget _buildSnapshotChip(BuildContext context, String label, double? price, IconData icon) {
    final String prefix = label.contains('INR') ? '₹' : (label.contains('Spot') ? '\$' : '');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 10, color: isDark ? Colors.white70 : Colors.grey),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white70 : Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          AnimatedPriceText(
            price: price ?? 0.0,
            prefix: prefix,
            decimalPlaces: label.contains('USD') || label.contains('Silver Spot') ? 2 : 0, 
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveRateRow(BuildContext context, {
    required String title,
    required String quality,
    required double rate,
    required double mcx,
    double? high,
    double? low,
    required bool isGold,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Product Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isGold 
                      ? (isDark ? const Color(0xFFFFD700) : Colors.orange[800]) 
                      : (isDark ? Colors.white : Colors.grey[800]),
                ),
              ),
              Text(
                quality,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
              ),
            ],
          ),
          
          // MCX & Premium
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                 children: [
                   Text('MCX: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : Colors.grey)),
                   FlashPriceCell(
                     price: mcx,
                     isDark: isDark,
                     style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : Colors.grey),
                   ),
                 ],
              ),
              // Premium
              Row(
                 children: [
                   Builder(
                     builder: (context) {
                       final double premium = rate - mcx;
                       final bool isPositive = premium >= 0;
                       
                       return Text(
                         'Prem: ${isPositive ? "+" : ""}${premium.toStringAsFixed(0)}',
                         style: TextStyle(
                           fontSize: 11,
                           fontWeight: FontWeight.w600,
                           color: isPositive 
                               ? (isDark ? Colors.white : Colors.green) 
                               : Colors.red,
                         ),
                       );
                     }
                   ),
                 ],
               )
            ],
          ),

          // Sell Price (Big)
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
             decoration: BoxDecoration(
               color: isDark ? Colors.white10 : const Color(0xFFE8F5E9), // Light Green bg
               borderRadius: BorderRadius.circular(6),
             ),
             child: Column(
               children: [
                 AnimatedPriceText(
                   price: rate,
                   style: TextStyle(
                     fontSize: 20,
                     fontWeight: FontWeight.bold,
                     color: isDark ? Colors.white : Colors.black87,
                     letterSpacing: 0.5,
                   ),
                 ),
                 if (high != null && low != null)
                 Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Text('H:', style: TextStyle(fontSize: 9, color: isDark ? Colors.white70 : Colors.grey[600])),
                     FlashPriceCell(
                        price: high, 
                        isDark: isDark,
                        style: TextStyle(fontSize: 9, color: isDark ? Colors.white70 : Colors.grey[600]),
                     ),
                     const SizedBox(width: 4),
                     Text('L:', style: TextStyle(fontSize: 9, color: isDark ? Colors.white70 : Colors.grey[600])),
                     FlashPriceCell(
                        price: low, 
                        isDark: isDark,
                        style: TextStyle(fontSize: 9, color: isDark ? Colors.white70 : Colors.grey[600]),
                     ),
                   ],
                 ),
               ],
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTable(BuildContext context, {required bool isFuture}) {
     // Header
     return Container(
       decoration: BoxDecoration(
         color: Theme.of(context).cardTheme.color,
         borderRadius: BorderRadius.circular(8),
         border: Border.all(color: Colors.grey.withOpacity(0.1)),
       ),
       child: Column(
         children: [
           // Table Header
           Container(
             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
             decoration: BoxDecoration(
               color: Colors.grey.withOpacity(0.05),
               borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
             ),
             child: Row(
               children: [
                 Expanded(flex: 3, child: _headerText('PRODUCT')),
                 Expanded(flex: 3, child: _headerText('BID', align: TextAlign.center)),
                 Expanded(flex: 3, child: _headerText('ASK', align: TextAlign.center)),
                 Expanded(flex: 3, child: _headerText('HIGH / LOW', align: TextAlign.end)),
               ],
             ),
           ),
            Divider(height: 1, thickness: 0.5, color: isDark ? Colors.white.withOpacity(0.15) : null),
           // Future Table (MCX)
             _tableRow(context, 'GOLD', _rates['gold']?['mcx_price']?.toDouble()),
             Divider(height: 1, thickness: 0.5, color: isDark ? Colors.white.withOpacity(0.15) : null),
             _tableRow(context, 'SILVER', _rates['silver']?['mcx_price']?.toDouble()),
         ],
       ),
     );
  }
  
  Widget _buildRtgsTable(BuildContext context) {
    return Container(
       decoration: BoxDecoration(
         color: Theme.of(context).cardTheme.color,
         borderRadius: BorderRadius.circular(8),
         border: Border.all(color: Colors.grey.withOpacity(0.1)),
       ),
       child: Column(
         children: [
            _rtgsRow(context, 'Gold', _rates['gold']?['rate_999']?.toDouble(), _rates['gold']?['mcx_price']?.toDouble()),
            Divider(height: 1, thickness: 0.5, color: isDark ? Colors.white.withOpacity(0.15) : null),
            _rtgsRow(context, 'Silver', _rates['silver']?['rate_9999']?.toDouble(), _rates['silver']?['mcx_price']?.toDouble()),
         ],
       )
    );
  }
  
  Widget _rtgsRow(BuildContext context, String title, double? rate, double? mcx) {
    double? premium;
    if (rate != null && mcx != null) {
      premium = rate - mcx;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          // Title
          Expanded(
            flex: 2,
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          
          // Premium (Center)
          if (premium != null)
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  'Prem: ${premium >= 0 ? "+" : ""}${premium.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: premium >= 0 
                        ? (isDark ? Colors.white70 : Colors.green[700])
                        : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          
          // Price (Right)
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: rate != null 
              ? AnimatedPriceText(
                  price: rate,
                  prefix: '₹',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: isDark ? Colors.white : Theme.of(context).primaryColor,
                    fontSize: 16
                  ),
                )
              : const Text('-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerText(String text, {TextAlign align = TextAlign.start}) {
    return Text(
      text, 
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.grey[800]),
      textAlign: align,
    );
  }

  Widget _tableRow(BuildContext context, String product, double? price, {bool isCurrency = false}) {
    double? bidPrice;
    if (product == 'GOLD' && _rates['gold'] != null) bidPrice = _rates['gold']['bid']?.toDouble();
    if (product == 'SILVER' && _rates['silver'] != null) bidPrice = _rates['silver']['bid']?.toDouble();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3, 
            child: Text(
              product, 
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3, 
            child: Center(
              child: bidPrice != null 
                  ? FlashPriceCell(
                      price: bidPrice, 
                      isDark: isDark,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
                    )
                  : const Text('-', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
          ),
          Expanded(
            flex: 3, 
             child: Center(
              child: price != null
                  ? FlashPriceCell(
                      price: price, 
                      isDark: isDark,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
                    )
                  : Text('-', style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.green, fontWeight: FontWeight.w600)),
            ),
          ),
          Expanded(
            flex: 3, 
            child: Text(
              price != null ? '${price.toStringAsFixed(0)} / ${price.toStringAsFixed(0)}' : '-', 
              style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.grey[800]),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _contactIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
       child: Icon(icon, color: Colors.white, size: 22),
    );
  }

  void _openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  Widget _buildDrawer() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color goldColor = Theme.of(context).colorScheme.secondary;
    
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.2), // Slightly above center (behind logo)
                radius: 1.2,
                colors: [
                  const Color(0xFF1E5642), // Lighter Emerald Spotlight
                  Theme.of(context).primaryColor, // Base
                  const Color(0xFF051510), // Dark Edges
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/header_logo.png',
                    height: 125, // Reduced to fit DrawerHeader without overflow
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  title: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 2);
                  },
                  isSelected: _selectedIndex == 2,
                ),
                _buildDrawerItem(
                  icon: Icons.info_outline,
                  title: 'About Us',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 0);
                  },
                  isSelected: _selectedIndex == 0,
                ),
                _buildDrawerItem(
                  icon: Icons.account_balance,
                  title: 'Bank Details',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 1);
                  },
                  isSelected: _selectedIndex == 1,
                ),
                _buildDrawerItem(
                   icon: Icons.phone_in_talk,
                   title: 'Contact Us',
                   onTap: () {
                     Navigator.pop(context);
                     setState(() => _selectedIndex = 3);
                   },
                   isSelected: _selectedIndex == 3,
                ),
                Divider(color: goldColor.withOpacity(0.2)),
                ListTile(
                  leading: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: goldColor,
                  ),
                  title: Text(
                    isDark ? 'Light Mode' : 'Dark Mode',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Switch(
                    value: isDark,
                    activeColor: goldColor,
                    onChanged: (value) {
                      ThemeController().toggleTheme();
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'App Version 1.0.1',
                  style: TextStyle(
                    color: isDark ? Colors.white30 : Colors.black26,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                 Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Text(
                        'Powered by ',
                        style: TextStyle(
                          color: isDark ? Colors.white24 : Colors.black26,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'AV Digital Lab',
                        style: TextStyle(
                          color: isDark ? const Color(0xFFD4AF37).withOpacity(0.7) : Colors.green[800],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    final Color goldColor = Theme.of(context).colorScheme.secondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: isSelected
        ? BoxDecoration(
            color: goldColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          )
        : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? goldColor : Theme.of(context).iconTheme.color?.withOpacity(0.7) ?? Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? goldColor : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


}

class AnimatedPriceText extends StatefulWidget {
  final double price;
  final TextStyle style;
  final String prefix;
  final int decimalPlaces;

  const AnimatedPriceText({
    super.key, 
    required this.price, 
    required this.style, 
    this.prefix = '',
    this.decimalPlaces = 0,
  });

  @override
  State<AnimatedPriceText> createState() => _AnimatedPriceTextState();
}

class _AnimatedPriceTextState extends State<AnimatedPriceText> with SingleTickerProviderStateMixin {
  late Color _currentColor;
  late double _prevPrice;
  Timer? _colorTimer;
  
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.style.color ?? Colors.black;
    _prevPrice = widget.price;
  }

  @override
  void didUpdateWidget(AnimatedPriceText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.price != oldWidget.price) {
      _handlePriceChange(widget.price, oldWidget.price);
    } else if (widget.style.color != oldWidget.style.color) {
      // Update base color if theme changes (and no animation running)
      _currentColor = widget.style.color ?? Colors.black;
    }
  }
  
  @override
  void dispose() {
    _colorTimer?.cancel();
    super.dispose();
  }

  void _handlePriceChange(double newPrice, double oldPrice) {
    if (newPrice > oldPrice) {
      // Increase -> Green (or GreenAccent in Dark Mode)
      // Increase -> Green (or GreenAccent in Dark Mode)
      setState(() => _currentColor = isDark ? Colors.greenAccent : Colors.green);
    } else if (newPrice < oldPrice) {
      // Decrease -> Red
      setState(() => _currentColor = isDark ? Colors.redAccent : Colors.red);
    } else {
       // No change, do nothing
       return;
    }

    _colorTimer?.cancel();
    _colorTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _currentColor = widget.style.color ?? Colors.black);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: widget.style.copyWith(color: _currentColor),
     child: Text(
        '${widget.prefix}${widget.price.toStringAsFixed(widget.decimalPlaces)}',
      ),
    );
  }
}
