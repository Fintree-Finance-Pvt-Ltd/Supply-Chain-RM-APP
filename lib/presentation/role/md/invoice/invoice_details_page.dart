import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'models/invoice_model.dart';

class InvoiceDetailsPage extends StatefulWidget {
  final InvoiceModel invoice;
  const InvoiceDetailsPage({super.key, required this.invoice});

  @override
  State<InvoiceDetailsPage> createState() => _InvoiceDetailsPageState();
}

class _InvoiceDetailsPageState extends State<InvoiceDetailsPage> {
  final remarksController = TextEditingController();
  bool loading = false;

  // Modern Fintech styling constants
  final Color primaryDark = const Color(0xFF1A1C1E);
  final Color secondaryText = const Color(0xFF6C757D);
  final Color cardBg = Colors.white;

  Future<void> _handleAction(bool isApprove) async {
    final endpoint = isApprove ? 'md-approve' : 'md-reject';
    final successMsg = isApprove ? "Invoice Approved" : "Invoice Rejected";

    try {
      setState(() => loading = true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final bodyData = isApprove 
          ? {"approved": true, "remarks": remarksController.text.isEmpty ? "ok" : remarksController.text}
          : {"remarks": remarksController.text};

      final response = await http.post(
        Uri.parse("${ApiEndpoints.baseUrl}/workflows/invoices/${widget.invoice.id}/$endpoint"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(bodyData),
      );

      final body = jsonDecode(response.body);

      if (body["success"] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMsg), behavior: SnackBarBehavior.floating));
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: primaryDark,
        title: const Text("Invoice Details", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120), // Bottom padding for buttons
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAmountHero(inv),
                const SizedBox(height: 24),
                _buildSectionLabel("PARTICIPANTS"),
                _buildInfoCard([
                  _detailItem("Customer", inv.customerName ?? "N/A", Icons.person_outline),
                  _detailItem("Supplier", inv.supplierName ?? "N/A", Icons.storefront),
                ]),
                const SizedBox(height: 24),
                _buildSectionLabel("FINANCIAL TERMS"),
                _buildInfoCard([
                  _detailItem("ROI", "${inv.roiPercentage}%", Icons.trending_up),
                  _detailItem("Penal Charges", "${inv.penalCharges}%", Icons.warning_amber_rounded),
                  _detailItem("Service Fee", "₹${inv.serviceFee}", Icons.account_balance_wallet_outlined),
                ]),
                const SizedBox(height: 24),
                _buildSectionLabel("REMARKS"),
                TextField(
                  controller: remarksController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Add a note regarding this decision...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildBottomActions(),
          if (loading) Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _buildAmountHero(InvoiceModel inv) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text("Disbursement Amount", style: TextStyle(color: secondaryText, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            "₹${inv.disbursementAmount}",
            style: TextStyle(color: primaryDark, fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text("Inv #${inv.invoiceNumber}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: secondaryText, letterSpacing: 1.1)),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _detailItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: secondaryText),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(color: secondaryText, fontSize: 14)),
          const Spacer(),
          Text(value, style: TextStyle(color: primaryDark, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: loading ? null : () => _handleAction(false),
                child: const Text("Reject", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: loading ? null : () => _handleAction(true),
                child: const Text("Approve Invoice", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}