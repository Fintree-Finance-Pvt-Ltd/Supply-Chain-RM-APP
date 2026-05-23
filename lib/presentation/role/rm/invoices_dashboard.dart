import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/auth_service.dart';
import 'package:supply_chain/core/theme/app_colors.dart';
import 'package:supply_chain/presentation/role/rm/Cases/invoice_page.dart';

class InvoiceDashboard {
  final int totalInvoices;
  final int pending;
  final int active;
  final int rejected;
  final String totalAmount;

  InvoiceDashboard({
    required this.totalInvoices,
    required this.pending,
    required this.active,
    required this.rejected,
    required this.totalAmount,
  });

  factory InvoiceDashboard.fromJson(Map<String, dynamic> json) {
    return InvoiceDashboard(
      totalInvoices: json["totalInvoices"] ?? 0,
      pending: json["pending"] ?? 0,
      active: json["active"] ?? 0,
      rejected: json["rejected"] ?? 0,
      totalAmount: json["totalDisbursed"] ?? "0",
    );
  }
}

/// ================= MODEL =================
class InvoiceModel {
  final String invoiceNumber;
  final String supplierName;
  final String amount;
  final String status;
  final int? customerId;
  final int? invoiceId;
  final String customerName;
  InvoiceModel({
    required this.invoiceNumber,
    required this.supplierName,
    required this.amount,
    required this.status,
    this.customerId,
    this.invoiceId,
    required this.customerName,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      invoiceNumber: json["invoiceNumber"] ?? "",
      supplierName: json["supplier"]?["supplierName"] ?? "N/A",
      amount: json["invoiceAmount"] ?? "0",
      status: json["status"] ?? "",
      customerId: json["customerId"],
      customerName: (json["customer"]?["companyName"] ?? "").toString().trim(),
      invoiceId: json["id"], // if exists
    );
  }
}

/// ================= PAGE =================
class InvoiceDashboardPage extends StatefulWidget {
  const InvoiceDashboardPage({super.key});
  // final int customerId;

  @override
  State<InvoiceDashboardPage> createState() => _InvoiceDashboardPageState();
}

class _InvoiceDashboardPageState extends State<InvoiceDashboardPage> {
  List<InvoiceModel> invoices = [];
  bool loading = true;
  InvoiceDashboard? dashboard;
  int? expandedInvoiceId;
  Map<int, List<InvoiceModel>> groupedInvoices = {};

  int? expandedCustomerId;
  bool isDarkMode = false;
  Map<String, dynamic>? expandedInvoiceDetails;
  Map<String, dynamic>? expandedInvoiceData;

  @override
  void initState() {
    super.initState();
    fetchInvoices();
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode") ?? false;
    });
  }

  /// ================= API =================
  Future<void> sendEmailApi(int customerId, String invoiceId) async {
    final token = await SharedPreferences.getInstance().then(
      (prefs) => prefs.getString("token"),
    );

    final response = await http.post(
      Uri.parse(
        "${ApiEndpoints.baseUrl}/workflows/invoices/$invoiceId/send-customer-email",
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"customerId": customerId, "invoiceId": invoiceId}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Email sent successfully")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to send email")));
    }
  }

  //   Future<void> _sendEmail(String email) async {
  //   final Uri emailUri = Uri(
  //     scheme: 'mailto',
  //     path: email,
  //     query: 'subject=Invoice Details&body=Please find attached invoice details.',
  //   );
  // //workflows/invoices/4/send-customer-email
  //   if (await canLaunchUrl(emailUri)) {
  //     await launchUrl(emailUri);
  //   } else {
  //     throw 'Could not launch email app';
  //   }
  // }
  Future<void> loadInvoiceById(int invoiceId) async {
    try {
      final token = await AuthService().getToken();

      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/workflows/invoices/dashboard/rm"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        final invoices = data["data"]["invoices"] as List;

        final invoice = invoices.firstWhere((item) => item["id"] == invoiceId);

        setState(() {
          expandedInvoiceId = invoiceId;
          expandedInvoiceDetails = invoice;
        });
      }
    } catch (e) {
      print("Error loading invoice: $e");
    }
  }

  Future<void> fetchInvoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/workflows/invoices/dashboard/rm"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        final List list = data["data"]["invoices"];
        setState(() {
          dashboard = InvoiceDashboard.fromJson(data["data"]);

          invoices = list.map((e) => InvoiceModel.fromJson(e)).toList();

          groupedInvoices.clear();

          for (var invoice in invoices) {
            if (invoice.customerId == null) continue;

            groupedInvoices
                .putIfAbsent(invoice.customerId!, () => [])
                .add(invoice);
          }
        });
      }
    } catch (e) {
      debugPrint("ERROR: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  Widget _dashboardStats() {
    if (dashboard == null) return const SizedBox();

    final totalAmount =
        double.tryParse(dashboard!.totalAmount)?.toStringAsFixed(2) ?? "0.00";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF5F7FB),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          /// 🔵 LEFT CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Invoice Portfolio",
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),

                const SizedBox(height: 8),

                /// 💰 AMOUNT
                Text(
                  "₹$totalAmount",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "${dashboard!.totalInvoices} invoices tracked",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),

          /// 🖼️ RIGHT SIDE (ICON / IMAGE STYLE)
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFE0E7FF), // soft purple
            ),
            child: const Icon(
              Icons.receipt_long,
              size: 32,
              color: AppColors.darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickStatsGrid() {
    if (dashboard == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _smallStatCard(
            title: "Total",
            value: dashboard!.totalInvoices,
            icon: Icons.receipt_long,
            color: Colors.blue,
          ),
          _smallStatCard(
            title: "Pending",
            value: dashboard!.pending,
            icon: Icons.hourglass_bottom,
            color: Colors.orange,
          ),
          _smallStatCard(
            title: "Active",
            value: dashboard!.active,
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          _smallStatCard(
            title: "Rejected",
            value: dashboard!.rejected,
            icon: Icons.cancel,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _smallStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color],
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),

            const SizedBox(height: 10),

            Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0F172A)
          : const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        title: Text(
          "My Invoices",
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _dashboardStats(),
                ),

                _quickStatsGrid(),

                const SizedBox(height: 10),

                /// 📄 LIST
                ///
                Expanded(
                  child: ListView(
                    children: groupedInvoices.entries.map((entry) {
                      return _customerCard(entry.key, entry.value);
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  /// ================= CARD UI =================
  Widget _customerCard(int customerId, List<InvoiceModel> invoices) {
    final firstInvoice = invoices.first;

    final isExpanded = expandedCustomerId == customerId;

    // final customerName = invoices.isNotEmpty
    //     ? invoices.first.supplierName
    //     : "Customer";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔝 HEADER
          Row(
            children: [
              /// 👤 AVATAR
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: isDarkMode ? Colors.white : AppColors.darkBlue,
                ),
              ),

              const SizedBox(width: 10),

              /// NAME + ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstInvoice.customerName.isNotEmpty
                          ? "Company name: ${firstInvoice.customerName}"
                          : "Customer ID: $customerId",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// 🔘 ACTION BUTTONS
          Row(
            children: [
              /// CREATE NEW
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InvoicePage(customerId: customerId),
                        ),
                      );
                    },
                    child: const Text(
                      "Create New",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              /// VIEW BUTTON (EXPAND)
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF334155)
                        : const Color(0xFFE0E7FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        expandedCustomerId = isExpanded ? null : customerId;
                      });
                    },
                    child: Text(
                      isExpanded ? "Hide" : "View",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : AppColors.darkBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          /// 📄 EXPANDED INVOICES
          if (isExpanded)
            Column(
              children: invoices
                  .map((invoice) => _invoiceCardExpanded(invoice))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _invoiceCardExpanded(InvoiceModel invoice) {
    final isExpanded = expandedInvoiceId == invoice.invoiceId;
    Color statusColor;
    final status = invoice.status.toUpperCase();

    if (status == "ACTIVE") {
      statusColor = Colors.green;
    } else if (status.contains("PENDING")) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1E293B) // 🔥 DARK CARD
            : Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : const Color(0xFFE5E7EB),
        ),

        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔝 HEADER ROW
          InkWell(
            onTap: () async {
              if (isExpanded) {
                setState(() {
                  expandedInvoiceId = null;
                  expandedInvoiceDetails = null;
                });
              } else {
                await loadInvoiceById(invoice.invoiceId!);
              }
            },

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// FIRST ROW
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF334155)
                            : const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        size: 16,
                        color: isDarkMode
                            ? Colors.white
                            : const Color(0xFF4F46E5),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        "Invoice #${invoice.invoiceNumber}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),

                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: isDarkMode ? Colors.white70 : Colors.grey,
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                /// SECOND ROW
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        invoice.supplierName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    /// EMAIL BUTTON
                    SizedBox(
                      height: 30,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.darkBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          sendEmailApi(
                            invoice.customerId!,
                            invoice.invoiceId.toString(),
                          );
                        },
                        child: const Text(
                          "Send Email",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    /// STATUS BADGE
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(
                            isDarkMode ? 0.2 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status.replaceAll("_", " "),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// 💰 AMOUNT
          const SizedBox(height: 10),

          Text(
            "₹${invoice.amount}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDarkMode ? Colors.white : const Color(0xFF111827),
            ),
          ),

          /// 📄 EXPANDED DETAILS
          if (isExpanded && expandedInvoiceDetails != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color.fromARGB(255, 18, 22, 39)
                    : const Color(0xFFF9FAFB),

                borderRadius: BorderRadius.circular(12),

                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.05) // subtle border
                      : Colors.black.withOpacity(0.05),
                ),

                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? const Color.fromARGB(255, 18, 22, 39) // deeper shadow
                        : Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: _expandedInvoiceDetails(),
            ),
        ],
      ),
    );
  }

  Widget _expandedInvoiceDetails() {
    final invoice = expandedInvoiceDetails!;

    // ✅ USE THIS
    final dark = isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: dark
              ? const Color.fromARGB(255, 18, 22, 39)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row("Invoice Number", invoice["invoiceNumber"], dark),
            _row("Invoice Date", invoice["invoiceDate"], dark),
            _row("Amount", invoice["invoiceAmount"], dark),
            _row("Disbursement", invoice["disbursementAmount"], dark),

            if (invoice["supplier"] != null)
              _row("Supplier", invoice["supplier"]["supplierName"], dark),

            if (invoice["loanAccount"] != null)
              _row("LAN", invoice["loanAccount"]["lanId"], dark),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, dynamic value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.grey[300] : Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "-",
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
