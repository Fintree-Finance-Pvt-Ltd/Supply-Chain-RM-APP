import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/auth_service.dart';
import 'package:supply_chain/core/utils/toast_helper.dart';
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
  List<dynamic> sanctionList = [];
  bool showAllDocuments = false; // Manages expand/collapse behavior for files

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
      setState(() {
        loading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

      // CUSTOMER KYC API
      final kycResponse = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/customers/${widget.customerId}/kyc"),
        headers: headers,
      );

      // CO-APPLICANTS API
      final coApplicantResponse = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/customers/${widget.customerId}/coapplicants"),
        headers: headers,
      );

      // ADDRESSES API
      final addressResponse = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/customers/${widget.customerId}/addresses"),
        headers: headers,
      );

      // CONTACT PERSONS API
      final contactPersonResponse = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/customers/${widget.customerId}/contact-persons"),
        headers: headers,
      );

      // DOCUMENTS API
      final documentResponse = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/documents/customer/${widget.customerId}"),
        headers: headers,
      );

      final kycBody = jsonDecode(kycResponse.body);
      final coApplicantBody = jsonDecode(coApplicantResponse.body);
      final addressBody = jsonDecode(addressResponse.body);
      final contactPersonBody = jsonDecode(contactPersonResponse.body);
      final documentBody = jsonDecode(documentResponse.body);

      final baseUrl = ApiEndpoints.baseUrl.replaceAll("/api", "");
      final uploadedDocs = documentBody["data"] ?? documentBody ?? [];

      setState(() {
        caseData = {
          "customerProfile": kycBody["data"]?["customerProfile"] ?? {},
          "applicant": kycBody["data"]?["applicant"] ?? {},
          "kycDetails": kycBody["data"]?["kycDetails"] ?? [],
          "coApplicants": coApplicantBody["data"] ?? coApplicantBody ?? [],
          "addresses": addressBody["data"] ?? addressBody ?? [],
          "contactPersons": contactPersonBody["data"] ?? contactPersonBody ?? [],
          "documents": uploadedDocs.map((doc) {
            final filePath = doc["filePath"] ?? "";
            final cleanPath = filePath.startsWith("/") ? filePath.substring(1) : filePath;

            return {
              ...doc,
              "fileUrl": filePath.isNotEmpty ? "$baseUrl/$cleanPath" : null,
            };
          }).toList(),
        };
        loading = false;
      });

      print("Customer Details Loaded");
    } catch (e) {
      print("Fetch Customer Details Error: $e");
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> submitToMD() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.post(
        Uri.parse("${ApiEndpoints.baseUrl}/workflows/customers/${widget.customerId}/rm-submit-md"),
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
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Submission failed")),
        );
      }
    } catch (e) {
      print("Submit error: $e");
    }
  }

  Future<void> loadDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse(
        "${ApiEndpoints.baseUrl}/documents/customer/${widget.customerId}",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

      final body = jsonDecode(response.body);
      final uploadedDocs = body["data"] ?? body ?? [];
      final baseUrl = ApiEndpoints.baseUrl.replaceAll("/api", "");

      setState(() {
        caseData ??= {};
        caseData!["documents"] = uploadedDocs.map((doc) {
          final filePath = doc["filePath"] ?? "";
          final cleanPath = filePath.startsWith("/") ? filePath.substring(1) : filePath;

          return {
            ...doc,
            "fileUrl": filePath.isNotEmpty ? "$baseUrl/$cleanPath" : null,
          };
        }).toList();
      });
    } catch (e) {
      print("Load Documents Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final String status = (caseData?["status"] ?? "").toString().toLowerCase();

    final applicant = caseData?["applicant"] ?? {};
    final company = caseData?["customerProfile"] ?? {};
    final coApplicants = caseData?["coApplicants"] ?? [];
    final addresses = caseData?["addresses"] ?? [];
    final contacts = caseData?["contactPersons"] ?? [];
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
            FinalSanctionTermsSection(customerId: widget.customerId),
            const SizedBox(height: 16),

            /// DOCUMENTS (With Expand/Collapse functionality)
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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
        if (partner == "FFPL") {
          partner = "Fintree";
        }

        return {
          "partner": partner,
          "sanctionAmount": double.tryParse(sanction["sanctionAmount"].toString()) ?? 0,
          "tenure": sanction["tenure"] ?? 0,
          "interestRate": sanction["interestRate"] ?? 0,
          "penalCharges": sanction["penalCharges"] ?? 0,
          "processingFees": sanction["processingFees"] ?? 0,
          "conditions": conditionsController.text.trim(),
        };
      }).toList();

      final response = await http.post(
        Uri.parse("${ApiEndpoints.baseUrl}/workflows/customers/${widget.customerId}/md-approve"),
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

  void _openFile(String url) {
    final isPdf = url.toLowerCase().endsWith(".pdf");

    if (isPdf) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (_) => _imagePreview(url),
    );
  }

  Widget _imagePreview(String url) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.6,
      maxChildSize: 1,
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    const Text(
                      "Preview",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.open_in_new, color: Colors.white),
                      onPressed: () {
                        launchUrl(Uri.parse(url));
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5,
                  child: Center(child: Image.network(url, fit: BoxFit.contain)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> rejectCase() async {
    final token = await AuthService().getToken();

    await http.post(
      Uri.parse("${ApiEndpoints.baseUrl}/workflows/customers/${widget.customerId}/md-reject"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"remarks": remarksController.text}),
    );

    Navigator.pop(context);
  }

  Widget _documentsCard(List documents) {
    if (documents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          "Bank Related Documents",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      );
    }

    // Displays the first 2 documents initially unless the showAllDocuments state flag is toggled
    final visibleDocuments = showAllDocuments ? documents : documents.take(2).toList();

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
         Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // Wrap the title text with Expanded to prevent horizontal overflow
    Expanded( 
      child: const Text(
        "Bank Related Documents",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis, // Elegantly truncates with '...' if the screen is too narrow
      ),
    ),
    const SizedBox(width: 8), // Added subtle spacing between the title and the button
    if (documents.length > 2)
      TextButton(
        onPressed: () {
          setState(() {
            showAllDocuments = !showAllDocuments; 
          });
        },
        child: Text(
          showAllDocuments ? "Show Less" : "View All (${documents.length})",
          style: const TextStyle(
            color: Color(0xFF4F46E5),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
  ],
),
          const SizedBox(height: 18),
          Column(
            children: visibleDocuments.map((doc) {
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
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                          Text(
                            date,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.remove_red_eye_rounded,
                        color: Color(0xFF2563EB),
                      ),
                      onPressed: () {
                        if (fileUrl.isNotEmpty && fileUrl.startsWith("http")) {
                          _openFile(fileUrl);
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

  @override
  State<FinalSanctionTermsSection> createState() => _FinalSanctionTermsSectionState();
}

class _FinalSanctionTermsSectionState extends State<FinalSanctionTermsSection> {
  List<dynamic> sanctionList = [];
  bool loading = true;
  bool isEditable = true;

  final TextEditingController sanctionAmountController = TextEditingController();
  final TextEditingController tenureController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController penalChargesController = TextEditingController();
  final TextEditingController processingFeesController = TextEditingController();

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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.2,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(10),
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