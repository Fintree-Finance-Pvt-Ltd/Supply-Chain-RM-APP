import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/auth_service.dart';
import 'package:supply_chain/core/theme/app_colors.dart';
import 'package:supply_chain/core/utils/toast_helper.dart';
import 'package:supply_chain/presentation/role/rm/Cases/bank_details.dart';
import 'package:url_launcher/url_launcher.dart';

class CaseDetailsPage extends StatefulWidget {
  final int customerId;
  const CaseDetailsPage({super.key, required this.customerId});

  @override
  State<CaseDetailsPage> createState() => _CaseDetailsPageState();
}

class _CaseDetailsPageState extends State<CaseDetailsPage> {
  Map<String, dynamic>? caseData;
  bool loading = true;
  bool submitting = false;
  bool bankDetailsCompleted = false;
  final TextEditingController remarksController = TextEditingController();
  PlatformFile? selectedFile;
  String? selectedDocType;
  bool showAllDocuments = false;
  List<dynamic> sanctionList = [];
  final sanctionAmountController = TextEditingController();
  final tenureController = TextEditingController();
  final interestRateController = TextEditingController();
  final penalChargesController = TextEditingController();
  final processingFeesController = TextEditingController();
  final conditionsController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchCustomerDetails();
    
  }

  /// FETCH API
  Future<void> _fetchUploadedDocuments() async {
    try {
      final token = await AuthService().getToken();
 
      final response = await http.get(
        Uri.parse(
          "${ApiEndpoints.baseUrl}/documents/customer/${widget.customerId}",
        ),
        headers: {"Authorization": "Bearer $token"},
      );
 
      final data = jsonDecode(response.body);
 
      if (response.statusCode == 200 && data["success"] == true) {
        final List uploadedDocs = data["data"];
        final baseUrl = ApiEndpoints.baseUrl.replaceAll("/api", "");
 
        setState(() {
          for (var doc in caseData?["documents"] ?? []) {
            /// ✅ FIRST: check existing filePath
            final existingPath = doc["filePath"] ?? "";
 
            if (existingPath.isNotEmpty) {
              final cleanPath = existingPath.startsWith("/")
                  ? existingPath.substring(1)
                  : existingPath;
 
              doc["fileUrl"] = "$baseUrl/$cleanPath";
            }
 
            /// ✅ SECOND: match from API
            final match = uploadedDocs.firstWhere(
              (d) =>
                  (d["documentType"] ?? "").toString().toUpperCase().trim() ==
                  (doc["documentType"] ?? "").toString().toUpperCase().trim(),
              orElse: () => null,
            );
 
            if (match != null) {
              final filePath = match["filePath"] ?? "";
 
              if (filePath.isNotEmpty) {
                final cleanPath = filePath.startsWith("/")
                    ? filePath.substring(1)
                    : filePath;
 
                doc["fileUrl"] = "$baseUrl/$cleanPath";
              }
            }
 
            print("FINAL FILE URL: ${doc["fileUrl"]}");
          }
        });
      }
    } catch (e) {
      print("FETCH ERROR: $e");
    }
  }
 
  Future<void> _openFile(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // 🔥 opens in browser
    )) {
      throw 'Could not launch $url';
    }
  }

  Future<void> fetchCustomerDetails() async {
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
        setState(() {
          caseData = body["data"];

          loading = false;
        });
          await _fetchUploadedDocuments();
 
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> submitToMD() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      List<Map<String, dynamic>> partnerSanctions = sanctionList.map((s) {
        return {
          "partner": s["partner"],
          "sanctionAmount": s["sanctionAmount"],
          "tenure": s["tenure"],
          "interestRate": s["interestRate"],
          "penalCharges": s["penalCharges"],
          "processingFees": s["processingFees"],
          "conditions": s["conditions"] ?? "ok",
        };
      }).toList();

      final payload = {
        "remarks": remarksController.text.isEmpty
            ? "Final terms confirmed by RM"
            : remarksController.text,
        "partnerSanctions": partnerSanctions,
      };

      /// DEBUG LOGS
      print("========== SUBMIT TO MD ==========");
      print("CustomerId: ${widget.customerId}");
      print("Payload: ${jsonEncode(payload)}");

      final response = await http.post(
        Uri.parse(
          "${ApiEndpoints.baseUrl}/workflows/customers/${widget.customerId}/rm-submit-md",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final body = jsonDecode(response.body);

      if (body["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Submitted to MD successfully")),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body["message"] ?? "Submission failed")),
        );
      }
    } catch (e) {
      print("Submit error: $e");
    }
  }

  // correct
  // Future<void> submitToMD() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString("token");

  //     List<Map<String, dynamic>> partnerSanctions = sanctionList.map((s) {
  //       return {
  //         "partner": s["partner"],
  //         "sanctionAmount": s["sanctionAmount"],
  //         "tenure": s["tenure"],
  //         "interestRate": s["interestRate"],
  //         "penalCharges": s["penalCharges"],
  //         "processingFees": s["processingFees"],
  //       };
  //     }).toList();

  //     final payload = {
  //       "remarks": "Final terms confirmed by RM",
  //       "partnerSanctions": partnerSanctions,
  //     };

  //     print("Payload: $payload"); // Debug

  //     final response = await http.post(
  //       Uri.parse(
  //         "${ApiEndpoints.baseUrl}/workflows/customers/${widget.customerId}/rm-submit-md",
  //       ),
  //       headers: {
  //         "Authorization": "Bearer $token",
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonEncode(payload),
  //     );

  //     final body = jsonDecode(response.body);

  //     if (body["success"] == true) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Submitted to MD successfully")),
  //       );

  //       Navigator.pop(context);
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(body["message"] ?? "Submission failed")),
  //       );
  //     }
  //   } catch (e) {
  //     print("Submit error: $e");
  //   }
  // }

  // Future<void> submitToMD() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString("token");
  //     print("TOKEN VALUE: $token"); // 👈 debug

  //     final response = await http.post(
  //       // /customers/:customerId/rm-submit-md
  //       Uri.parse(
  //         "${ApiEndpoints.baseUrl}/workflows/customers/${widget.customerId}/rm-submit-md",
  //       ),

  //       headers: {
  //         "Authorization": "Bearer $token",
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonEncode({
  //         "remarks": "Final terms confirmed by RM",
  //         "sanctionAmount": "500000.00",
  //         "tenure": "4",
  //         "interestRate": "10.00",
  //         "penalCharges": "5.00",
  //         "processingFees": "1000",
  //         "conditions": "ok",
  //       }),
  //     );

  //     final body = jsonDecode(response.body);

  //     if (body["success"] == true) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Submitted to MD successfully")),
  //       );

  //       Navigator.pop(context); // Go back to cases screen
  //     } else {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(const SnackBar(content: Text("Submission failed")));
  //     }
  //   } catch (e) {
  //     print("Submit error: $e");
  //   }
  // }

  Future<void> submitToOps() async {
    try {
      setState(() {
        submitting = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.post(
        Uri.parse(
          "${ApiEndpoints.baseUrl}/workflows/customers/${widget.customerId}/ops-submit",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"remarks": remarksController.text.trim()}),
      );

      final body = jsonDecode(response.body);

      if (body["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Case successfully submitted to Operations"),
          ),
        );

        /// reload case data
        await fetchCustomerDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body["message"] ?? "Submission failed")),
        );
      }
    } catch (e) {
      print("Submit Ops Error: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    } finally {
      setState(() {
        submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final status = caseData?["status"];
    final applicant = caseData?["applicant"] ?? {};
    final company = caseData ?? {};
    final coApplicants = caseData?["coApplicants"] ?? [];
    final addresses = caseData?["addresses"] ?? [];
    final contacts = caseData?["contactPersons"] ?? [];
    final sanctions = caseData?["creditSanctions"] ?? [];
    // financialSanctionSection(sanctions);

    // nextStepSection();
    // if (status != "md_approved") nextStepSection();
    final documents = caseData?["documents"] ?? [];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(title: const Text("Case Details")),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // padding: const EdgeInsets.all(16),

            // child: Column(
            children: [
              /// COMPANY CARD
              expandableCard(
                icon: Icons.business,

                title: "Company Details",
                children: [
                  _infoRow("Company Name", company["companyName"]),
                  _infoRow("Mobile", company["companyMobile"]),
                  _infoRow("Email", company["companyEmail"]),
                  _infoRow("GST", company["gstNumber"]),
                ],
              ),
              // const SizedBox(height: 16),

              // /// APPLICANT
              expandableCard(
                icon: Icons.person,

                title: "Applicant Details",
                children: [
                  _infoRow("Name", applicant["name"]),
                  _infoRow("Mobile", applicant["mobile"]),
                  _infoRow("Email", applicant["email"]),
                  _infoRow("PAN", applicant["pan"]),
                ],
              ),
              // const SizedBox(height: 16),

              /// ADDRESS
              // if (addresses.isNotEmpty)
              //   _card(
              //     title: "Address Details",
              //     children: [
              //       for (var a in addresses)
              //         Column(
              //           children: [
              //             _infoRow("Address", a["fullAddress"]),
              //             _infoRow("City", a["city"]),
              //             _infoRow("State", a["state"]),
              //             _infoRow("Pincode", a["pincode"]),
              //             const Divider(),
              //           ],
              //         ),
              //     ],
              //   ),
              if (addresses.isNotEmpty)
                expandableCard(
                  icon: Icons.location_on,

                  title: "Address Details",
                  children: [
                    for (var a in addresses)
                      Column(
                        children: [
                          _infoRow("Address", a["fullAddress"]),
                          _infoRow("City", a["city"]),
                          _infoRow("State", a["state"]),
                          _infoRow("Pincode", a["pincode"]),
                          const Divider(),
                        ],
                      ),
                  ],
                ),
              // const SizedBox(height: 16),

              /// CONTACT PERSON
              // if (contacts.isNotEmpty)
              //   _card(
              //     title: "Contact Person",
              //     children: [
              //       for (var c in contacts)
              //         Column(
              //           children: [
              //             _infoRow("Name", c["name"]),
              //             _infoRow("Mobile", c["mobile"]),
              //             _infoRow("Email", c["email"]),
              //             const Divider(),
              //           ],
              //         ),
              //     ],
              //   ),
              if (contacts.isNotEmpty)
                expandableCard(
                  icon: Icons.phone,

                  title: "Contact Person",
                  children: [
                    for (var c in contacts)
                      Column(
                        children: [
                          _infoRow("Name", c["name"]),
                          _infoRow("Mobile", c["mobile"]),
                          _infoRow("Email", c["email"]),
                          const Divider(),
                        ],
                      ),
                  ],
                ),
              // const SizedBox(height: 16),

              /// CO APPLICANTS
              // if (coApplicants.isNotEmpty)
              //   _card(
              //     title: "Co Applicant",
              //     children: [
              //       for (var co in coApplicants)
              //         Column(
              //           children: [
              //             _infoRow("Name", co["name"]),
              //             _infoRow("Mobile", co["mobile"]),
              //             _infoRow("Email", co["email"]),
              //             _infoRow("PAN", co["pan"]),
              //             const Divider(),
              //           ],
              //         ),
              //     ],
              //   ),
              if (coApplicants.isNotEmpty)
                expandableCard(
                  icon: Icons.group,

                  title: "Co Applicant",
                  children: [
                    for (var co in coApplicants)
                      Column(
                        children: [
                          _infoRow("Name", co["name"]),
                          _infoRow("Mobile", co["mobile"]),
                          _infoRow("Email", co["email"]),
                          _infoRow("PAN", co["pan"]),
                          const Divider(),
                        ],
                      ),
                  ],
                ),
              const SizedBox(height: 16),

              /// Financial Sanction
              // final sanctions = caseData?["creditSanctions"];
              // if (sanctions is List && sanctions.isNotEmpty)
              // _financialSanctionCard(sanctions.last),
              // FinalSanctionTermsSection(customerId: widget.customerId),
              FinalSanctionTermsSection(
                customerId: widget.customerId,
                onSanctionChange: (list) {
                  sanctionList = list;
                },
              ),

              // const SizedBox(height: 16),

              // const SizedBox(height: 16),
              // nextStepSection(),
              // if (status != null &&
              // status != "submitted" &&
              //     status != "md_approved" &&
              //     status != "completed" &&
              //     status != "ops_l1_approved" &&
              //     status != "ops_l1_review")
              if (status == "md_pending_terms") nextStepSection(),
              const SizedBox(height: 16),
              if (status == "md_approved")
                // BankDetailsPage(customerId: widget.customerId),
                _optionTile(
                  context,
                  icon: Icons.account_balance,
                  title: "Bank Details",
                  subtitle: "Add or update customer bank details",
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BankDetailsPage(customerId: widget.customerId),
                      ),
                    );

                    if (result == true) {
                      setState(() {
                        bankDetailsCompleted = true;
                      });
                    }
                  },
                  verified: bankDetailsCompleted,
                ),

              // _optionTile(
              //   context,

              //   icon: Icons.account_balance,
              //   title: "Bank Details",
              //   subtitle: "Add or update customer bank details",
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) =>
              //             BankDetailsPage(customerId: widget.customerId),
              //       ),
              //     );
              //   },
              // ),
              // _bankDetailsButton(),
              const SizedBox(height: 16),

              /// Documents
              _documentsCard(documents),

              // if (BankDetailsPage != null) submissionToOpsCard(),
              if (status == "md_approved") ...[
                const SizedBox(height: 16),
                submitToOpsSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget submitToOpsSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECF8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Submit Case to Operations",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: remarksController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Enter remarks...",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: submitting ? null : submitToOps,
              icon: submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send),
              label: const Text("Submit to Operations"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget submissionToOpsCard() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECF8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Submission to Operations",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: remarksController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Final submission remarks...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text("Final Submit to Ops"),
              onPressed: () {
                submitToOps();
              },
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Complete digital journey before submission",
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _bankDetailsButton() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.account_balance),
        label: const Text(" Bank Details"),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BankDetailsPage(customerId: widget.customerId),
            ),
          );
        },
      ),
    );
  }

  Widget _financialSanctionCard(Map<String, dynamic> sanction) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF4F46E5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          const Row(
            children: [
              Expanded(
                child: Text(
                  "Final Sanction Terms",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.send, size: 18, color: Color(0xFF4F46E5)),
            ],
          ),

          const SizedBox(height: 20),

          /// Grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: 1.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _sanctionTile(
                "SANCTION AMOUNT",
                sanction["sanctionAmount"]?.toString() ?? "-",
              ),

              _sanctionTile(
                "TENURE (MONTHS)",
                sanction["tenure"]?.toString() ?? "-",
              ),

              _sanctionTile(
                "INTEREST RATE (%)",
                sanction["interestRate"]?.toString() ?? "-",
              ),

              _sanctionTile(
                "PENAL CHARGES (%)",
                sanction["penalCharges"]?.toString() ?? "-",
              ),

              _sanctionTile(
                "PROCESSING FEES (%)",
                sanction["processingFees"]?.toString() ?? "-",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sanctionTile(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE2F1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _sanctionCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE2F1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4F46E5),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget nextStepSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECF8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Next Step: Submit to MD",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          const Text(
            "Please verify the final sanction terms above. Once submitted, the Managing Director will review and provide final approval.",
            style: TextStyle(color: Color(0xFF3B5BDB)),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              /// Save Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check),
                  label: const Text("Save Progress"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              /// Submit Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: submitToMD,
                  icon: const Icon(Icons.send),
                  label: const Text("Submit to MD"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.darkBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _uploadDocument({
    required PlatformFile file,
    required String documentType,
    Map<String, dynamic> meta = const {},
  }) async {
    try {
      final token = await AuthService().getToken();

      /// ✅ Use customerId from widget
      final int customerId = widget.customerId;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.uploadDocument),
      );

      request.headers.addAll({"Authorization": "Bearer $token"});

      /// ✅ Required Fields
      request.fields['customerId'] = customerId.toString();
      request.fields['documentType'] = documentType;
      request.fields['applicantType'] = "COMPANY";
      request.fields['applicantIndex'] = "0";

      request.fields['issueDate'] = meta['issueDate'] ?? '';
      request.fields['expiryDate'] = meta['expiryDate'] ?? '';
      request.fields['remarks'] = meta['remarks'] ?? '';
      request.fields['rmRemarks'] = meta['rmRemarks'] ?? '';

      /// FILE
      if (file.bytes != null) {
        final ext = file.extension?.toLowerCase();
        http.MediaType contentType;

        if (ext == 'pdf') {
          contentType = http.MediaType('application', 'pdf');
        } else if (ext == 'jpg' || ext == 'jpeg') {
          contentType = http.MediaType('image', 'jpeg');
        } else if (ext == 'png') {
          contentType = http.MediaType('image', 'png');
        } else {
          throw Exception("Invalid file type. Only PDF & images allowed.");
        }

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes as Uint8List,
            filename: file.name,
            contentType: contentType,
          ),
        );
      } else if (file.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', file.path!),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data["success"] == true) {
        showTopToast(
          context,
          data["message"] ?? "Document uploaded successfully",
          success: true,
        );

        /// refresh document list
        await fetchCustomerDetails();
      } else {
        throw Exception(data["message"] ?? "Upload failed");
      }
    } catch (e) {
      print("UPLOAD ERROR: $e");

      showTopToast(context, e.toString(), success: false);
    }
  }

  Widget expandableCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

          leading: Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE6E8FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.description,
              color: AppColors.darkBlue,
              size: 20,
            ),
          ),

          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),

          trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),

          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),

          children: children,
        ),
      ),
    );
  }

  Widget _documentsCard(List documents) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          const Text(
            "Bank Related Documents",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 18),

          /// UPLOAD ROW
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              /// DOCUMENT TYPE
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedDocType,
                  decoration: InputDecoration(
                    labelText: "Document Type",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "CHEQUE", child: Text("Cheque")),
                    DropdownMenuItem(
                      value: "LIVE PHOTO",
                      child: Text("Live Photo"),
                    ),
                    DropdownMenuItem(
                      value: "SHOP PHOTO",
                      child: Text("Shop Photo"),
                    ),
                    DropdownMenuItem(
                      value: "BANK STATEMENT",
                      child: Text("Bank Statement"),
                    ),
                    DropdownMenuItem(
                      value: "OTHER DOCUMENT",
                      child: Text("Other Document"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedDocType = value;
                    });
                  },
                ),
              ),

              /// CHOOSE FILE
              OutlinedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: Text(
                  selectedFile == null ? "Choose Files" : selectedFile!.name,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                  );

                  if (result != null) {
                    setState(() {
                      selectedFile = result.files.first;
                    });
                  }
                },
              ),

              /// UPLOAD BUTTON
              ElevatedButton(
                onPressed: () async {
                  if (selectedFile == null || selectedDocType == null) {
                    showTopToast(
                      context,
                      "Select document type and file",
                      success: false,
                    );
                    return;
                  }

                  await _uploadDocument(
                    file: selectedFile!,
                    documentType: selectedDocType!,
                  );

                  setState(() {
                    selectedFile = null;
                    selectedDocType = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8EA2D9),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Upload",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// DOCUMENT LIST
          if (documents.isEmpty)
            const Text(
              "No documents uploaded",
              style: TextStyle(color: Colors.grey),
            )
          else
            Column(
              children: [
                /// SHOW FIRST DOCUMENT
                if (documents.isNotEmpty) _documentItem(documents.first),

                /// VIEW ALL BUTTON
                if (documents.length > 1 && !showAllDocuments)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showAllDocuments = true;
                      });
                    },
                    child: Text(
                      "View All Documents (${documents.length})",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),

                /// SHOW ALL DOCUMENTS
                if (showAllDocuments)
                  ...documents.map((doc) => _documentItem(doc)),
              ],
            ),
          // Column(
          //   children: documents.map((doc) {
          //     final String fileName = doc["fileName"] ?? "-";
          //     final String docType = doc["documentType"] ?? "-";
          //     final String date = doc["createdAt"] != null
          //         ? "${DateTime.parse(doc["createdAt"]).day}/${DateTime.parse(doc["createdAt"]).month}/${DateTime.parse(doc["createdAt"]).year}"
          //         : "-";

          //     return Container(
          //       margin: const EdgeInsets.only(bottom: 14),
          //       padding: const EdgeInsets.all(16),
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.circular(16),
          //         border: Border.all(color: Colors.grey.shade200),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.black.withOpacity(0.04),
          //             blurRadius: 14,
          //             offset: const Offset(0, 6),
          //           ),
          //         ],
          //       ),
          //       child: Row(
          //         children: [
          //           /// FILE ICON BOX
          //           Container(
          //             height: 46,
          //             width: 46,
          //             decoration: BoxDecoration(
          //               color: const Color(0xFFE8ECF8),
          //               borderRadius: BorderRadius.circular(12),
          //             ),
          //             child: const Icon(
          //               Icons.insert_drive_file_rounded,
          //               color: Color(0xFF3B5EDB),
          //             ),
          //           ),

          //           const SizedBox(width: 14),

          //           /// FILE DETAILS
          //           Expanded(
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 /// FILE NAME
          //                 Text(
          //                   fileName,
          //                   style: const TextStyle(
          //                     fontWeight: FontWeight.w600,
          //                     fontSize: 14,
          //                   ),
          //                   overflow: TextOverflow.ellipsis,
          //                 ),

          //                 const SizedBox(height: 8),

          //                 /// TAGS
          //                 Wrap(
          //                   spacing: 8,
          //                   runSpacing: 6,
          //                   children: [
          //                     /// DOCUMENT TYPE
          //                     Container(
          //                       padding: const EdgeInsets.symmetric(
          //                         horizontal: 10,
          //                         vertical: 4,
          //                       ),
          //                       decoration: BoxDecoration(
          //                         color: const Color(0xFFE0E7FF),
          //                         borderRadius: BorderRadius.circular(20),
          //                       ),
          //                       child: Text(
          //                         docType.replaceAll("_", " "),
          //                         style: const TextStyle(
          //                           fontSize: 11,
          //                           fontWeight: FontWeight.w600,
          //                           color: Color(0xFF3730A3),
          //                         ),
          //                       ),
          //                     ),

          //                     /// APPLICANT TAG
          //                     Container(
          //                       padding: const EdgeInsets.symmetric(
          //                         horizontal: 10,
          //                         vertical: 4,
          //                       ),
          //                       decoration: BoxDecoration(
          //                         color: Colors.grey.shade200,
          //                         borderRadius: BorderRadius.circular(20),
          //                       ),
          //                       child: const Text(
          //                         "COMPANY",
          //                         style: TextStyle(
          //                           fontSize: 11,
          //                           fontWeight: FontWeight.w600,
          //                         ),
          //                       ),
          //                     ),

          //                     /// STATUS TAG
          //                     Container(
          //                       padding: const EdgeInsets.symmetric(
          //                         horizontal: 10,
          //                         vertical: 4,
          //                       ),
          //                       decoration: BoxDecoration(
          //                         color: const Color(0xFFFFF3CD),
          //                         borderRadius: BorderRadius.circular(20),
          //                       ),
          //                       child: Text(
          //                         doc["status"] ?? "pending",
          //                         style: const TextStyle(
          //                           fontSize: 11,
          //                           fontWeight: FontWeight.w600,
          //                           color: Colors.orange,
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),

          //                 const SizedBox(height: 6),

          //                 /// DATE
          //                 Text(
          //                   date,
          //                   style: const TextStyle(
          //                     fontSize: 11,
          //                     color: Colors.grey,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),

          //           /// VIEW BUTTON
          //           IconButton(
          //             icon: const Icon(
          //               Icons.remove_red_eye_rounded,
          //               color: Color(0xFF2563EB),
          //             ),
          //             onPressed: () {
          //               /// open document viewer
          //             },
          //           ),
          //         ],
          //       ),
          //     );
          //   }).toList(),
          // ), 
        ],
      ),
    );
  }

  Widget _documentItem(Map doc) {
    final String fileName = doc["fileName"] ?? "-";
    final String docType = doc["documentType"] ?? "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_rounded),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(docType.replaceAll("_", " ")),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.remove_red_eye_rounded,
              color: AppColors.darkBlue,
            ),
            onPressed: () {
              final String fileUrl = doc["fileUrl"] ?? "";

              print("OPEN FILE URL: $fileUrl");

              if (fileUrl.isEmpty || !fileUrl.startsWith("http")) {
                showTopToast(context, "File not available", success: false);
                return;
              }

              _openFile(fileUrl); // ✅ OPEN IN BROWSER
            },
          ),

          // IconButton(
          //   icon: const Icon(Icons.remove_red_eye),
          //   onPressed: () {
          //     /// open document viewer
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _optionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool verified = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2563EB)),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            verified
                ? const Icon(Icons.verified, color: Colors.green)
                : const Icon(Icons.arrow_forward_ios, size: 16),

            // const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _card({required String title, required List<Widget> children}) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value?.toString() ?? "N/A",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// class FinalSanctionTermsSection extends StatefulWidget {
//   final int customerId;
//   const FinalSanctionTermsSection({super.key, required this.customerId});
//   // const FinalSanctionTermsSection({super.key});

//   @override
//   State<FinalSanctionTermsSection> createState() =>
//       _FinalSanctionTermsSectionState();
// }

// class _FinalSanctionTermsSectionState extends State<FinalSanctionTermsSection> {
//   // Map<String, dynamic>? sanctionData;
//   List<dynamic> sanctionList = [];

//   bool loading = true;
//   bool isEditable = true;
//   final TextEditingController sanctionAmountController =
//       TextEditingController();
//   final TextEditingController tenureController = TextEditingController();
//   final TextEditingController interestRateController = TextEditingController();
//   final TextEditingController penalChargesController = TextEditingController();
//   final TextEditingController processingFeesController =
//       TextEditingController();
//   @override
//   void initState() {
//     super.initState();
//     fetchSanctionTerms();
//   }

//   @override
//   void dispose() {
//     sanctionAmountController.dispose();
//     tenureController.dispose();
//     interestRateController.dispose();
//     penalChargesController.dispose();
//     processingFeesController.dispose();
//     super.dispose();
//   }

//   // Future<void> fetchSanctionTerms() async {
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final token = prefs.getString("token");
//   //     // final int? customerId = prefs.getInt("customerId");
//   //     final customerId = widget.customerId;

//   //     final response = await http.get(
//   //       Uri.parse("${ApiEndpoints.baseUrl}/customers/$customerId"),
//   //       headers: {
//   //         "Authorization": "Bearer $token",
//   //         "Content-Type": "application/json",
//   //       },
//   //     );

//   //     final body = jsonDecode(response.body);

//   //     final sanctions = body["data"]?["creditSanctions"];

//   //     if (sanctions != null) {
//   //       sanctionList = sanctions;
//   //     }
//   //     setState(() {
//   //       loading = false;
//   //     });
//   //   } catch (e) {
//   //     loading = false;
//   //   }
//   // }

//   // Future<void> fetchSanctionTerms() async {
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final token = prefs.getString("token");
//   //     // final int? customerId = prefs.getInt("customerId");
//   //     final customerId = widget.customerId;
//   //     final response = await http.get(
//   //       // Uri.parse("${ApiEndpoints.baseUrl}/customers/$customerId"),
//   //             Uri.parse("${ApiEndpoints.baseUrl}/sanctions/customer/$customerId"),

//   //       headers: {
//   //         "Authorization": "Bearer $token",
//   //         "Content-Type": "application/json",
//   //       },
//   //     );

//   //     final body = jsonDecode(response.body);
//   //     final sanctions = body["data"]?["creditSanctions"];
//   //   final status = body["data"]?["status"];

//   //     if (sanctions != null) {
//   //       sanctionList = sanctions;
//   //     }
//   //     if (status == "md_pending_terms") {
//   //     isEditable = true;
//   //   }
//   //     setState(() {
//   //        sanctionList = sanctions;
//   //       loading = false;
//   //     });
//   //   } catch (e) {
//   //     loading = false;
//   //   }
//   // }

//   Future<void> fetchSanctionTerms() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString("token");
//       final customerId = widget.customerId;

//       final response = await http.get(
//         Uri.parse("${ApiEndpoints.baseUrl}/sanctions/customer/$customerId"),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//       );

//       if (response.statusCode == 200) {
//         final List body = jsonDecode(response.body);

//         setState(() {
//           sanctionList = body;
//           loading = false;
//         });
//       } else {
//         setState(() {
//           loading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF3F4F6),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: const Color(0xFF4F46E5), width: 1.5),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   "Final Sanction Terms",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               Icon(Icons.send, size: 18, color: Color(0xFF4F46E5)),
//             ],
//           ),
//           const SizedBox(height: 20),

//           ListView.builder(
//             itemCount: sanctionList.length,
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemBuilder: (context, i) {
//               final sanction = sanctionList[i];

//               final titles = [
//                 "SANCTION AMOUNT",
//                 "TENURE (MONTHS)",
//                 "INTEREST RATE (%)",
//                 "PENAL CHARGES (%)",
//                 "PROCESSING FEES (%)",
//               ];

//               final values = [
//                 sanction["sanctionAmount"] ?? "",
//                 sanction["tenure"] ?? "",
//                 sanction["interestRate"] ?? "",
//                 sanction["penalCharges"] ?? "",
//                 sanction["processingFees"] ?? "",
//               ];

//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 10),

//                   /// Partner Title
//                   Text(
//                     sanction["partner"] == "Fintree"
//                         ? "Fintree Finance Pvt Ltd (FFPL)"
//                         : sanction["partner"] == "Kite"
//                         ? "KITE FINANCE (KF)"
//                         : "Muthoot Finance (MF)",
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),

//                   const SizedBox(height: 14),

//                   GridView.builder(
//                     itemCount: titles.length,
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 3,
//                           crossAxisSpacing: 10,
//                           mainAxisSpacing: 10,
//                           childAspectRatio: 1.2,
//                         ),
//                     itemBuilder: (context, index) {
//                       return Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 10,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFDDE2F1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               titles[index],
//                               style: const TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w700,
//                                 color: Color(0xFF4F46E5),
//                               ),
//                             ),
//                             const SizedBox(height: 6),
//                             isEditable
//                                 ? TextFormField(
//                                     initialValue: values[index].toString(),
//                                     decoration: const InputDecoration(
//                                       border: InputBorder.none,
//                                       isDense: true,
//                                     ),
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   )
//                                 : Text(
//                                     values[index].toString(),
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                             // Text(
//                             //   values[index].toString(),
//                             //   style: const TextStyle(
//                             //     fontSize: 14,
//                             //     fontWeight: FontWeight.w600,
//                             //   ),
//                             // ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),

//                   const SizedBox(height: 25),
//                   const Divider(),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
class FinalSanctionTermsSection extends StatefulWidget {
  final int customerId;
  final Function(List<dynamic>) onSanctionChange;

  const FinalSanctionTermsSection({
    super.key,
    required this.customerId,
    required this.onSanctionChange,
  });

  @override
  State<FinalSanctionTermsSection> createState() =>
      _FinalSanctionTermsSectionState();
}

class _FinalSanctionTermsSectionState extends State<FinalSanctionTermsSection> {
  List<dynamic> sanctionList = [];
  bool loading = true;
  bool isEditable = true;

  @override
  void initState() {
    super.initState();
    fetchSanctionTerms();
  }

  Future<void> fetchSanctionTerms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final customerId = widget.customerId;

      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/sanctions/customer/$customerId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List body = jsonDecode(response.body);

        setState(() {
          sanctionList = List<Map<String, dynamic>>.from(body);
          loading = false;
        });

        widget.onSanctionChange(sanctionList); // ✅ pass to parent
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("fetchSanctionTerms error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF4F46E5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  "Final Sanction Terms",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.send, size: 18, color: Color(0xFF4F46E5)),
            ],
          ),
          const SizedBox(height: 20),

          ListView.builder(
            itemCount: sanctionList.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, i) {
              final sanction = sanctionList[i];

              final titles = [
                "SANCTION AMOUNT",
                "TENURE (MONTHS)",
                "INTEREST RATE (%)",
                "PENAL CHARGES (%)",
                "PROCESSING FEES (%)",
              ];

              final values = [
                sanction["sanctionAmount"] ?? "",
                sanction["tenure"] ?? "",
                sanction["interestRate"] ?? "",
                sanction["penalCharges"] ?? "",
                sanction["processingFees"] ?? "",
              ];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  Text(
                    sanction["partner"] == "Fintree"
                        ? "Fintree Finance Pvt Ltd (FFPL)"
                        : sanction["partner"] == "Kite"
                        ? "KITE FINANCE (KF)"
                        : "Muthoot Finance (MF)",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 14),

                  GridView.builder(
                    itemCount: titles.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.2,
                        ),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDE2F1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titles[index],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              initialValue: values[index].toString(),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  switch (index) {
                                    case 0:
                                      sanctionList[i]["sanctionAmount"] =
                                          num.tryParse(value) ?? 0;
                                      break;
                                    case 1:
                                      sanctionList[i]["tenure"] =
                                          num.tryParse(value) ?? 0;
                                      break;
                                    case 2:
                                      sanctionList[i]["interestRate"] =
                                          num.tryParse(value) ?? 0;
                                      break;
                                    case 3:
                                      sanctionList[i]["penalCharges"] =
                                          num.tryParse(value) ?? 0;
                                      break;
                                    case 4:
                                      sanctionList[i]["processingFees"] =
                                          num.tryParse(value) ?? 0;
                                      break;
                                  }
                                });

                                widget.onSanctionChange(
                                  sanctionList,
                                ); // ✅ update parent
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 25),
                  const Divider(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
