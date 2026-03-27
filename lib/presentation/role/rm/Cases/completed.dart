// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supply_chain/core/constants/api_endpoints.dart';
// import 'package:supply_chain/presentation/role/rm/Cases/case_details.dart';
// import 'package:supply_chain/presentation/role/rm/Cases/draft.dart';
// // import 'case_details_page.dart';

// class CompletedCasesPage extends StatefulWidget {
//   const CompletedCasesPage({super.key});

//   @override
//   State<CompletedCasesPage> createState() => _CompletedCasesPageState();
// }

// class _CompletedCasesPageState extends State<CompletedCasesPage> {

//   List completedCases = [];
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchCompletedCases();
//   }

//   /// Fetch completed cases from API
//   Future<void> fetchCompletedCases() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString("token");

//       final response = await http.get(
//         Uri.parse("${ApiEndpoints.baseUrl}/customers?status=completed"),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//       );

//       final body = jsonDecode(response.body);

//       if (body["success"] == true) {
//         setState(() {
//           completedCases = body["data"];
//           loading = false;
//         });
//       }

//     } catch (e) {
//       print("Completed Cases Error: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {

//     if (loading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }

//     if (completedCases.isEmpty) {
//       return const Center(
//         child: Text("No completed cases"),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: completedCases.length,
//       itemBuilder: (context, index) {

//         final caseItem = completedCases[index];

//         final applicant = caseItem["applicant"] ?? {};
//         final company = caseItem["company"] ?? {};

//         return InkWell(
//           onTap: () {

//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => CaseDetailsPage(
//                   customerId: caseItem["id"],
//                 ),
//               ),
//             );

//           },
//           child: CaseCard(
//             name: applicant["name"] ??
//                 company["companyName"] ??
//                 "Unknown",

//             mobile: applicant["mobile"] ??
//                 company["companyMobile"] ??
//                 "",

//             status: "Completed",

//             date: caseItem["createdAt"] ?? "",

//             PAN: applicant["pan"] ?? "",

//             LAN: caseItem["lanId"] ?? "N/A",
//           ),
//         );
//       },
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/theme/app_colors.dart';
import 'package:supply_chain/presentation/role/rm/Cases/case_details.dart';
import 'package:supply_chain/presentation/role/rm/Cases/invoice_page.dart';

class CompletedCasesPage extends StatefulWidget {
  const CompletedCasesPage({super.key});

  @override
  State<CompletedCasesPage> createState() => _CompletedCasesPageState();
}

class _CompletedCasesPageState extends State<CompletedCasesPage> {
  List completedCases = [];
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
        Uri.parse("${ApiEndpoints.baseUrl}/customers?status=completed"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final body = jsonDecode(response.body);

      if (body["success"] == true) {
        /// Filter only completed cases
        final allCases = body["data"] ?? [];

  completedCases = allCases.where((e) {
    return e["status"] == "completed" && e["rmId"] == rmId;
  }).toList();

  setState(() {
    // completedCases = completed;
    loading = false;
  });
        // completedCases = allCases.where((c) {
        //   return (c["status"] ?? "").toString().toLowerCase() == "completed";
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
      appBar: AppBar(title: const Text("Completed Cases")),

      backgroundColor: const Color(0xFFF5F7FB),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : completedCases.isEmpty
          ? const Center(child: Text("No completed cases"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: completedCases.length,
              itemBuilder: (context, index) {
                final caseItem = completedCases[index];

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
                    // onTap: () {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (_) =>

                    //           // CaseDetailsPage(customerId: caseItem["id"]),
                    //     ),
                    //   );
                    // },
                        onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /// VIEW CASE DETAILS
                                ListTile(
                                  leading: const Icon(Icons.visibility),
                                  title: const Text("View Details"),
                                  onTap: () {
                                    Navigator.pop(context);
 
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CaseDetailsPage(
                                          customerId: caseItem["id"],
                                        ),
                                      ),
                                    );
                                  },
                                ),
 
                                const Divider(),
 
                                /// INVOICE DETAILS
                                ListTile(
                                  leading: const Icon(Icons.receipt_long),
                                  title: const Text("Invoice Details"),
                                  onTap: () {
                                    Navigator.pop(context);
 
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => InvoicePage(
                                          customerId: caseItem["id"],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
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
                                  color: AppColors.darkBlue,
                                
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
                                  color: const Color(0xFFE6F7ED),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 14,
                                      color: Color(0xFF16A34A),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Completed",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF16A34A),
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
                                  color: AppColors.darkBlue,
                                ),
                              ),
                            ),
 
                          const SizedBox(height: 12),
 
                          /// DATE + ARROW
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
