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
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    fetchCompletedCases();
    loadTheme(); // ✅ added
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode") ?? false;
    });
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
        final allCases = body["data"] ?? [];

        completedCases = allCases.where((e) {
          return e["status"] == "completed" && e["rmId"] == rmId;
        }).toList();

        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print("Completed Cases Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor:
            isDarkMode ? const Color(0xFF1E293B) : Colors.white,

        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),

        title: Text(
          "Completed Cases",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : completedCases.isEmpty
              ? Center(
                  child: Text(
                    "No completed cases",
                    style: TextStyle(
                      color:
                          isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: completedCases.length,
                  itemBuilder: (context, index) {
                    final caseItem = completedCases[index];

                    String name =
                        (caseItem["companyName"] ??
                                caseItem["name"] ??
                                "")
                            .toString();

                    String initial =
                        name.isNotEmpty ? name[0].toUpperCase() : "U";

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: isDarkMode
                                ? const Color(0xFF1E293B)
                                : Colors.white,
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
                                    ListTile(
                                      leading: Icon(Icons.visibility,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black),
                                      title: Text(
                                        "View Details",
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                CaseDetailsPage(
                                              customerId:
                                                  caseItem["id"],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const Divider(),
                                    ListTile(
                                      leading: Icon(Icons.receipt_long,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black),
                                      title: Text(
                                        "Invoice Details",
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                InvoicePage(
                                              customerId:
                                                  caseItem["id"],
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
                            color: isDarkMode
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.white10
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
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
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          caseItem["companyName"] ??
                                              caseItem["name"] ??
                                              "Applicant",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.w600,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.phone,
                                              size: 14,
                                              color: isDarkMode
                                                  ? Colors.white60
                                                  : Colors.grey,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              caseItem[
                                                      "companyMobile"] ??
                                                  caseItem[
                                                      "mobile"] ??
                                                  "",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isDarkMode
                                                    ? Colors.white70
                                                    : Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.green
                                              .withOpacity(0.25)
                                          : const Color(0xFFE6F7ED),
                                      borderRadius:
                                          BorderRadius.circular(20),
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
                                            fontWeight:
                                                FontWeight.w600,
                                            color:
                                                Color(0xFF16A34A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              if ((caseItem["lanId"] ?? "")
                                  .toString()
                                  .isNotEmpty)
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.blue
                                            .withOpacity(0.2)
                                        : const Color(0xFFEFF6FF),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "LAN ${caseItem["lanId"]}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight:
                                          FontWeight.w600,
                                      color: isDarkMode
                                          ? Colors.blue.shade200
                                          : AppColors.darkBlue,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 14,
                                    color: isDarkMode
                                        ? Colors.white60
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    (caseItem["createdAt"] ?? "")
                                        .toString()
                                        .split("T")
                                        .first,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDarkMode
                                          ? Colors.white60
                                          : Colors.grey,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.chevron_right,
                                    color: isDarkMode
                                        ? Colors.white60
                                        : Colors.grey,
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