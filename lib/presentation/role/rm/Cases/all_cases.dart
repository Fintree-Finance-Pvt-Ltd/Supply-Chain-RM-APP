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
enum UserRole { rm, credit, ceo, md, operations_team_l1 }

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
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),
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
    case CaseStatus.ops_l1_review:
    case CaseStatus.credit_l1_approved:
    case CaseStatus.credit_l2_approved:
      return UserRole.credit;
    case CaseStatus.ceoApproved:
      return UserRole.ceo;
    case CaseStatus.mdApproved:
    case CaseStatus.md_terms_submitted:
    case CaseStatus.md_pending_terms:
      return UserRole.md;
    case CaseStatus.ops_l1_approved:
      return UserRole.operations_team_l1;
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
      return "MD Approved";
    case CaseStatus.returnedToRm:
      return "Returned";
    case CaseStatus.credit_l1_approved:
      return "Credit L1 Approved";
    case CaseStatus.credit_l2_approved:
      return "Credit L2 Approved";
    case CaseStatus.md_terms_submitted:
      return "MD Terms Submitted";
    case CaseStatus.ops_l1_approved:
      return "Ops L1 Approved";
    case CaseStatus.md_pending_terms:
      return "MD Pending Terms";
    case CaseStatus.ops_l1_review:
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

  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    fetchCustomers();
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode") ?? false;
    });
  }

  Future<void> fetchCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final rmId = prefs.getInt("rmId");

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
        final filteredList = list.where((e) => e["rmId"] == rmId).toList();

        setState(() {
          cases = filteredList.map((e) => CaseModel.fromJson(e)).toList();
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("Customer Fetch Error: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0F172A)
          : const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,

        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),

        title: Text(
          "Cases",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Customers",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Monitor and track onboarding progress",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white60 : Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
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

  Widget _caseCard(CaseModel c) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CaseDetailsPage(customerId: int.parse(c.id)),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                _statusChip(c.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.phone,
                  size: 16,
                  color: isDarkMode ? Colors.white60 : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  c.mobile.isEmpty ? "-" : c.mobile,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "PAN: ${c.pan.isEmpty ? "-" : c.pan}  •  LAN: ${c.lan.isEmpty ? "-" : c.lan}",
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: isDarkMode ? Colors.white60 : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${c.createdAt.day}/${c.createdAt.month}/${c.createdAt.year}",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white60 : Colors.grey,
                      ),
                    ),
                  ],
                ),
                // Text(
                //   getPendingLabel(c.createdAt),
                //   style: TextStyle(
                //     color: Colors.blueGrey.shade400,
                //     fontSize: 12,
                //     fontStyle: FontStyle.italic,
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(CaseStatus status) {
    Color bg;
    Color fg;

    

    switch (status) {
      case CaseStatus.completed:
      case CaseStatus.ops_l1_review:
      case CaseStatus.ops_l1_approved:
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
      case CaseStatus.md_terms_submitted:
      case CaseStatus.credit_l1_approved:
      case CaseStatus.credit_l2_approved:
      case CaseStatus.md_pending_terms:
        bg = const Color(0xFFFDE68A);
        fg = const Color(0xFF92400E);
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

if (isDarkMode) {
  bg = bg.withOpacity(0.2);
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
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
