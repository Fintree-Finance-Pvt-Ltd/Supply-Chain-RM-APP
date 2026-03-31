import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/presentation/role/rm/Cases/case_details.dart';

class SubmittedCasesPage extends StatefulWidget {
  const SubmittedCasesPage({super.key});

  @override
  State<SubmittedCasesPage> createState() => _SubmittedCasesPageState();
}

class _SubmittedCasesPageState extends State<SubmittedCasesPage> {
  List<dynamic> submittedCases = [];
  bool loading = true;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSubmittedCases();
    loadTheme(); // ✅ ADD
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode") ?? false;
    });
  }

  Future<void> _loadSubmittedCases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final rmId = prefs.getInt("rmId");

      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/customers"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final body = jsonDecode(response.body);

      if (body["success"] == true) {
        final List data = body["data"];

        final submitted = data.where((e) {
          return e["status"] == "submitted" && e["rmId"] == rmId;
        }).toList();

        setState(() {
          submittedCases = submitted;
          loading = false;
        });
      }
    } catch (e) {
      print("Submitted cases fetch error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor:
            isDarkMode ? const Color(0xFF1E293B) : Colors.white,

        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black, // ✅ back arrow fix
        ),

        title: Text(
          "Supply Chain Finance",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: submittedCases.length,
        itemBuilder: (context, index) {
          final caseData = submittedCases[index];

          final name = caseData["companyName"] ?? "Unknown";
          final mobile = caseData["companyMobile"] ?? "";
          final pan = caseData["companyPan"] ?? "N/A";
          final lan = caseData["lanId"] ?? "Pending";
          final date = caseData["createdAt"] ?? "";

          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CaseDetailsPage(customerId: caseData["id"]),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                        isDarkMode ? 0.2 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// COMPANY ICON
                  Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    child: const Icon(
                      Icons.apartment_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),

                  const SizedBox(width: 14),

                  /// DETAILS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// NAME + STATUS
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name.isEmpty
                                    ? "Unknown Company"
                                    : name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(
                                    isDarkMode ? 0.25 : 0.15),
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Submitted",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        /// MOBILE
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14,
                              color: isDarkMode
                                  ? Colors.white60
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              mobile.isEmpty
                                  ? "No mobile"
                                  : mobile,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        /// PAN + LAN
                        Wrap(
                          spacing: 8,
                          children: [
                            if (pan != "N/A")
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.white10
                                      : const Color(0xFFF1F5F9),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "PAN $pan",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black,
                                  ),
                                ),
                              ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.blue.withOpacity(0.2)
                                    : const Color(0xFFE0F2FE),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Text(
                                "LAN $lan",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDarkMode
                                      ? Colors.blue.shade200
                                      : const Color(0xFF0369A1),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        /// DATE
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: isDarkMode
                                  ? Colors.white60
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              date.split("T").first,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.white60
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}