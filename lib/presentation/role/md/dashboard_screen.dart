import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/auth_service.dart';
import 'package:supply_chain/core/routes/app_route.dart';
import 'package:supply_chain/presentation/role/md/Cases/handled_cases_page.dart';
import 'package:supply_chain/presentation/role/md/Cases/pending_approvals_page.dart';
import 'package:supply_chain/presentation/role/md/Cases/rejected_cases_page.dart';

class MdDashboard extends StatefulWidget {
  const MdDashboard({super.key});

  @override
  State<MdDashboard> createState() => _MdDashboardState();
}

class _MdDashboardState extends State<MdDashboard> {
  int pendingCount = 0;
  bool loadingCount = true;
  int get approvedCases =>
      handledCases.where((e) => e["currentStatus"] == "md_approved").length;

  List handledCases = [];
  List filteredCases = [];
  String selectedFilter = "All";

  Future<void> _logout() async {
    await AuthService().logout(context);
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  int previousPendingCount = 0;

  Future<void> fetchDashboardData() async {
    try {
      final token = await AuthService().getToken();

      final response = await http.get(
        Uri.parse(
          "${ApiEndpoints.baseUrl}/workflows/customers/dashboard/executive",
        ),
        // Uri.parse(
        //   "http://localhost:4000/api/workflows/customers/dashboard/executive",
        // ),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        final pending = data["data"]["pending"];
        handledCases = data["data"]["handled"];

        int newCount = pending.length;

        if (newCount > previousPendingCount) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("🔔 New case received for approval")),
          );
        }

        previousPendingCount = newCount;

        setState(() {
          pendingCount = newCount;
          filteredCases = handledCases;
          loadingCount = false;
        });
      }
    } catch (e) {
      debugPrint("Dashboard error: $e");
    }
  }

  Timer? dashboardTimer;

  @override
  void initState() {
    super.initState();

    fetchDashboardData();

    /// Poll API every 5 seconds
    dashboardTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      fetchDashboardData();
    });
  }

  @override
  void dispose() {
    dashboardTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: _drawer(),
      bottomNavigationBar: _bottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// HEADER
              _header(),

              const SizedBox(height: 20),

              /// QUICK ACTIONS
              // _quickActions(),
              const SizedBox(height: 20),

              /// RECENT CASES
              _recentSection(),

              const SizedBox(height: 20),
              // _caseList(),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= DRAWER =================

  Widget _drawer() {
    return Drawer(
      child: Column(
        children: [
          /// HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 25),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F5C4A), Color(0xFF1A7F63)],
              ),
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/150?img=3",
                  ),
                ),

                SizedBox(height: 12),

                Text(
                  "Managing Director",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  "md@company.com",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// DASHBOARD
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.dashboard, color: Colors.green),
            ),
            title: const Text(
              "Dashboard",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          const Divider(height: 30),

          /// LOGOUT
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: Colors.red),
            ),
            title: const Text(
              "Logout",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  /// ================= HEADER =================

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF0F5C4A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP BAR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// MENU
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),

              /// NOTIFICATION ICON
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications,
                      color: Color.fromARGB(255, 252, 253, 252),
                      size: 24,
                    ),
                  ),

                  if (pendingCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          "$pendingCount",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// GREETING
          const Text(
            "Hi there 👋",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),

          const SizedBox(height: 4),

          const Text(
            "Managing Director",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),

          const SizedBox(height: 25),

          /// ACTION BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dashboardButton(
                icon: Icons.pending_actions,
                title: "Pending",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PendingApprovalsPage(),
                    ),
                  );
                },
              ),

              _dashboardButton(
                icon: Icons.task_alt,
                title: "Handled",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HandledCasesPage()),
                  );
                },
              ),

              _dashboardButton(
                icon: Icons.support_agent,
                title: "Help",
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dashboardButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(221, 17, 140, 101),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= RECENT SECTION =================

  Widget _recentSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Cases",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _caseTile(
            Icons.schedule,
            "Pending Approvals",
            loadingCount ? "Loading..." : "$pendingCount Cases",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PendingApprovalsPage()),
              );
            },
          ),

          _caseTile(
            Icons.check_circle,
            "Handled Cases",
            loadingCount ? "Loading..." : "${handledCases.length} Cases",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HandledCasesPage()),
              );
            },
          ),

          _caseTile(Icons.cancel, "Rejected Cases", "View", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RejectedCasesPage()),
            );
          }),
        ],
      ),
    );
  }

  Widget _caseTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Colors.green.withOpacity(.1),
        child: Icon(icon, color: Colors.green),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  /// ================= BOTTOM NAV =================

  Widget _bottomNav() {
    return BottomNavigationBar(
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),

        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: "Customer",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: "Analytics",
        ),

        BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: "Card"),
      ],
    );
  }
}
