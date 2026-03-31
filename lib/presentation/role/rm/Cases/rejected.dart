import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/presentation/role/rm/Cases/case_details.dart';
import 'package:supply_chain/presentation/role/rm/Cases/draft.dart';

class Rejected extends StatefulWidget {
  const Rejected({super.key});

  @override
  State<Rejected> createState() => _RejectedState();
}

class _RejectedState extends State<Rejected> {
  List rejectedCases = [];
  bool loading = true;
  bool isDarkMode = false; // ✅ ADD

  @override
  void initState() {
    super.initState();
    fetchCompletedCases();
    loadTheme(); // ✅ ADD
  }

  /// LOAD DARK MODE
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode") ?? false;
    });
  }

  /// FETCH REJECTED CASES
  Future<void> fetchCompletedCases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final rmId = prefs.getInt("rmId");

      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/customers?status=rejected"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final body = jsonDecode(response.body);

      if (body["success"] == true) {
        final allCases = body["data"] ?? [];

        rejectedCases = allCases.where((e) {
          return e["status"] == "rejected" && e["rmId"] == rmId;
        }).toList();

        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print("Rejected Cases Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor:
            isDarkMode ? const Color(0xFF1E293B) : Colors.white,

        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),

        title: Text(
          "Rejected Cases",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : rejectedCases.isEmpty
              ? Center(
                  child: Text(
                    "No Rejected cases",
                    style: TextStyle(
                      color:
                          isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rejectedCases.length,
                  itemBuilder: (context, index) {
                    final caseItem = rejectedCases[index];
                    final applicant = caseItem["applicant"] ?? {};

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 3,
                        color: isDarkMode
                            ? const Color(0xFF1E293B)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
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
                          child: CaseCard(
                            name: applicant["name"] ??
                                caseItem["companyName"] ??
                                "Unknown",

                            mobile: applicant["mobile"] ??
                                caseItem["companyMobile"] ??
                                "",

                            status: "Rejected", // ✅ fixed label

                            date: caseItem["createdAt"] ?? "",

                            PAN: applicant["pan"] ?? "",

                            LAN: caseItem["lanId"] ?? "N/A",

                            isDarkMode: isDarkMode, // ✅ IMPORTANT
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}