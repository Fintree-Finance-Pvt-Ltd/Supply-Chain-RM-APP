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

  List<Map<String, dynamic>> invoices = []; 
    // List of LANs and suppliers
  List<Map<String, dynamic>> loanAccounts = []; // <-- define this
  List<Map<String, dynamic>> suppliers = [];// <-- store all invoices



  final TextEditingController roiController =
    TextEditingController();

final TextEditingController penalController =
    TextEditingController();

final TextEditingController serviceFeeController =
    TextEditingController();

  List<Map<String, dynamic>> lanList = [];

double? sanctionAmount;
double? utilizedAmount;
double? unutilizedAmount;
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
    loadInvoices();
    
      
  if (lanList.isNotEmpty) {

  sanctionAmount =
      double.tryParse(
        lanList[0]["sanctionAmount"]
            .toString(),
      ) ??
      0;

  utilizedAmount =
      double.tryParse(
        lanList[0]["utilizedAmount"]
            .toString(),
      ) ??
      0;

  unutilizedAmount =
      double.tryParse(
        lanList[0]["unutilizedAmount"]
            .toString(),
      ) ??
      0;

  tenureDays.text =
      lanList[0]["tenure"]
          ?.toString() ??
      "90";

  roiController.text =
      lanList[0]["interestRate"]
          ?.toString() ??
      "";

  penalController.text =
      lanList[0]["penalCharges"]
          ?.toString() ??
      "";

  serviceFeeController.text =
      lanList[0]["processingFees"]
          ?.toString() ??
      "";
}

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

Future<void> loadInvoices() async {
  try {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse("${ApiEndpoints.baseUrl}/workflows/invoices/dashboard/rm"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Flatten data to a list of Map<String, dynamic>
      final fetchedInvoices = List<Map<String, dynamic>>.from(
        data["data"]["invoices"] ?? [],
      );

      setState(() {
        invoices = fetchedInvoices;
      });

      print("Invoices loaded: ${invoices.length}");
    } else {
      print("Failed to fetch invoices: ${response.statusCode}");
      setState(() => invoices = []);
    }
  } catch (e) {
    print("Error fetching invoices: $e");
    setState(() => invoices = []);
  }
}


/// Call this whenever disbursementAmount changes
void validateAndSetDisbursement(String value) {
  final enteredAmount = int.tryParse(value) ?? 0;

  // Total allowed limit
  final availableLimit = unutilizedAmount ?? sanctionAmount ?? 0;

  // Calculate existing disbursement for the same invoice
  final existingDisbursement = invoices
      .where((inv) =>
          (inv["invoiceNumber"] == invoiceNumber.text ||
              (inv["invoiceNumber"]?.toString().startsWith(
                      "${invoiceNumber.text}_") ??
                  false)) &&
          (inv["supplierId"] ?? inv["supplier"]?["id"]) ==
              selectedSupplier?["id"] &&
          inv["invoiceDate"]?.toString().split("T")[0] == invoiceDate.text &&
          inv["loanAccountId"] == selectedLanId)
      .fold<double>(
          0, (sum, inv) => sum + (double.tryParse(inv["disbursementAmount"]?.toString() ?? "0") ?? 0));

  final invoiceAmt = double.tryParse(invoiceAmount.text) ?? 0;

  final totalDisbursement = existingDisbursement + enteredAmount;

  // ❌ invoice amount exceeded
  if (totalDisbursement > invoiceAmt) {
    showTopToast(
      context,
      "Total disbursement cannot exceed invoice amount.\n"
      "Already Utilized: ₹${existingDisbursement.toStringAsFixed(2)}\n"
      "Invoice Amount: ₹${invoiceAmt.toStringAsFixed(2)}\n"
      "Remaining Allowed: ₹${(invoiceAmt - existingDisbursement).toStringAsFixed(2)}",
      success: false,
    );
    return;
  }

  // ❌ validation against unutilized limit
  if (enteredAmount > availableLimit) {
    showTopToast(
      context,
      "Disbursement amount cannot exceed unutilized limit of ₹${availableLimit.toStringAsFixed(2)}",
      success: false,
    );
    return;
  }

  // ✅ If valid, update controller
  setState(() {
    disbursementAmount.text = enteredAmount.toStringAsFixed(2);
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

/// Fetch rates for selected LAN and supplier
Future<void> fetchRates({required int lanId}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse(
        "${ApiEndpoints.baseUrl}/workflows/invoices/customers/${widget.customerId}/lans/$lanId/rates",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["success"] == true && data["data"] != null) {
        final rateData = data["data"];

        setState(() {
          roiController.text = rateData["roi"] ?? "";
          penalController.text = rateData["penalCharges"] ?? "";
          serviceFeeController.text = rateData["serviceFee"] ?? "";
          sanctionAmount =
              double.tryParse(rateData["sanctionAmount"] ?? "0") ?? 0;
          utilizedAmount =
              double.tryParse(rateData["utilizedLimit"]?.toString() ?? "0") ?? 0;
          unutilizedAmount =
              double.tryParse(rateData["unutilizedLimit"]?.toString() ?? "0") ?? 0;
        });
      }
    } else {
      showTopToast(
          context, "Rate API error: ${response.statusCode}", success: false);
    }
  } catch (e) {
    print("Rate API error: $e");
    showTopToast(context, "Error fetching rate details", success: false);
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


/// Fetch invoice amount locally based on LAN, Supplier, Number, and Date
/// Fetch invoice amount locally based on LAN, Supplier, Number, and Date
void fetchInvoiceAmountFromLocal({
  required String invoiceNumber,
  required String invoiceDate,
  required int lanId,
  required int supplierId,
}) {
  if (invoiceNumber.isEmpty || invoiceDate.isEmpty || lanId == 0 || supplierId == 0) {
    setState(() => invoiceAmount.text = "");
    return;
  }

  if (invoices.isEmpty) {
    print("Invoices list is empty. Fetch invoices first.");
    return;
  }

  final existingInvoice = invoices.firstWhere(
    (inv) =>
        inv["invoiceNumber"]?.toString().toLowerCase().trim() == invoiceNumber.toLowerCase().trim() &&
        inv["invoiceDate"]?.toString().split("T")[0] == invoiceDate &&
        inv["loanAccountId"] == lanId &&
        (inv["supplierId"] ?? inv["supplier"]?["id"]) == supplierId,
    orElse: () => {},
  );

  setState(() {
    invoiceAmount.text = existingInvoice["invoiceAmount"]?.toString() ?? "";
  });

  if (existingInvoice.isNotEmpty) {
    showTopToast(context, "Invoice amount loaded", success: true);
  }
}

  Future<void> fetchCustomerName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse(
          "${ApiEndpoints.baseUrl}/customers/${widget.customerId}",
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

      // onChanged: (value) async{
      //   setState(() {
      //     selectedLanId = value;
      //   });
      //     await fetchRates();
      // },
onChanged: (value) async {
  if (value == null) return;

  setState(() => selectedLanId = value);

  // fetch rates immediately for selected LAN
  await fetchRates(lanId: value);
}
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

            Text("Account: ${bank["bankAccountNumber"] ?? ""}",
            style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDarkMode ? Colors.white : Colors.black,
                    )
            ),
            Text("IFSC: ${bank["ifscCode"] ?? ""}",
             style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDarkMode ? Colors.white : Colors.black,
                    )),
            Text("Holder: ${bank["accountHolderName"] ?? ""}",
             style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDarkMode ? Colors.white : Colors.black,
                    )),
          ],
        ),
      ),
    );
  }

  Widget _limitItem(
  String title,
  String value,
) {
  return Column(
    children: [

      Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),

      const SizedBox(height: 6),

      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    ],
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
                  modernCard(
  title: "Customer Invoice",
  child: Column(
    children: [

      /// CUSTOMER NAME
      inputField(
        label: "Customer Name",
        controller: TextEditingController(
          text: customerName ?? "",
        ),
        icon: Icons.person,
        readOnly: true,
      ),

      /// LAN DROPDOWN
      lanExists
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
              margin: const EdgeInsets.only(
                bottom: 14,
              ),

              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(14),

                border: Border.all(
                  color:
                      Colors.grey.shade300,
                ),

                color:
                    isDarkMode
                        ? const Color(
                            0xFF1E293B,
                          )
                        : Colors
                            .grey
                            .shade100,
              ),

              child: Row(
                children: [

                  Icon(
                    Icons.account_tree,
                    color:
                        isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      existinglanName ?? "",

                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,

                        fontSize: 15,

                        color:
                            isDarkMode
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : lanDropdown(),

      /// LAN DROPDOWN
      supplierExists
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
              margin: const EdgeInsets.only(
                bottom: 14,
              ),

              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(14),

                border: Border.all(
                  color:
                      Colors.grey.shade300,
                ),

                color:
                    isDarkMode
                        ? const Color(
                            0xFF1E293B,
                          )
                        : Colors
                            .grey
                            .shade100,
              ),

              child: Row(
                children: [

                  Icon(
                    Icons.account_tree,
                    color:
                        isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      existingSupplierName ?? "",

                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,

                        fontSize: 15,

                        color:
                            isDarkMode
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : supplierDropdown(),
      /// INVOICE NUMBER
      // inputField(
      //   label: "Invoice Number",
      //   controller: invoiceNumber,
      //   icon: Icons.receipt_long,
      // ),

// Invoice Number TextField
// Invoice Number TextField

// Invoice Number Input
TextField(
  controller: invoiceNumber,
  decoration: InputDecoration(
    labelText: "Invoice Number",
    prefixIcon: Icon(Icons.receipt_long),
  ),
  onChanged: (_) {
    if (selectedLanId != null && selectedSupplier?['id'] != null) {
      fetchInvoiceAmountFromLocal(
        invoiceNumber: invoiceNumber.text,
        invoiceDate: invoiceDate.text,
        lanId: selectedLanId!,
        supplierId: selectedSupplier!['id'],
      );
    }
  },
),

// Invoice Date Input
TextField(
  controller: invoiceDate,
  decoration: InputDecoration(
    labelText: "Invoice Date",
    prefixIcon: Icon(Icons.calendar_today),
  ),
  readOnly: true,
  onTap: () async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      invoiceDate.text = picked.toString().split(" ")[0];
      if (selectedLanId != null && selectedSupplier?['id'] != null) {
        fetchInvoiceAmountFromLocal(
          invoiceNumber: invoiceNumber.text,
          invoiceDate: invoiceDate.text,
          lanId: selectedLanId!,
          supplierId: selectedSupplier!['id'],
        );
      }
    }
  },
),

// LAN Dropdown

// Supplier Dropdown

// Invoice Amount (read-only)


      /// INVOICE DATE
      // inputField(
      //   label: "Invoice Date",
      //   controller: invoiceDate,
      //   icon: Icons.calendar_today,
      //   readOnly: true,
      //   onTap: pickDate,
      // ),

      /// INVOICE AMOUNT
      // inputField(
      //   label: "Invoice Amount",
      //   controller: invoiceAmount,
      //   icon: Icons.currency_rupee,
      // ),
TextField(
  controller: invoiceAmount,
  decoration: InputDecoration(
    labelText: "Invoice Amount",
    prefixIcon: Icon(Icons.currency_rupee),
  ),
  keyboardType: TextInputType.number,
),

            // inputField(
            //   label: "disbursement amount",
            //   controller: disbursementAmount,
            //   icon: Icons.price_change,
            // ),
//          TextField(
//   controller: disbursementAmount,
//   keyboardType: TextInputType.number,
//   decoration: InputDecoration(
//     labelText: "Disbursement Amount",
//     prefixIcon: Icon(Icons.attach_money),
//     border: OutlineInputBorder(),
//   ),
//   onChanged: validateAndSetDisbursement,
// ),
      
  //     TextField(
  // controller: disbursementAmount,
  // keyboardType: TextInputType.number,
  // decoration: InputDecoration(
  //   labelText: "Disbursement Amount",
  //   prefixIcon: Icon(Icons.attach_money),
  //   border: OutlineInputBorder(),
  // ),
  // onChanged: (value) {
  //   final enteredAmount = double.tryParse(value) ?? 0;

  //   final availableLimit = unutilizedAmount ?? sanctionAmount ?? 0;

  //   final existingDisbursement = invoices
  //       .where((inv) =>
  //           (inv["invoiceNumber"] == invoiceNumber.text ||
  //               (inv["invoiceNumber"]?.toString().startsWith("${invoiceNumber.text}_") ?? false)) &&
  //           (inv["supplierId"] ?? inv["supplier"]?["id"]) == selectedSupplier?["id"] &&
  //           inv["invoiceDate"]?.toString().split("T")[0] == invoiceDate.text &&
  //           inv["loanAccountId"] == selectedLanId)
  //       .fold<double>(
  //           0,
  //           (sum, inv) =>
  //               sum + (double.tryParse(inv["disbursementAmount"]?.toString() ?? "0") ?? 0));

  //   final invoiceAmt = double.tryParse(invoiceAmount.text) ?? 0;

  //   final totalDisbursement = existingDisbursement + enteredAmount;

  //   // Show validation toast but do NOT modify controller
  //   if (totalDisbursement > invoiceAmt) {
  //     showTopToast(
  //       context,
  //       "Total disbursement cannot exceed invoice amount.\n"
  //       "Already Utilized: ₹${existingDisbursement.toStringAsFixed(2)}\n"
  //       "Invoice Amount: ₹${invoiceAmt.toStringAsFixed(2)}\n"
  //       "Remaining Allowed: ₹${(invoiceAmt - existingDisbursement).toStringAsFixed(2)}",
  //       success: false,
  //     );
  //     return;
  //   }

  //   if (enteredAmount > availableLimit) {
  //     showTopToast(
  //       context,
  //       "Disbursement amount cannot exceed unutilized limit of ₹${availableLimit.toStringAsFixed(2)}",
  //       success: false,
  //     );
  //     return;
  //   }

  //   // ✅ Valid input, just allow typing — don't set controller text
  // },
// ), 
TextField(
  controller: disbursementAmount,
  keyboardType: TextInputType.number,
  decoration: InputDecoration(
    labelText: "Disbursement Amount",
    prefixIcon: Icon(Icons.attach_money),
    border: OutlineInputBorder(),
  ),
  onChanged: (value) {
    double enteredAmount = double.tryParse(value) ?? 0;

    // Available/unutilized limit
    final double availableLimit = (unutilizedAmount ?? sanctionAmount ?? 0);

    // Existing utilized disbursement for same invoice
    final double existingDisbursement = invoices
        .where((inv) =>
            (inv["invoiceNumber"] == invoiceNumber.text ||
                (inv["invoiceNumber"]?.toString().startsWith("${invoiceNumber.text}_") ?? false)) &&
            (inv["supplierId"] ?? inv["supplier"]?["id"]) == selectedSupplier?["id"] &&
            inv["invoiceDate"]?.toString().split("T")[0] == invoiceDate.text &&
            inv["loanAccountId"] == selectedLanId)
        .fold<double>(
            0,
            (sum, inv) =>
                sum + (double.tryParse(inv["disbursementAmount"]?.toString() ?? "0") ?? 0));

    final double invoiceAmt = double.tryParse(invoiceAmount.text) ?? 0;
    final double totalDisbursement = existingDisbursement + enteredAmount;

    // ❌ Invoice amount exceeded — clamp and show toast
    if (totalDisbursement > invoiceAmt) {
      enteredAmount = invoiceAmt - existingDisbursement;
      if (enteredAmount < 0) enteredAmount = 0;

      setState(() {
        disbursementAmount.text = enteredAmount.toStringAsFixed(2);
        disbursementAmount.selection = TextSelection.fromPosition(
          TextPosition(offset: disbursementAmount.text.length),
        );
      });

      showTopToast(
        context,
        "Total disbursement cannot exceed invoice amount.\n"
        "Already Utilized: ₹${existingDisbursement.toStringAsFixed(2)}\n"
        "Invoice Amount: ₹${invoiceAmt.toStringAsFixed(2)}\n"
        "Remaining Allowed: ₹${(invoiceAmt - existingDisbursement).toStringAsFixed(2)}",
        success: false,
      );
      return;
    }

    // ❌ Available/unutilized limit exceeded — clamp and show toast
    if (enteredAmount > availableLimit) {
      enteredAmount = availableLimit;

      setState(() {
        disbursementAmount.text = enteredAmount.toStringAsFixed(2);
        disbursementAmount.selection = TextSelection.fromPosition(
          TextPosition(offset: disbursementAmount.text.length),
        );
      });

      showTopToast(
        context,
        "Disbursement amount cannot exceed unutilized limit of ₹${availableLimit.toStringAsFixed(2)}",
        success: false,
      );
      return;
    }

    // ✅ Valid input — update controller
    setState(() {
      disbursementAmount.text = enteredAmount.toStringAsFixed(2);
      disbursementAmount.selection = TextSelection.fromPosition(
        TextPosition(offset: disbursementAmount.text.length),
      );
    });
  },
),  
      /// TENURE + ROI
      Row(
        children: [

          Expanded(
            child: inputField(
              label: "Tenure Days",
              controller: tenureDays,
              icon: Icons.schedule,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: inputField(
              label: "ROI %",
              controller: roiController,
              icon: Icons.percent,
            ),
          ),
           
        ],
      ),

      /// PENAL + PROCESSING
      Row(
        children: [

          Expanded(
            child: inputField(
              label: "Penal Charges",
              controller: penalController,
              icon: Icons.money_off,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: inputField(
              label: "Processing Fee",
              controller:
                  serviceFeeController,
              icon: Icons.wallet,
            ),
          ),
        ],
      ),

      /// LIMIT CARD
      if (sanctionAmount != null)
        Container(
          width: double.infinity,

          margin: const EdgeInsets.only(
            top: 10,
          ),

          padding: const EdgeInsets.all(
            16,
          ),

          decoration: BoxDecoration(
            color:AppColors.darkBlue,
            // gradient:
            //     const LinearGradient(
            //   colors: [
               
            //     AppColors.darkBlue,
            //   ],
            // ),

            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),

          child: Column(
            children: [

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [

                  _limitItem(
                    "Sanction",
                    "₹${sanctionAmount ?? 0}",
                  ),

                  _limitItem(
                    "Utilized",
                    "₹${utilizedAmount ?? 0}",
                  ),

                  _limitItem(
                    "Available",
                    "₹${unutilizedAmount ?? 0}",
                  ),
                ],
              ),

              const SizedBox(height: 16),

              LinearProgressIndicator(
                value:
                    sanctionAmount == 0
                        ? 0
                        : (utilizedAmount ??
                                0) /
                            (sanctionAmount ??
                                1),

                backgroundColor:
                    Colors.white24,

                valueColor:
                    const AlwaysStoppedAnimation(
                  Colors.white,
                ),

                minHeight: 8,

                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
            ],
          ),
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
                  // supplierExists
                  //     ? Container(
                  //         width: double.infinity,
                  //         padding: const EdgeInsets.symmetric(
                  //           horizontal: 12,
                  //           vertical: 14,
                  //         ),
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(12),
                  //           border: Border.all(color: Colors.grey.shade300),
                  //           color: isDarkMode
                  //               ? const Color(0xFF1E293B)
                  //               : Colors.grey.shade100,
                  //         ),
                  //         child: Text(
                  //           existingSupplierName ?? "",
                  //           style: TextStyle(
                  //             fontWeight: FontWeight.w600,
                  //             fontSize: 15,
                  //             color: isDarkMode ? Colors.white : Colors.black,
                  //           ),
                  //         ),
                  //       )
                  //     : supplierDropdown(),

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
                  // modernCard(
                  //   title: "Disbursement Details",
                  //   child: inputField(
                  //     label: "disbursement amount",
                  //     controller: disbursementAmount,
                  //     icon: Icons.price_change,
                  //   ),
                  // ),

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
