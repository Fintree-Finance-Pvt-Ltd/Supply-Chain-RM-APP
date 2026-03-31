import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/presentation/role/rm/Cases/case_details.dart';

class mdApproved extends StatefulWidget {
  const mdApproved({super.key});

  @override
  State<mdApproved> createState() => _mdApprovedState();
}

class _mdApprovedState extends State<mdApproved> {
  List mdApprovedCases = [];
  bool loading = true;
  bool isDarkMode = false; // ✅ ADD

  @override
  void initState() {
    super.initState();
    fetchCompletedCases();
    loadTheme(); // ✅ ADD
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode") ?? false;
    });
  }

  /// FETCH CASES
  Future<void> fetchCompletedCases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/customers?status=md_approved"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final body = jsonDecode(response.body);

      if (body["success"] == true) {
        final allCases = body["data"] ?? [];

        mdApprovedCases = allCases.where((e) {
          return e["status"] == "md_approved";
        }).toList();

        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print("Completed Cases Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        title: Text(
          "MD Approved Cases",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : mdApprovedCases.isEmpty
              ? Center(
                  child: Text(
                    "No MD Approved cases",
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: mdApprovedCases.length,
                  itemBuilder: (context, index) {
                    final caseItem = mdApprovedCases[index];
                    final applicant = caseItem["applicant"] ?? {};

                    final name = applicant["name"] ??
                        caseItem["companyName"] ??
                        "Unknown";

                    final mobile = applicant["mobile"] ??
                        caseItem["companyMobile"] ??
                        "";

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CaseDetailsPage(
                              customerId: caseItem["id"],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                  isDarkMode ? 0.2 : 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            /// Avatar
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.indigo.withOpacity(0.2)
                                    : const Color(0xFFE0E7FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.business,
                                color: isDarkMode
                                    ? Colors.indigo.shade200
                                    : const Color(0xFF4F46E5),
                              ),
                            ),

                            const SizedBox(width: 14),

                            /// Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: 14,
                                        color: isDarkMode
                                            ? Colors.white60
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        mobile,
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    "Created: ${caseItem["createdAt"]?.toString().split("T")[0]}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDarkMode
                                          ? Colors.white60
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// STATUS
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.green.withOpacity(0.25)
                                    : Colors.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "MD Approved",
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.green.shade300
                                      : Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}