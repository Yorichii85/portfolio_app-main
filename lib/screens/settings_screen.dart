import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color forestGreen = Color(0xFF075B48);
  static const Color darkForest = Color(0xFF064536);
  static const Color softGreen = Color(0xFF71B98C);
  static const Color lightGreen = Color(0xFFE7F2E5);
  static const Color cream = Color(0xFFF8F7ED);
  static const Color darkText = Color(0xFF12352D);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: context.read<AppState>().userName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ============================================================
  // SAVE NAME
  // ============================================================

  void _saveName() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: darkForest,
          content: Text('Please enter a display name.'),
        ),
      );
      return;
    }

    context.read<AppState>().updateName(name);

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: forestGreen,
        content: Text('Name updated!'),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: cream,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: forestGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,

        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),

        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: Stack(
        children: [
          const Positioned.fill(child: _SettingsLeafBackground()),

          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                // ==================================================
                // APP PREFERENCES
                // ==================================================
                const _SectionTitle(title: 'App Preferences'),

                const SizedBox(height: 8),

                _SettingsCard(
                  icon: appState.isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  title: 'Theme',
                  subtitle: appState.isDarkMode ? 'Dark Mode' : 'Light Mode',
                  onTap: () => _showThemeDialog(context, appState),
                ),

                const SizedBox(height: 8),

                _SettingsCard(
                  icon: Icons.chat_bubble_rounded,
                  title: 'Chat Settings',
                  subtitle: 'Message & notification options',
                  onTap: () {
                    _showComingSoon(context, 'Chat Settings');
                  },
                ),

                const SizedBox(height: 8),

                _SettingsCard(
                  icon: Icons.wifi_rounded,
                  title: 'Connection Settings',
                  subtitle: 'Nearby device preferences',
                  onTap: () {
                    _showComingSoon(context, 'Connection Settings');
                  },
                ),

                const SizedBox(height: 24),

                // ==================================================
                // PROFILE
                // ==================================================
                const _SectionTitle(title: 'Profile'),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _CircleIcon(icon: Icons.person_rounded),
                          const SizedBox(width: 12),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Display Name',
                                  style: TextStyle(
                                    color: darkText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Name shown in your portfolio',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // NAME FIELD
                      TextField(
                        controller: _nameController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _saveName(),
                        style: const TextStyle(
                          color: darkText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your name',
                          hintStyle: const TextStyle(
                            color: Colors.black38,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: lightGreen,
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: forestGreen,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: softGreen.withValues(alpha: 0.20),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: forestGreen,
                              width: 1.3,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: FilledButton.icon(
                          onPressed: _saveName,
                          icon: const Icon(Icons.save_rounded, size: 19),
                          label: const Text('Save Name'),
                          style: FilledButton.styleFrom(
                            backgroundColor: forestGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // ABOUT
                // ==================================================
                const _SectionTitle(title: 'About'),

                const SizedBox(height: 8),

                _SettingsCard(
                  icon: Icons.info_rounded,
                  title: 'Local Mesh Chat',
                  subtitle: 'v1.0.0',
                  onTap: () => _showAboutDialog(context),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // BRAND CARD
                // ==================================================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCEED7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: softGreen.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: forestGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: Colors.white,
                          size: 29,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Local Mesh Chat',
                              style: TextStyle(
                                color: darkText,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Connect. Chat. Stay Nearby.',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // THEME DIALOG
  // ============================================================

  void _showThemeDialog(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                const _CircleIcon(
                  icon: Icons.palette_rounded,
                  size: 56,
                  iconSize: 28,
                ),

                const SizedBox(height: 10),

                const Text(
                  'Theme',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Choose how the app should look.',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),

                const SizedBox(height: 18),

                _ThemeOption(
                  icon: Icons.light_mode_rounded,
                  title: 'Light Theme',
                  selected: !appState.isDarkMode,
                  onTap: () {
                    appState.toggleTheme(false);
                    Navigator.pop(sheetContext);
                  },
                ),

                const SizedBox(height: 8),

                _ThemeOption(
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark Theme',
                  selected: appState.isDarkMode,
                  onTap: () {
                    appState.toggleTheme(true);
                    Navigator.pop(sheetContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // COMING SOON
  // ============================================================

  void _showComingSoon(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cream,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'These settings can be configured here in a future update.',
            style: TextStyle(color: Colors.black54, height: 1.4),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: FilledButton.styleFrom(backgroundColor: forestGreen),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ABOUT
  // ============================================================

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cream,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _CircleIcon(
                icon: Icons.eco_rounded,
                size: 64,
                iconSize: 34,
              ),

              const SizedBox(height: 12),

              const Text(
                'Local Mesh Chat',
                style: TextStyle(
                  color: darkText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),

              const SizedBox(height: 15),

              const Text(
                'Nearby device-to-device messaging.\n'
                'Connect and chat without requiring internet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: FilledButton.styleFrom(
                    backgroundColor: forestGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // CARD DECORATION
  // ============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: softGreen.withValues(alpha: 0.22)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.035),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}

// ==================================================================
// SECTION TITLE
// ==================================================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: _SettingsScreenState.darkText,
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

// ==================================================================
// SETTINGS CARD
// ==================================================================

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _SettingsScreenState.softGreen.withValues(alpha: 0.20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 7,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _CircleIcon(icon: icon),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _SettingsScreenState.darkText,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: _SettingsScreenState.darkText,
                size: 23,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// CIRCLE ICON
// ==================================================================

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;

  const _CircleIcon({required this.icon, this.size = 44, this.iconSize = 22});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: _SettingsScreenState.lightGreen,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: _SettingsScreenState.forestGreen,
        size: iconSize,
      ),
    );
  }
}

// ==================================================================
// THEME OPTION
// ==================================================================

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _SettingsScreenState.lightGreen : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? _SettingsScreenState.forestGreen
                  : Colors.black12,
            ),
          ),
          child: Row(
            children: [
              _CircleIcon(icon: icon),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _SettingsScreenState.darkText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: _SettingsScreenState.forestGreen,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// LEAF BACKGROUND
// ==================================================================

class _SettingsLeafBackground extends StatelessWidget {
  const _SettingsLeafBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _SettingsLeafPainter()));
  }
}

class _SettingsLeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBBD7A8).withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    _leaf(canvas, paint, Offset(size.width - 20, 100), 35, -0.7);

    _leaf(canvas, paint, Offset(size.width - 55, 135), 28, -0.45);

    _leaf(canvas, paint, Offset(15, size.height - 65), 30, 2.7);

    _leaf(canvas, paint, Offset(45, size.height - 40), 24, 2.95);
  }

  void _leaf(
    Canvas canvas,
    Paint paint,
    Offset center,
    double length,
    double angle,
  ) {
    canvas.save();

    canvas.translate(center.dx, center.dy);

    canvas.rotate(angle);

    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(length * .65, -length * .55, length, 0)
      ..quadraticBezierTo(length * .62, length * .55, 0, 0)
      ..close();

    canvas.drawPath(path, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
