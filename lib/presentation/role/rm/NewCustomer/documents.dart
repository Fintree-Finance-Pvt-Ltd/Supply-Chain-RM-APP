 
import 'dart:convert';
import 'dart:typed_data';
 
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/auth_service.dart';
import 'package:supply_chain/core/services/draft_service.dart';
import 'package:supply_chain/core/services/web_camera_capture.dart';
import 'package:supply_chain/core/utils/toast_helper.dart';
import 'package:supply_chain/presentation/role/rm/dashboard_screen.dart';
import 'package:url_launcher/url_launcher.dart';
 
/// =======================
/// COLORS (Mock AppColors)
/// =======================
class AppColors {
  static const scaffoldBg = Color(0xFFF5F7FB);
  static const primary = Color(0xFF2563EB);
}
 
/// =======================
/// DOCUMENT MODEL
/// =======================
class DocumentItem {
  final String name;
  final String type;
  final bool mandatory;
 
  List<String> fileUrls; // ✅ MULTIPLE FILES
 
  DocumentItem({
    required this.name,
    required this.type,
    required this.mandatory,
    this.fileUrls = const [],
  });
}
 
final List<DocumentItem> allDocuments = [
  DocumentItem(
    name: "GST Certificate",
    type: "applicant_gst",
    mandatory: false,
  ),
  DocumentItem(
    name: "MSME Certificate",
    type: "msme_certificate",
    mandatory: false,
  ),
  DocumentItem(
    name: "Office Electricity Bill",
    type: "office_electricity_bill",
    mandatory: false,
  ),
  DocumentItem(
    name: "PAN & Aadhaar of Applicant",
    type: "applicant_pan",
    mandatory: false,
  ),
  DocumentItem(
    name: "PAN & Aadhaar of Female Co-Applicant",
    type: "female_co_applicant_pan_aadhaar",
    mandatory: false,
  ),
  DocumentItem(
    name: "Residence Electricity Bill",
    type: "residence_electricity_bill",
    mandatory: false,
  ),
  DocumentItem(
    name: "Audited Financials (Last 3 Years)",
    type: "audited_financials",
    mandatory: false,
  ),
  DocumentItem(
    name: "GSTR-3B (Latest 2 – Required)",
    type: "gstr_3b",
    mandatory: false,
  ),
  DocumentItem(
    name: "Bank Statement (Last 12 months)",
    type: "bank_statement",
    mandatory: false,
  ),
  DocumentItem(
    name: "Obligation Sheet",
    type: "obligation_sheet",
    mandatory: false,
  ),
  DocumentItem(
    name: "Sales & Purchase (Monthwise, Tally)",
    type: "sales_purchase",
    mandatory: false,
  ),
  DocumentItem(
    name: "PAN & Aadhaar of ALL Partners",
    type: "PAN_AADHAAR_OF_ALL_PARTNERS",
    mandatory: false,
  ),
  DocumentItem(name: "Company PAN", type: "company_pan", mandatory: false),
  DocumentItem(name: "Debtor Ageing", type: "debtor_ageing", mandatory: false),
  DocumentItem(
    name: "MOA (Memorandum of Association)",
    type: "moa",
    mandatory: false,
  ),
  DocumentItem(
    name: "AOA (Articles of Association)",
    type: "aoa",
    mandatory: false,
  ),
  DocumentItem(
    name: "List of Directors & Shareholders",
    type: "list_of_directors",
    mandatory: false,
  ),
  DocumentItem(
    name: "COI (Certificate of Incorporation)",
    type: "coi",
    mandatory: false,
  ),
  DocumentItem(
    name: "Partnership Deed / LLP Deed",
    type: "partnership_deed",
    mandatory: false,
  ),
];
 
/// =======================
/// DOCUMENT CONFIG
/// =======================
///
Map<String, List<String>> optionalDocsByCompanyType = {
  "proprietorship": [
    "GST Certificate",
    "MSME Certificate",
    "Office Electricity Bill",
    "PAN & Aadhaar of Female Co-Applicant",
    "Residence Electricity Bill",
    "Obligation Sheet",
    "Sales & Purchase (Monthwise, Tally)",
  ],
 
  "partnership": [
    "GST Certificate",
    "MSME Certificate",
    "Office Electricity Bill",
    "Residence Electricity Bill",
    "Obligation Sheet",
    "Sales & Purchase (Monthwise, Tally)",
  ],
 
  "pvt ltd /ltd": [
    "GST Certificate",
    "MSME Certificate",
    "Office Electricity Bill",
    "Obligation Sheet",
    "Sales & Purchase (Monthwise, Tally)",
    "debtor Ageing",
  ],
  "llp": [
    "GST Certificate",
    "MSME Certificate",
    "Office Electricity Bill",
    "Obligation Sheet",
    "Sales & Purchase (Monthwise, Tally)",
    "debtor Ageing",
  ],
};
 
final Map<String, List<String>> mandatoryDocsByCompanyType = {
  "proprietorship": [
    "PAN & Aadhaar of Applicant",
    "Audited Financials (Last 3 Years)",
    "GSTR-3B (Latest 2 – Required)",
    "Bank Statement (Last 12 months)",
  ],
 
  "partnership": [
    "PAN & Aadhaar of ALL Partners",
    "Audited Financials (Last 3 Years)",
    "Bank Statement (Last 12 months)",
    "Partnership Deed / LLP Deed",
    "GSTR-3B (Latest 2 – Required)",
    "Company PAN",
  ],
 
  "llp": [
    "PAN & Aadhaar of ALL Partners",
    "Partnership Deed / LLP Deed",
    "Audited Financials (Last 3 Years)",
    "GSTR-3B (Latest 2 – Required)",
    "Bank Statement (Last 12 months)",
    "Company PAN",
  ],
 
  "huf": [
    "PAN & Aadhaar of Applicant",
    "Audited Financials (Last 3 Years)",
    "GSTR-3B (Latest 2 – Required)",
    "Bank Statement (Last 12 months)",
  ],
 
  "pvt ltd /ltd": [
    "PAN & Aadhaar of ALL Directors",
    "Audited Financials (Last 3 Years)",
    "GSTR-3B (Latest 2 – Required)",
    "Bank Statement (Last 12 months)",
    "MOA (Memorandum of Association)",
    "AOA (Articles of Association)",
    "List of Directors & Shareholders",
    "Company PAN",
    "COI (Certificate of Incorporation)",
  ],
};
 
/// =======================
/// DOCUMENTS PAGE
/// =======================
class DocumentsPage extends StatefulWidget {
  final String companyType;
  final int customerId;
 
  const DocumentsPage({
    super.key,
    required this.companyType,
    required this.customerId,
  });
 
  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}
 
class _DocumentsPageState extends State<DocumentsPage> {
  late List<DocumentItem> documents;
  bool isDarkMode = false;
 
  @override
  void initState() {
    print("Company Type from previous screen: ${widget.companyType}");
    print("Mandatory Map Keys: ${mandatoryDocsByCompanyType.keys}");
    super.initState();
loadTheme();
    final type = widget.companyType.toLowerCase().trim();
 
    final mandatoryList = mandatoryDocsByCompanyType[type] ?? [];
    final optionalList = optionalDocsByCompanyType[type] ?? [];
 
    List<DocumentItem> mandatoryDocs = [];
    List<DocumentItem> optionalDocs = [];
 
    /// ✅ Step 1: Separate docs
    for (var doc in allDocuments) {
      if (mandatoryList.contains(doc.name)) {
        mandatoryDocs.add(
          DocumentItem(name: doc.name, type: doc.type, mandatory: true),
        );
      } else if (optionalList.contains(doc.name)) {
        optionalDocs.add(
          DocumentItem(name: doc.name, type: doc.type, mandatory: false),
        );
      }
    }
 
    /// ✅ Step 2: Final merge
    documents = [...mandatoryDocs, ...optionalDocs];
 
    print("Final Docs: ${documents.map((e) => e.name).toList()}");
 
    _fetchUploadedDocuments();
  }
 
  int get totalDocs => documents.length;
  int get mandatoryDocs => documents.where((d) => d.mandatory).length;
  int get uploadedDocs => documents.where((d) => d.fileUrls.isNotEmpty).length;
 
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isDarkMode = prefs.getBool("isDarkMode") ?? false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF121212) : AppColors.scaffoldBg,
 
         
      appBar: AppBar(
        // backgroundColor: Colors.white,
           backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF4F6FA),
 iconTheme: IconThemeData(
    color: isDarkMode ? Colors.white : Colors.black,
  ),
 
        elevation: 0,
        title: Text(
          "Documents - ${widget.companyType}",
          style:  TextStyle(
            fontWeight: FontWeight.w700,
            // color: Colors.black87,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _uploadSummaryCard(),
            const SizedBox(height: 16),
            Expanded(child: _documentList()),
            const SizedBox(height: 12),
            _bottomButtons(context),
          ],
        ),
      ),
    );
  }
 
  Future<int> _loadCustomerId() async {
    return widget.customerId;
  }
 
  Widget _uploadSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: const Color(0xFFF1F7FF),
        color: isDarkMode ? const Color(0xFF1E293B): const Color(0xFFF1F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // color: const Color(0xFFB6D4FF)
 
          color: isDarkMode ? Colors.white24 : const Color(0xFFB6D4FF),
      ),),
      child: Text(
        "Total: $totalDocs | Mandatory: $mandatoryDocs | Uploaded: $uploadedDocs",
 
        style:  TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          // color: Color(0xFF1E3A8A),
            color: isDarkMode
      ? Colors.white
      : const Color(0xFF1E3A8A),
 
        ),
      ),
    );
  }
 
  Widget _documentList() {
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            // color: Colors.white,
            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(blurRadius: 12,
               color: Colors.black.withOpacity(0.06)
               ),
            ],
          ),
          child: Row(
            children: [
              /// 📄 LEFT INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.name,
                      style:  TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                       
    color: isDarkMode ? Colors.white : Colors.black,
 
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doc.mandatory ? "REQUIRED" : "OPTIONAL",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: doc.mandatory ? Colors.red : Colors.grey,
                      ),
                    ),
 
                    /// FILE COUNT
                    if (doc.fileUrls.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          "${doc.fileUrls.length} files uploaded",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
 
              /// 📤 ACTIONS
              Column(
                children: [
                  /// Upload
                  IconButton(
                    icon: const Icon(Icons.upload_file, color: Colors.blue),
                    onPressed: () => _pickFromDevice(doc),
                  ),
 
                  /// View
                  if (doc.fileUrls.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.visibility,
                        color: Color(0xFF64748B),
                      ), // Modern slate color
                      onPressed: () => _showFilesBottomSheet(
                        doc,
                      ), // Pass the full 'doc' object here
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
 
  void _showFilesBottomSheet(DocumentItem doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Required for custom rounded corners
      builder: (_) {
        return Container(
          decoration:  BoxDecoration(
            // color: Colors.white,
            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gray handle at top
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  // color: Colors.grey[300],
                  color: isDarkMode ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
 
              // 1. Top Header Card (Matches the "Prostarm" card in your image)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        doc.name,
                        style:  TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          // color: Color(0xFF334155),
                          color: isDarkMode ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${doc.fileUrls.length} Files",
                          style:  TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            // color: Colors.black,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const Text(
                          "Uploaded",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
 
              // 2. Action List (Matches "Set trigger order", etc.)
              _buildActionItem(
                icon: Icons.folder_open_outlined,
                title: "View All Documents",
             
                  // color: isDarkMode ? Colors.white : Colors.black87,
               
                onTap: () {
                  Navigator.pop(context); // Close the current menu
                  _showAllFilesGallery(doc); // Open the gallery
                },
              ),
              const Divider(height: 1),
              _buildActionItem(
                icon: Icons.add_circle_outline,
                title: "Add Another File",
                onTap: () {
                  Navigator.pop(context);
                  _pickFromDevice(doc);
                },
              ),
 
              const SizedBox(height: 24),
 
              // 3. Bottom Action Buttons (Matches Sell/Buy)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFF05336,
                        ), // Reddish orange
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (doc.fileUrls.isNotEmpty) {
                          _viewDocument(doc.fileUrls.first);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B287), // Green
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Open Latest",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
 
  // Helper to build list items in the bottom sheet
  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon,
      color: isDarkMode ? Colors.white : Colors.black87
      , size: 22),
      title: Text(
        title,
        style:  TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
        color: isDarkMode ? Colors.white : Colors.black87
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
 
  Future<void> _viewDocument(String? url) async {
    if (url == null || url.trim().isEmpty) {
      showTopToast(context, "Document URL not found", success: false);
      return;
    }
 
    try {
      final uri = Uri.parse(url);
 
      final ok = await launchUrl(
        uri,
 
        mode: LaunchMode.inAppBrowserView, // 🔥 better than external
      );
 
      if (!ok) {
        showTopToast(context, "Unable to open document", success: false);
      }
    } catch (e) {
      showTopToast(context, "Invalid document url", success: false);
    }
  }
 
  Future<void> _fetchUploadedDocuments() async {
    try {
      final customerId = await _loadCustomerId();
 
      final token = await AuthService().getToken();
 
      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/documents/customer/$customerId"),
 
        headers: {"Authorization": "Bearer $token"},
      );
 
      print("FETCH STATUS: ${response.statusCode}");
      print("FETCH BODY: ${response.body}");
 
      final data = jsonDecode(response.body);
 
      if (response.statusCode == 200 && data["success"] == true) {
        final List uploadedDocs = data["data"];
 
        setState(() {
          for (var doc in documents) {
            final backendType = doc.type; // ✅ FIXED
 
            final matches = uploadedDocs
                .where((d) => d["documentType"] == backendType)
                .toList();
 
            final base = ApiEndpoints.baseUrl.replaceAll("/api", "");
 
            doc.fileUrls = matches.map<String>((m) {
              return "$base/${m["filePath"]}";
            }).toList();
          }
        });
      }
    } catch (e) {
      print("FETCH ERROR: $e");
    }
  }
 
  void _showAllFilesGallery(DocumentItem doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // backgroundColor: Colors.transparent,
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration:  BoxDecoration(
            // color: Colors.white,
            color:isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle and Header
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon:  Icon(Icons.arrow_back_ios,
color: isDarkMode ? Colors.white : const Color(0xFF334155),
                       size: 20),
                      onPressed: () {
                        Navigator.pop(context);
                        _showFilesBottomSheet(doc); // Go back to menu
                      },
                    ),
                    Expanded(
                      child: Text(
                        "${doc.name} Files",
                        style:  TextStyle(
                          fontSize: 18,
                          color: isDarkMode ? Colors.white : const Color(0xFF334155),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      "${doc.fileUrls.length}",
                      style:  TextStyle(
                          color: isDarkMode ? Colors.white : const Color(0xFF334155),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
 
              // List of Files
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: doc.fileUrls.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final url = doc.fileUrls[index];
                    // Extracting a simple filename or using index
                    final fileName = "Document Part ${index + 1}";
 
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.description,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fileName,
                                  style:  TextStyle(
                                                              color: isDarkMode ? Colors.white : const Color(0xFF334155),
 
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "Tap to view full document",
                                  style: TextStyle(
                                    fontSize: 12,
                                    // color: Colors.grey.shade600,
                                    color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Individual View Icon
                          IconButton(
                            icon: const Icon(
                              Icons.visibility_outlined,
                              color: Color(0xFF00B287),
                            ),
                            onPressed: () => _viewDocument(url),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
 
  Future<Map<String, String>?> _showDocumentMetaDialog() async {
    final issueController = TextEditingController();
    final expiryController = TextEditingController();
 
    Future<void> pickDate(TextEditingController controller) async {
      final date = await showDatePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDate: DateTime.now(),
      );
 
      if (date != null) {
        controller.text = date.toIso8601String().split("T")[0];
      }
    }
 
    return await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Document Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: issueController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Issue Date",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => pickDate(issueController),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: expiryController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Expiry Date",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => pickDate(expiryController),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, {
                  "issueDate": issueController.text,
                  "expiryDate": expiryController.text,
                });
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }
 
  Future<void> _uploadDocument({
    required PlatformFile file,
    required String documentType,
    Map<String, dynamic> meta = const {},
  }) async {
    // print("Customer ID => $CustomerId");
    if (documentType == "PAN_CARD") {
      showTopToast(
        context,
        "Verify mobile number before saving PAN",
        success: false,
      );
      return;
    }
    try {
      // setState(() => isApiLoading = true);
      final token = await AuthService().getToken();
 
      // final int? storedCustomerId = prefs.getInt("customerId");
      final storedCustomerId = await _loadCustomerId();
 
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.uploadDocument),
      );
 
      // ✅ Headers
      request.headers.addAll({"Authorization": "Bearer $token"});
 
      // ✅ Required Fields
      request.fields['customerId'] = storedCustomerId.toString();
      request.fields['documentType'] = documentType;
      request.fields['applicantType'] = "COMPANY";
      request.fields['applicantIndex'] = "0";
 
      request.fields['issueDate'] = meta['issueDate'] ?? '';
      request.fields['expiryDate'] = meta['expiryDate'] ?? '';
      request.fields['remarks'] = meta['remarks'] ?? '';
      request.fields['rmRemarks'] = meta['rmRemarks'] ?? '';
 
      // ✅ File Upload (Web + Mobile Safe)
      if (file.bytes != null) {
        final ext = file.extension?.toLowerCase();
 
        MediaType contentType;
 
        if (ext == 'pdf') {
          contentType = MediaType('application', 'pdf');
        } else if (ext == 'jpg' || ext == 'jpeg') {
          contentType = MediaType('image', 'jpeg');
        } else if (ext == 'png') {
          contentType = MediaType('image', 'png');
        } else {
          throw Exception(
            "Invalid file type selected. Only PDF & images allowed.",
          );
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
      } else {
        throw Exception("Unable to read file");
      }
 
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
 
      print("UPLOAD STATUS: ${response.statusCode}");
      print("UPLOAD BODY: ${response.body}");
 
      final data = jsonDecode(response.body);
 
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data["success"] == true) {
        showTopToast(
          context,
          data["message"] ?? "Document uploaded successfully",
          success: true,
        );
      } else {
        final message = data["message"] ?? "Upload failed";
        throw Exception(message);
      }
    } catch (e) {
      print("UPLOAD ERROR: $e");
      showTopToast(context, e.toString(), success: false);
      // } finally {
      //   setState(() => isApiLoading = false);
      // }
    }
  }
 
  Future<void> _pickFromDevice(DocumentItem doc) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );
 
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
 
      final meta = await _showDocumentMetaDialog();
      if (meta == null) return;
 
      /// ✅ Upload file
      await _uploadDocument(
        file: file,
        documentType: doc.type,
        meta: {
          "issueDate": meta["issueDate"],
          "expiryDate": meta["expiryDate"],
        },
      );
 
      /// ✅ Refresh documents from backend
      await _fetchUploadedDocuments();
    }
  }
 
  Future<void> _takePhoto(DocumentItem doc) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WebCameraCapture()),
    );
 
    if (result != null) {
      await _fetchUploadedDocuments(); // ✅ refresh instead
 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${doc.name} captured successfully")),
      );
    }
  }
 
  static Future<void> submitCustomer(int customerId) async {
    try {
      final token = await AuthService().getToken();
 
      final response = await http.post(
        Uri.parse(
          ApiEndpoints.baseUrl + ApiEndpoints.submitCustomer(customerId),
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
 
      final data = jsonDecode(response.body);
 
      if (response.statusCode != 200 || data["success"] != true) {
        throw Exception(data["message"] ?? "Failed to submit customer");
      }
    } catch (e) {
      rethrow;
    }
  }
 
  Widget _bottomButtons(BuildContext context) {
    return ElevatedButton(
      onPressed: uploadedDocs >= mandatoryDocs
          ? () async {
              try {
                // setState(() => isApiLoading = true);
 
                final prefs = await SharedPreferences.getInstance();
                // final customerId = prefs.getInt("customerId");
 
                final customerId = await _loadCustomerId();
 
                // ✅ CALL SUBMIT API
                await submitCustomer(customerId);
 
                // ✅ MOVE DRAFT
                await DraftService.moveDraftToSubmitted(customerId);
 
                showTopToast(
                  context,
                  "Case Submitted Successfully",
                  success: true,
                );
 
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RmDashboard()),
                );
              } catch (e) {
                showTopToast(context, e.toString(), success: false);
              }
              //finally {
              //   setState(() => isApiLoading = false);
              // }
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 22, 61, 145),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: const Text(
        "Submit Case",
        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}
 
 