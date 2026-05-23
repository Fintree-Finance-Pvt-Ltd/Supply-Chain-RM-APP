 


 
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/auth_service.dart';
import 'package:supply_chain/core/services/cheque_ocr_service.dart';
 
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supply_chain/core/utils/toast_helper.dart';
import 'package:supply_chain/core/widgets/app_loader.dart';
 
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
 
  String accountType = "Savings";
    bool isDarkMode = false;
 
 
  bool bankSaved = false;
 
  bool loading = false;
   Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isDarkMode = prefs.getBool("isDarkMode") ?? false);
  }
 
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
        "name": nameController.text,
        "bankBranch": branchController.text,
        "bankType": accountType,
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
        setState(() {
          bankSaved = true;
        });
 
        showTopToast(
          context,
          "Bank details saved successfully",
          success: true,
          icon: Icons.account_balance,
        );
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
  // Future<void> startChequeOCR() async {
  //   final result = await FilePicker.platform.pickFiles(type: FileType.image);
 
  //   if (result == null) return;
 
  //   final file = result.files.first;
 
  //   try {
  //     setState(() {
  //       loading = true;
  //     });
 
  //     final ocr = await ChequeOcrService.scanCheque(file);
 
  //     if (ocr != null) {
  //       accountController.text = ocr.accountNumber ?? "";
 
  //       nameController.text = ocr.name ?? "";
 
  //       final ifsc = (ocr.ifscCode ?? "").toUpperCase().trim();
 
  //       ifscController.text = ifsc;
  //       bankController.text = ocr.bankName ?? "";
  //       branchController.text = ocr.branch ?? "";
 
  //       // 🔥 Trigger IFSC API automatically
  //       if (ifsc.length == 11) {
  //         await fetchBankDetails(ifsc);
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("OCR ERROR: $e");
 
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("OCR Failed: $e")));
  //   }
 
  //   setState(() {
  //     loading = false;
  //   });
  // }
 
 
Future<void> startChequeOCR() async {
  final result = await FilePicker.platform.pickFiles(type: FileType.image);
 
  if (result == null) return;
 
  final file = result.files.first;
 
  try {
    setState(() => loading = true);
 
    /// 🔥 OCR API CALL
    final ocr = await ChequeOcrService.scanCheque(file);
 
    if (ocr != null) {
      /// AUTO-FILL
      accountController.text = ocr.accountNumber ?? "";
      nameController.text = ocr.name ?? "";
 
      final ifsc = (ocr.ifscCode ?? "").toUpperCase().trim();
 
      ifscController.text = ifsc;
      bankController.text = ocr.bankName ?? "";
      branchController.text = ocr.branch ?? "";
 
      /// 🔥 AUTO IFSC FETCH
      if (ifsc.length == 11) {
        await fetchBankDetails(ifsc);
      }
 
      /// 🚀 NEW: AUTO UPLOAD DOCUMENT AFTER OCR
      await _uploadChequeDocument(file);
    }
  } catch (e) {
    debugPrint("OCR ERROR: $e");
 
    showTopToast(context, "OCR Failed: $e", success: false);
  } finally {
    setState(() => loading = false);
  }
}
 
 
 
Future<void> _uploadChequeDocument(PlatformFile file) async {
  try {
    final token = await AuthService().getToken();
 
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.uploadDocument),
    );
 
    /// ✅ HEADERS
    request.headers.addAll({
      "Authorization": "Bearer $token",
    });
 
    /// ✅ REQUIRED FIELDS
    request.fields['customerId'] = widget.customerId.toString();
    request.fields['documentType'] = "CANCELLED_CHEQUE";
    request.fields['applicantType'] = "COMPANY"; // 🔥 IMPORTANT FIX
    request.fields['applicantIndex'] = "0";
 
    /// OPTIONAL META (SAFE)
    request.fields['issueDate'] = '';
    request.fields['expiryDate'] = '';
    request.fields['remarks'] = '';
    request.fields['rmRemarks'] = '';
 
    /// ✅ FILE UPLOAD (WITH CONTENT TYPE)
    if (file.bytes != null) {
      final ext = file.extension?.toLowerCase();
 
      http.MediaType contentType;
 
      if (ext == 'jpg' || ext == 'jpeg') {
        contentType = MediaType('image', 'jpeg');
      } else if (ext == 'png') {
        contentType = MediaType('image', 'png');
      } else if (ext == 'pdf') {
        contentType = MediaType('application', 'pdf');
      } else {
        throw Exception("Invalid file type");
      }
 
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
          contentType: contentType,
        ),
      );
    } else if (file.path != null) {
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path!),
      );
    }
 
    /// 🚀 SEND REQUEST
    final res = await request.send();
    final response = await http.Response.fromStream(res);
 
    debugPrint("UPLOAD STATUS: ${response.statusCode}");
    debugPrint("UPLOAD BODY: ${response.body}");
 
    final data = jsonDecode(response.body);
 
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data["success"] == true) {
      showTopToast(context, "Cheque uploaded successfully", success: true);
    } else {
      throw Exception(data["message"] ?? "Upload failed");
    }
 
  } catch (e) {
    debugPrint("UPLOAD ERROR: $e");
    showTopToast(context, e.toString(), success: false);
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
    loadTheme();
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
        // color: Colors.white,
                color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF5F7FB),
 
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
                style:  TextStyle(
                  fontSize: 18,
                                    color: isDarkMode ? Colors.white : Colors.black,
 
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
            style:  TextStyle(   color: isDarkMode ? Colors.white : Colors.black,
fontSize: 14),
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
 
 @override
Widget build(BuildContext context) {
  return Scaffold(
     backgroundColor: isDarkMode
          ? const Color(0xFF0F172A)
          : const Color(0xFFF5F7FB),
 appBar: AppBar(
        backgroundColor: isDarkMode
            ? const Color(0xFF0F172A)
            : const Color(0xFFF4F6FA),
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        title: Text(
          "Bank Details",
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
    body: Stack(
      children: [
 
        /// ================= MAIN UI =================
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
 
                /// TITLE
                 Text(
                  "Bank Details & Cheque OCR",
                  style: TextStyle(fontSize: 18,
                                    color: isDarkMode ? Colors.white : Colors.black,
 fontWeight: FontWeight.bold),
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
                       Text(
                        "Cheque Capture",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                                                  color: isDarkMode ? Colors.white : Colors.black,
 
                          fontSize: 16,
                        ),
                      ),
 
                      const SizedBox(height: 4),
 
                       Text(
                        "Capture cheque photo to auto-fill bank details",
                        style: TextStyle(fontSize: 12,
                                                color: isDarkMode ? Colors.white : Colors.black
),
                      ),
 
                      const SizedBox(height: 12),
 
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: startChequeOCR,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Upload cheque"),
                        ),
                      ),
                    ],
                  ),
                ),
 
                const SizedBox(height: 25),
 
                /// ACCOUNT NUMBER
                TextField(
                                     style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                  controller: accountController,
                  decoration: InputDecoration(
                    labelText: "Account Number",
                    labelStyle: TextStyle(
                    color: isDarkMode ? Colors.white : const Color(0xFF1F3C88),
                  ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
 
                const SizedBox(height: 16),
 
                /// IFSC
                TextField(
                   style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
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
                     labelStyle: TextStyle(
                    color: isDarkMode ? Colors.white : const Color(0xFF1F3C88),
                  ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
 
                const SizedBox(height: 16),
 
                /// BANK NAME
                TextField(
                   style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                  controller: bankController,
                  decoration: InputDecoration(
                    labelText: "Bank Name",
                     labelStyle: TextStyle(
                    color: isDarkMode ? Colors.white : const Color(0xFF1F3C88),
                  ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
 
                const SizedBox(height: 16),
 
                /// NAME
                TextField(
                  style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                     labelStyle: TextStyle(
                    color: isDarkMode ? Colors.white : const Color(0xFF1F3C88),
                  ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
 
                const SizedBox(height: 16),
 
                /// BRANCH
                TextField(
                   style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                  controller: branchController,
                  decoration: InputDecoration(
                    labelText: "Branch",
                     labelStyle: TextStyle(
                    color: isDarkMode ? Colors.white : const Color(0xFF1F3C88),
                  ),
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
                     labelStyle: TextStyle(
                    color: isDarkMode ? Colors.white : const Color(0xFF1F3C88),
                  ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                   style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
 
                dropdownColor: isDarkMode
                    ? const Color(0xFF1E293B)
                    : Colors.white,
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
                            Navigator.pop(context, true);
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text("Continue"),
                        )
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 22, 61, 145),
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
 
                const SizedBox(height: 30),
 
                /// E-NACH
                actionCard(
                  title: "E-NACH Mandate",
                  description: "Setup automated repayment from customer's bank account.",
                  buttonText: "Trigger e-NACH",
                  onPressed: () {},
                ),
 
                /// E-SIGN
                actionCard(
                  title: "E-Sign Agreement",
                  description: "Digitally sign the loan agreement with the customer.",
                  buttonText: "Trigger e-Sign",
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
 
        /// ================= FULL SCREEN LOADER =================
        if (loading)
          Container(
            color: Colors.black.withOpacity(0.25),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppLoader(size: 70),
 
                  SizedBox(height: 16),
 
                  Text(
                    "Scanning Cheque...",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
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
