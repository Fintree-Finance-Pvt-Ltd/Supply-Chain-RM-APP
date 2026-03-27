// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supply_chain/core/services/draft_service.dart';
// import 'package:supply_chain/presentation/role/rm/Cases/all_cases.dart';
 
// /// =======================================================
// /// ENUMS
 
// enum CaseStatus {
//   draft,
//   submitted,
//   opsReview,
//   completed,
//   rejected,
// }
 
// /// CASE MODEL
// /// =======================================================
 
// class CaseModel {
//   final String id;
//   final String name;
//   final String mobile;
//   final String pan;
//   final DateTime createdAt;
//   CaseStatus status;
 
//   CaseModel({
//     required this.id,
//     required this.name,
//     required this.mobile,
//     required this.pan,
//     required this.createdAt,
//     required this.status,
//   });
 
//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         "mobile": mobile,
//         "pan": pan,
//         "createdAt": createdAt.toIso8601String(),
//         "status": status.name,
//       };
 
//   factory CaseModel.fromJson(Map<String, dynamic> json) {
//     return CaseModel(
//       id: json["id"],
//       name: json["name"],
//       mobile: json["mobile"],
//       pan: json["pan"],
//       createdAt: DateTime.parse(json["createdAt"]),
//       status: CaseStatus.values.firstWhere(
//         (e) => e.name == json["status"],
//       ),
//     );
//   }
// }
 
// /// =======================================================
// /// STORAGE KEYS
// /// =======================================================
 
// const String allCasesKey = "all_cases";
// const String submittedCasesKey = "submitted_cases"; // from your flow
 
// /// =======================================================
// /// CASE FLOW PAGE (RM VIEW)
// /// =======================================================
 
// class CaseFlowPage extends StatefulWidget {
//   final UserRole role;
 
//   const CaseFlowPage({
//     super.key,
//     required this.role,
//   });
 
//   @override
//   State<CaseFlowPage> createState() => _CaseFlowPageState();
// }
 
// class _CaseFlowPageState extends State<CaseFlowPage>
//     with SingleTickerProviderStateMixin {
//   // late TabController _tabController;
//   List<CaseModel> allCases = [];
 

//   @override
//   void initState() {
//     super.initState();
//     _loadCases();
//   }
 
//   /// =======================================================
//   /// LOAD + MERGE CASES
//   /// =======================================================
//  Future<void> _loadCases() async {
//   final prefs = await SharedPreferences.getInstance();
//   final List<CaseModel> master = [];

//   /// 1️⃣ LOAD DRAFT
//   final draftList = await DraftService.loadDraft();

//   if (draftList.isNotEmpty) {
//     for (final item in draftList) {
//       if (item is Map<String, dynamic>) {
//         final company = item["company"] ?? {};
//         final applicant = item["applicant"] ?? {};

//         master.add(
//           CaseModel(
//             id: DateTime.now().millisecondsSinceEpoch.toString(),
//             name: applicant["name"] ??
//                 company["companyName"] ??
//                 "Draft Case",
//             mobile: applicant["mobile"] ??
//                 company["mobile"] ??
//                 "",
//             pan: applicant["pan"] ?? "",
//             createdAt: DateTime.now(),
//             status: CaseStatus.draft,
//           ),
//         );
//       }
//     }
//   }

//   /// 2️⃣ LOAD submitted_cases (HANDLE DOUBLE LIST)
//   final rawSubmitted = prefs.getString(submittedCasesKey);

//   if (rawSubmitted != null) {
//     final decoded = jsonDecode(rawSubmitted);

//     if (decoded is List) {
//       for (final item in decoded) {
//         // Case 1: normal map
//         if (item is Map<String, dynamic>) {
//           _addSubmitted(master, item);
//         }

//         // Case 2: nested list
//         else if (item is List) {
//           for (final inner in item) {
//             if (inner is Map<String, dynamic>) {
//               _addSubmitted(master, inner);
//             }
//           }
//         }
//       }
//     }
//   }

//   /// 3️⃣ LOAD saved all_cases
//   final rawAll = prefs.getString(allCasesKey);

//   if (rawAll != null) {
//     final decoded = jsonDecode(rawAll) as List;
//     master.addAll(decoded.map((e) => CaseModel.fromJson(e)));
//   }

//   setState(() {
//     allCases = master;
//   });
// }

// /// helper
// void _addSubmitted(List<CaseModel> master, Map<String, dynamic> item) {
//   final company = item["company"] ?? {};
//   final applicant = item["applicant"] ?? {};

//   master.add(
//     CaseModel(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       name: applicant["name"] ??
//           company["companyName"] ??
//           "Submitted Case",
//       mobile: applicant["mobile"] ??
//           company["mobile"] ??
//           "",
//       pan: applicant["pan"] ?? "",
//       createdAt: DateTime.now(),
//       status: CaseStatus.submitted,
//     ),
//   );
// }

//  @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: const Color(0xFFF5F7FB),
//     appBar: AppBar(
//       elevation: 0,
//       backgroundColor: Colors.white,
//       centerTitle: true,
//       title: const Text(
//         "All Cases",
//         style: TextStyle(
//           fontWeight: FontWeight.w600,
//           color: Colors.black,
//         ),
//       ),
//     ),
//     body: allCases.isEmpty
//         ? const Center(child: Text("No cases available"))
//         : ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: allCases.length,
//             itemBuilder: (_, i) => CaseCard(allCases[i]),
//           ),
//   );
// }
 
 
// }
 
// /// =======================================================
// /// CASE CARD (UI)
// /// =======================================================
 
// class CaseCard extends StatelessWidget {
//   final CaseModel c;
//   const CaseCard(this.c, {super.key});
 
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 16,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(c.name,
//                 style:
//                     const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//             _statusChip(c.status),
//           ],
//         ),
//         const SizedBox(height: 10),
//         Row(children: [
//           const Icon(Icons.phone, size: 16, color: Colors.grey),
//           const SizedBox(width: 6),
//           Text(c.mobile),
//         ]),
//         const SizedBox(height: 10),
//         Text("PAN : ${c.pan}",
//             style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
//         const SizedBox(height: 10),
//         Row(children: [
//           const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
//           const SizedBox(width: 6),
//           Text(c.createdAt.toString().split(" ").first),
//         ]),
//       ]),
//     );
//   }
 
//   Widget _statusChip(CaseStatus status) {
//     Color bg;
//     Color fg;
 
//     switch (status) {
//       case CaseStatus.submitted:
//         bg = const Color(0xFFDBEAFE);
//         fg = const Color(0xFF1D4ED8);
//         break;
//       case CaseStatus.completed:
//         bg = const Color(0xFFD1FAE5);
//         fg = const Color(0xFF065F46);
//         break;
//       case CaseStatus.rejected:
//         bg = const Color(0xFFFEE2E2);
//         fg = const Color(0xFF991B1B);
//         break;
//       default:
//         bg = const Color(0xFFE5E7EB);
//         fg = const Color(0xFF374151);
//     }
 
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration:
//           BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
//       child: Text(status.name.toUpperCase(),
//           style: TextStyle(color: fg, fontSize: 12)),
//     );
//   }
// }
 