import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:supply_chain/core/constants/api_endpoints.dart';

class ApprovedInvoicePage extends StatefulWidget {
  const ApprovedInvoicePage({
    super.key,
  });

  @override
  State<ApprovedInvoicePage> createState() =>
      _ApprovedInvoicePageState();
}

class _ApprovedInvoicePageState
    extends State<ApprovedInvoicePage> {
  bool loading = true;

  List approvedInvoices = [];

  @override
  void initState() {
    super.initState();

    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      final token =
          prefs.getString("token");

      final response = await http.get(
        Uri.parse(
          "${ApiEndpoints.baseUrl}/workflows/customers/dashboard/executive",
        ),

        headers: {
          "Authorization":
              "Bearer $token",
        },
      );

      final data =
          jsonDecode(response.body);

      if (data["success"] == true) {
        final handled =
            data["data"]["handled"];

        final invoices =
            handled.where((item) {
          return item["workflowType"] ==
                  "INVOICE_DISCOUNTING" &&
              item["currentStatus"] !=
                  "REJECTED";
        }).toList();

        setState(() {
          approvedInvoices =
              invoices;

          loading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        loading = false;
      });
    }
  }

  Color getStatusColor(
    String status,
  ) {
    switch (status) {
      case "ACTIVE":
        return Colors.green;

      case "PENDING_OPS_HEAD_APPROVAL":
        return Colors.orange;

      case "PENDING_FINAL_OPS_L2_APPROVAL":
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Approved Invoices",
        ),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : approvedInvoices.isEmpty
          ? const Center(
              child: Text(
                "No Approved Invoices",
              ),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.all(
                    16,
                  ),

              itemCount:
                  approvedInvoices.length,

              itemBuilder:
                  (context, index) {
                final invoice =
                    approvedInvoices[index];

                final customer =
                    invoice["customer"];

                return Card(
                  margin:
                      const EdgeInsets.only(
                        bottom: 16,
                      ),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                          18,
                        ),
                  ),

                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                          16,
                        ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Invoice ID : ${invoice["invoiceId"]}",

                                style:
                                    const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,

                                      fontSize:
                                          18,
                                    ),
                              ),
                            ),

                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal:
                                        12,
                                    vertical:
                                        6,
                                  ),

                              decoration: BoxDecoration(
                                color:
                                    getStatusColor(
                                      invoice["currentStatus"],
                                    ),

                                borderRadius:
                                    BorderRadius.circular(
                                      20,
                                    ),
                              ),

                              child: Text(
                                invoice["currentStatus"],

                                style:
                                    const TextStyle(
                                      color:
                                          Colors
                                              .white,
                                    ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        Text(
                          "Customer : ${customer["companyName"]}",
                        ),

                        Text(
                          "Customer Code : ${customer["customerCode"]}",
                        ),

                        Text(
                          "Industry : ${customer["industryType"]}",
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Text(
                          "Remarks : ${invoice["remarks"] ?? "N/A"}",
                        ),

                        Text(
                          "Approver : ${invoice["currentApproverRoleName"]}",
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}