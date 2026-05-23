import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';

import 'invoice_details_page.dart';
import 'models/invoice_model.dart';

class PendingInvoicePage extends StatefulWidget {
  const PendingInvoicePage({super.key});

  @override
  State<PendingInvoicePage> createState() => _PendingInvoicePageState();
}

class _PendingInvoicePageState extends State<PendingInvoicePage> {
  bool loading = true;
  List<InvoiceModel> invoices = [];

  @override
  void initState() {
    super.initState();
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/workflows/invoices/pending/md"),
        headers: {"Authorization": "Bearer $token"},
      );

      final body = jsonDecode(response.body);

      if (body["success"] == true) {
        final List data = body["data"];
        setState(() {
          invoices = data.map((e) => InvoiceModel.fromJson(e)).toList();
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        loading = false;
      });
    }
  }

  // Modern Fintech Status Color (Background and Text pair)
  Map<String, Color> getStatusTheme(String status) {
    switch (status) {
      case "PENDING_MD_APPROVAL":
        return {"bg": Colors.orange.withOpacity(0.1), "text": Colors.orange.shade800};
      case "ACTIVE":
        return {"bg": Colors.green.withOpacity(0.1), "text": Colors.green.shade800};
      case "REJECTED":
        return {"bg": Colors.red.withOpacity(0.1), "text": Colors.red.shade800};
      default:
        return {"bg": Colors.grey.withOpacity(0.1), "text": Colors.grey.shade800};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Light fintech background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Pending Invoices",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : invoices.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    return _buildInvoiceCard(invoices[index]);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("No Pending Invoices", 
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceModel invoice) {
    final statusTheme = getStatusTheme(invoice.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => InvoiceDetailsPage(invoice: invoice)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Invoice No & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "#${invoice.invoiceNumber}",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusTheme["bg"],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      invoice.status.replaceAll('_', ' '),
                      style: TextStyle(
                        color: statusTheme["text"],
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Main Info: Customer Name
              Text(
                invoice.customerName ?? "Unknown Customer",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Color(0xFF1A1C1E),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.business_center_outlined, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                   invoice.supplierName ?? "Unknown Supplier",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),

              // Footer: Amounts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("INVOICE AMOUNT", 
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text(
                        "₹${invoice.invoiceAmount}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF1A1C1E),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("DISBURSEMENT", 
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text(
                        "₹${invoice.disbursementAmount}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}