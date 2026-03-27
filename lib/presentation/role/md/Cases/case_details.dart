import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/auth_service.dart';
import 'package:supply_chain/core/theme/app_colors.dart';
import 'package:supply_chain/core/utils/toast_helper.dart';

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
    List<dynamic> sanctionList = [];

  

  PlatformFile? selectedFile;
  String? selectedDocType;

  final sanctionAmountController = TextEditingController();
  final tenureController = TextEditingController();
  final interestRateController = TextEditingController();
  final penalChargesController = TextEditingController();
  final processingFeesController = TextEditingController();
  final conditionsController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchCustomerDetails();
  }

  /// FETCH API
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
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> submitToMD() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      print("TOKEN VALUE: $token"); // 👈 debug

      final response = await http.post(
        // /customers/:customerId/rm-submit-md
        Uri.parse(
          "${ApiEndpoints.baseUrl}/workflows/customers/${widget.customerId}/rm-submit-md",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "remarks": "Final terms confirmed by RM",
          "sanctionAmount": "500000.00",
          "tenure": "4",
          "interestRate": "10.00",
          "penalCharges": "5.00",
          "processingFees": "1000",
          "conditions": "ok",
        }),
      );

      final body = jsonDecode(response.body);

      if (body["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Submitted to MD successfully")),
        );

        Navigator.pop(context); // Go back to cases screen
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Submission failed")));
      }
    } catch (e) {
      print("Submit error: $e");
    }
  }

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
    final String status = (caseData?["status"] ?? "").toString().toLowerCase();

    final applicant = caseData?["applicant"] ?? {};
    final company = caseData ?? {};
    final coApplicants = caseData?["coApplicants"] ?? [];
    final addresses = caseData?["addresses"] ?? [];
    final contacts = caseData?["contactPersons"] ?? [];
    // nextStepSection();
    // if (status != "md_approved") nextStepSection();
    final documents = caseData?["documents"] ?? [];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(title: const Text("Approval Screen")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// CUSTOMER INFORMATION
            expandableCard(
              title: "Customer Information",
              children: [
                _infoRow("Company Name", company["companyName"]),
                _infoRow("Mobile", company["companyMobile"]),
                _infoRow("Email", company["companyEmail"]),
                _infoRow("GST", company["gstNumber"]),
              ],
            ),


             const SizedBox(height: 16),

              /// APPLICANT CARD
              expandableCard(
                title: "Applicant Details",
                children: [
                  _infoRow("Name", applicant["name"]),
                  _infoRow("Mobile", applicant["mobile"]),
                  _infoRow("Email", applicant["email"]),
                  _infoRow("PAN", applicant["pan"]),
                ],
              ),

            const SizedBox(height: 16),

            /// CO APPLICANTS
            if (coApplicants.isNotEmpty)
              expandableCard(
                title: "Co-Applicants",
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

              /// CONTACT PERSON
              if (contacts.isNotEmpty)
                expandableCard(
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
              const SizedBox(height: 16),

              /// ADDRESS
              if (addresses.isNotEmpty)
                expandableCard(
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

             


            const SizedBox(height: 16),

            /// SANCTION DETAILS
            // _financialSanctionCard(sanctions.isNotEmpty ? sanctions.last : {}),
            FinalSanctionTermsSection(customerId: widget.customerId),
            const SizedBox(height: 16),

            /// DOCUMENTS
            _documentsCard(documents),

            const SizedBox(height: 16),

            /// APPROVAL REMARKS
            _approvalRemarksSection(),

            const SizedBox(height: 20),

            /// APPROVE / REJECT BUTTONS
            if (status == "ceo_approved" || status == "md_terms_submitted")
              _approvalButtons()
            else
              _readOnlyCard(),
          ],
        ),
      ),
    );
  }

// Future<void> openDocument(String url) async {
//   final Uri uri = Uri.parse(url);

//   if (await canLaunchUrl(uri)) {
//     await launchUrl(uri, mode: LaunchMode.externalApplication);
//   } else {
//     showTopToast(context, "Unable to open document", success: false);
//   }
// }


// Future<void> openDocument(String url) async {

//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (_) => DocumentViewer(url: url),
//     ),
//   );

// }


  Widget _readOnlyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Read Only Mode",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  "Case has been processed or is not at your stage.",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget expandableCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),

          /// HEADER
          title: Row(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 20,
                color: Color(0xFF4F46E5),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          /// RIGHT TEXT BUTTON
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "View",
              style: TextStyle(
                color: Color(0xFF4F46E5),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),

          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),

          children: children,
        ),
      ),
    );
  }

  Widget _approvalRemarksSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Approval Remarks",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: remarksController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Enter remarks...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _approvalButtons() {
    return Row(
      children: [
        /// REJECT
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.close),
            label: const Text("Reject"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              rejectCase();
            },
          ),
        ),

        const SizedBox(width: 12),

        /// APPROVE
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text("Approve"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              approveCase();
            },
          ),
        ),
      ],
    );
  }



Future<void> approveCase() async {
  try {
    final token = await AuthService().getToken();

   final partnerSanctions = sanctionList.map((sanction) {
  String partner = sanction["partner"] ?? "";

  // Fix unsupported lender
  if (partner == "FFPL") {
    partner = "Fintree";
  }

  return {
    "partner": partner,
    "sanctionAmount":
        double.tryParse(sanction["sanctionAmount"].toString()) ?? 0,
    "tenure": sanction["tenure"] ?? 0,
    "interestRate": sanction["interestRate"] ?? 0,
    "penalCharges": sanction["penalCharges"] ?? 0,
    "processingFees": sanction["processingFees"] ?? 0,
    "conditions": conditionsController.text.trim(),
  };
}).toList();

    final response = await http.post(
      Uri.parse(
        "${ApiEndpoints.baseUrl}/workflows/customers/${widget.customerId}/md-approve",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "approved": true,
        "remarks": remarksController.text.trim(),
        "partnerSanctions": partnerSanctions,
      }),
    );

    final body = jsonDecode(response.body);

    if (body["success"] == true) {
      showTopToast(context, "Case Approved Successfully", success: true);
      Navigator.pop(context);
    } else {
      showTopToast(
        context,
        body["message"] ?? "Approval failed",
        success: false,
      );
    }
  } catch (e) {
    showTopToast(context, "Something went wrong", success: false);
  }
}
  // Future<void> approveCase() async {
  //   try {
  //     final token = await AuthService().getToken();

  //     final response = await http.post(
  //       Uri.parse(
  //         "${ApiEndpoints.baseUrl}/workflows/customers/${widget.customerId}/md-approve",
  //       ),
  //       headers: {
  //         "Authorization": "Bearer $token",
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonEncode({
  //         "approved": true,
  //         "remarks": remarksController.text.trim(),
  //         "partnerSanctions": [
  //           {
  //             "partner": "FFPL",
  //             "sanctionAmount":
  //                 double.tryParse(sanctionAmountController.text) ?? 0,
  //             "tenure": int.tryParse(tenureController.text) ?? 0,
  //             "interestRate": double.tryParse(interestRateController.text) ?? 0,
  //             "penalCharges": double.tryParse(penalChargesController.text) ?? 0,
  //             "processingFees":
  //                 double.tryParse(processingFeesController.text) ?? 0,
  //             "conditions": conditionsController.text.trim(),
  //           },
  //         ],
  //       }),
  //     );

  //     final body = jsonDecode(response.body);

  //     if (body["success"] == true) {
  //       showTopToast(context, "Case Approved Successfully", success: true);

  //       Navigator.pop(context);
  //     } else {
  //       showTopToast(
  //         context,
  //         body["message"] ?? "Approval failed",
  //         success: false,
  //       );
  //     }
  //   } catch (e) {
  //     showTopToast(context, "Something went wrong", success: false);
  //   }
  // }

  Future<void> rejectCase() async {
    final token = await AuthService().getToken();

    await http.post(
      Uri.parse(
        "${ApiEndpoints.baseUrl}/workflows/customers/${widget.customerId}/md-reject",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"remarks": remarksController.text}),
    );

    Navigator.pop(context);
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
        const Text(
          "Bank Related Documents",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 18),

        if (documents.isEmpty)
          const Text(
            "No documents uploaded",
            style: TextStyle(color: Colors.grey),
          )
        else
          Column(
            children: documents.map((doc) {
              final String fileName = doc["fileName"] ?? "-";
              final String fileUrl = doc["fileUrl"] ?? "";
              final String docType = doc["documentType"] ?? "-";

              final String date = doc["createdAt"] != null
                  ? "${DateTime.parse(doc["createdAt"]).day}/${DateTime.parse(doc["createdAt"]).month}/${DateTime.parse(doc["createdAt"]).year}"
                  : "-";

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [

                    /// FILE ICON
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8ECF8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.insert_drive_file_rounded,
                        color: Color(0xFF3B5EDB),
                      ),
                    ),

                    const SizedBox(width: 14),

                    /// FILE DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// FILE NAME
                          Text(
                            fileName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [

                              /// DOC TYPE
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E7FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  docType.replaceAll("_", " "),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3730A3),
                                  ),
                                ),
                              ),

                              /// STATUS
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3CD),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  doc["status"] ?? "pending",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// DATE
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// VIEW DOCUMENT
                    IconButton(
                      icon: const Icon(
                        Icons.remove_red_eye_rounded,
                        color: Color(0xFF2563EB),
                      ),
                      onPressed: () {

                        if (fileUrl.isNotEmpty) {
                          // openDocument(fileUrl);
                          // _viewDocument(doc.fileUrl);
                        } else {
                          showTopToast(
                            context,
                            "Document not available",
                            success: false,
                          );
                        }

                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
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

class FinalSanctionTermsSection extends StatefulWidget {
  final int customerId;
  const FinalSanctionTermsSection({super.key, required this.customerId});
  // const FinalSanctionTermsSection({super.key});

  @override
  State<FinalSanctionTermsSection> createState() =>
      _FinalSanctionTermsSectionState();
}

class _FinalSanctionTermsSectionState extends State<FinalSanctionTermsSection> {
  // Map<String, dynamic>? sanctionData;
  List<dynamic> sanctionList = [];

  bool loading = true;
  bool isEditable = true;

  final TextEditingController sanctionAmountController =
      TextEditingController();
  final TextEditingController tenureController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController penalChargesController = TextEditingController();
  final TextEditingController processingFeesController =
      TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchSanctionTerms();
  }

  @override
  void dispose() {
    sanctionAmountController.dispose();
    tenureController.dispose();
    interestRateController.dispose();
    penalChargesController.dispose();
    processingFeesController.dispose();
    super.dispose();
  }

  // Future<void> fetchSanctionTerms() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString("token");
  //     // final int? customerId = prefs.getInt("customerId");
  //     final customerId = widget.customerId;

  //     final response = await http.get(
  //       Uri.parse("${ApiEndpoints.baseUrl}/customers/$customerId"),
  //       headers: {
  //         "Authorization": "Bearer $token",
  //         "Content-Type": "application/json",
  //       },
  //     );

  //     final body = jsonDecode(response.body);

  //     final sanctions = body["data"]?["creditSanctions"];

  //     if (sanctions != null) {
  //       sanctionList = sanctions;
  //     }
  //     setState(() {
  //       loading = false;
  //     });
  //   } catch (e) {
  //     loading = false;
  //   }
  // }

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
          sanctionList = body;
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
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

                  /// Partner Title
                  Text(
                    sanction["partner"] == "FFPL"
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

                            // Text(
                            //   values[index].toString(),
                            //   style: const TextStyle(
                            //     fontSize: 14,
                            //     fontWeight: FontWeight.w600,
                            //   ),
                            // ),
                            isEditable
                                ? TextFormField(
                                    initialValue: values[index].toString(),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : Text(
                                    values[index].toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
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
