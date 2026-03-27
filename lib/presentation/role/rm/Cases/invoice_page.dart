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
     final int? invoiceId; // ✅ optional (new)


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

  List<Map<String, dynamic>> suppliers = [];
  Map<String, dynamic>? selectedSupplier;
  final ScrollController _scrollController = ScrollController();
  double scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    
    // loadExistingInvoiceFromRM(); // load existing invoice if any
    loadSuppliers();
    fetchCustomerName();
    loadLan(); // 👈 fetch LAN list
// if (widget.loadExistingInvoice) {
//   if (widget.invoiceId != null) {
//     loadInvoiceById(widget.invoiceId!);
//   } else {
//     loadExistingInvoiceFromRM();
//   }
// }
    // fetchLanList();
    // 👈 fetch suppliers
    tenureDays.text = "90 Days"; // default value
    _scrollController.addListener(() {
      setState(() {
        scrollOffset = _scrollController.offset;
      });
    });
  }

// Future<void> loadInvoiceById(int invoiceId) async {
//   try {
//     final token = await AuthService().getToken();

//     final response = await http.get(
//       Uri.parse(
//         "${ApiEndpoints.baseUrl}/workflows/invoices/dashboard/rm",
//       ),
//       headers: {"Authorization": "Bearer $token"},
//     );

//     final data = jsonDecode(response.body);

//     if (data["success"] == true && data["data"] != null) {
//       final invoice = data["data"];

//       setState(() {
//         invoiceNumber.text = invoice["invoiceNumber"] ?? "";

//         invoiceDate.text = invoice["invoiceDate"] ?? "";

//         invoiceAmount.text =
//             invoice["invoiceAmount"]?.toString() ?? "";

//         disbursementAmount.text =
//             invoice["disbursementAmount"]?.toString() ?? "";

//         if (invoice["loanAccount"] != null) {
//           lanExists = true;
//           existinglanName =
//               invoice["loanAccount"]["lanId"];
//           selectedLan =
//               invoice["loanAccount"]["id"];
//         }

//         if (invoice["supplier"] != null) {
//           supplierExists = true;
//           existingSupplierName =
//               invoice["supplier"]["supplierName"];
//           selectedSupplier =
//               invoice["supplier"];
//         }

//         if (invoice["document"] != null) {
//           invoiceFileUrl =
//               "${ApiEndpoints.fileBaseUrl}/${invoice["document"]["filePath"]}";
//           isInvoiceUploaded = true;
//         }
//       });
//     }
//   } catch (e) {
//     print("Load invoice error: $e");
//   }
// }
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

            /// Supplier
//             if (invoice["supplier"] != null) {
//   supplierExists = true;

//   existingSupplierName =
//       invoice["supplier"]["supplierName"];

//   selectedSupplier = invoice["supplier"];

//   supplierName.text =
//       invoice["supplier"]["supplierName"];

//   loadSupplierBanks(invoice["supplier"]["id"]);
// }

if (invoice["supplier"] != null &&
    invoice["supplier"]["supplierName"] != null) {

  supplierExists = true;

  existingSupplierName =
      invoice["supplier"]["supplierName"];

  selectedSupplier =
      invoice["supplier"];

  supplierName.text =
      invoice["supplier"]["supplierName"];

  loadSupplierBanks(invoice["supplier"]["id"]);
}
            // if (invoice["supplier"] != null) {
            //   supplierExists = true;

            //   existingSupplierName = invoice["supplier"]["supplierName"];

            //   selectedSupplier = {
            //     "id": invoice["supplier"]["id"],
            //     "supplierName": invoice["supplier"]["supplierName"],
            //   };

            //   supplierName.text = invoice["supplier"]["supplierName"];

            //   // loadSupplierBanks();
            //   loadSupplierBanks(value["id"]);
            // }
          });
        } else {
          print("No invoice found for this customer");
        }
      }
    } catch (e) {
      print("Load RM invoice error: $e");
    }
  }

  // Future<void> loadExistingInvoiceFromRM() async {
  //   try {
  //     final token = await AuthService().getToken();

  //     final response = await http.get(
  //       Uri.parse("${ApiEndpoints.baseUrl}/workflows/invoices/dashboard/rm"),
  //       headers: {"Authorization": "Bearer $token"},
  //     );

  //     final data = jsonDecode(response.body);

  //     print("RM Invoice Response: $data");

  //     if (data["success"] == true &&
  //         data["data"] != null &&
  //         data["data"]["invoices"] != null) {
  //       final invoices = data["data"]["invoices"] as List;

  //       /// match invoice by customerId
  //       final invoice = invoices.firstWhere(
  //         (item) => item["customerId"] == widget.customerId,
  //         orElse: () => null,
  //       );

  //       if (invoice != null) {
  //         setState(() {
  //           invoiceNumber.text = invoice["invoiceNumber"] ?? "";
  //           invoiceDate.text = invoice["invoiceDate"] ?? "";
  //           invoiceAmount.text = invoice["invoiceAmount"]?.toString() ?? "";
  //           tenureDays.text = "90 Days";
  //           disbursementAmount.text =
  //               invoice["disbursementAmount"]?.toString() ?? "";

  //           // selectedSupplier = invoice["supplierName"];
  //           if (invoice["loanAccount"] != null) {
  //             lanExists = true;
  //             existinglanName = invoice["loanAccount"]["lanId"];
  //             selectedLan = invoice["loanAccount"]["id"]; // keep ID for API
  //           }
  //           if (invoice["supplier"] != null) {
  //             supplierExists = true;
  //             existingSupplierName = invoice["supplier"]["supplierName"];
  //             selectedSupplier = invoice["supplier"]["id"]; // keep ID for API
  //           }

  //           /// load uploaded document
  //           if (invoice["document"] != null) {
  //             invoiceFileUrl =
  //                 "${ApiEndpoints.fileBaseUrl}/${invoice["document"]["filePath"]}";

  //             isInvoiceUploaded = true;
  //           }
  //         });
  //       } else {
  //         print("No invoice found for this customer");
  //       }
  //     }
  //   } catch (e) {
  //     print("Load RM invoice error: $e");
  //   }
  // }
  //

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

  // Future<void> fetchLanList() async {
  //   try {
  //     setState(() {
  //       loadingLan = true;
  //     });

  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString("token");

  //     final response = await http.get(
  //       Uri.parse(
  //         "${ApiEndpoints.baseUrl}/workflows/invoices/customers/${widget.customerId}/lans",
  //       ),
  //       headers: {
  //         "Authorization": "Bearer $token",
  //         "Content-Type": "application/json",
  //       },
  //     );

  //     final data = jsonDecode(response.body);

  //     if (data["success"] == true) {
  //       List customers = data["data"];

  //       setState(() {
  //         lanList = customers
  //             .map<String>((e) => e["lanId"].toString())
  //             .toList();

  //         loadingLan = false;
  //       });
  //     }
  //   } catch (e) {
  //     print("LAN fetch error: $e");
  //   }
  // }

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
        MaterialPageRoute(
          builder: (_) => const RmDashboard(),
        ),
        (route) => false,
      );
    } else {
      print("Submit API response: ${response.body}");

      showTopToast(context, data["message"], success: false);
    }
  }

  // Future<void> loadSupplierBanks() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString("token");
  //     final response = await http.get(
  //       Uri.parse(
  //         "${ApiEndpoints.baseUrl}/workflows/suppliers/${widget.customerId}/details",
  //       ),
  //       headers: {
  //         "Authorization": "Bearer $token",
  //         "Content-Type": "application/json",
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       print("API RESPONSE: $data"); // debug
  //       final bank = data["data"]?["supplier"]?["bankDetail"];

  //       setState(() {
  //         // supplierBanks = [data["data"]["supplier"]["bankDetail"]];
  //         // supplierBanks = data["data"];   // adjust according to your API
  //         supplierBanks = bank != null ? [bank] : [];
  //       });
  //     } else {
  //       print("Failed to load banks");
  //     }
  //   } catch (e) {
  //     print("API Error: $e");
  //   }
  // }
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
  //   Future<void> fetchCustomer(String customerId) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString("token");
  //     final response = await http.get(
  //       Uri.parse(
  //         "https://supplychain-prod.fintreelms.com/api/customers/${widget.customerId}",
  //       ),
  //       headers: {
  //         "Authorization": "Bearer $token",
  //         "Content-Type": "application/json",
  //       },
  //     );

  //     final data = jsonDecode(response.body);
  //     if (data["success"] == true) {
  //       final customer = data["data"];
  //       setState(() {
  //         customerName = customer["name"];
  //       });
  //       /// fetch LAN after customer
  //       // fetchCustomerLan(customerId);
  //       fetchLanList();
  //     }
  //   } catch (e) {
  //     print("Customer fetch error: $e");
  //   }
  // }
  // void loadSupplierBanks() {
  //   setState(() {
  //     supplierBanks = [
  //       {
  //         "bank_account_number": "1234567890",
  //         "ifsc_code": "HDFC0001234",
  //         "bank_name": "HDFC Bank",
  //         "account_holder_name": "LLM Appliance Pvt Ltd",
  //       },
  //       {
  //         "bank_account_number": "9876543210",
  //         "ifsc_code": "ICIC0004567",
  //         "bank_name": "ICICI Bank",
  //         "account_holder_name": "LLM Appliance Pvt Ltd",
  //       },
  //     ];
  //   });
  // }

  /// BUILD INPUT FIELD
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
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
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
        hint: const Text("Select LAN"),
        initialValue: selectedLanId,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: lanList.map((lan) {
          return DropdownMenuItem<int>(
            value: lan["id"], // 👈 API ID
            child: Text(lan["lanId"]), // 👈 shown to user
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedLanId = value;
          });
        },
      ),
      // child: DropdownButtonFormField<String>(
      //   value: selectedLan,

      //   hint: const Text("Select LAN"),

      //   decoration: InputDecoration(
      //     prefixIcon: const Icon(Icons.credit_card),
      //     filled: true,
      //     fillColor: const Color(0xFFF8FAFC),
      //     border: OutlineInputBorder(
      //       borderRadius: BorderRadius.circular(14),
      //       borderSide: BorderSide.none,
      //     ),
      //   ),

      //   items: lanList.map((lan) {
      //     return DropdownMenuItem<String>(value: lan, child: Text(lan));
      //   }).toList(),

      //   onChanged: (value) {
      //     setState(() {
      //       selectedLan = value;
      //     });
      //   },
      // ),
    );
  }

  Widget supplierDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<Map<String, dynamic>>(
        initialValue: selectedSupplier,
        hint: const Text("Select Supplier"),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.store),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        items: suppliers.map<DropdownMenuItem<Map<String, dynamic>>>((
          supplier,
        ) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: supplier,
            child: Text(supplier["supplierName"] ?? ""),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedSupplier = value;
            supplierName.text = value?["supplierName"] ?? "";
          });
          if (value != null) {
            loadSupplierBanks(value["id"]); // 👈 load banks
          }
        },
      ),
    );
  }

  //   Widget supplierDropdown() {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 14),
  //     DropdownButtonFormField<Map<String, dynamic>>(
  //   value: selectedSupplier,
  //   hint: const Text("Select Supplier"),
  //   decoration: InputDecoration(
  //     prefixIcon: const Icon(Icons.store),
  //     filled: true,
  //     fillColor: const Color(0xFFF8FAFC),
  //     border: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(14),
  //       borderSide: BorderSide.none,
  //     ),
  //   ),
  //   items: suppliers.map<DropdownMenuItem<Map<String, dynamic>>>((supplier) {
  //     return DropdownMenuItem<Map<String, dynamic>>(
  //       value: supplier,
  //       child: Text(supplier["supplierName"] ?? ""),
  //     );
  //   }).toList(),
  //   onChanged: (value) {
  //     setState(() {
  //       selectedSupplier = value;
  //       supplierName.text = value?["supplierName"] ?? "";
  //     });
  //   },
  // )
  // //     child: DropdownButtonFormField<Map>(
  // //       value: selectedSupplier,
  // //       hint: const Text("Select Supplier"),
  // //       decoration: InputDecoration(
  // //         prefixIcon: const Icon(Icons.store),
  // //         filled: true,
  // //         fillColor: const Color(0xFFF8FAFC),
  // //         border: OutlineInputBorder(
  // //           borderRadius: BorderRadius.circular(14),
  // //           borderSide: BorderSide.none,
  // //         ),
  // //       ),
  // //      items: suppliers.map<DropdownMenuItem<Map>>((supplier) {
  // //   return DropdownMenuItem<Map>(
  // //     value: supplier,
  // //     child: Text(supplier["customer"]?["name"] ?? "Supplier"),
  // //   );
  // // }).toList(),
  // //       onChanged: (value) {
  // //         setState(() {
  // //           selectedSupplier = value;

  // //           supplierName.text = value?["customer"]?["name"] ?? "";

  // //           final bank = value?["bankDetail"];
  // //           supplierBanks = bank != null ? [bank] : [];
  // //         });
  // //       },
  // //     ),
  //   );
  // }

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
          color: isSelected ? const Color(0xFFE8F0FE) : Colors.white,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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
      backgroundColor: const Color(0xFFF4F6FA),

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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
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
                                  color: Colors.grey.shade100,
                                ),
                                child: Text(
                                  existinglanName ?? "",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
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
                              color: const Color(0xFFEFF6FF),
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
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

                                // IconButton(
                                //   icon: const Icon(Icons.visibility, color: Colors.blue),
                                //   onPressed: () {
                                //     if (invoiceFileUrl != null) {
                                //       viewDocument(context, invoiceFileUrl);
                                //     }
                                //   },
                                // ),
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
                            color: Colors.grey.shade100,
                          ),
                          child: Text(
                            existingSupplierName ?? "",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
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
