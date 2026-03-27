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

  @override
  void initState() {
    super.initState();
    fetchCompletedCases();
  }

  /// FETCH COMPLETED CASES
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
        /// Filter only completed cases
        final allCases = body["data"] ?? [];

rejectedCases = allCases.where((e) {
    return e["status"] == "rejected" && e["rmId"] == rmId;
  }).toList();

  setState(() {
    // completedCases = completed;
    loading = false;
  });
        // rejectedCases = allCases.where((c) {
        //   final status = (c["status"] ?? "").toString().toLowerCase();
        //   return status == "ops_l1_review";
        // }).toList();

        // setState(() {
        //   loading = false;
        // });
      }
    } catch (e) {
      print("Completed Cases Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rejected Cases")),

      backgroundColor: const Color(0xFFF5F7FB),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : rejectedCases.isEmpty
          ? const Center(child: Text("No Rejected cases"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rejectedCases.length,
              itemBuilder: (context, index) {
                final caseItem = rejectedCases[index];

                final applicant = caseItem["applicant"] ?? {};
                // final company = caseItem["company"] ?? {};

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),

                    /// Card already provides Material
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CaseDetailsPage(customerId: caseItem["id"]),
                          ),
                        );
                      },

                      child: CaseCard(
                        name:
                            applicant["name"] ??
                            caseItem["companyName"] ??
                            "Unknown",

                        mobile:
                            applicant["mobile"] ??
                            caseItem["companyMobile"] ??
                            "",
                        status: "Completed",

                        date: caseItem["createdAt"] ?? "",

                        PAN: applicant["pan"] ?? "",

                        LAN: caseItem["lanId"] ?? "N/A",
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
