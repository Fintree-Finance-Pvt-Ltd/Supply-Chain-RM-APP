import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/auth_service.dart';
import 'package:supply_chain/core/routes/app_route.dart';
import 'package:supply_chain/presentation/role/md/Cases/handled_cases_page.dart';
import 'package:supply_chain/presentation/role/md/Cases/pending_approvals_page.dart';
import 'package:supply_chain/presentation/role/md/invoice/invoice_dashboard.dart';

class MdDashboard extends StatefulWidget {
  const MdDashboard({super.key});

  @override
  State<MdDashboard> createState() => _MdDashboardState();
}

class _MdDashboardState extends State<MdDashboard> {
  int pendingCount = 0;
  bool loadingCount = true;
  List handledCases = [];
  int previousPendingCount = 0;
  Timer? dashboardTimer;

  // Modern Fintech Colors
  final Color primaryGreen = const Color(0xFF004D40);
  final Color accentMint = const Color(0xFF00BFA5);
  final Color scaffoldBg = const Color(0xFFF8FAF9);

String userName = "Loading...";
String userEmail = "...";

@override
void initState() {
  super.initState();
  fetchDashboardData();
  loadUserData(); // <-- Add this here

  dashboardTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
    fetchDashboardData();
  });
}

Future<void> loadUserData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Stripping the 'flutter.' prefix as shared_preferences handles it natively
      userName = prefs.getString("rmName") ?? "Managing Director";
      userEmail = prefs.getString("userEmail") ?? "md@scf.com";
    });
  } catch (e) {
    debugPrint("Error loading user profile: $e");
  }
}

  @override
  void dispose() {
    dashboardTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchDashboardData() async {
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/workflows/customers/dashboard/executive"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        final pending = data["data"]["pending"];
        int newCount = pending.length;
        if (newCount > previousPendingCount) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("🔔 New case received for approval"), behavior: SnackBarBehavior.floating),
          );
        }
        previousPendingCount = newCount;
        setState(() {
          pendingCount = newCount;
          handledCases = data["data"]["handled"];
          loadingCount = false;
        });
      }
    } catch (e) {
      debugPrint("Dashboard error: $e");
    }
  }

  Future<void> _logout() async {
    await AuthService().logout(context);
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      drawer: _buildModernDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Quick Statistics"),
                  const SizedBox(height: 16),
                  _buildStatsRow(),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Operational Workflows"),
                  const SizedBox(height: 16),
                  _buildWorkflowGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 220,
      collapsedHeight: 80,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: primaryGreen,
      leading: Builder(builder: (context) {
        return IconButton(
          icon: const Icon(Icons.align_horizontal_left_rounded, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        );
      }),
      actions: [_buildNotificationIcon()],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryGreen, const Color(0xFF00695C)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.05)),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Welcome back,", style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const Text(
                      "Managing Director",
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentMint.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accentMint.withOpacity(0.3)),
                      ),
                      child: const Text("System Online", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
          if (pendingCount > 0)
            Positioned(
              right: 2,
              top: 14,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                child: Text("$pendingCount", style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard("Active Cases", "${handledCases.length}", Icons.auto_graph_rounded, Colors.blue),
        const SizedBox(width: 16),
        _buildStatCard("Pending", "$pendingCount", Icons.hourglass_empty_rounded, Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
            Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowGrid() {
    return Column(
      children: [
        _buildWorkflowCard(
          title: "Invoice Discounting",
          subtitle: "Approve supply chain invoices",
          icon: Icons.receipt_long_rounded,
          color: Colors.indigo,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceDashboard())),
        ),
        _buildWorkflowCard(
          title: "Pending Approvals",
          subtitle: "Review $pendingCount new case files",
          icon: Icons.pending_actions_rounded,
          color: Colors.amber.shade700,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingApprovalsPage())),
        ),
        _buildWorkflowCard(
          title: "Handled Cases History",
          subtitle: "View previously handled cases",
          icon: Icons.history_rounded,
          color: primaryGreen,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HandledCasesPage())),
        ),
      ],
    );
  }

  Widget _buildWorkflowCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1C1E))),
                      Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1A1C1E), letterSpacing: 1.1));
  }

  Widget _buildModernBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 70,
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon(Icons.home_filled, true),
          _navIcon(Icons.account_balance_rounded, false),
          _navIcon(Icons.analytics_rounded, false),
          _navIcon(Icons.person_rounded, false),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, bool isActive) {
    return Icon(icon, color: isActive ? Colors.white : Colors.white38, size: 26);
  }

  Widget _buildModernDrawer() {
  return Drawer(
    backgroundColor: scaffoldBg,
    child: Column(
      children: [
        UserAccountsDrawerHeader(
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: primaryGreen,
            image: const DecorationImage(
              fit: BoxFit.cover,
              opacity: 0.08,
              image: NetworkImage("assets/images/logo.png"),
            ),
          ),
          currentAccountPicture: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const CircleAvatar(
               backgroundImage: NetworkImage("assets/images/logo.png"),
            ),
          ),
          accountName: Text(
            userName, // <-- Dynamic name from local storage
            style: const TextStyle(
              fontWeight: FontWeight.w800, 
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
          accountEmail: Text(
            userEmail, // <-- Dynamic email from local storage
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Navigation items
        _drawerItem(Icons.person_outline_rounded, "My Profile"),
        _drawerItem(Icons.settings_outlined, "Settings"),
        _drawerItem(Icons.security_rounded, "Security"),
        
        const Spacer(),
        const Divider(indent: 20, endIndent: 20),
        
        // Premium structured logout button
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
          ),
          title: const Text(
            "Logout", 
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
          onTap: _logout,
        ),
        const SizedBox(height: 30),
      ],
    ),
  );
}

Widget _drawerItem(IconData icon, String title) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    leading: Icon(icon, color: primaryGreen.withOpacity(0.7), size: 22),
    title: Text(
      title,
      style: const TextStyle(
        color: Color(0xFF1A1C1E),
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    ),
    onTap: () {},
  );
}
}