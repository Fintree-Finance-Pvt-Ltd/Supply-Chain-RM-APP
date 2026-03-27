// import 'package:flutter/material.dart';
// import 'package:supply_chain/core/services/draft_service.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/address_details.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/applicant_details.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/co_applicant.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/company_details.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/contact_person.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/documents.dart';
 
// class Draft extends StatefulWidget {
//   const Draft({super.key});
 
//   @override
//   State<Draft> createState() => _DraftState();
// }
 
// // class _DraftState extends State<Draft>
// //     with SingleTickerProviderStateMixin {
// //   late TabController _tabController;
 
// //   final tabs = ["Draft"];
// //  List<Map<String, dynamic>> drafts = [];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: tabs.length, vsync: this);
// //   }
 
// //   @override
// //   void dispose() {
// //     _tabController.dispose();
// //     super.dispose();
// //       _loadDraft();

// //   }
 
// //  Future<void> _loadDraft() async {
// //   final draft = await DraftService.loadDraft();

// //   if (draft != null) {
// //     setState(() {
// //       drafts = [draft]; // since you store only 1 draft
// //     });
// //   }
// // }
// //   // ================= RESUME DRAFT =================
// // void _resumeDraft(BuildContext context, Map<String, dynamic> draft) {
// //   final step = draft["lastStep"];

// //   switch (step) {
// //     case "company":
// //       Navigator.push(context,
// //           MaterialPageRoute(builder: (_) => const CompanyDetails()));
// //       break;

// //     case "applicantDetails":
// //       Navigator.push(context,
// //           MaterialPageRoute(builder: (_) => const ApplicantDetails()));
// //       break;

// //     case "coApplicantDetails":
// //       Navigator.push(context,
// //           MaterialPageRoute(builder: (_) => const CoApplicant()));
// //       break;

// //     case "contactPerson":
// //       Navigator.push(context,
// //           MaterialPageRoute(builder: (_) => const ContactPerson()));
// //       break;

// //     case "addressDetails":
// //       Navigator.push(context,
// //           MaterialPageRoute(builder: (_) => const AddressDetails()));
// //       break;

// //     case "documents":
// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //           builder: (_) => DocumentsPage(
// //             companyType:
// //                 draft["company"]?["companyType"] ?? "Proprietorship",
// //           ),
// //         ),
// //       );
// //       break;

// //     default:
// //       Navigator.push(context,
// //           MaterialPageRoute(builder: (_) => const CompanyDetails()));
// //   }
// // }


 
// //   // ================= CASE LIST =================
// // //  

// // Widget _caseList() {
// //   return FutureBuilder<Map<String, dynamic>?>(
// //     future: DraftService.loadDraft(),
// //     builder: (context, snapshot) {
// //       if (!snapshot.hasData || snapshot.data == null) {
// //         return const Center(
// //           child: Text("No drafts available"),
// //         );
// //       }

// //       final draft = snapshot.data!;
// //       final company = draft["company"] ?? {};
// //       final applicant = draft["applicant"] ?? {};

// //       return ListView(
// //         padding: const EdgeInsets.all(16),
// //         children: [
// //           InkWell(
// //             onTap: () => _resumeDraft(context, draft),
// //             child: CaseCard(
// //               name: applicant["name"] ??
// //                   company["companyName"] ??
// //                   "Unknown",
// //               mobile: applicant["mobile"] ??
// //                   company["mobile"] ??
// //                   "",
// //               status: "Draft",
// //               date: "Saved Draft",
// //               PAN: applicant["pan"] ?? "",
// //               LAN: "N/A",
// //             ),
// //           ),
// //         ],
// //       );
// //     },
// //   );
// // }

  
 
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF5F7FB),
// //       appBar: AppBar(
// //         elevation: 0,
// //         backgroundColor: Colors.white,
// //         title: const Text(
// //           "Supply Chain Finance",
// //           style: TextStyle(color: Colors.black),
// //         ),
// //       ),
// //       body: Column(
// //         children: [
// //           TabBar(
// //             controller: _tabController,
// //             labelColor: const Color(0xFF2563EB),
// //             unselectedLabelColor: Colors.grey,
// //             tabs: tabs.map((t) => Tab(text: t)).toList(),
// //           ),
// //           Expanded(
// //             child: TabBarView(
// //               controller: _tabController,
// //               children: tabs.map((_) => _caseList()).toList(),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
 
// // /* ================= CASE CARD ================= */
 
// // class CaseCard extends StatelessWidget {
// //   final String name;
// //   final String mobile;
// //   final String status;
// //   final String date;
// //   final String PAN;
// //   final String LAN;
 
// //   const CaseCard({
// //     super.key,
// //     required this.name,
// //     required this.mobile,
// //     required this.status,
// //     required this.date,
// //     required this.PAN,
// //     required this.LAN,
// //   });
 
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 16),
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 16,
// //             offset: const Offset(0, 8),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(name,
// //               style:
// //                   const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
// //           const SizedBox(height: 6),
// //           Text("PAN : $PAN | LAN : $LAN"),
// //           const SizedBox(height: 6),
// //           Text(date, style: const TextStyle(color: Colors.grey)),
// //         ],
// //       ),
// //     );
// //   }
// // }
 
 

//  class _DraftState extends State<Draft>
//     with SingleTickerProviderStateMixin {

//   late TabController _tabController;
//   final tabs = ["Draft"];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: tabs.length, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   // ================= RESUME DRAFT =================
//   void _resumeDraft(BuildContext context, Map<String, dynamic> draft) {
//     final step = draft["lastStep"];

//     switch (step) {
//       case "company":
//         Navigator.push(context,
//             MaterialPageRoute(builder: (_) => const CompanyDetails()));
//         break;

//       case "applicantDetails":
//         Navigator.push(context,
//             MaterialPageRoute(builder: (_) => const ApplicantDetails()));
//         break;

//       case "coApplicantDetails":
//         Navigator.push(context,
//             MaterialPageRoute(builder: (_) => const CoApplicantPage()));
//         break;

//       case "contactPerson":
//         Navigator.push(context,
//             MaterialPageRoute(builder: (_) => const ContactPerson()));
//         break;

//       case "addressDetails":
//         Navigator.push(context,
//             MaterialPageRoute(builder: (_) => const AddressDetails()));
//         break;

//       case "documents":
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => DocumentsPage(
//               companyType:
//                   draft["company"]?["companyType"] ?? "Proprietorship",
//             ),
//           ),
//         );
//         break;

//       default:
//         Navigator.push(context,
//             MaterialPageRoute(builder: (_) => const CompanyDetails()));
//     }
//   }

//   // ================= CASE LIST =================
//   Widget _caseList() {
//     // return FutureBuilder<Map<String, dynamic>?>(
//     //   future: DraftService.loadDraft(),
//     //   builder: (context, snapshot) {

//     //     if (!snapshot.hasData || snapshot.data == null) {
//     //       return const Center(
//     //         child: Text("No drafts available"),
//     //       );
//     //     }

//     //     final draft = snapshot.data!;
//     //     final company = draft["company"] ?? {};
//     //     final applicant = draft["applicant"] ?? {};

//     //     return ListView(
//     //       padding: const EdgeInsets.all(16),
//     //       children: [
//     //         InkWell(
//     //           onTap: () => _resumeDraft(context, draft),
//     //           child: CaseCard(
//     //             name: applicant["name"] ??
//     //                 company["companyName"] ??
//     //                 "Unknown",
//     //             mobile: applicant["mobile"] ??
//     //                 company["mobile"] ??
//     //                 "",
//     //             status: "Draft",
//     //             date: "Saved Draft",
//     //             PAN: applicant["pan"] ?? "",
//     //             LAN: "N/A",
//     //           ),
//     //         ),
//     //       ],
//     //     );
//     //   },
//     // );


//     return FutureBuilder<List<dynamic>>(
//   future: DraftService.loadDraft(),
//   builder: (context, snapshot) {

//     if (!snapshot.hasData || snapshot.data!.isEmpty) {
//       return const Center(
//         child: Text("No drafts available"),
//       );
//     }

//     final draftList = snapshot.data!;

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: draftList.length,
//       itemBuilder: (context, index) {
//         final draft = draftList[index];

//         final company = draft["company"] ?? {};
//         final applicant = draft["applicant"] ?? {};

//         return InkWell(
//           onTap: () => _resumeDraft(context, draft),
//           child: CaseCard(
//             name: applicant["name"] ??
//                 company["companyName"] ??
//                 "Unknown",
//             mobile: applicant["mobile"] ??
//                 company["mobile"] ??
//                 "",
//             status: "Draft",
//             date: "Saved Draft",
//             PAN: applicant["pan"] ?? "",
//             LAN: "N/A",
//           ),
//         );
//       },
//     );
//   },
// );

//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FB),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         title: const Text(
//           "Supply Chain Finance",
//           style: TextStyle(color: Colors.black),
//         ),
//       ),
//       body: Column(
//         children: [
//           TabBar(
//             controller: _tabController,
//             labelColor: const Color(0xFF2563EB),
//             unselectedLabelColor: Colors.grey,
//             tabs: tabs.map((t) => Tab(text: t)).toList(),
//           ),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: tabs.map((_) => _caseList()).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//     }
// class CaseCard extends StatelessWidget {
//   final String name;
//   final String mobile;
//   final String status;
//   final String date;
//   final String PAN;
//   final String LAN;
 
//   const CaseCard({
//     super.key,
//     required this.name,
//     required this.mobile,
//     required this.status,
//     required this.date,
//     required this.PAN,
//     required this.LAN,
//   });
 
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
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(name,
//               style:
//                   const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//           const SizedBox(height: 6),
//           Text("PAN : $PAN | LAN : $LAN"),
//           const SizedBox(height: 6),
//           Text(date, style: const TextStyle(color: Colors.grey)),
//         ],
//       ),
//     );
//   }
// }
 


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
 
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/presentation/role/rm/Cases/resume_customer.dart';
 
 
class Draft extends StatefulWidget {
  const Draft({super.key});
 
  @override
  State<Draft> createState() => _DraftState();
}
 
class _DraftState extends State<Draft> with SingleTickerProviderStateMixin {
  late TabController _tabController;
 
  final tabs = ["Draft"];
 
  List<dynamic> drafts = [];
  bool loading = true;
 
  @override
  void initState() {
    super.initState();
 
    _tabController = TabController(length: tabs.length, vsync: this);
 
    _loadDraftCases();
  }
 
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
 
  /// ================= FETCH DRAFT LIST =================
  Future<void> _loadDraftCases() async {
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
 
 final draftCases = data.where((e) {
    return e["status"] == "draft" && e["rmId"] == rmId;
  }).toList();

  setState(() {
    drafts = draftCases;
    loading = false;
  });
        // final draftCases =
        //     data.where((e) => e["status"] == "draft").toList();
 
        // setState(() {
        //   drafts = draftCases;
        //   loading = false;
        // });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Draft Fetch Error: $e");
 
      setState(() {
        loading = false;
      });
    }
  }
 
  /// ================= FETCH SINGLE DRAFT =================
  Future<void> _openDraft(int customerId) async {
    try {
      setState(() {
        loading = true;
      });
 
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
 
      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/customers/$customerId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
 
      final body = jsonDecode(response.body);
 
      setState(() {
        loading = false;
      });
 
      if (body["success"] == true) {
        final draft = body["data"];
 
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResumeDraft(
              draftData: draft,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to load draft")),
        );
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
 
      debugPrint("Draft open error: $e");
 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    }
  }
 
  /// ================= CASE LIST =================
  Widget _caseList() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
 
    if (drafts.isEmpty) {
      return const Center(
        child: Text(
          "No Draft Cases Found",
          style: TextStyle(fontSize: 16),
        ),
      );
    }
 
    return RefreshIndicator(
      onRefresh: _loadDraftCases,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: drafts.length,
        itemBuilder: (context, index) {
          final draft = drafts[index];
 
          final name = draft["companyName"] ?? "Unknown";
          final mobile = draft["companyMobile"] ?? "";
          final pan = draft["companyPan"] ?? "";
          final lan = draft["lanId"] ?? "Pending";
          final createdAt = draft["createdAt"] ?? "";
 
          /// API returns id not customerId
          final customerId = draft["id"];
 
          return InkWell(
            onTap: () {
              _openDraft(customerId);
            },
            child: CaseCard(
              name: name,
              mobile: mobile,
              status: "Draft",
              date: createdAt,
              PAN: pan,
              LAN: lan,
            ),
          );
        },
      ),
    );
  }
 
  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Supply Chain Finance",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: Colors.grey,
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: tabs.map((_) => _caseList()).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
 
/// ================= CASE CARD =================
 
class CaseCard extends StatelessWidget {
  final String name;
  final String mobile;
  final String status;
  final String date;
  final String PAN;
  final String LAN;
 
  const CaseCard({
    super.key,
    required this.name,
    required this.mobile,
    required this.status,
    required this.date,
    required this.PAN,
    required this.LAN,
  });
  //   int getPendingDays() {
  //   try {
  //     DateTime createdDate = DateTime.parse(date);
  //     return DateTime.now().difference(createdDate).inDays;
  //   } catch (e) {
  //     return 0;
  //   }
  // }
 
 String getPendingLabel() {
  try {
    DateTime createdDate = DateTime.parse(date).toLocal();
    final difference = DateTime.now().difference(createdDate).inDays;

    if (difference == 0) {
      return "Pending • Today";
    } else if (difference == 1) {
      return "Pending • 1 day";
    } else {
      return "Pending • $difference days";
    }
  } catch (e) {
    return "Pending";
  }
}
  @override
  Widget build(BuildContext context) {
    //  final pendingDays = getPendingLabel();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
               /// Name + Pending badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              /// Pending Tag
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  // "Pending • $pendingDays day${pendingDays == 1 ? '' : 's'}",
                      getPendingLabel(),

                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          // Text(
          //   name,
          //   style:
          //       const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          // ),
          const SizedBox(height: 6),
          Text("PAN : $PAN | LAN : $LAN"),
          const SizedBox(height: 6),
          Text(date, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
 