
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
//   //   int getPendingDays() {
//   //   try {
//   //     DateTime createdDate = DateTime.parse(date);
//   //     return DateTime.now().difference(createdDate).inDays;
//   //   } catch (e) {
//   //     return 0;
//   //   }
//   // }
 
//  String getPendingLabel() {
//   try {
//     DateTime createdDate = DateTime.parse(date).toLocal();
//     final difference = DateTime.now().difference(createdDate).inDays;

//     if (difference == 0) {
//       return "Pending • Today";
//     } else if (difference == 1) {
//       return "Pending • 1 day";
//     } else {
//       return "Pending • $difference days";
//     }
//   } catch (e) {
//     return "Pending";
//   }
// }
//   @override
//   Widget build(BuildContext context) {
//     //  final pendingDays = getPendingLabel();

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
//                /// Name + Pending badge row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 name,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),

//               /// Pending Tag
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.shade100,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   // "Pending • $pendingDays day${pendingDays == 1 ? '' : 's'}",
//                       getPendingLabel(),

//                   style: TextStyle(
//                     color: Colors.orange.shade800,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           // Text(
//           //   name,
//           //   style:
//           //       const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//           // ),
//           const SizedBox(height: 6),
//           Text("PAN : $PAN | LAN : $LAN"),
//           const SizedBox(height: 6),
//           Text(date, style: const TextStyle(color: Colors.grey)),
//         ],
//       ),
//     );
//   }
// }
 


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

  String getPendingLabel() {
    try {
      DateTime createdDate = DateTime.parse(date).toLocal();
      final difference = DateTime.now().difference(createdDate).inDays;
      if (difference == 0) return "Today";
      return "$difference ${difference == 1 ? 'day' : 'days'} ago";
    } catch (e) {
      return "Pending";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // 1. Status Color Accent Bar (Matches Dashboard Style)
              Container(
                width: 6,
                color: Colors.orange.shade400,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Header: Company Name & Pending Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "DRAFT",
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // 3. Info Row: PAN & LAN with Icons
                      Row(
                        children: [
                          _buildInfoChip(Icons.badge_outlined, "PAN", PAN),
                          const SizedBox(width: 12),
                          _buildInfoChip(Icons.account_tree_outlined, "LAN", LAN),
                        ],
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                      ),

                      // 4. Footer: Mobile & Time Ago
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.phone_android, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                mobile,
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                          Text(
                            getPendingLabel(),
                            style: TextStyle(
                              color: Colors.blueGrey.shade400,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the PAN/LAN chips
  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF334155),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}