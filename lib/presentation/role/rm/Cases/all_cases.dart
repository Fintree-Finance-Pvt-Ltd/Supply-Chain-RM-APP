// //  import 'dart:convert';

// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:supply_chain/core/constants/api_endpoints.dart';
 
// // ///  CASE STATUS PIPELINE
// // /// =======================================================
 
// // enum CaseStatus {
// //   draft,
// //   submitted,
// //   opsReview,
// //   ceoApproved,
// //   mdApproved,
// //   returnedToRm,
// //   completed,
// //   rejected,
// // }
 
// // ///  ROLE DEFINITIONS
// // /// =======================================================
 
// // enum UserRole {
// //   rm,
// //   credit,
// //   ceo,
// //   md,
// // }
 
// // /// =======================================================
// // ///  CASE MODEL
// // /// =======================================================
 
// // class CaseModel {
// //   final String id;
// //   final String name;
// //   final String mobile;
// //   final String pan;
// //   final String lan;
// //   final DateTime createdAt;
 
// //   CaseStatus status;
// //   UserRole currentOwner;
 
// //   CaseModel({
// //     required this.id,
// //     required this.name,
// //     required this.mobile,
// //     required this.pan,
// //     required this.lan,
// //     required this.createdAt,
// //     required this.status,
// //     required this.currentOwner,
// //   });
// // }
 
// // /// =======================================================
// // /// STATUS → OWNER MAPPING
// // /// =======================================================
 
// // UserRole ownerForStatus(CaseStatus status) {
// //   switch (status) {
// //     case CaseStatus.draft:
// //     case CaseStatus.returnedToRm:
// //       return UserRole.rm;
// //     case CaseStatus.submitted:
// //     case CaseStatus.opsReview:
// //       return UserRole.credit;
// //     case CaseStatus.ceoApproved:
// //       return UserRole.ceo;
// //     case CaseStatus.mdApproved:
// //       return UserRole.md;
// //     case CaseStatus.completed:
// //     case CaseStatus.rejected:
// //       return UserRole.rm;
// //   }
// // }
 
// // /// =======================================================
// // /// STATUS LABEL
// // /// =======================================================
 
// // String statusLabel(CaseStatus s) {
// //   switch (s) {
// //     case CaseStatus.draft:
// //       return "Draft";
// //     case CaseStatus.submitted:
// //       return "Submitted";
// //     case CaseStatus.opsReview:
// //       return "Ops Review";
// //     case CaseStatus.ceoApproved:
// //       return "CEO Approved";
// //     case CaseStatus.mdApproved:
// //       return "MD Approved";
// //     case CaseStatus.returnedToRm:
// //       return "Returned";
// //     case CaseStatus.completed:
// //       return "Completed";
// //     case CaseStatus.rejected:
// //       return "Rejected";
// //   }
// // }
 
// // /// =======================================================
// // /// DEMO DATA
// // /// =======================================================
 
// // final List<CaseModel> demoCases = [
// //   CaseModel(
// //     id: "1",
// //     name: "Vishal Yadav",
// //     mobile: "9876543210",
// //     pan: "ABCDE1234F",
// //     lan: "LAN0001",
// //     createdAt: DateTime.now().subtract(const Duration(days: 1)),
// //     status: CaseStatus.draft,
// //     currentOwner: ownerForStatus(CaseStatus.draft),
// //   ),
// //   CaseModel(
// //     id: "2",
// //     name: "Rohit Joshi",
// //     mobile: "9876549876",
// //     pan: "PQRSX6789L",
// //     lan: "LAN0002",
// //     createdAt: DateTime.now().subtract(const Duration(days: 2)),
// //     status: CaseStatus.submitted,
// //     currentOwner: ownerForStatus(CaseStatus.submitted),
// //   ),
// //   CaseModel(
// //     id: "3",
// //     name: "Sandeep Kumar",
// //     mobile: "9123456789",
// //     pan: "LMNOP4321K",
// //     lan: "LAN0003",
// //     createdAt: DateTime.now().subtract(const Duration(days: 3)),
// //     status: CaseStatus.ceoApproved,
// //     currentOwner: ownerForStatus(CaseStatus.ceoApproved),
// //   ),
// //   CaseModel(
// //     id: "4",
// //     name: "Amit Verma",
// //     mobile: "9988776655",
// //     pan: "ZXCVB9876Q",
// //     lan: "LAN0004",
// //     createdAt: DateTime.now().subtract(const Duration(days: 4)),
// //     status: CaseStatus.completed,
// //     currentOwner: ownerForStatus(CaseStatus.completed),
// //   ),
// // ];
 
// // /// =======================================================
// // ///  MODERN CASES SCREEN (ALL USERS)
// // /// =======================================================
 
// // // class CasesScreen extends StatelessWidget {
// // //   const CasesScreen({super.key, required UserRole role});
// //  class CasesScreen extends StatefulWidget {
// //   final UserRole role;

// //   const CasesScreen({super.key, required this.role});

// //   @override
// //   State<CasesScreen> createState() => _CasesScreenState();
// // }
// // class _CasesScreenState extends State<CasesScreen> {
// //   List<CaseModel> cases = [];
// //   bool loading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchCases();
// //   }
// //   Future<void> fetchCases() async {
// //   try {
// //     final prefs = await SharedPreferences.getInstance();
// //     final token = prefs.getString("token");

// //     final response = await http.get(
// //       Uri.parse("${ApiEndpoints.baseUrl}/customers"),
// //       headers: {
// //         "Authorization": "Bearer $token",
// //         "Content-Type": "application/json",
// //       },
// //     );

// //     final body = jsonDecode(response.body);

// //     if (body["success"] == true) {
// //       final List data = body["data"];

// //       final fetchedCases = data.map((c) {
// //         return CaseModel(
// //           id: c["id"].toString(),
// //           name: c["companyName"] ?? "",
// //           mobile: c["companyMobile"] ?? "",
// //           pan: c["pan"] ?? "",
// //           lan: c["lanId"] ?? "Pending",
// //           createdAt: DateTime.parse(c["createdAt"]),
// //           status: _statusFromString(c["status"]),
// //           currentOwner: ownerForStatus(_statusFromString(c["status"])),
// //         );
// //       }).toList();

// //       setState(() {
// //         cases = fetchedCases;
// //         loading = false;
// //       });
// //     }
// //   } catch (e) {
// //     print("Fetch cases error: $e");
// //   }
// // }
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF5F7FB),
 
// //       /// Clean AppBar
// //       appBar: AppBar(
// //         elevation: 0,
// //         backgroundColor: Colors.white,
// //         title: const Text(
// //           "Cases",
// //           style: TextStyle(
// //             fontSize: 20,
// //             fontWeight: FontWeight.w700,
// //             color: Colors.black87,
// //           ),
// //         ),
// //       ),
 
// //       body: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           /// Header
// //           const Padding(
// //             padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   "Customers",
// //                   style: TextStyle(
// //                     fontSize: 24,
// //                     fontWeight: FontWeight.w800,
// //                   ),
// //                 ),
// //                 SizedBox(height: 6),
// //                 Text(
// //                   "Monitor and track onboarding progress",
// //                   style: TextStyle(
// //                     color: Colors.grey,
// //                     fontSize: 14,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
 
// //           /// Case List
// //         Expanded(
// //   child: loading
// //       ? const Center(child: CircularProgressIndicator())
// //       : cases.isEmpty
// //           ? const Center(child: Text("No cases found"))
// //           : ListView.builder(
// //               padding: const EdgeInsets.all(16),
// //               itemCount: cases.length,
// //               itemBuilder: (_, i) => _caseCard(cases[i]),
// //             ),
// // ),
// //         ],
// //       ),
// //     );
// //   }
 
// //   /// =======================================================
// //   /// MODERN CASE CARD
// //   /// =======================================================
 
// //   Widget _caseCard(CaseModel c) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 14),
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(18),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.04),
// //             blurRadius: 24,
// //             offset: const Offset(0, 12),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           /// Name + Status
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Expanded(
// //                 child: Text(
// //                   c.name,
// //                   style: const TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.w700,
// //                   ),
// //                 ),
// //               ),
// //               _statusChip(c.status),
// //             ],
// //           ),
 
// //           const SizedBox(height: 12),
 
// //           /// Phone
// //           Row(
// //             children: [
// //               const Icon(Icons.phone, size: 16, color: Colors.grey),
// //               const SizedBox(width: 6),
// //               Text(c.mobile),
// //             ],
// //           ),
 
// //           const SizedBox(height: 10),
 
// //           /// PAN & LAN
// //           Text(
// //             "PAN: ${c.pan}  •  LAN: ${c.lan}",
// //             style: const TextStyle(fontSize: 13),
// //           ),
 
// //           const SizedBox(height: 12),
 
// //           /// Date
// //           Row(
// //             children: [
// //               const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
// //               const SizedBox(width: 6),
// //               Text(
// //                 "${c.createdAt.day}/${c.createdAt.month}/${c.createdAt.year}",
// //                 style: const TextStyle(fontSize: 12, color: Colors.grey),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
 
// //   /// =======================================================
// //   /// STATUS CHIP
// //   /// =======================================================
 

// //  CaseStatus _statusFromString(String? status) {
// //   switch (status) {
// //     case "draft":
// //       return CaseStatus.draft;
// //     case "submitted":
// //       return CaseStatus.submitted;
// //     case "ops_review":
// //       return CaseStatus.opsReview;
// //     case "ceo_approved":
// //       return CaseStatus.ceoApproved;
// //     case "md_approved":
// //       return CaseStatus.mdApproved;
// //     case "returned":
// //       return CaseStatus.returnedToRm;
// //     case "completed":
// //       return CaseStatus.completed;
// //     case "rejected":
// //       return CaseStatus.rejected;
// //     default:
// //       return CaseStatus.draft;
// //   }
// // }
// //   Widget _statusChip(CaseStatus status) {
// //     Color bg;
// //     Color fg;
 
// //     switch (status) {
// //       case CaseStatus.completed:
// //         bg = const Color(0xFFD1FAE5);
// //         fg = const Color(0xFF065F46);
// //         break;
// //       case CaseStatus.draft:
// //         bg = const Color(0xFFE5E7EB);
// //         fg = const Color(0xFF374151);
// //         break;
// //       case CaseStatus.submitted:
// //       case CaseStatus.opsReview:
// //         bg = const Color(0xFFDBEAFE);
// //         fg = const Color(0xFF1D4ED8);
// //         break;
// //       case CaseStatus.ceoApproved:
// //       case CaseStatus.mdApproved:
// //         bg = const Color(0xFFFDE68A);
// //         fg = const Color(0xFF92400E);
// //         break;
// //       case CaseStatus.rejected:
// //         bg = const Color(0xFFFEE2E2);
// //         fg = const Color(0xFF991B1B);
// //         break;
// //       case CaseStatus.returnedToRm:
// //         bg = const Color(0xFFE0E7FF);
// //         fg = const Color(0xFF3730A3);
// //         break;
// //     }
 
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //       decoration: BoxDecoration(
// //         color: bg,
// //         borderRadius: BorderRadius.circular(20),
// //       ),
// //       child: Text(
// //         statusLabel(status),
// //         style: TextStyle(
// //           fontSize: 12,
// //           fontWeight: FontWeight.w600,
// //           color: fg,
// //         ),
// //       ),
// //     );
// //   }
// // }
 

//  import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supply_chain/core/constants/api_endpoints.dart';
// import 'package:supply_chain/presentation/role/rm/Cases/case_details.dart';
 
// /// =======================================================
// /// CASE STATUS PIPELINE
// /// =======================================================
 
// enum CaseStatus {
//   draft,
//   submitted,
//   opsReview,
//   ceoApproved,
//   mdApproved,
//   returnedToRm,
//   completed,
//   rejected,
// }
 
// CaseStatus statusFromApi(String? status) {
//   switch (status) {
//     case "draft":
//       return CaseStatus.draft;
//     case "submitted":
//       return CaseStatus.submitted;
//     case "completed":
//       return CaseStatus.completed;
//     case "md_pending_terms":
//       return CaseStatus.mdApproved;
//     default:
//       return CaseStatus.draft;
//   }
// }
 
// /// =======================================================
// /// ROLE DEFINITIONS
// /// =======================================================
 
// enum UserRole {
//   rm,
//   credit,
//   ceo,
//   md,
// }
 
// /// =======================================================
// /// CASE MODEL
// /// =======================================================
 
// class CaseModel {
//   final String id;
//   final String name;
//   final String mobile;
//   final String pan;
//   final String lan;
//   final DateTime createdAt;
 
//   CaseStatus status;
//   UserRole currentOwner;
 
//   CaseModel({
//     required this.id,
//     required this.name,
//     required this.mobile,
//     required this.pan,
//     required this.lan,
//     required this.createdAt,
//     required this.status,
//     required this.currentOwner,
//   });
 
//   factory CaseModel.fromJson(Map<String, dynamic> json) {
//     final status = statusFromApi(json["status"]);
 
//     return CaseModel(
//       id: json["id"].toString(),
//       name: json["companyName"] ?? json["name"] ?? "",
//       mobile: json["companyMobile"] ?? json["mobile"] ?? "",
//       pan: json["companyPan"] ?? json["pan"] ?? "",
//       lan: json["lanId"] ?? "",
//       createdAt: DateTime.parse(json["createdAt"]),
//       status: status,
//       currentOwner: ownerForStatus(status),
//     );
//   }
// }
 
// /// =======================================================
// /// STATUS → OWNER MAPPING
// /// =======================================================
 
// UserRole ownerForStatus(CaseStatus status) {
//   switch (status) {
//     case CaseStatus.draft:
//     case CaseStatus.returnedToRm:
//       return UserRole.rm;
//     case CaseStatus.submitted:
//     case CaseStatus.opsReview:
//       return UserRole.credit;
//     case CaseStatus.ceoApproved:
//       return UserRole.ceo;
//     case CaseStatus.mdApproved:
//       return UserRole.md;
//     case CaseStatus.completed:
//     case CaseStatus.rejected:
//       return UserRole.rm;
//   }
// }
 
// /// =======================================================
// /// STATUS LABEL
// /// =======================================================
 
// String statusLabel(CaseStatus s) {
//   switch (s) {
//     case CaseStatus.draft:
//       return "Draft";
//     case CaseStatus.submitted:
//       return "Submitted";
//     case CaseStatus.opsReview:
//       return "Ops Review";
//     case CaseStatus.ceoApproved:
//       return "CEO Approved";
//     case CaseStatus.mdApproved:
//       return "MD Approved";
//     case CaseStatus.returnedToRm:
//       return "Returned";
//     case CaseStatus.completed:
//       return "Completed";
//     case CaseStatus.rejected:
//       return "Rejected";
//   }
// }
 
// /// =======================================================
// /// CASES SCREEN
// /// =======================================================
 
// class CasesScreen extends StatefulWidget {
//   const CasesScreen({super.key, required this.role});
 
//   final UserRole role;
 
//   @override
//   State<CasesScreen> createState() => _CasesScreenState();
// }
 
// class _CasesScreenState extends State<CasesScreen> {
//   List<CaseModel> cases = [];
//   bool loading = true;
 
//   @override
//   void initState() {
//     super.initState();
//     fetchCustomers();
//   }
// Future<void> fetchCustomers() async {
//   try {
//     final prefs = await SharedPreferences.getInstance();
 
//     /// Get token stored during login
//     final token = prefs.getString("token");
 
//     final response = await http.get(
//       Uri.parse("${ApiEndpoints.baseUrl}/customers"),
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $token",
//       },
//     );
 
//     final data = jsonDecode(response.body);
 
//     if (data["success"]) {
//       final List list = data["data"];
 
//       setState(() {
//         cases = list.map((e) => CaseModel.fromJson(e)).toList();
//         loading = false;
//       });
//     } else {
//       setState(() {
//         loading = false;
//       });
//     }
//   } catch (e) {
//     print("Customer Fetch Error: $e");
 
//     setState(() {
//       loading = false;
//     });
//   }
// }
 
//   /// =======================================================
//   /// UI BUILD
//   /// =======================================================
 
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FB),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         title: const Text(
//           "Cases",
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w700,
//             color: Colors.black87,
//           ),
//         ),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// Header
//           const Padding(
//             padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Customers",
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 SizedBox(height: 6),
//                 Text(
//                   "Monitor and track onboarding progress",
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
 
//           /// Case List
//           loading
//               ? const Expanded(
//                   child: Center(child: CircularProgressIndicator()),
//                 )
//               : Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: cases.length,
//                     itemBuilder: (_, i) => _caseCard(cases[i]),
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }
 
//   /// =======================================================
//   /// CASE CARD
//   /// =======================================================
 
 
//   // Widget _caseCard(CaseModel c) {
//   //   return Container(
//   //     margin: const EdgeInsets.only(bottom: 14),
//   //     padding: const EdgeInsets.all(16),
//   //     decoration: BoxDecoration(
//   //       color: Colors.white,
//   //       borderRadius: BorderRadius.circular(18),
//   //       boxShadow: [
//   //         BoxShadow(
//   //           color: Colors.black.withOpacity(0.04),
//   //           blurRadius: 24,
//   //           offset: const Offset(0, 12),
//   //         ),
//   //       ],
//   //     ),
//   //     child: Column(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: [
//   //         /// Name + Status
//   //         Row(
//   //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //           children: [
//   //             Expanded(
//   //               child: Text(
//   //                 c.name.isEmpty ? "No Name" : c.name,
//   //                 style: const TextStyle(
//   //                   fontSize: 16,
//   //                   fontWeight: FontWeight.w700,
//   //                 ),
//   //               ),
//   //             ),
//   //             _statusChip(c.status),
//   //           ],
//   //         ),
 
//   //         const SizedBox(height: 12),
 
//   //         /// Phone
//   //         Row(
//   //           children: [
//   //             const Icon(Icons.phone, size: 16, color: Colors.grey),
//   //             const SizedBox(width: 6),
//   //             Text(c.mobile.isEmpty ? "-" : c.mobile),
//   //           ],
//   //         ),
 
//   //         const SizedBox(height: 10),
 
//   //         /// PAN & LAN
//   //         Text(
//   //           "PAN: ${c.pan.isEmpty ? "-" : c.pan}  •  LAN: ${c.lan.isEmpty ? "-" : c.lan}",
//   //           style: const TextStyle(fontSize: 13),
//   //         ),
 
//   //         const SizedBox(height: 12),
 
//   //         /// Date
//   //         Row(
//   //           children: [
//   //             const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
//   //             const SizedBox(width: 6),
//   //             Text(
//   //               "${c.createdAt.day}/${c.createdAt.month}/${c.createdAt.year}",
//   //               style: const TextStyle(fontSize: 12, color: Colors.grey),
//   //             ),
//   //           ],
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
 
//  Widget _caseCard(CaseModel c) {
//   return InkWell(
//     borderRadius: BorderRadius.circular(18),
//     onTap: () {

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => CaseDetailsPage(
//             customerId: int.parse(c.id),
//           ),
//         ),
//       );

//     },
//     child: Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 24,
//             offset: const Offset(0, 12),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   c.name.isEmpty ? "No Name" : c.name,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//               _statusChip(c.status),
//             ],
//           ),
//           const SizedBox(height: 12),

//           Row(
//             children: [
//               const Icon(Icons.phone, size: 16, color: Colors.grey),
//               const SizedBox(width: 6),
//               Text(c.mobile.isEmpty ? "-" : c.mobile),
//             ],
//           ),

//           const SizedBox(height: 10),

//           Text(
//             "PAN: ${c.pan.isEmpty ? "-" : c.pan}  •  LAN: ${c.lan.isEmpty ? "-" : c.lan}",
//             style: const TextStyle(fontSize: 13),
//           ),

//           const SizedBox(height: 12),

//           Row(
//             children: [
//               const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
//               const SizedBox(width: 6),
//               Text(
//                 "${c.createdAt.day}/${c.createdAt.month}/${c.createdAt.year}",
//                 style: const TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }
//   /// =======================================================
//   /// STATUS CHIP
//   /// =======================================================
 
//   Widget _statusChip(CaseStatus status) {
//     Color bg;
//     Color fg;
 
//     switch (status) {
//       case CaseStatus.completed:
//         bg = const Color(0xFFD1FAE5);
//         fg = const Color(0xFF065F46);
//         break;
 
//       case CaseStatus.draft:
//         bg = const Color(0xFFE5E7EB);
//         fg = const Color(0xFF374151);
//         break;
 
//       case CaseStatus.submitted:
//       case CaseStatus.opsReview:
//         bg = const Color(0xFFDBEAFE);
//         fg = const Color(0xFF1D4ED8);
//         break;
 
//       case CaseStatus.ceoApproved:
//       case CaseStatus.mdApproved:
//         bg = const Color(0xFFFDE68A);
//         fg = const Color(0xFF92400E);
//         break;
 
//       case CaseStatus.rejected:
//         bg = const Color(0xFFFEE2E2);
//         fg = const Color(0xFF991B1B);
//         break;
 
//       case CaseStatus.returnedToRm:
//         bg = const Color(0xFFE0E7FF);
//         fg = const Color(0xFF3730A3);
//         break;
//     }
 
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         statusLabel(status),
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: fg,
//         ),
//       ),
//     );
//   }
// }
 


import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/presentation/role/rm/Cases/case_details.dart';
 
/// =======================================================
/// CASE STATUS PIPELINE
/// =======================================================
 
enum CaseStatus {
  draft,
  submitted,
  opsReview,
  ceoApproved,
  mdApproved,
  credit_l1_approved,
    credit_l2_approved,
md_terms_submitted,
  md_pending_terms,
  ops_l1_review,
  ops_l1_approved,
  returnedToRm,
  completed,
  rejected,
}
 
CaseStatus statusFromApi(String? status) {
 
  switch (status) {
 
    case "draft":
      return CaseStatus.draft;
 
    case "submitted":
      return CaseStatus.submitted;
 
    case "credit_l1_approved":
    return CaseStatus.credit_l1_approved;

 case "credit_l2_approved":
    return CaseStatus.credit_l2_approved;

    // case "credit_review":
        case "ops_l2_review":
      return CaseStatus.opsReview;

case "md_terms_submitted":
      return CaseStatus.md_terms_submitted;

         case "ops_l1_review":
return CaseStatus.ops_l1_review;

 case "ops_l1_approved":
return CaseStatus.ops_l1_approved;
    case "ceo_approved":
      return CaseStatus.ceoApproved;
 
    case "md_approved":
      return CaseStatus.mdApproved;
 
     case "md_pending_terms":
      return CaseStatus.md_pending_terms;

    case "completed":
      return CaseStatus.completed;
 
    case "rejected":
      return CaseStatus.rejected;
 
    case "returned_to_rm":
      return CaseStatus.returnedToRm;

        
 
    default:
      return CaseStatus.draft;
  }
}
 
/// =======================================================
/// ROLE DEFINITIONS
/// =======================================================
 
enum UserRole {
  rm,
  credit,
  ceo,
  md,
  operations_team_l1,
}
 
/// =======================================================
/// CASE MODEL
/// =======================================================
 
class CaseModel {
  final String id;
  final String name;
  final String mobile;
  final String pan;
  final String lan;
  final DateTime createdAt;
 
  CaseStatus status;
  UserRole currentOwner;
 
  CaseModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.pan,
    required this.lan,
    required this.createdAt,
    required this.status,
    required this.currentOwner,
  });
 
  factory CaseModel.fromJson(Map<String, dynamic> json) {
    final status = statusFromApi(json["status"]);
 
    return CaseModel(
      id: json["id"].toString(),
      name: json["companyName"] ?? json["name"] ?? "",
      mobile: json["companyMobile"] ?? json["mobile"] ?? "",
      pan: json["companyPan"] ?? json["pan"] ?? "",
      lan: json["lanId"] ?? "",
      createdAt: DateTime.parse(json["createdAt"]),
      status: status,
      currentOwner: ownerForStatus(status),
    );
  }
}
 
/// =======================================================
/// STATUS → OWNER MAPPING
/// =======================================================
 
UserRole ownerForStatus(CaseStatus status) {
  switch (status) {
    case CaseStatus.draft:
    case CaseStatus.returnedToRm:
      return UserRole.rm;
    case CaseStatus.submitted:
    case CaseStatus.opsReview:
      return UserRole.credit;
    case CaseStatus.ceoApproved:
      return UserRole.ceo;
    case CaseStatus.mdApproved:
      return UserRole.md;
      
      case  CaseStatus.md_terms_submitted:
      return UserRole.md;

      case  CaseStatus.ops_l1_review:
      return UserRole.credit;

  case  CaseStatus.credit_l1_approved:
      return UserRole.credit;

 case  CaseStatus.credit_l2_approved:
      return UserRole.credit;
      
 case  CaseStatus.ops_l1_approved:
      return UserRole.operations_team_l1;
      case  CaseStatus.md_pending_terms:
        return UserRole.md;
    case CaseStatus.ops_l1_review:
      return UserRole.credit;
    case CaseStatus.completed:
    case CaseStatus.rejected:
      return UserRole.rm;
  }
}
 
/// =======================================================
/// STATUS LABEL
/// =======================================================
 
String statusLabel(CaseStatus s) {
  switch (s) {
    case CaseStatus.draft:
      return "Draft";
    case CaseStatus.submitted:
      return "Submitted";
    case CaseStatus.opsReview:
      return "Ops Review";
    case CaseStatus.ceoApproved:
      return "CEO Approved";
    case CaseStatus.mdApproved:
      return "mdApproved";
    case CaseStatus.returnedToRm:
      return "Returned";

  case  CaseStatus.credit_l1_approved:
      return "Credit L1 Approved";
    
  case  CaseStatus.credit_l2_approved:
      return "Credit L2 Approved";

    case  CaseStatus.md_terms_submitted:
      return "MD Terms Submitted";

 case  CaseStatus.ops_l1_approved:
      return "Ops L1 Approved";
      
      case  CaseStatus.md_pending_terms:
        return "md_pending_terms";
    case
      CaseStatus.ops_l1_review:
      return "Ops L1 Review";
    case CaseStatus.completed:
      return "Completed";
    case CaseStatus.rejected:
      return "Rejected";
  }
}
 
/// =======================================================
/// CASES SCREEN
/// =======================================================
 
class CasesScreen extends StatefulWidget {
  const CasesScreen({super.key, required this.role});
 
  final UserRole role;
 
  @override
  State<CasesScreen> createState() => _CasesScreenState();
}
 
class _CasesScreenState extends State<CasesScreen> {
  List<CaseModel> cases = [];
  bool loading = true;
 
  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }
Future<void> fetchCustomers() async {
  try {
    final prefs = await SharedPreferences.getInstance();
 
    /// Get token stored during login
    final token = prefs.getString("token");
 final rmId = prefs.getInt("rmId");// Get rmId stored during login

    final response = await http.get(
      Uri.parse("${ApiEndpoints.baseUrl}/customers"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
 
    final data = jsonDecode(response.body);
 
    if (data["success"]) {
      final List list = data["data"];
 
        /// FILTER CASES BY RM ID
      final filteredList = list.where((e) {
        return e["rmId"] == rmId;
      }).toList();

 setState(() {
        cases = filteredList
            .map((e) => CaseModel.fromJson(e))
            .toList();
        loading = false;
      });

      
      // setState(() {
      //   cases = list.map((e) => CaseModel.fromJson(e)).toList();
      //   loading = false;
      // });
    } else {
      setState(() {
        loading = false;
      });
    }
  } catch (e) {
    print("Customer Fetch Error: $e");
 
    setState(() {
      loading = false;
    });
  }
}
 
  /// =======================================================
  /// UI BUILD
  /// =======================================================
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Cases",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Customers",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Monitor and track onboarding progress",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
 
          /// Case List
          loading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cases.length,
                    itemBuilder: (_, i) => _caseCard(cases[i]),
                  ),
                ),
        ],
      ),
    );
  }
 
  /// =======================================================
  /// CASE CARD
  /// =======================================================
  Widget _caseCard(CaseModel c) {
  return InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CaseDetailsPage(
            customerId: int.parse(c.id),
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  c.name.isEmpty ? "No Name" : c.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _statusChip(c.status),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(c.mobile.isEmpty ? "-" : c.mobile),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            "PAN: ${c.pan.isEmpty ? "-" : c.pan}  •  LAN: ${c.lan.isEmpty ? "-" : c.lan}",
            style: const TextStyle(fontSize: 13),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                "${c.createdAt.day}/${c.createdAt.month}/${c.createdAt.year}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
  // Widget _caseCard(CaseModel c) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 14),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(18),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.04),
  //           blurRadius: 24,
  //           offset: const Offset(0, 12),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         /// Name + Status
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Expanded(
  //               child: Text(
  //                 c.name.isEmpty ? "No Name" : c.name,
  //                 style: const TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w700,
  //                 ),
  //               ),
  //             ),
  //             _statusChip(c.status),
  //           ],
  //         ),
 
  //         const SizedBox(height: 12),
 
  //         /// Phone
  //         Row(
  //           children: [
  //             const Icon(Icons.phone, size: 16, color: Colors.grey),
  //             const SizedBox(width: 6),
  //             Text(c.mobile.isEmpty ? "-" : c.mobile),
  //           ],
  //         ),
 
  //         const SizedBox(height: 10),
 
  //         /// PAN & LAN
  //         Text(
  //           "PAN: ${c.pan.isEmpty ? "-" : c.pan}  •  LAN: ${c.lan.isEmpty ? "-" : c.lan}",
  //           style: const TextStyle(fontSize: 13),
  //         ),
 
  //         const SizedBox(height: 12),
 
  //         /// Date
  //         Row(
  //           children: [
  //             const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
  //             const SizedBox(width: 6),
  //             Text(
  //               "${c.createdAt.day}/${c.createdAt.month}/${c.createdAt.year}",
  //               style: const TextStyle(fontSize: 12, color: Colors.grey),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
 
  /// =======================================================
  /// STATUS CHIP
  /// =======================================================
 
  Widget _statusChip(CaseStatus status) {
    Color bg;
    Color fg;
 
    switch (status) {
      case CaseStatus.completed:
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        break;
 
      case CaseStatus.draft:
        bg = const Color(0xFFE5E7EB);
        fg = const Color(0xFF374151);
        break;
 
      case CaseStatus.submitted:
      case CaseStatus.opsReview:
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1D4ED8);
        break;
 
      case CaseStatus.ceoApproved:
      case CaseStatus.mdApproved:
        bg = const Color(0xFFFDE68A);
        fg = const Color(0xFF92400E);
        break;

        case CaseStatus.md_terms_submitted:
        bg = const Color(0xFFFDE68A);
        fg = const Color(0xFF92400E);
        break;


  case  CaseStatus.credit_l1_approved:
        bg = const Color(0xFFFDE68A);
                fg = const Color(0xFF92400E);
        break;

 case  CaseStatus.credit_l2_approved:
        bg = const Color(0xFFFDE68A);
                fg = const Color(0xFF92400E);
        break;
      
        case CaseStatus.md_pending_terms:
        bg = const Color(0xFFFDE68A);
        fg = const Color(0xFF92400E);
        break;
 case CaseStatus.ops_l1_review:
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        break;

            
 case  CaseStatus.ops_l1_approved:
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        break;
      case CaseStatus.rejected:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        break;
 
      case CaseStatus.returnedToRm:
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF3730A3);
        break;
    }
 
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusLabel(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
 