

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/presentation/role/rm/Cases/case_details.dart';
import 'package:supply_chain/presentation/role/rm/Cases/draft.dart';

class mdApproved extends StatefulWidget {
  const mdApproved({super.key});

  @override
  State<mdApproved> createState() => _mdApprovedState();
}

class _mdApprovedState extends State<mdApproved> {
List mdApprovedCases = [];
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
        Uri.parse("${ApiEndpoints.baseUrl}/customers?status=md_approved"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final body = jsonDecode(response.body);

      if (body["success"] == true) {

        /// Filter only completed cases
        final allCases = body["data"] ?? [];

mdApprovedCases = allCases.where((e) {
    return e["status"] == "md_approved" && e["rmId"] == rmId;
  }).toList();

// mdApprovedCases = 
            // customers.where((c) => c["status"] == "credit_l2_approved").toList();

  setState(() {
    // completedCases = completed;
    loading = false;
  });
//        opsCases = allCases.where((c) {
//   final status = (c["status"] ?? "").toString().toLowerCase();
//   return status == "ops_l1_review";
// }).toList();

//         setState(() {
//           loading = false;
//         });
      }

    } catch (e) {
      print("Completed Cases Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("pending Cases"),
      ),

      backgroundColor: const Color(0xFFF5F7FB),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : mdApprovedCases.isEmpty
              ? const Center(child: Text("No MD Approved cases"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: mdApprovedCases.length,
                  itemBuilder: (context, index) {

                    final caseItem = mdApprovedCases[index];

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