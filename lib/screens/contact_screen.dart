import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    await launchUrl(emailUri);
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    // Basic whatsapp link - requires full number with country code
    // Assuming +91 for India based on context
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (!formattedNumber.startsWith('91')) formattedNumber = '91$formattedNumber';
    
    final Uri whatsappUri = Uri.parse("https://wa.me/$formattedNumber");
    try {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    }
  }

  Future<void> _openLink(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 35, 16, 24),
        child: Column(
          children: [
            // CARD 1 — ADDRESS
            _buildPremiumCard(
              context,
              title: 'ADDRESS',
              icon: Icons.location_on,
              content: Column(
                children: [
                  _buildContentText(context, 'YASH TRADERS (2025–26)', isBold: true),
                  const SizedBox(height: 4),
                  _buildContentText(context, '29/68, Mahal Market'),
                  _buildContentText(context, 'Namak Mandi, Agra'),
                  _buildContentText(context, 'Uttar Pradesh, India'),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openLink('https://www.google.com/maps?q=27.186336,78.0157156&z=17'),
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text("OPEN IN MAPS"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CARD 2 — BOOKING NUMBER
            _buildPremiumCard(
              context,
              title: 'BOOKING NUMBER',
              icon: Icons.phone_iphone,
              content: Column(
                children: [
                  _buildContactRow(context, 'Phone:', '7017515981', onTap: () => _makePhoneCall('7017515981')),
                  const Divider(height: 24, thickness: 0.5),
                  _buildContactRow(
                    context, 
                    'Phone:', 
                    '9411464754', 
                    onTap: () => _makePhoneCall('9411464754'),
                  ),
                  const Divider(height: 24, thickness: 0.5),
                  _buildContactRow(
                    context, 
                    'WhatsApp:', 
                    '9411464754', 
                    onTap: () => _openWhatsApp('9411464754'),
                    onWhatsApp: () => _openWhatsApp('9411464754'),
                  ),
                  const Divider(height: 24, thickness: 0.5),
                  _buildContactRow(context, 'Landline:', '0562-6713334', onTap: () => _makePhoneCall('05626713334')),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CARD 3 — EMAIL
            _buildPremiumCard(
              context,
              title: 'EMAIL',
              icon: Icons.email,
              content: InkWell(
                onTap: () => _sendEmail('SHEKHARSONI3059334@GMAIL.COM'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'SHEKHARSONI3059334@GMAIL.COM',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100), // Bottom spacing for FAB/Nav
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    final Color cardBg = Theme.of(context).cardTheme.color!;
    final Color accentColor = Theme.of(context).primaryColor;
    final Color goldColor = Theme.of(context).colorScheme.secondary;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: goldColor.withOpacity(0.2), 
          width: 0.5
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Content
          Column(
            children: [
              const SizedBox(height: 10), // Spacing for the icon sitting on top
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: isDark ? goldColor : accentColor,
                ),
              ),
              const SizedBox(height: 20),
              content,
            ],
          ),
          
          // Floating Icon
          Positioned(
            top: -70, // Half inside, half outside? No, let's keep it inside but pushed up. 
            // The request said "Top-center circular... icon". Let's put it slightly overlapping or just at the top.
            // Simplified: Just put it at the very top of the column, but let's shift it up a bit using transform or similar if we want a break-out effect.
            // User asked for "Top-center circular icon". I'll put it at the top of the stack, offset up.
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
                border: Border.all(color: cardBg, width: 4), // Border to blend with card
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentText(BuildContext context, String text, {bool isBold = false}) {
    final Color textColor = Theme.of(context).colorScheme.onBackground;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
          color: textColor.withOpacity(isBold ? 1.0 : 0.8),
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildContactRow(
    BuildContext context, 
    String label, 
    String value, 
    {required VoidCallback onTap, VoidCallback? onWhatsApp}
  ) {
    final Color textColor = Theme.of(context).colorScheme.onBackground;
    final Color goldColor = Theme.of(context).colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80, // Fixed width for alignment
            child: Text(
              label, 
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onTap,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: goldColor, // Highlight numbers in gold
              ),
            ),
          ),
          /* if (onWhatsApp != null) ...[
             const SizedBox(width: 12),
             InkWell(
               onTap: onWhatsApp,
               child: const Icon(Icons.chat_bubble_outline, color: Colors.green, size: 18),
             ),
          ] */
        ],
      ),
    );
  }
}