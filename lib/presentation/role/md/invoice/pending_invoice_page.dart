import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';


import 'invoice_details_page.dart';
import 'models/invoice_model.dart';

class PendingInvoicePage extends StatefulWidget {
  const PendingInvoicePage({super.key});

  @override
  State<PendingInvoicePage> createState() =>
      _PendingInvoicePageState();
}

class _PendingInvoicePageState
    extends State<PendingInvoicePage> {
  bool loading = true;

  List<InvoiceModel> invoices = [];

  @override
  void initState() {
    super.initState();

    loadInvoices();
  }

Future<void> loadInvoices() async {
  try {
    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString("token");

    final response = await http.get(
      Uri.parse(
        "${ApiEndpoints.baseUrl}/workflows/invoices/pending/md",
      ),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final body = jsonDecode(response.body);

    if (body["success"] == true) {
      final List data = body["data"];

      setState(() {
        invoices = data
            .map(
              (e) => InvoiceModel.fromJson(e),
            )
            .toList();

        loading = false;
      });
    } else {
      setState(() {
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
      case "PENDING_MD_APPROVAL":
        return Colors.orange;

      case "ACTIVE":
        return Colors.green;

      case "REJECTED":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Pending Invoices"),
      ),
      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : invoices.isEmpty
          ? const Center(
              child: Text(
                "No Pending Invoices",
              ),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.all(16),
              itemCount:
                  invoices.length,
              itemBuilder:
                  (context, index) {
                final invoice =
                    invoices[index];

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
                                invoice
                                    .invoiceNumber,

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
                                      invoice
                                          .status,
                                    ),

                                borderRadius:
                                    BorderRadius.circular(
                                      20,
                                    ),
                              ),

                              child: Text(
                                invoice
                                    .status,

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
                          "Customer : ${invoice.customerName}",
                        ),

                        Text(
                          "Supplier : ${invoice.supplierName}",
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Text(
                          "Invoice Amount : ₹${invoice.invoiceAmount}",
                        ),

                        Text(
                          "Disbursement : ₹${invoice.disbursementAmount}",
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              InvoiceDetailsPage(
                                                invoice:
                                                    invoice,
                                              ),
                                    ),
                                  );
                                },

                                child:
                                    const Text(
                                      "View",
                                    ),
                              ),
                            ),
                          ],
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