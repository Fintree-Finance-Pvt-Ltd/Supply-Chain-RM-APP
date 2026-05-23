import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/auth_service.dart';
import 'package:supply_chain/presentation/role/md/Cases/case_details.dart';

class HandledCasesPage extends StatefulWidget {
  const HandledCasesPage({super.key});

  @override
  State<HandledCasesPage> createState() => _HandledCasesPageState();
}

class _HandledCasesPageState extends State<HandledCasesPage> {
  bool isLoading = true;
  List handledList = [];

  @override
  void initState() {
    super.initState();
    fetchHandledCases();
  }

  Future<void> fetchHandledCases() async {
    try {
      final token = await AuthService().getToken();

      final response = await http.get(
        Uri.parse(
          "${ApiEndpoints.baseUrl}/workflows/customers/dashboard/executive",
          // "http://localhost:4000/api/workflows/customers/dashboard/executive",
        ),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        setState(() {
          handledList = data["data"]["handled"];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Handled cases error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Handled Cases")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : handledList.isEmpty
              ? const Center(child: Text("No Handled Cases"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: handledList.length,
                  itemBuilder: (context, index) {
                    final item = handledList[index];
                    final customer = item["customer"];

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CaseDetailsPage(
                              customerId: item["customerId"],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// COMPANY NAME
                            Text(
                              customer["companyName"] ?? "N/A",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 8),

                            /// CUSTOMER CODE
                            Row(
                              children: [
                                const Text(
                                  "Customer Code: ",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Expanded(
                                  child: Text(customer["lanId"] ?? "N/A"),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            /// STATUS + DATE
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                _statusBadge(item["currentStatus"]),

                                Text(
                                  _formatDate(item["updatedAt"]),
                                  style:
                                      const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  /// STATUS BADGE
  Widget _statusBadge(String status) {
    Color bg;
    Color text;

    switch (status) {
      case "completed":
        bg = Colors.green.shade100;
        text = Colors.green.shade800;
        break;

      case "md_approved":
        bg = Colors.blue.shade100;
        text = Colors.blue.shade800;
        break;

      case "ceo_approved":
        bg = Colors.teal.shade100;
        text = Colors.teal.shade800;
        break;

      case "ops_l1_review":
        bg = Colors.orange.shade100;
        text = Colors.orange.shade800;
        break;

      case "md_terms_submitted":
        bg = Colors.grey.shade200;
        text = Colors.black87;
        break;

      default:
        bg = Colors.purple.shade100;
        text = Colors.purple.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll("_", " ").toUpperCase(),
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// DATE FORMAT
  String _formatDate(String date) {
    final parsed = DateTime.parse(date);
    return "${parsed.day} ${_month(parsed.month)} ${parsed.year}";
  }

  String _month(int m) {
    const months = [
      "",
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
    return months[m];
  }
}