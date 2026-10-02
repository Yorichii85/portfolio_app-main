import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

import 'activity_one_screen.dart';
import 'network_monitor_screen.dart';
import 'network_diagnostic_dashboard.dart';
import 'local_mesh_chat.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ============================================================
  // COLORS
  // ============================================================

  static const Color forestGreen = Color(0xFF075B48);
  static const Color darkForest = Color(0xFF064536);
  static const Color cream = Color(0xFFF8F7ED);
  static const Color cardColor = Color(0xFFFCFCF4);
  static const Color softGreen = Color(0xFF71B98C);
  static const Color lightGreen = Color(0xFFE7F2E5);
  static const Color darkText = Color(0xFF12352D);

  // ============================================================
  // NAVIGATION HELPERS
  // ============================================================

  void _openActivityOne(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ActivityOneScreen()),
    );
  }

  void _openNetworkMonitor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NetworkMonitorScreen()),
    );
  }

  void _openDiagnostic(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NetworkDiagnosticDashboard()),
    );
  }

  void _openChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocalMeshChat()),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
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

      body: SafeArea(
        child: Stack(
          children: [
            // ====================================================
            // LEAF BACKGROUND DECORATION
            // ====================================================
            Positioned(
              top: 45,
              right: -15,
              child: IgnorePointer(
                child: CustomPaint(
                  size: const Size(150, 180),
                  painter: _LeafPainter(),
                ),
              ),
            ),

            // ====================================================
            // MAIN CONTENT
            // ====================================================
            Column(
              children: [
                // ------------------------------------------------
                // HEADER
                // ------------------------------------------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      // Logo
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cream,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: forestGreen,
                          size: 32,
                        ),
                      ),

                      const SizedBox(width: 8),

                      const Expanded(
                        child: Text(
                          'My Portfolio',
                          style: TextStyle(
                            color: darkText,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      // Settings
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => _openSettings(context),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.settings,
                              color: darkText,
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ------------------------------------------------
                // SCROLLABLE CONTENT
                // ------------------------------------------------
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // WELCOME
                        // ==================================================
                        const Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: darkText,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          appState.userName,
                          style: const TextStyle(
                            color: darkText,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'BSCS 3A',
                          style: TextStyle(
                            color: darkText,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ==================================================
                        // ACTIVITY 1
                        // ==================================================
                        _PortfolioCard(
                          title: 'Activity 1 – Counter & Color Picker',
                          subtitle: 'Two mini-apps in one screen (tabs)',
                          icon: Icons.sports_esports_outlined,
                          onTap: () => _openActivityOne(context),
                        ),

                        const SizedBox(height: 9),

                        // ==================================================
                        // ACTIVITY 2
                        // ==================================================
                        _PortfolioCard(
                          title: 'Activity 2 – Network Monitor',
                          subtitle: 'Real-time handover & request queueing',
                          icon: Icons.wifi,
                          onTap: () => _openNetworkMonitor(context),
                        ),

                        const SizedBox(height: 9),

                        // ==================================================
                        // NETWORK DIAGNOSTIC
                        // ==================================================
                        _PortfolioCard(
                          title: 'Network Diagnostic Dashboard',
                          subtitle: 'Test ping, download & upload speed',
                          icon: Icons.bar_chart_rounded,
                          onTap: () => _openDiagnostic(context),
                        ),

                        const SizedBox(height: 9),

                        // ==================================================
                        // LOCAL MESH CHAT
                        // ==================================================
                        _PortfolioCard(
                          title: 'Local Mesh Chat',
                          subtitle: 'Offline messaging with nearby devices',
                          icon: Icons.forum_rounded,
                          isHighlighted: true,
                          onTap: () => _openChat(context),
                        ),

                        const SizedBox(height: 9),

                        // ==================================================
                        // SETTINGS
                        // ==================================================
                        _PortfolioCard(
                          title: 'Settings',
                          subtitle: 'Change name & theme (global state)',
                          icon: Icons.settings,
                          onTap: () => _openSettings(context),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // ====================================================
                // BOTTOM NAVIGATION
                // ====================================================
                _BottomNavigation(
                  onHomeTap: () {},
                  onChatTap: () => _openChat(context),
                  onDevicesTap: () => _openNetworkMonitor(context),
                  onProfileTap: () => _openSettings(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// PORTFOLIO CARD
// ==================================================================

class _PortfolioCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _PortfolioCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color background = isHighlighted
        ? HomeScreen.forestGreen
        : HomeScreen.cardColor;

    final Color primaryText = isHighlighted
        ? Colors.white
        : HomeScreen.darkText;

    final Color secondaryText = isHighlighted
        ? Colors.white.withValues(alpha: 0.85)
        : HomeScreen.darkText;

    final Color iconBackground = isHighlighted
        ? Colors.white
        : HomeScreen.forestGreen;

    final Color iconColor = isHighlighted
        ? HomeScreen.forestGreen
        : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: isHighlighted
                  ? HomeScreen.forestGreen
                  : const Color(0xFFDDE5D8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isHighlighted ? 0.08 : 0.04,
                ),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // ----------------------------------------------------
              // ICON
              // ----------------------------------------------------
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),

              const SizedBox(width: 12),

              // ----------------------------------------------------
              // TEXT
              // ----------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ----------------------------------------------------
              // ARROW
              // ----------------------------------------------------
              Icon(
                Icons.chevron_right,
                color: isHighlighted ? Colors.white : HomeScreen.darkText,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// BOTTOM NAVIGATION
// ==================================================================

class _BottomNavigation extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onChatTap;
  final VoidCallback onDevicesTap;
  final VoidCallback onProfileTap;

  const _BottomNavigation({
    required this.onHomeTap,
    required this.onChatTap,
    required this.onDevicesTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 8, 15, 9),
      decoration: const BoxDecoration(
        color: HomeScreen.cream,
        border: Border(top: BorderSide(color: Color(0xFFDCE5D9), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: true,
            onTap: onHomeTap,
          ),
          _BottomItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
            onTap: onChatTap,
          ),
          _BottomItem(
            icon: Icons.phone_android_rounded,
            label: 'Devices',
            onTap: onDevicesTap,
          ),
          _BottomItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            onTap: onProfileTap,
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// BOTTOM NAV ITEM
// ==================================================================

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomItem({
    required this.icon,
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = selected
        ? HomeScreen.forestGreen
        : HomeScreen.darkText.withValues(alpha: 0.75);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// LEAF BACKGROUND PAINTER
// ==================================================================

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // --------------------------------------------------------------
    // Stem
    // --------------------------------------------------------------

    final stem = Paint()
      ..color = const Color(0xFFB4D3A9)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(size.width * 0.50, size.height);
    path.quadraticBezierTo(
      size.width * 0.52,
      size.height * 0.62,
      size.width * 0.50,
      size.height * 0.25,
    );

    canvas.drawPath(path, stem);

    // --------------------------------------------------------------
    // Leaves
    // --------------------------------------------------------------

    void drawLeaf({
      required Offset start,
      required Offset control,
      required Offset end,
      required double rotation,
      required Color color,
    }) {
      canvas.save();
      canvas.translate(start.dx, start.dy);
      canvas.rotate(rotation);

      paint.color = color;

      final leaf = Path();

      leaf.moveTo(0, 0);

      leaf.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

      leaf.quadraticBezierTo(control.dx * 0.55, control.dy * 0.75, 0, 0);

      canvas.drawPath(leaf, paint);

      canvas.restore();
    }

    drawLeaf(
      start: Offset(size.width * 0.50, size.height * 0.30),
      control: Offset(-42, -28),
      end: Offset(-42, -67),
      rotation: -0.20,
      color: const Color(0xFFC7DDBD),
    );

    drawLeaf(
      start: Offset(size.width * 0.50, size.height * 0.47),
      control: Offset(45, -20),
      end: Offset(58, -63),
      rotation: 0.12,
      color: const Color(0xFFB7D6AC),
    );

    drawLeaf(
      start: Offset(size.width * 0.50, size.height * 0.61),
      control: Offset(-45, -13),
      end: Offset(-61, -48),
      rotation: -0.15,
      color: const Color(0xFFB9D6AD),
    );

    drawLeaf(
      start: Offset(size.width * 0.51, size.height * 0.75),
      control: Offset(38, -5),
      end: Offset(54, -34),
      rotation: 0.08,
      color: const Color(0xFFD0E3C7),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
