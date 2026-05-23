// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:supply_chain/core/services/auth_service.dart';
// import 'package:supply_chain/presentation/role/md/Cases/case_details.dart';

// class PendingApprovalsPage extends StatefulWidget {
//   const PendingApprovalsPage({super.key});

//   @override
//   State<PendingApprovalsPage> createState() => _PendingApprovalsPageState();
// }

// class _PendingApprovalsPageState extends State<PendingApprovalsPage> {

//   bool isLoading = true;
//   List pendingList = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchPendingApprovals();
//   }

//   Future<void> fetchPendingApprovals() async {
//     try {

//       final token = await AuthService().getToken();

//       final response = await http.get(
//         Uri.parse(
//           "https://supplychain-prod.fintreelms.com/api/workflows/customers/dashboard/executive"
//         ),
//         headers: {
//           "Authorization": "Bearer $token"
//         },
//       );

//       final data = jsonDecode(response.body);

//      if (data["success"] == true) {
//   setState(() {
//     pendingList = data["data"]["pending"];
//     isLoading = false;
//   });
// }

//     } catch (e) {
//       debugPrint("Pending approvals error: $e");
//       setState(() {
//         isLoading = false;
//       });

//     }
//   }

// Widget _statusBadge(String status) {

//   Color bg;
//   Color text;

//   switch (status) {
//     case "ceo_approved":
//       bg = Colors.green.shade100;
//       text = Colors.green.shade800;
//       break;

//     case "md_terms_submitted":
//       bg = Colors.grey.shade200;
//       text = Colors.black87;
//       break;

//     default:
//       bg = Colors.orange.shade100;
//       text = Colors.orange.shade800;
//   }

//   return Container(
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//     decoration: BoxDecoration(
//       color: bg,
//       borderRadius: BorderRadius.circular(20),
//     ),
//     child: Text(
//       status.replaceAll("_", " ").toUpperCase(),
//       style: TextStyle(
//         color: text,
//         fontSize: 12,
//         fontWeight: FontWeight.w600,
//       ),
//     ),
//   );
// }

// String _formatDate(String date) {
//   final parsed = DateTime.parse(date);
//   return "${parsed.day} ${_month(parsed.month)} ${parsed.year}";
// }

// String _month(int m) {
//   const months = [
//     "",
//     "Jan","Feb","Mar","Apr","May","Jun",
//     "Jul","Aug","Sep","Oct","Nov","Dec"
//   ];
//   return months[m];
// }
//   @override
// Widget build(BuildContext context) {

//   return Scaffold(
//     appBar: AppBar(
//       title: const Text("Pending Approvals"),
//     ),

//     body: isLoading
//         ? const Center(child: CircularProgressIndicator())
//         : pendingList.isEmpty
//             ? const Center(child: Text("No Pending Approvals"))
//             : ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: pendingList.length,
//                 itemBuilder: (context, index) {

//                   final item = pendingList[index];
//                   final customer = item["customer"];

//                   return InkWell(
//                     borderRadius: BorderRadius.circular(18),

//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => CaseDetailsPage(
//                             customerId: item["customerId"],
//                           ),
//                         ),
//                       );
//                     },

//                     child: Container(
//                       margin: const EdgeInsets.only(bottom: 14),
//                       padding: const EdgeInsets.all(16),

//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(18),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 12,
//                           ),
//                         ],
//                       ),

//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [

//                           /// COMPANY NAME
//                           Text(
//                             customer["companyName"] ?? "N/A",
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w700,
//                               fontSize: 16,
//                             ),
//                           ),

//                           const SizedBox(height: 10),

//                           /// CUSTOMER CODE
//                           Row(
//                             children: [
//                               const Text(
//                                 "Customer Code: ",
//                                 style: TextStyle(
//                                   color: Colors.grey,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Text(
//                                   customer["lanId"] ?? "N/A",
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),

//                           const SizedBox(height: 12),

//                           /// STATUS + DATE
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [

//                               _statusBadge(item["currentStatus"]),

//                               Text(
//                                 _formatDate(item["updatedAt"]),
//                                 style: const TextStyle(
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//   );
// }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/auth_service.dart';
import 'package:supply_chain/presentation/role/md/Cases/case_details.dart';

class PendingApprovalsPage extends StatefulWidget {
  const PendingApprovalsPage({super.key});

  @override
  State<PendingApprovalsPage> createState() => _PendingApprovalsPageState();
}

class _PendingApprovalsPageState extends State<PendingApprovalsPage> {
  bool isLoading = true;
  List pendingList = [];

  @override
  void initState() {
    super.initState();
    fetchPendingApprovals();
  }

  Future<void> fetchPendingApprovals() async {
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
          pendingList = data["data"]["pending"];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Pending approvals error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  /// STATUS BADGE
  Widget _statusBadge(String status) {
    Color bg;
    Color text;

    switch (status) {
      case "ceo_approved":
        bg = Colors.green.shade100;
        text = Colors.green.shade800;
        break;

      case "md_terms_submitted":
        bg = Colors.grey.shade200;
        text = Colors.black87;
        break;

      default:
        bg = Colors.orange.shade100;
        text = Colors.orange.shade800;
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
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Pending Approvals",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pendingList.isEmpty
          ? const Center(child: Text("No Pending Approvals"))
          : RefreshIndicator(
              onRefresh: fetchPendingApprovals,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pendingList.length,
                itemBuilder: (context, index) {
                  final item = pendingList[index];
                  final customer = item["customer"];

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),

                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CaseDetailsPage(customerId: item["customerId"]),
                        ),
                      );

                      /// reload API after returning
                      fetchPendingApprovals();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [
                          /// COMPANY ICON
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.business,
                              color: Colors.blue,
                              size: 26,
                            ),
                          ),

                          const SizedBox(width: 14),

                          /// TEXT CONTENT
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// COMPANY NAME
                                Text(
                                  customer["companyName"] ?? "N/A",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                /// CUSTOMER CODE
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.badge_outlined,
                                      size: 15,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        customer["lanId"] ?? "N/A",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
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

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDate(item["updatedAt"]),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          /// ARROW
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
