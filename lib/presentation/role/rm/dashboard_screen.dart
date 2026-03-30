
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
 
// Your existing imports
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/auth_service.dart';
import 'package:supply_chain/core/utils/toast_helper.dart';
import 'package:supply_chain/presentation/auth/login_screen.dart';
import 'package:supply_chain/presentation/role/rm/Cases/all_Cases.dart';
import 'package:supply_chain/presentation/role/rm/Cases/completed.dart';
import 'package:supply_chain/presentation/role/rm/Cases/draft.dart';
import 'package:supply_chain/presentation/role/rm/Cases/mdApprove.dart';
import 'package:supply_chain/presentation/role/rm/Cases/ops_review.dart';
import 'package:supply_chain/presentation/role/rm/Cases/rejected.dart';
import 'package:supply_chain/presentation/role/rm/Cases/submitted.dart';
import 'package:supply_chain/presentation/role/rm/NewCustomer/company_details.dart';
import 'package:supply_chain/presentation/role/rm/invoices_dashboard.dart';
 
class RmDashboard extends StatefulWidget {
  const RmDashboard({super.key});
 
  @override
  State<RmDashboard> createState() => _RmDashboardState();
}
 
class _RmDashboardState extends State<RmDashboard> {
  int selectedBottomIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
 
  int totalCustomers = 0;
  int draftCount = 0;
  int submittedCount = 0;
  int approvedCount = 0;
  int rejectedCount = 0;
 
  String rmName = "";
  String rmEmail = "";
  int notificationCount = 0;
  bool isDarkMode = false;
  bool loadingNotification = true;
 
  @override
  void initState() {
    super.initState();
    loadRMDetails();
    fetchDashboardData();
    loadTheme();
  }
 
  // LOGIC HANDLERS (Same as original)
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isDarkMode = prefs.getBool("isDarkMode") ?? false);
  }
 
  Future<void> toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isDarkMode = value);
    await prefs.setBool("isDarkMode", value);
  }
 
  Future<void> loadRMDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rmName = prefs.getString("rmName") ?? "User";
      rmEmail = prefs.getString("rmEmail") ?? "";
    });
  }
 
  Future<void> fetchDashboardData() async {
    try {
      final token = await AuthService().getToken();
 
      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/workflows/customers/dashboard/rm"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
 
      final body = jsonDecode(response.body);
 
      if (body["success"] == true) {
        final data = body["data"];
 
        final customers = data["customers"] ?? [];
 
        // Existing logic (notification)
        final approvedForMD = customers.where((c) {
          return (c["status"] ?? "").toString().toLowerCase() == "md_approved";
        }).toList();
 
        setState(() {
          // 🔴 NEW DATA
          totalCustomers = data["totalCustomers"] ?? 0;
          draftCount = data["draft"] ?? 0;
          submittedCount = data["submitted"] ?? 0;
          approvedCount = data["approved"] ?? 0;
          rejectedCount = data["rejected"] ?? 0;
 
          // 🔔 OLD LOGIC
          notificationCount = approvedForMD.length;
          loadingNotification = false;
        });
      }
    } catch (e) {
      debugPrint("Dashboard error: $e");
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final Color bgColor = isDarkMode
        ? const Color(0xFF0F172A)
        : const Color.fromARGB(255, 215, 225, 235);
    final Color cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
 
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      endDrawer: _settingsDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. MODERN HEADER
          SliverToBoxAdapter(child: _buildSuperHeader()),
 
          SliverToBoxAdapter(child: _buildDashboardCards(cardColor)),
 
          // 2. QUICK ACTIONS SECTION
          SliverToBoxAdapter(child: _buildSectionTitle("Quick Actions")),
          SliverToBoxAdapter(child: _buildQuickActions(cardColor)),
 
          // 3. SERVICES GRID SECTION
          SliverToBoxAdapter(child: _buildSectionTitle("Case Management")),
          _buildServicesGrid(cardColor),
 
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ), // Bottom spacing
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
 
  Widget _buildDashboardCards(Color cardColor) {
    return SizedBox(
      height: 90, // 🔥 compact height
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _dashboardCard("Total", totalCustomers, Colors.blue),
          _dashboardCard("Draft", draftCount, Colors.orange),
          _dashboardCard("Submitted", submittedCount, Colors.purple),
          _dashboardCard("Approved", approvedCount, Colors.green),
          _dashboardCard("Rejected", rejectedCount, Colors.red),
        ],
      ),
    );
  }
 
  Widget _dashboardCard(String title, int count, Color color) {
    return Container(
      width: 100, // 🔥 fixed width for row layout
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3), // 🔥 colored border instead of icon
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🔢 COUNT (Main Focus)
          Text(
            "$count",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color, // 🔥 colored number
            ),
          ),
 
          const SizedBox(height: 4),
 
          // 🏷 TITLE
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
 
  /* ================= UI COMPONENTS ================= */
  String _getDayName(int day) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[day - 1];
  }
 
  String _getMonthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }
 
  Widget _buildSuperHeader() {
    final hour = DateTime.now().hour;
    final now = DateTime.now();
    final formattedDate =
        "${_getDayName(now.weekday)}, ${now.day} ${_getMonthName(now.month)}";
    String greeting = hour < 12
        ? "Good Morning"
        : hour < 17
        ? "Good Afternoon"
        : "Good Evening";
 
    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          // Gradient Background
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [
                        const Color.fromARGB(255, 29, 70, 158),
                        const Color.fromARGB(255, 43, 70, 113),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
            ),
          ),
          // Abstract Illustration Blobs
          Positioned(
            top: -20,
            right: -20,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withOpacity(0.08),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -30,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
 
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
 
                          Text(
                            rmName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      _buildNotificationBadge(),
                    ],
                  ),
                  const Spacer(),
                  // Glassmorphic Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color.fromARGB(255, 250, 240, 240)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "You have $notificationCount cases ready for final MD Approval.",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildNotificationBadge() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const mdApproved()),
      ),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
          ),
          if (notificationCount > 0)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "$notificationCount",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
 
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
    );
  }
 
  Widget _buildQuickActions(Color cardColor) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 24),
        physics: const BouncingScrollPhysics(),
        children: [
          _quickActionItem(
            "New Customer",
            Icons.person_add_alt_1,
            Colors.blue,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CompanyDetails(isResume: false),
                ),
              );
            },
          ),
          _quickActionItem("Invoices", Icons.receipt_long, Colors.teal, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InvoiceDashboardPage()),
            );
          }),
     
          _quickActionItem("Support", Icons.help_outline, Colors.purple, () {}),
        ],
      ),
    );
  }
 
  Widget _quickActionItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildServicesGrid(Color cardColor) {
    final items = [
      (
        "All Cases",
        Icons.folder_open,
        Colors.indigo,
        const CasesScreen(role: UserRole.rm),
      ),
      ("Draft", Icons.edit_note_outlined, Colors.orange, const Draft()),
      (
        "Submitted",
        Icons.send_outlined,
        Colors.purple,
        const SubmittedCasesPage(),
      ),
      ("Ops Review", Icons.rate_review_outlined, Colors.amber, OpsReview()),
      (
        "Completed",
        Icons.verified_outlined,
        Colors.green,
        CompletedCasesPage(),
      ),
      ("Rejected", Icons.cancel_outlined, Colors.red, const Rejected()),
    ];
 
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: 140,
        ),
        delegate: SliverChildBuilderDelegate((context, i) {
          return _menuItem(
            items[i].$1,
            items[i].$2,
            items[i].$3,
            cardColor,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => items[i].$4),
              );
            },
          );
        }, childCount: items.length),
      ),
    );
  }
 
  Widget _menuItem(
    String title,
    IconData icon,
    Color color,
    Color cardColor,
    VoidCallback onTap,
  ) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(24),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: color.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white10
                  : Colors.black.withOpacity(0.04),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDarkMode ? const Color.fromARGB(255, 157, 216, 182) : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
 
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 70,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_filled, "Home", 0),
          _navItem(Icons.people_alt, "Customers", 1),
          _navItem(Icons.settings_rounded, "Settings", 2),
        ],
      ),
    );
  }
 
  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = selectedBottomIndex == index;
    return InkWell(
      onTap: () {
        setState(() => selectedBottomIndex = index);
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CasesScreen(role: UserRole.rm),
            ),
          );
        }
        if (index == 2) _scaffoldKey.currentState?.openEndDrawer();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2563EB) : Colors.grey,
              size: 26,
            ),
            if (isSelected) const SizedBox(width: 8),
            if (isSelected)
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
 
  // REUSABLE DRAWER (Refined for the new theme)
  Widget _settingsDrawer() {
    return Drawer(
      backgroundColor: isDarkMode
          ? const Color.fromARGB(255, 21, 29, 52)
          : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            /// 🔵 HEADER (DARK MODE SUPPORT)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 40, bottom: 24),
              decoration: BoxDecoration(
                gradient: isDarkMode
                    ? const LinearGradient(
                        colors: [Color(0xFF020617), Color(0xFF0F172A)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF1A4196), Color(0xFF2D9CDB)],
                      ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundImage: NetworkImage("assets/images/logo.png"),
                  ),
 
                  const SizedBox(height: 12),
 
                  Text(
                    rmName.isEmpty ? "Relationship Manager" : rmName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
 
                  const SizedBox(height: 4),
 
                  const Text(
                    "Relationship Manager",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
 
            const SizedBox(height: 12),
 
            /// 🔹 MENU ITEMS
            _drawerItem(
              icon: Icons.person_add,
              title: "New Customer",
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CompanyDetails()),
                );
              },
            ),
 
            const SizedBox(height: 10),
 
            _drawerItem(
              icon: Icons.receipt_long,
              title: "Invoices",
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InvoiceDashboardPage(),
                  ),
                );
              },
            ),
 
            const SizedBox(height: 10),
 
            Divider(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade300,
            ),
 
            /// 🌙 DARK MODE TOGGLE
            SwitchListTile(
              value: isDarkMode,
              onChanged: (value) {
                toggleTheme(value);
              },
              secondary: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: isDarkMode ? Colors.cyan : Colors.orange,
              ),
              title: Text(
                isDarkMode ? "Dark Mode" : "Light Mode",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
 
            Divider(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade300,
            ),
 
            /// LOGOUT
            _drawerItem(
              icon: Icons.logout,
              title: "Logout",
              color: Colors.red,
              onTap: () async {
                Navigator.pop(context);
 
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: isDarkMode
                        ? const Color(0xFF1E1E1E)
                        : Colors.white,
                    title: Text(
                      "Logout",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    content: Text(
                      "Are you sure you want to logout?",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
 
                if (confirm != true) return;
 
                await AuthService().logout(context);
 
                showTopToast(
                  context,
                  "Logged out successfully",
                  success: true,
                  icon: Icons.logout_rounded,
                );
 
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
 
            const Spacer(),
 
            /// 🔹 FOOTER
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Divider(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.08)
                        : Colors.grey.shade300,
                  ),
                  Text(
                    "App Version 1.0.0",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white54 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _drawerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDarkMode ? color.withOpacity(0.2) : color.withOpacity(.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      onTap: onTap,
    );
  }
 
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (r) => false,
    );
  }
}
 
 