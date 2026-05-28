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
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    loadTheme();
    fetchMdApprovedCases();
  }

  /// LOAD THEME
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isDarkMode = prefs.getBool("isDarkMode") ?? false;
    });
  }

  /// FETCH MD APPROVED CASES
  Future<void> fetchMdApprovedCases() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");
      final rmId = prefs.getInt("rmId");

      setState(() {
        loading = true;
      });

      final response = await http.get(
        Uri.parse(
          "${ApiEndpoints.baseUrl}/customers?status=md_approved",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final body = jsonDecode(response.body);

      print("MD APPROVED RESPONSE => $body");

      if (body["success"] == true) {
        final List allCases = body["data"] ?? [];

        final filteredCases = allCases.where((e) {
          final status =
              (e["status"] ?? "")
                  .toString()
                  .toLowerCase();

          return status == "md_approved" &&
              e["rmId"] == rmId;
        }).toList();

        setState(() {
          opsCases = filteredCases;
          loading = false;
        });

        print("TOTAL MD APPROVED => ${opsCases.length}");
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
      backgroundColor:
          isDarkMode
              ? const Color(0xFF0F172A)
              : const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            isDarkMode
                ? const Color(0xFF1E293B)
                : Colors.white,

        iconTheme: IconThemeData(
          color:
              isDarkMode
                  ? Colors.white
                  : Colors.black,
        ),

        title: Text(
          "Ops Review Cases",
          style: TextStyle(
            color:
                isDarkMode
                    ? Colors.white
                    : Colors.black,
          ),
        ),
      ),

      body:
          loading
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : opsCases.isEmpty
              ? Center(
                child: Text(
                  "No MD Approved Cases",
                  style: TextStyle(
                    color:
                        isDarkMode
                            ? Colors.white60
                            : Colors.black54,
                  ),
                ),
              )
              : RefreshIndicator(
                onRefresh: fetchMdApprovedCases,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: opsCases.length,

                  itemBuilder: (context, index) {
                    final caseItem = opsCases[index];

                    final String name =
                        (caseItem["companyName"] ??
                                caseItem["name"] ??
                                "")
                            .toString();

                    final String mobile =
                        (caseItem["companyMobile"] ??
                                caseItem["mobile"] ??
                                "")
                            .toString();

                    final String gst =
                        (caseItem["gstNumber"] ??
                                "")
                            .toString();

                    final String customerCode =
                        (caseItem["customerCode"] ??
                                "N/A")
                            .toString();

                    final String createdAt =
                        (caseItem["createdAt"] ??
                                "")
                            .toString();

                    final String initial =
                        name.isNotEmpty
                            ? name[0].toUpperCase()
                            : "U";

                    return _modernCard(
                      caseItem,
                      name,
                      mobile,
                      gst,
                      customerCode,
                      createdAt,
                      initial,
                    );
                  },
                ),
              ),
    );
  }

  /// MODERN CARD
  Widget _modernCard(
    Map caseItem,
    String name,
    String mobile,
    String gst,
    String customerCode,
    String createdAt,
    String initial,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => CaseDetailsPage(
                  customerId: caseItem["id"],
                ),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),

        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? const Color(0xFF1E293B)
                  : Colors.white,

          borderRadius: BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                isDarkMode ? 0.2 : 0.05,
              ),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Row(
          children: [
            /// LEFT STATUS BAR
            Container(
              width: 5,
              height: 120,

              decoration: const BoxDecoration(
                color: Colors.green,

                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    /// TOP ROW
                    Row(
                      children: [
                        /// AVATAR
                        CircleAvatar(
                          radius: 20,

                          backgroundColor:
                              Colors.green.withOpacity(
                                0.15,
                              ),

                          child: Text(
                            initial,

                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// NAME + MOBILE
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Text(
                                name.isEmpty
                                    ? "Applicant"
                                    : name,

                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,

                                  color:
                                      isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: 14,

                                    color:
                                        isDarkMode
                                            ? Colors
                                                .white60
                                            : Colors
                                                .grey,
                                  ),

                                  const SizedBox(
                                    width: 4,
                                  ),

                                  Text(
                                    mobile,

                                    style: TextStyle(
                                      fontSize: 13,

                                      color:
                                          isDarkMode
                                              ? Colors
                                                  .white70
                                              : Colors
                                                  .black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        /// STATUS BADGE
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),

                          decoration: BoxDecoration(
                            color: Colors.green
                                .withOpacity(0.15),

                            borderRadius:
                                BorderRadius.circular(
                                  20,
                                ),
                          ),

                          child: const Text(
                            "MD APPROVED",

                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    /// GST
                    Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 14,

                          color:
                              isDarkMode
                                  ? Colors.white60
                                  : Colors.grey,
                        ),

                        const SizedBox(width: 6),

                        Expanded(
                          child: Text(
                            gst,

                            style: TextStyle(
                              fontSize: 12,

                              color:
                                  isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// CUSTOMER CODE
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),

                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? Colors.blue
                                    .withOpacity(0.2)
                                : const Color(
                                  0xFFEFF6FF,
                                ),

                        borderRadius:
                            BorderRadius.circular(10),
                      ),

                      child: Text(
                        "LAN : $customerCode",

                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,

                          color:
                              isDarkMode
                                  ? Colors.blue.shade200
                                  : const Color(
                                    0xFF2563EB,
                                  ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// FOOTER
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,

                          color:
                              isDarkMode
                                  ? Colors.white60
                                  : Colors.grey,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          createdAt
                              .split("T")
                              .first,

                          style: TextStyle(
                            fontSize: 12,

                            color:
                                isDarkMode
                                    ? Colors.white60
                                    : Colors.grey,
                          ),
                        ),

                        const Spacer(),

                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,

                          color:
                              isDarkMode
                                  ? Colors.white60
                                  : Colors.grey,
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
    );
  }
}