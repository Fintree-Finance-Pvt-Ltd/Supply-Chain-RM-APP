import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';



import 'models/invoice_model.dart';

class InvoiceDetailsPage
    extends StatefulWidget {
  final InvoiceModel invoice;

  const InvoiceDetailsPage({
    super.key,
    required this.invoice,
  });

  @override
  State<InvoiceDetailsPage>
  createState() =>
      _InvoiceDetailsPageState();
}

class _InvoiceDetailsPageState
    extends State<
      InvoiceDetailsPage
    > {
  final remarksController =
      TextEditingController();

  bool loading = false;

  Future<void> approveInvoice() async {
  try {
    setState(() {
      loading = true;
    });

    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString("token");

    final response = await http.post(
      Uri.parse(
        "${ApiEndpoints.baseUrl}/workflows/invoices/${widget.invoice.id}/md-approve",
      ),

      headers: {
        "Authorization":
            "Bearer $token",

        "Content-Type":
            "application/json",
      },

      body: jsonEncode({
        "approved": true,
        "remarks":
            remarksController.text.isEmpty
                ? "ok"
                : remarksController.text,
      }),
    );

    final body =
        jsonDecode(response.body);

    debugPrint(body.toString());

    if (body["success"] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            "Invoice Approved",
          ),
        ),
      );

      Navigator.pop(context, true);
    }
  } catch (e) {
    debugPrint(e.toString());
  } finally {
    setState(() {
      loading = false;
    });
  }
}

  Future<void> rejectInvoice()
  async {
    try {
      setState(() {
        loading = true;
      });

      final prefs =
          await SharedPreferences.getInstance();

      final token =
          prefs.getString("token");

      final response = await http.post(
        Uri.parse(
          "${ApiEndpoints.baseUrl}/workflows/invoices/${widget.invoice.id}/md-reject",
        ),

        headers: {
          "Authorization":
              "Bearer $token",

          "Content-Type":
              "application/json",
        },

        body: jsonEncode({
          "remarks":
              remarksController.text,
        }),
      );

      final body =
          jsonDecode(response.body);

      if (body["success"] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              "Invoice Rejected",
            ),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Widget item(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
            bottom: 14,
          ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(
                    color:
                        Colors.grey,
                  ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style:
                  const TextStyle(
                    fontWeight:
                        FontWeight
                            .bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invoice =
        widget.invoice;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Invoice Details"),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(18),

        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
              ),

              child: Padding(
                padding:
                    const EdgeInsets.all(
                      20,
                    ),

                child: Column(
                  children: [
                    item(
                      "Invoice No",
                      invoice
                          .invoiceNumber,
                    ),

                    item(
                      "Customer",
                      invoice
                              .customerName ??
                          "N/A",
                    ),

                    item(
                      "Supplier",
                      invoice
                              .supplierName ??
                          "N/A",
                    ),

                    item(
                      "Invoice Amount",
                      "₹${invoice.invoiceAmount}",
                    ),

                    item(
                      "Disbursement",
                      "₹${invoice.disbursementAmount}",
                    ),

                    item(
                      "ROI",
                      "${invoice.roiPercentage}%",
                    ),

                    item(
                      "Penal Charges",
                      "${invoice.penalCharges}%",
                    ),

                    item(
                      "Service Fee",
                      "₹${invoice.serviceFee}",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller:
                  remarksController,

              maxLines: 4,

              decoration:
                  InputDecoration(
                    hintText:
                        "Enter Remarks",

                    border:
                        OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                                14,
                              ),
                        ),
                  ),
            ),

            const SizedBox(
              height: 20,
            ),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red,
                        ),

                    onPressed:
                        loading
                        ? null
                        : rejectInvoice,

                    child:
                        const Text(
                          "Reject",
                        ),
                  ),
                ),

                const SizedBox(
                  width: 14,
                ),

                Expanded(
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green,
                        ),

                    onPressed:
                        loading
                        ? null
                        : approveInvoice,

                    child:
                        const Text(
                          "Approve",
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}