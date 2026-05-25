import 'package:flutter/material.dart';
import 'pending_invoice_page.dart';
import 'approved_invoice_page.dart';
import 'rejected_invoice_page.dart';

class InvoiceDashboard extends StatefulWidget {
  const InvoiceDashboard({super.key});

  @override
  State<InvoiceDashboard> createState() => _InvoiceDashboardState();
}

class _InvoiceDashboardState extends State<InvoiceDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  const Color.fromARGB(255, 42, 117, 79).withValues(alpha: 0.9), // Fresh Green background
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildQuickStats(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC), // Crisp White-Grey for the list area
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      PendingInvoicePage(),
                      ApprovedInvoicePage(),
                      RejectedInvoicePage(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Floating Bottom Navigation Style Tabs
      bottomNavigationBar: _buildModernTabBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Invoices",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
              const Text(
                "Manage all your invoices in one place",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune_rounded, color: Colors.white),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          _statItem("Pending", "12", Colors.orangeAccent),
          const SizedBox(width: 12),
          _statItem("Approved", "45", Colors.lightBlueAccent),
        ],
      ),
    );
  }

  Widget _statItem(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(count, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 15, 24, 30),
      height: 70,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 30, 59, 56), // Navy button bar
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.4),
        tabs: [
          _buildTabIcon(Icons.hourglass_empty_rounded, "Pending", 0),
          _buildTabIcon(Icons.check_circle_outline_rounded, "Approved", 1),
          _buildTabIcon(Icons.cancel_outlined, "Rejected", 2),
        ],
      ),
    );
  }

  Widget _buildTabIcon(IconData icon, String label, int index) {
    return Tab(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}