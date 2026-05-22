import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:supply_chain/core/constants/api_endpoints.dart';

class RejectedInvoicePage
    extends StatefulWidget {
  const RejectedInvoicePage({
    super.key,
  });

  @override
  State<RejectedInvoicePage>
  createState() =>
      _RejectedInvoicePageState();
}

class _RejectedInvoicePageState
    extends State<
      RejectedInvoicePage
    > {
  bool loading = true;

  List rejectedInvoices = [];

  @override
  void initState() {
    super.initState();

    fetchRejectedInvoices();
  }

  Future<void>
  fetchRejectedInvoices() async {
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
              item["currentStatus"] ==
                  "REJECTED";
        }).toList();

        setState(() {
          rejectedInvoices =
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Rejected Invoices",
        ),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : rejectedInvoices.isEmpty
          ? const Center(
              child: Text(
                "No Rejected Invoices",
              ),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.all(
                    16,
                  ),

              itemCount:
                  rejectedInvoices
                      .length,

              itemBuilder:
                  (context, index) {
                final invoice =
                    rejectedInvoices[
                        index];

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
                                    Colors.red,

                                borderRadius:
                                    BorderRadius.circular(
                                      20,
                                    ),
                              ),

                              child: const Text(
                                "REJECTED",

                                style:
                                    TextStyle(
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

                        if (invoice["rejectionReason"] !=
                            null)
                          Text(
                            "Reason : ${invoice["rejectionReason"]}",
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