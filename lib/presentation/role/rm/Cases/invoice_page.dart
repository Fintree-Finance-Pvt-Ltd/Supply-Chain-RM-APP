import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/auth_service.dart';
import 'package:supply_chain/core/theme/app_colors.dart';
import 'package:supply_chain/core/utils/toast_helper.dart';
import 'package:supply_chain/presentation/role/rm/dashboard_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class InvoicePage extends StatefulWidget {
  final int customerId;
  final bool loadExistingInvoice;
  final int? invoiceId;

  const InvoicePage({
    super.key,
    required this.customerId,
    this.loadExistingInvoice = false,
    this.invoiceId, //
  });

  // const InvoicePage({super.key, required this.customerId});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final TextEditingController partnerLoanId = TextEditingController();
  final TextEditingController lan = TextEditingController();
  final TextEditingController invoiceDate = TextEditingController();
  final TextEditingController invoiceAmount = TextEditingController();
  final TextEditingController tenureDays = TextEditingController();
  TextEditingController invoiceNumber = TextEditingController();
  final TextEditingController disbursementAmount = TextEditingController();
  final TextEditingController supplierName = TextEditingController();

  final TextEditingController bankAccount = TextEditingController();
  final TextEditingController ifsc = TextEditingController();
  final TextEditingController bankName = TextEditingController();
  final TextEditingController accountHolder = TextEditingController();
  String? customerName;

  List<Map<String, dynamic>> lanList = [];

  // File? invoiceFile;
  PlatformFile? invoiceFile;
  bool isInvoiceUploaded = false;
  String? invoiceFileName;
  String? invoiceFileUrl; // optional if backend returns URL

  int? selectedLanId;
  String? selectedLanNumber;
  // List<String> lanList = [];
  String? selectedLan;
  bool loadingLan = false;

  List supplierBanks = [];
  Map? selectedBank;
  bool supplierExists = false;
  String? existingSupplierName;

  bool lanExists = false;
  String? existinglanName;
  // int? selectedLan;

  bool isDarkMode = false;

  List<Map<String, dynamic>> suppliers = [];
  Map<String, dynamic>? selectedSupplier;
  final ScrollController _scrollController = ScrollController();
  double scrollOffset = 0;

  @override
  void initState() {
    super.initState();

    loadTheme();

    loadSuppliers();
    fetchCustomerName();
    loadLan();

    tenureDays.text = "90 Days"; // default value
    _scrollController.addListener(() {
      setState(() {
        scrollOffset = _scrollController.offset;
      });
    });
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode") ?? false;
    });
  }

  Future<void> loadExistingInvoiceFromRM() async {
    try {
      final token = await AuthService().getToken();

      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/workflows/invoices/dashboard/rm"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(response.body);

      print("RM Invoice Response: $data");

      if (data["success"] == true &&
          data["data"] != null &&
          data["data"]["invoices"] != null) {
        final invoices = data["data"]["invoices"] as List;

        Map<String, dynamic>? invoice;

        for (var item in invoices) {
          if (item["customerId"] == widget.customerId) {
            invoice = item;

            if (item["supplier"] != null) break;
          }
        }
        invoice ??= invoices
            .where((item) => item["customerId"] == widget.customerId)
            .cast<Map<String, dynamic>?>()
            .firstOrNull;
        //         invoice ??= invoices.firstWhere(
        //   (item) => item["customerId"] == widget.customerId,
        //   orElse: () => null,
        // );

        if (invoice != null && invoice.isNotEmpty) {
          setState(() {
            invoiceNumber.text = invoice!["invoiceNumber"] ?? "";

            invoiceDate.text = invoice["invoiceDate"] ?? "";

            invoiceAmount.text = invoice["invoiceAmount"]?.toString() ?? "";

            tenureDays.text = "90 Days";

            disbursementAmount.text =
                invoice["disbursementAmount"]?.toString() ?? "";

            /// LAN
            if (invoice["loanAccount"] != null) {
              lanExists = true;

              existinglanName = invoice["loanAccount"]["lanId"];

              selectedLan = invoice["loanAccount"]["id"];
            }

            if (invoice["supplier"] != null &&
                invoice["supplier"]["supplierName"] != null) {
              supplierExists = true;

              existingSupplierName = invoice["supplier"]["supplierName"];

              selectedSupplier = invoice["supplier"];

              supplierName.text = invoice["supplier"]["supplierName"];

              loadSupplierBanks(invoice["supplier"]["id"]);
            }
          });
        } else {
          print("No invoice found for this customer");
        }
      }
    } catch (e) {
      print("Load RM invoice error: $e");
    }
  }

  Future<void> viewDocument(BuildContext context, String? url) async {
    print("Opening document: $url");

    if (url == null || url.trim().isEmpty) {
      showTopToast(context, "Document URL not found", success: false);
      return;
    }

    try {
      final uri = Uri.parse(url);

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      print("Launch result = $launched");

      if (!launched) {
        showTopToast(context, "Unable to open document", success: false);
      }
    } catch (e) {
      print("VIEW ERROR: $e");
      showTopToast(context, "Invalid document URL", success: false);
    }
  }

  Future<void> pickInvoiceFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result == null) return;

    final PlatformFile file = result.files.single;

    final response = await _uploadInvoiceDocument(file);

    print("Upload response: $response");

    if (response["success"] == true) {
      setState(() {
        invoiceFile = file;

        invoiceFileUrl =
            "${ApiEndpoints.fileBaseUrl}/${response["data"]["filePath"]}";

        print("SET invoiceFileUrl = $invoiceFileUrl");

        isInvoiceUploaded = true;
      });

      showTopToast(context, "Invoice uploaded successfully", success: true);
    } else {
      showTopToast(context, response["message"], success: false);
    }
  }

  Future<Map<String, dynamic>> _uploadInvoiceDocument(PlatformFile file) async {
    try {
      final token = await AuthService().getToken();

      var request = http.MultipartRequest(
        "POST",
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.uploadDocument),
      );

      request.headers.addAll({"Authorization": "Bearer $token"});

      request.fields["customerId"] = widget.customerId.toString();
      request.fields["documentType"] = "INVOICE";

      final ext = file.extension?.toLowerCase() ?? "";

      MediaType contentType;

      if (ext == "pdf") {
        contentType = MediaType("application", "pdf");
      } else if (ext == "jpg" || ext == "jpeg") {
        contentType = MediaType("image", "jpeg");
      } else if (ext == "png") {
        contentType = MediaType("image", "png");
      } else {
        throw Exception("Only PDF and image files allowed");
      }

      if (file.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            "file",
            file.bytes!,
            filename: file.name,
            contentType: contentType,
          ),
        );
      } else if (file.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "file",
            file.path!,
            contentType: contentType,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      print("UPLOAD RESPONSE = $data");

      return data; // ✅ IMPORTANT
    } catch (e) {
      return {"success": false, "message": "Upload error: $e"};
    }
  }

  /// DATE PICKER
  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      invoiceDate.text = picked.toString().split(" ")[0];
    }
  }

  Future<void> loadLan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse(
          "${ApiEndpoints.baseUrl}/workflows/invoices/customers/${widget.customerId}/lans",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          lanList = List<Map<String, dynamic>>.from(data["data"]);
        });
      }
    } catch (e) {
      print("LAN API Error: $e");
    }
  }

  Future<void> loadSuppliers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse(
          "${ApiEndpoints.baseUrl}/workflows/invoices/customers/${widget.customerId}/suppliers",
          // "${ApiEndpoints.baseUrl}/workflows/suppliers/customer/${widget.customerId}/all",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          suppliers = List<Map<String, dynamic>>.from(data["data"]);
        });
      }
    } catch (e) {
      print("Supplier API Error: $e");
    }
  }

  Future<void> createInvoice() async {
    print("Create Invoice API called");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    Map payload = {
      "customerId": widget.customerId,
      "loanAccountId": selectedLanId,
      // "supplierId": selectedSupplier,
      "supplierId": selectedSupplier!["id"], // ✅ only supplier id

      "invoiceNumber": invoiceNumber.text,
      "invoiceDate": invoiceDate.text,
      "invoiceAmount": invoiceAmount.text,
      "disbursementAmount": disbursementAmount.text,
    };

    final response = await http.post(
      Uri.parse("${ApiEndpoints.baseUrl}/workflows/invoices/create"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );
    print("Create API response: ${response.body}");

    final data = jsonDecode(response.body);

    if (data["success"] == true) {
      print("Create API response: ${response.body}");
      int invoiceId = data["data"]["workflow"]["invoiceId"];

      /// invoice created → now submit case
      await submitCase(invoiceId);
    } else {
      print("Invoice Created Successfully");

      showTopToast(context, data["message"], success: false);
    }
  }

  Future<void> submitCase(int invoiceId) async {
    print("Submit Case API called");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("${ApiEndpoints.baseUrl}/workflows/invoices/$invoiceId/submit"),

      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({}), // 👈 send empty payload
    );
    print("Submit API response: ${response.body}");

    final data = jsonDecode(response.body);

    if (data["success"] == true) {
      showTopToast(context, "Case submitted successfully");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RmDashboard()),
        (route) => false,
      );
    } else {
      print("Submit API response: ${response.body}");

      showTopToast(context, data["message"], success: false);
    }
  }

  Future<void> loadSupplierBanks(int supplierId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse(
          "${ApiEndpoints.baseUrl}/workflows/suppliers/$supplierId/details",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final bank = data["data"]?["supplier"]?["bankDetail"];

        setState(() {
          supplierBanks = bank != null ? [bank] : [];
        });
      } else {
        print("Failed to load banks");
      }
    } catch (e) {
      print("API Error: $e");
    }
  }

  Future<void> fetchCustomerName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse(
          "https://supplychain-prod.fintreelms.com/api/customers/${widget.customerId}",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        setState(() {
          customerName = data["data"]["name"];
        });
      }
    } catch (e) {
      print("Customer fetch error: $e");
    }
  }

  Widget inputField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.white60 : Colors.grey,
          ),
          prefixIcon: icon != null
              ? Icon(icon, color: isDarkMode ? Colors.white70 : Colors.black)
              : null,
          filled: true,
          fillColor: isDarkMode
              ? const Color(0xFF1E293B)
              : const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget modernCard({required String title, required Widget child}) {
    /// scale reduces when scrolling
    double scale = 1 - (scrollOffset / 800);
    if (scale < 0.92) scale = 0.92;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 20),
      transform: Matrix4.identity()..scale(scale),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : .05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.darkBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(width: 10),

              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          child,
        ],
      ),
    );
  }

 Widget lanDropdown() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DropdownButtonFormField<int>(
      initialValue: selectedLanId,

      hint: Text(
        "Select LAN",
        style: TextStyle(
          color: isDarkMode ? Colors.white60 : Colors.grey,
        ),
      ),

      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.account_tree,
          color: isDarkMode ? Colors.white70 : Colors.black,
        ),

        filled: true,
        fillColor:
            isDarkMode ? const Color(0xFF1E293B) : Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        /// 🔥 optional premium border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white10 : Colors.grey.shade300,
          ),
        ),
      ),

      /// TEXT COLOR
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
      ),

      /// DROPDOWN POPUP COLOR
      dropdownColor:
          isDarkMode ? const Color(0xFF1E293B) : Colors.white,

      items: lanList.map<DropdownMenuItem<int>>((lan) {
        return DropdownMenuItem<int>(
          value: lan["id"],
          child: Text(
            lan["lanId"],
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        );
      }).toList(),

      onChanged: (value) {
        setState(() {
          selectedLanId = value;
        });
      },
    ),
  );
}

  Widget supplierDropdown() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DropdownButtonFormField<Map<String, dynamic>>(
      initialValue: selectedSupplier,
      hint: Text(
        "Select Supplier",
        style: TextStyle(
          color: isDarkMode ? Colors.white60 : Colors.grey,
        ),
      ),

      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.store,
          color: isDarkMode ? Colors.white70 : Colors.black,
        ),
        filled: true,
        fillColor:
            isDarkMode ? const Color(0xFF1E293B) : Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),

      /// 🔥 IMPORTANT (text color inside field)
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
      ),

      /// 🔥 IMPORTANT (dropdown popup color)
      dropdownColor:
          isDarkMode ? const Color(0xFF1E293B) : Colors.white,

      items: suppliers.map<DropdownMenuItem<Map<String, dynamic>>>(
        (supplier) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: supplier,
            child: Text(
              supplier["supplierName"] ?? "",
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          );
        },
      ).toList(),

      onChanged: (value) {
        setState(() {
          selectedSupplier = value;
          supplierName.text = value?["supplierName"] ?? "";
        });

        if (value != null) {
          loadSupplierBanks(value["id"]);
        }
      },
    ),
  );
}

  Widget bankCard(Map bank) {
    bool isSelected = selectedBank == bank;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBank = bank;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode
                    ? Colors.blue.withOpacity(0.2)
                    : const Color(0xFFE8F0FE))
              : (isDarkMode ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.darkBlue : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance, color: AppColors.darkBlue),
                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    bank["bank_name"] ?? "",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),

                if (isSelected)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),

            const SizedBox(height: 10),

            Text("Account: ${bank["bankAccountNumber"] ?? ""}"),
            Text("IFSC: ${bank["ifscCode"] ?? ""}"),
            Text("Holder: ${bank["accountHolderName"] ?? ""}"),
          ],
        ),
      ),
    );
  }

  /// BUILD PAGE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0F172A)
          : const Color(0xFFF4F6FA),
      body: Column(
        children: [
          /// MODERN HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(16, 42, 16, 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.darkBlue, AppColors.darkBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TOP ROW (Back + Welcome)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Text(
                      "Welcome RM 👋",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                /// TITLE
                const Text(
                  "Create Invoice",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                /// CUSTOMER BADGE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 16,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        "Customer ID: ${widget.customerId}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isDarkMode ? Colors.white : const Color.fromARGB(255, 250, 253, 254),
                        ),
                      ),

                      const Spacer(),

                      const Icon(Icons.verified, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// CONTENT
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /// CUSTOMER CARD
                  modernCard(
                    title: "Customer Invoice",
                    child: Column(
                      children: [
                        inputField(
                          label: "Customer Name",
                          controller: TextEditingController(
                            text: customerName ?? "",
                          ),
                          icon: Icons.person,
                          readOnly: true,
                        ),
                        // lanDropdown(),
                        lanExists
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  color: isDarkMode
                                      ? const Color(0xFF1E293B)
                                      : Colors.grey.shade100,
                                ),
                                child: Text(
                                  existinglanName ?? "",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 5,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              )
                            : lanDropdown(),

                        inputField(
                          label: "Invoice Number",
                          controller: invoiceNumber,
                          icon: Icons.receipt_long,
                        ),
                        inputField(
                          label: "Invoice Date",
                          controller: invoiceDate,
                          icon: Icons.calendar_today,
                          readOnly: true,
                          onTap: pickDate,
                        ),

                        inputField(
                          label: "Invoice Amount",
                          controller: invoiceAmount,
                          icon: Icons.currency_rupee,
                        ),

                        inputField(
                          label: "Tenure Days",
                          controller: tenureDays,
                          icon: Icons.schedule,
                        ),
                      ],
                    ),
                  ),

                  Column(
                    children: [
                      /// Upload button (before upload)
                      if (!isInvoiceUploaded)
                        GestureDetector(
                          onTap: pickInvoiceFile,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF2563EB),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: isDarkMode
                                  ? Colors.blue.withOpacity(0.15)
                                  : const Color(0xFFEFF6FF),
                            ),
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.upload_file,
                                  color: Color(0xFF2563EB),
                                  size: 28,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Tap to Upload Invoice",
                                  style: TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      if (isInvoiceUploaded)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.insert_drive_file,
                                  color: Colors.green,
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                  child: Text(
                                    invoiceFile?.name ?? "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.visibility,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    print("VIEW BUTTON CLICKED");

                                    print("invoiceFileUrl = $invoiceFileUrl");

                                    if (invoiceFileUrl != null) {
                                      viewDocument(context, invoiceFileUrl);
                                    } else {
                                      print("URL is NULL");
                                    }
                                  },
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      invoiceFile = null;
                                      invoiceFileUrl = null;
                                      isInvoiceUploaded = false;
                                    });
                                  },
                                ),

                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// SUPPLIER CARD
                  // supplierDropdown(),
                  supplierExists
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            color: isDarkMode
                                ? const Color(0xFF1E293B)
                                : Colors.grey.shade100,
                          ),
                          child: Text(
                            existingSupplierName ?? "",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        )
                      : supplierDropdown(),

                  const SizedBox(height: 10),

                  /// BANK CARDS
                  if (supplierBanks.isNotEmpty)
                    modernCard(
                      title: "Select Supplier Bank",
                      child: Column(
                        children: supplierBanks
                            .map((bank) => bankCard(bank))
                            .toList(),
                      ),
                    ),

                  const SizedBox(height: 10),
                  modernCard(
                    title: "Disbursement Details",
                    child: inputField(
                      label: "disbursement amount",
                      controller: disbursementAmount,
                      icon: Icons.price_change,
                    ),
                  ),

                  /// SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                      ),
                      onPressed: createInvoice,

                      child: const Text(
                        "Submit Invoice",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
