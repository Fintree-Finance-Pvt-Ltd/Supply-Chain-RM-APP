import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/presentation/role/rm/Cases/case_details.dart';

class OpsReview extends StatefulWidget {
  const OpsReview({super.key});

  @override
  State<OpsReview> createState() => _OpsReviewState();
}

class _OpsReviewState extends State<OpsReview> {
  List opsCases = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCompletedCases();
  }

  /// FETCH COMPLETED CASES
  // Future<void> fetchCompletedCases() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString("token");

  //     final response = await http.get(
  //       Uri.parse("${ApiEndpoints.baseUrl}/customers?status=ops_l1_review"),
  //       headers: {
  //         "Authorization": "Bearer $token",
  //         "Content-Type": "application/json",
  //       },
  //     );

  //     final body = jsonDecode(response.body);

  //     if (body["success"] == true) {
  //       /// Filter only completed cases
  //       final allCases = body["data"] ?? [];

  //       opsCases = allCases.where((c) {
  //         final status = (c["status"] ?? "").toString().toLowerCase();
  //         return status == "ops_l1_review";
  //       }).toList();

  //       setState(() {
  //         loading = false;
  //       });
  //     }
  //   } catch (e) {
  //     print("Completed Cases Error: $e");
  //   }
  // }


  Future<void> fetchCompletedCases() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("${ApiEndpoints.baseUrl}/workflows/customers/dashboard/rm"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    final body = jsonDecode(response.body);

    if (body["success"] == true) {
      final dashboardData = body["data"];
      final List customers = dashboardData["customers"];

      /// Filter OPS REVIEW cases for this RM
      final ops = customers.where((c) {
        final status = (c["status"] ?? "").toString().toLowerCase();
        return status == "ops_l1_review" || status == "ops_l2_review";
      }).toList();

      setState(() {
        opsCases = ops;
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  } catch (e) {
    debugPrint("OpsReview Cases Error: $e");

    setState(() {
      loading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OpsReview Cases")),

      backgroundColor: const Color(0xFFF5F7FB),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : opsCases.isEmpty
          ? const Center(child: Text("No OpsReview cases"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: opsCases.length,
              itemBuilder: (context, index) {
                final caseItem = opsCases[index];

                final applicant = caseItem["applicant"] ?? {};
                // final company = caseItem["company"] ?? {};

                String name =
                    (caseItem["companyName"] ?? caseItem["name"] ?? "")
                        .toString();

                String initial = name.isNotEmpty ? name[0].toUpperCase() : "U";

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
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
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// TOP ROW
                          Row(
                            children: [
                              /// AVATAR
                              Container(
                                height: 42,
                                width: 42,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2563EB),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    initial,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              /// COMPANY NAME + MOBILE
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      caseItem["companyName"] ??
                                          caseItem["name"] ??
                                          "Applicant",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          caseItem["companyMobile"] ??
                                              caseItem["mobile"] ??
                                              "",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              /// STATUS BADGE
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3E8FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.rate_review,
                                      size: 14,
                                      color: Color(0xFF6B21A8),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Ops Review",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6B21A8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          /// LAN TAG
                          if ((caseItem["lanId"] ?? "").toString().isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "LAN ${caseItem["lanId"]}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),

                          const SizedBox(height: 12),

                          /// DATE
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                size: 14,
                                color: Colors.grey,
                              ),

                              const SizedBox(width: 6),

                              Text(
                                (caseItem["createdAt"] ?? "")
                                    .toString()
                                    .split("T")
                                    .first,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),

                              const Spacer(),

                              const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
