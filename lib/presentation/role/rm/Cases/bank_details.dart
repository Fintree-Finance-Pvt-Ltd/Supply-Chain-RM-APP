import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/cheque_ocr_service.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class BankDetailsPage extends StatefulWidget {
  final int customerId;

  const BankDetailsPage({super.key, required this.customerId});

  @override
  State<BankDetailsPage> createState() => _BankDetailsPageState();
}

class _BankDetailsPageState extends State<BankDetailsPage> {
  /// Controllers
  final TextEditingController accountController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController bankController = TextEditingController();
  final TextEditingController branchController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
bool bankSaved = false;
  String accountType = "Savings";

  bool loading = false;
  bool bankDetailsSaved = false;

  Future<void> fetchBankDetails(String ifsc) async {
    try {
      debugPrint("Calling IFSC API for: $ifsc");

      final response = await http.get(
        Uri.parse("https://ifsc.razorpay.com/$ifsc"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        debugPrint("API Response: $data");

        setState(() {
          bankController.text = data["BANK"] ?? "";
          branchController.text = data["BRANCH"] ?? "";
        });
      } else {
        debugPrint("Invalid IFSC or API error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("IFSC API Error: $e");
    }
  }
Future<void> loadBankFromCustomerAPI() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
 
    final response = await http.get(
      Uri.parse("${ApiEndpoints.baseUrl}/customers/${widget.customerId}"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
 
    final body = jsonDecode(response.body);
 
    if (body["success"] == true) {
      final data = body["data"];
 
      setState(() {
        accountController.text = data["bankAccountNo"] ?? "";
        ifscController.text = data["bankIfscCode"] ?? "";
        bankController.text = data["bankName"] ?? "";
        branchController.text = data["bankBranch"] ?? "";
        accountType = data["bankType"] ?? "Savings";
 
        // optional
        nameController.text = data["companyName"] ?? "";
 
        if (data["bankAccountNo"] != null) {
          bankSaved = true;
        }
      });
    }
  } catch (e) {
    debugPrint("Load bank details error: $e");
  }
}
 
@override
void initState() {
  super.initState();
  loadBankFromCustomerAPI();
}
 
  Future<void> saveBankDetails() async {
    try {
      setState(() {
        loading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final int customerId = widget.customerId;

      final url = Uri.parse(
        "${ApiEndpoints.baseUrl}${ApiEndpoints.bankDetail(customerId)}",
      );

      final body = {
        "bankAccountNo": accountController.text,
        "bankIfscCode": ifscController.text,
        "bankName": bankController.text,
        "bankBranch": branchController.text,
        "bankType": accountType,
        "name": nameController.text,
      };

      final response = await http.patch(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bank details saved successfully")),
        );
        setState(() {
          bankDetailsSaved = true;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data["message"] ?? "Failed")));
      }
    } catch (e) {
      debugPrint("Bank Save Error: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() {
      loading = false;
    });
  }

  /// =============================
  /// CHEQUE OCR FUNCTION
  /// =============================
  Future<void> startChequeOCR() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result == null) return;

    final file = result.files.first;

    try {
      setState(() {
        loading = true;
      });

      final ocr = await ChequeOcrService.scanCheque(file);

      if (ocr != null) {
        accountController.text = ocr.accountNumber ?? "";
        nameController.text = ocr.name ?? "";

        final ifsc = (ocr.ifscCode ?? "").toUpperCase().trim();

        ifscController.text = ifsc;
        bankController.text = ocr.bankName ?? "";
        branchController.text = ocr.branch ?? "";

        // 🔥 Trigger IFSC API automatically
        if (ifsc.length == 11) {
          await fetchBankDetails(ifsc);
        }
      }
    } catch (e) {
      debugPrint("OCR ERROR: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("OCR Failed: $e")));
    }

    setState(() {
      loading = false;
    });
  }

  Widget actionCard({
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
    String status = "PENDING",
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE + STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E6A1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "PENDING",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// DESCRIPTION
          Text(
            description,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),

          const SizedBox(height: 18),

          /// BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: const Color(0xFF3B5EDB),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              onPressed: onPressed,
              child: Text(buttonText, style: const TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  /// =============================
  /// UI
  /// =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bank Details")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
              const Text(
                "Bank Details & Cheque OCR",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              /// CHEQUE CAPTURE CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Cheque Capture",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "Capture cheque photo to auto-fill bank details",
                      style: TextStyle(fontSize: 12),
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: startChequeOCR,
                        icon: const Icon(Icons.upload),
                        label: const Text("Upload Cheque"),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// ACCOUNT NUMBER
              TextField(
                controller: accountController,
                decoration: InputDecoration(
                  labelText: "Account Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// IFSC
              TextField(
                controller: ifscController,
                textCapitalization: TextCapitalization.characters,
                onChanged: (value) {
                  final upper = value.toUpperCase().trim();

                  ifscController.value = ifscController.value.copyWith(
                    text: upper,
                    selection: TextSelection.collapsed(offset: upper.length),
                  );

                  if (upper.length == 11) {
                    fetchBankDetails(upper);
                  }
                },
                decoration: InputDecoration(
                  labelText: "IFSC Code",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// BANK NAME
              TextField(
                controller: bankController,
                decoration: InputDecoration(
                  labelText: "Bank Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Account Holder Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// BRANCH
              TextField(
                controller: branchController,
                decoration: InputDecoration(
                  labelText: "Branch",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// ACCOUNT TYPE
              DropdownButtonFormField(
                initialValue: accountType,
                decoration: InputDecoration(
                  labelText: "Account Type",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                items: const [
                  DropdownMenuItem(value: "Savings", child: Text("Savings")),
                  DropdownMenuItem(value: "Current", child: Text("Current")),
                ],

                onChanged: (value) {
                  setState(() {
                    accountType = value!;
                  });
                },
              ),

              const SizedBox(height: 25),

              /// SAVE BUTTON
              const SizedBox(height: 25),
 
              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: bankSaved
                    ? ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context, true); // return success
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text("Continue"),
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            22,
                            61,
                            145,
                          ),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: saveBankDetails,
                        icon: const Icon(Icons.check),
                        label: const Text("Save Bank Details"),
                      ),
              ),
 
 
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton.icon(
              //     style: ElevatedButton.styleFrom(
              //       // backgroundColor: const Color.fromARGB(255, 22, 61, 145),
              //       backgroundColor: bankDetailsSaved
              //           ? Colors.grey
              //           : const Color.fromARGB(255, 22, 61, 145),
              //       foregroundColor: Colors.white,
              //       minimumSize: const Size(double.infinity, 52),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(14),
              //       ),
              //       padding: const EdgeInsets.symmetric(
              //         vertical: 14,
              //         horizontal: 20,
              //       ),
              //     ),

              //     // onPressed: saveBankDetails,
              //     onPressed: bankDetailsSaved
              //         ? null
              //         : saveBankDetails, // 👈 disables button

              //     icon: const Icon(Icons.check),
              //     // label: const Text("Save Bank Details"),
              //     label: Text(bankDetailsSaved ? "Saved" : "Save Bank Details"),
              //   ),
              // ),

              const SizedBox(height: 30),

              /// E-NACH CARD
              actionCard(
                title: "E-NACH Mandate",
                description:
                    "Setup automated repayment from customer's bank account.",
                buttonText: "Trigger e-NACH",
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Trigger e-NACH clicked")),
                  );
                },
              ),

              /// E-SIGN CARD
              actionCard(
                title: "E-Sign Agreement",
                description:
                    "Digitally sign the loan agreement with the customer.",
                buttonText: "Trigger e-Sign",
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Trigger e-Sign clicked")),
                  );
                },
              ),

              if (loading)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
