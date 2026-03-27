// // import 'dart:convert';
// // import 'dart:typed_data';

// // import 'package:flutter/material.dart';
// // import 'package:file_picker/file_picker.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:http/http.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:supply_chain/core/constants/api_endpoints.dart';
// // import 'package:supply_chain/core/services/auth_service.dart';
// // import 'package:supply_chain/core/services/draft_service.dart';
// // import 'package:supply_chain/core/services/web_camera_capture.dart';
// // import 'package:supply_chain/core/utils/toast_helper.dart';
// // import 'package:supply_chain/presentation/role/rm/dashboard_screen.dart';
// // import 'package:url_launcher/url_launcher.dart';

// // /// =======================
// // /// COLORS (Mock AppColors)
// // /// =======================
// // class AppColors {
// //   static const scaffoldBg = Color(0xFFF5F7FB);
// //   static const primary = Color(0xFF2563EB);
// // }

// // /// =======================
// // /// DOCUMENT MODEL
// // /// =======================
// // class DocumentItem {
// //   final String name;
// //   final bool mandatory;
// //   bool uploaded;
// //   String? fileUrl;

// //   DocumentItem({
// //     required this.name,
// //     required this.mandatory,
// //     this.uploaded = false,
// //     this.fileUrl,
// //   });
// // }

// // /// =======================
// // /// DOCUMENT CONFIG
// // /// =======================

// // final List<DocumentItem> allDocuments = [
// //   DocumentItem(name: "GST Certificate", mandatory: false),
// //   DocumentItem(name: "MSME Certificate", mandatory: false),
// //   DocumentItem(name: "Office Electricity Bill", mandatory: false),
// //   DocumentItem(name: "PAN & Aadhaar of Applicant", mandatory: false),
// //   // DocumentItem(name: "PAN & Aadhaar of Female Co-Applicant", mandatory: false),
// //   DocumentItem(name: "Residence Electricity Bill", mandatory: false),
// //   DocumentItem(name: "Audited Financials (Last 3 Years)", mandatory: false),
// //   DocumentItem(name: "GSTR-3B (Latest 2 – Required)", mandatory: false),
// //   DocumentItem(name: "Bank Statement (Last 12 months)", mandatory: false),
// //   DocumentItem(name: "Obligation Sheet", mandatory: false),
// //   DocumentItem(name: "Sales & Purchase (Monthwise, Tally)", mandatory: false),
// //   DocumentItem(name: "PAN & Aadhaar of ALL Partners", mandatory: false),
// //   DocumentItem(name: "Company PAN", mandatory: false),
// //   DocumentItem(name: "Debtor Ageing", mandatory: false),
// //   DocumentItem(name: "MOA (Memorandum of Association)", mandatory: false),
// //   DocumentItem(name: "AOA (Articles of Association)", mandatory: false),
// //   DocumentItem(name: "List of Directors & Shareholders", mandatory: false),
// //   DocumentItem(name: "COI (Certificate of Incorporation)", mandatory: false),
// //   DocumentItem(name: "Partnership Deed / LLP Deed", mandatory: false),
// // ];

// // /// =======================
// // /// DOCUMENT CONFIG
// // /// =======================
// // ///

// // final Map<String, List<String>> mandatoryDocsByCompanyType = {
// //   "proprietorship": [
// //     "PAN & Aadhaar of Applicant",
// //     "Audited Financials (Last 3 Years)",
// //     "GSTR-3B (Latest 2 – Required)",
// //     "Bank Statement (Last 12 months)",
// //   ],

// //   "partnership": [
// //     "PAN & Aadhaar of ALL Partners",
// //     "Audited Financials (Last 3 Years)",
// //     "Bank Statement (Last 12 months)",
// //     "Partnership Deed / LLP Deed",
// //     "GSTR-3B (Latest 2 – Required)",
// //     "Company PAN",
// //   ],

// //   "llp": [
// //     "PAN & Aadhaar of ALL Partners",
// //     "Partnership Deed / LLP Deed",
// //     "Audited Financials (Last 3 Years)",
// //     "GSTR-3B (Latest 2 – Required)",
// //     "Bank Statement (Last 12 months)",
// //     "Company PAN",
// //   ],

// //   "huf": [
// //     "PAN & Aadhaar of Applicant",
// //     "Audited Financials (Last 3 Years)",
// //     "GSTR-3B (Latest 2 – Required)",
// //     "Bank Statement (Last 12 months)",
// //   ],

// //   "pvt ltd /ltd": [
// //     "PAN & Aadhaar of ALL Directors",
// //     "Audited Financials (Last 3 Years)",
// //     "GSTR-3B (Latest 2 – Required)",
// //     "Bank Statement (Last 12 months)",
// //     "MOA (Memorandum of Association)",
// //     "AOA (Articles of Association)",
// //     "List of Directors & Shareholders",
// //     "Company PAN",
// //     "COI (Certificate of Incorporation)",
// //   ],
// // };

// // // final Map<String, List<DocumentItem>> requiredDocumentsByCompanyType = {
// // //   "Proprietorship": [
// // //     DocumentItem(name: "Proprietor PAN", mandatory: true),
// // //     DocumentItem(name: "GST Certificate", mandatory: true),
// // //     DocumentItem(name: "Address Proof", mandatory: true),
// // //     DocumentItem(name: "Bank Statement", mandatory: false),
// // //   ],
// // //   "HUF": [
// // //     DocumentItem(name: "HUF PAN", mandatory: true),
// // //     DocumentItem(name: "Karta PAN", mandatory: true),
// // //     DocumentItem(name: "GST Certificate", mandatory: true),
// // //   ],
// // //   "Partnership": [
// // //     DocumentItem(name: "Firm PAN", mandatory: true),
// // //     DocumentItem(name: "Partnership Deed", mandatory: true),
// // //     DocumentItem(name: "GST Certificate", mandatory: true),
// // //   ],
// // //   "Pvt Ltd /Ltd": [
// // //     DocumentItem(name: "Company PAN", mandatory: true),
// // //     DocumentItem(name: "Certificate of Incorporation", mandatory: true),
// // //     DocumentItem(name: "GST Certificate", mandatory: true),
// // //     DocumentItem(name: "MOA & AOA", mandatory: false),
// // //   ],
// // //   "LLP": [
// // //     DocumentItem(name: "LLP PAN", mandatory: true),
// // //     DocumentItem(name: "LLP Agreement", mandatory: true),
// // //     DocumentItem(name: "GST Certificate", mandatory: true),
// // //   ],
// // // };

// // /// =======================
// // /// DOCUMENTS PAGE
// // /// =======================
// // class DocumentsPage extends StatefulWidget {
// //   final String companyType;
// //   final int customerId;

// //   const DocumentsPage({
// //     super.key,
// //     required this.companyType,
// //     required this.customerId,
// //   });

// //   @override
// //   State<DocumentsPage> createState() => _DocumentsPageState();
// // }

// // class _DocumentsPageState extends State<DocumentsPage> {
// //   late List<DocumentItem> documents;
// //   @override

// // void initState() {
// //   super.initState();

// //   documents = allDocuments.map((doc) {
// //     final mandatoryList =
// //         mandatoryDocsByCompanyType[widget.companyType] ?? [];

// //     return DocumentItem(
// //       name: doc.name,
// //       mandatory: mandatoryList.contains(doc.name),
// //     );
// //   }).toList();

// //   _fetchUploadedDocuments();
// // }

// //   // void initState() {
// //   //   super.initState();

// //   //   debugPrint("Company Type Received: ${widget.companyType}");

// //   //   final type = requiredDocumentsByCompanyType.containsKey(widget.companyType)
// //   //       ? widget.companyType
// //   //       : "Proprietorship"; // fallback

// //   //   documents = requiredDocumentsByCompanyType[type]!
// //   //       .map((e) => DocumentItem(name: e.name, mandatory: e.mandatory))
// //   //       .toList();

// //   //   _fetchUploadedDocuments(); // 🔥 ADD THIS
// //   // }

// //   int get totalDocs => documents.length;
// //   int get mandatoryDocs => documents.where((d) => d.mandatory).length;
// //   int get uploadedDocs => documents.where((d) => d.uploaded).length;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: AppColors.scaffoldBg,
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         title: Text(
// //           "Documents - ${widget.companyType}",
// //           style: const TextStyle(
// //             fontWeight: FontWeight.w700,
// //             color: Colors.black87,
// //           ),
// //         ),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           children: [
// //             _uploadSummaryCard(),
// //             const SizedBox(height: 16),
// //             Expanded(child: _documentList()),
// //             const SizedBox(height: 12),
// //             _bottomButtons(context),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _uploadSummaryCard() {
// //     return Container(
// //       width: double.infinity,
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: const Color(0xFFF1F7FF),
// //         borderRadius: BorderRadius.circular(16),
// //         border: Border.all(color: const Color(0xFFB6D4FF)),
// //       ),
// //       child: Text(
// //         "Total: $totalDocs | Mandatory: $mandatoryDocs | Uploaded: $uploadedDocs",
// //         style: const TextStyle(
// //           fontSize: 14,
// //           fontWeight: FontWeight.w600,
// //           color: Color(0xFF1E3A8A),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _documentList() {
// //     return ListView.builder(
// //       itemCount: documents.length,
// //       itemBuilder: (context, index) {
// //         final doc = documents[index];

// //         return Container(
// //           margin: const EdgeInsets.only(bottom: 12),
// //           padding: const EdgeInsets.all(14),
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(16),
// //             boxShadow: [
// //               BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.06)),
// //             ],
// //           ),
// //           child: Row(
// //             children: [
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       doc.name,
// //                       style: const TextStyle(
// //                         fontSize: 15,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 4),
// //                     Text(
// //                       doc.mandatory ? "REQUIRED" : "OPTIONAL",
// //                       style: TextStyle(
// //                         fontSize: 12,
// //                         fontWeight: FontWeight.w600,
// //                         color: doc.mandatory ? Colors.red : Colors.grey,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               Row(
// //   children: [
// //     /// CAMERA ICON (only if not uploaded)
// //     if (!doc.uploaded)
// //       IconButton(
// //         tooltip: "Take Photo",
// //         onPressed: () => _takePhoto(doc),
// //         icon: const Icon(
// //           Icons.camera_alt,
// //           color: Color.fromARGB(255, 7, 29, 74),
// //         ),
// //       ),

// //     /// UPLOAD ICON (only if not uploaded)
// //     if (!doc.uploaded)
// //       IconButton(
// //         tooltip: "Upload File",
// //         onPressed: () => _pickFromDevice(doc),
// //         icon: const Icon(
// //           Icons.upload_file,
// //           color: Color.fromARGB(255, 7, 29, 74),
// //         ),
// //       ),

// //     /// VERIFIED ICON (only if uploaded)
// //     if (doc.uploaded)
// //       const Icon(
// //         Icons.check_circle,
// //         color: Colors.green,
// //         size: 22,
// //       ),
// //   ],
// // ),
// //               // Row(
// //               //   children: [
// //               //     IconButton(
// //               //       tooltip: doc.uploaded ? "View Document" : "Take Photo",
// //               //       onPressed: doc.uploaded
// //               //           ? () => _viewDocument(doc.fileUrl)
// //               //           : () => _takePhoto(doc),
// //               //       icon: Icon(
// //               //         doc.uploaded ? Icons.visibility : Icons.camera_alt,
// //               //         color: const Color.fromARGB(255, 7, 29, 74),
// //               //       ),
// //               //     ),

// //               //     IconButton(
// //               //       tooltip: doc.uploaded ? "View Document" : "Upload File",
// //               //       onPressed: doc.uploaded
// //               //           ? () => _viewDocument(doc.fileUrl)
// //               //           : () => _pickFromDevice(doc),
// //               //       icon: Icon(
// //               //         doc.uploaded ? Icons.visibility : Icons.upload_file,
// //               //         color: const Color.fromARGB(255, 7, 29, 74),
// //               //       ),
// //               //     ),

// //               //     /// VERIFIED ICON
// //               //     if (doc.uploaded)
// //               //       const Icon(
// //               //         Icons.check_circle,
// //               //         color: Colors.green,
// //               //         size: 22,
// //               //       ),
// //               //   ],
// //               // ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Future<void> _viewDocument(String? url) async {
// //     if (url == null || url.trim().isEmpty) {
// //       showTopToast(context, "Document URL not found", success: false);
// //       return;
// //     }

// //     try {
// //       final uri = Uri.parse(url);

// //       final ok = await launchUrl(
// //         uri,
// //         mode: LaunchMode.externalApplication, // opens in browser/pdf viewer
// //       );

// //       if (!ok) {
// //         showTopToast(context, "Unable to open document", success: false);
// //       }
// //     } catch (e) {
// //       showTopToast(context, "Invalid document url", success: false);
// //     }
// //   }

// //    Future<int> _loadCustomerId() async {

// //      return widget.customerId;
// //   }
// //   Future<void> _fetchUploadedDocuments() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       // final int? customerId = prefs.getInt("customerId");
// //           final customerId = await _loadCustomerId();

// //       final token = await AuthService().getToken();

// //       final response = await http.get(
// //         Uri.parse("${ApiEndpoints.baseUrl}/documents/customer/$customerId"),

// //         headers: {"Authorization": "Bearer $token"},
// //       );

// //       print("FETCH STATUS: ${response.statusCode}");
// //       print("FETCH BODY: ${response.body}");

// //       final data = jsonDecode(response.body);

// //       if (response.statusCode == 200 && data["success"] == true) {
// //         final List uploadedDocs = data["data"];

// //         setState(() {
// //           for (var doc in documents) {
// //             final backendType = doc.name.toUpperCase().replaceAll(' ', '_');

// //             final match = uploadedDocs.firstWhere(
// //               (d) => d["documentType"] == backendType,
// //               orElse: () => null,
// //             );

// //             if (match != null) {
// //               doc.uploaded = true;
// //               // doc.fileUrl = match["fileUrl"];
// //               final filePath = match["filePath"];
// //               // doc.fileUrl = "${ApiEndpoints.baseUrl}/$filePath";
// //               final base = ApiEndpoints.baseUrl.replaceAll("/api", "");
// //               doc.fileUrl = "$base/$filePath";
// //             }
// //           }
// //         });
// //       }
// //     } catch (e) {
// //       print("FETCH ERROR: $e");
// //     }
// //   }

// //   Future<void> _uploadDocument({
// //     required PlatformFile file,
// //     required String documentType,
// //     Map<String, dynamic> meta = const {},
// //   }) async {
// //     // print("Customer ID => $CustomerId");
// //     if (documentType == "PAN_CARD") {
// //       showTopToast(
// //         context,
// //         "Verify mobile number before saving PAN",
// //         success: false,
// //       );
// //       return;
// //     }
// //     try {
// //       // setState(() => isApiLoading = true);

// //       final token = await AuthService().getToken();
// //       final prefs = await SharedPreferences.getInstance();

// //       // final int? storedCustomerId = prefs.getInt("customerId");
// //        final storedCustomerId = await _loadCustomerId();

// //       var request = http.MultipartRequest(
// //         'POST',
// //         Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.uploadDocument),
// //       );

// //       // ✅ Headers
// //       request.headers.addAll({"Authorization": "Bearer $token"});

// //       // ✅ Required Fields
// //       request.fields['customerId'] = storedCustomerId.toString();
// //       request.fields['documentType'] = documentType;
// //       request.fields['applicantType'] = "COMPANY";
// //       request.fields['applicantIndex'] = "0";

// //       request.fields['issueDate'] = meta['issueDate'] ?? '';
// //       request.fields['expiryDate'] = meta['expiryDate'] ?? '';
// //       request.fields['remarks'] = meta['remarks'] ?? '';
// //       request.fields['rmRemarks'] = meta['rmRemarks'] ?? '';

// //       // ✅ File Upload (Web + Mobile Safe)
// //       if (file.bytes != null) {
// //         final ext = file.extension?.toLowerCase();

// //         MediaType contentType;

// //         if (ext == 'pdf') {
// //           contentType = MediaType('application', 'pdf');
// //         } else if (ext == 'jpg' || ext == 'jpeg') {
// //           contentType = MediaType('image', 'jpeg');
// //         } else if (ext == 'png') {
// //           contentType = MediaType('image', 'png');
// //         } else {
// //           throw Exception(
// //             "Invalid file type selected. Only PDF & images allowed.",
// //           );
// //         }

// //         request.files.add(
// //           http.MultipartFile.fromBytes(
// //             'file',
// //             file.bytes as Uint8List,
// //             filename: file.name,
// //             contentType: contentType,
// //           ),
// //         );
// //       } else if (file.path != null) {
// //         request.files.add(
// //           await http.MultipartFile.fromPath('file', file.path!),
// //         );
// //       } else {
// //         throw Exception("Unable to read file");
// //       }

// //       final streamedResponse = await request.send();
// //       final response = await http.Response.fromStream(streamedResponse);

// //       print("UPLOAD STATUS: ${response.statusCode}");
// //       print("UPLOAD BODY: ${response.body}");

// //       final data = jsonDecode(response.body);

// //       if (response.statusCode >= 200 &&
// //           response.statusCode < 300 &&
// //           data["success"] == true) {
// //         showTopToast(
// //           context,
// //           data["message"] ?? "Document uploaded successfully",
// //           success: true,
// //         );
// //       } else {
// //         final message = data["message"] ?? "Upload failed";
// //         throw Exception(message);
// //       }
// //     } catch (e) {
// //       print("UPLOAD ERROR: $e");
// //       showTopToast(context, e.toString(), success: false);
// //       // } finally {
// //       //   setState(() => isApiLoading = false);
// //       // }
// //     }
// //   }

// //   Future<void> _pickFromDevice(DocumentItem doc) async {
// //     final result = await FilePicker.platform.pickFiles(
// //       type: FileType.custom,
// //       allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
// //       withData: true, // 🔥 IMPORTANT
// //     );

// //     if (result != null && result.files.isNotEmpty) {
// //       final file = result.files.first;

// //       await _uploadDocument(
// //         file: file,
// //         documentType: doc.name.toUpperCase().replaceAll(' ', '_'),
// //       );

// //       setState(() {
// //         doc.uploaded = true; // ✅ Only after success
// //       });
// //     }
// //   }
// //   // Future<void> _pickFromDevice(DocumentItem doc) async {
// //   //   final result = await FilePicker.platform.pickFiles(
// //   //     type: FileType.custom,
// //   //     allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
// //   //   );

// //   //   if (result != null && result.files.isNotEmpty) {
// //   //     final file = result.files.first;

// //   //     setState(() {
// //   //       doc.uploaded = true;
// //   //     });

// //   //       _uploadDocument(
// //   //         file: file,
// //   //         documentType: doc.name.toUpperCase().replaceAll(' ', '_'),
// //   //       );
// //   //     ScaffoldMessenger.of(context).showSnackBar(
// //   //       SnackBar(content: Text("${doc.name} uploaded (${file.name})")),
// //   //     );
// //   //   }
// //   // }

// //   Future<void> _takePhoto(DocumentItem doc) async {
// //     final result = await Navigator.push(
// //       context,
// //       MaterialPageRoute(builder: (_) => const WebCameraCapture()),
// //     );

// //     if (result != null) {
// //       // result is XFile from camera
// //       setState(() {
// //         doc.uploaded = true;
// //       });

// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("${doc.name} captured successfully")),
// //       );
// //     }
// //   }

// // static Future<void> submitCustomer(int customerId) async {
// //   try {
// //     final token = await AuthService().getToken();

// //     final response = await http.post(
// //       Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.submitCustomer(customerId)),
// //       headers: {
// //         "Content-Type": "application/json",
// //         "Authorization": "Bearer $token",
// //       },
// //     );

// //     final data = jsonDecode(response.body);

// //     if (response.statusCode != 200 || data["success"] != true) {
// //       throw Exception(data["message"] ?? "Failed to submit customer");
// //     }
// //   } catch (e) {
// //     rethrow;
// //   }
// // }

// // Widget _bottomButtons(BuildContext context) {
// //   return ElevatedButton(
// //     onPressed: uploadedDocs >= mandatoryDocs
// //         ? () async {
// //             try {
// //               // setState(() => isApiLoading = true);

// //               final prefs = await SharedPreferences.getInstance();
// //               // final customerId = prefs.getInt("customerId");
// //                      final customerId = await _loadCustomerId();

// //               // ✅ CALL SUBMIT API
// //               await submitCustomer(customerId);

// //               // ✅ MOVE DRAFT
// //               await DraftService.moveDraftToSubmitted(customerId);

// //               showTopToast(
// //                 context,
// //                 "Case Submitted Successfully",
// //                 success: true,
// //               );

// //               Navigator.pushReplacement(
// //                 context,
// //                 MaterialPageRoute(builder: (_) => const RmDashboard()),
// //               );
// //             } catch (e) {
// //               showTopToast(context, e.toString(), success: false);
// //             }
// //             //finally {
// //             //   setState(() => isApiLoading = false);
// //             // }
// //           }
// //         : null,
// //     style: ElevatedButton.styleFrom(
// //       backgroundColor: const Color.fromARGB(255, 22, 61, 145),
// //       minimumSize: const Size(double.infinity, 52),
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(14),
// //       ),
// //     ),
// //     child: const Text(
// //       "Submit Case",
// //       style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
// //     ),
// //   );
// // }

// //   // Widget _bottomButtons(BuildContext context) {
// //   //   return ElevatedButton(
// //   //     onPressed: uploadedDocs >= mandatoryDocs
// //   //         ? () async {
// //   //             ScaffoldMessenger.of(context).showSnackBar(
// //   //               const SnackBar(content: Text("Case Submitted Successfully")),
// //   //             );
// //   //             // await DraftService.moveDraftToCompleted();
// //   //             await DraftService.moveDraftToSubmitted();

// //   //             // Navigator.push(
// //   //             //   context,
// //   //             //   MaterialPageRoute(builder: (_) => Draft()),
// //   //             // );
// //   //             Navigator.pushReplacement(
// //   //               context,
// //   //               MaterialPageRoute(builder: (_) => const RmDashboard()),
// //   //             );
// //   //           }
// //   //         : null,
// //   //     style: ElevatedButton.styleFrom(
// //   //       backgroundColor: const Color.fromARGB(255, 22, 61, 145),
// //   //       minimumSize: const Size(double.infinity, 52),
// //   //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
// //   //     ),
// //   //     child: const Text(
// //   //       "Submit Case",
// //   //       style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
// //   //     ),
// //   //   );
// //   // }
// // }

// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:http/http.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supply_chain/core/constants/api_endpoints.dart';
// import 'package:supply_chain/core/services/auth_service.dart';
// import 'package:supply_chain/core/services/draft_service.dart';
// import 'package:supply_chain/core/services/web_camera_capture.dart';
// import 'package:supply_chain/core/utils/toast_helper.dart';
// import 'package:supply_chain/presentation/role/rm/dashboard_screen.dart';
// import 'package:url_launcher/url_launcher.dart';

// /// =======================
// /// COLORS (Mock AppColors)
// /// =======================
// class AppColors {
//   static const scaffoldBg = Color(0xFFF5F7FB);
//   static const primary = Color(0xFF2563EB);
// }

// /// =======================
// /// DOCUMENT MODEL
// /// =======================
// class DocumentItem {
//   final String name;
//   final String type;
//   final bool mandatory;
//   bool uploaded;
//   String? fileUrl;
//   int? id; // ✅ ADD THIS

//   DocumentItem({
//     required this.name,
//     required this.type,

//     required this.mandatory,
//     this.uploaded = false,
//     this.fileUrl,
//   });
// }

// final List<DocumentItem> allDocuments = [
//   DocumentItem(
//     name: "GST Certificate",
//     type: "GST_CERTIFICATE",
//     mandatory: false,
//   ),
//   DocumentItem(
//     name: "MSME Certificate",
//     type: "MSME_CERTIFICATE",
//     mandatory: false,
//   ),
//   DocumentItem(
//     name: "Office Electricity Bill",
//     type: "OFFICE_ELECTRICITY_BILL",
//     mandatory: false,
//   ),
//   DocumentItem(
//     name: "PAN & Aadhaar of Applicant",
//     type: "PAN_&_AADHAAR_OF_APPLICANT",
//     mandatory: false,
//   ),
//   DocumentItem(
//     name: "PAN & Aadhaar of Female Co-Applicant",
//     type: "PAN_&_AADHAAR_OF_FEMALE_CO-APPLICANT",
//     mandatory: false,
//   ),
//   DocumentItem(
//     name: "Residence Electricity Bill",
//     type: "RESIDENCE_ELECTRICITY_BILL",
//     mandatory: false,
//   ),
//   DocumentItem(
//     name: "Audited Financials (Last 3 Years)",
//     type: "AUDITED_FINANCIALS_(LAST_3_YEARS)",
//     mandatory: false,
//   ),
//   DocumentItem(
//     name: "GSTR-3B (Latest 2 – Required)",
//     type: "GSTR-3B_(LATEST_2_–_REQUIRED)",
//     mandatory: false,
//   ),
//   DocumentItem(
//     name: "Bank Statement (Last 12 months)",
//     type: "BANK_STATEMENT_(LAST_12_MONTHS)",
//     mandatory: false,
//   ),
//   DocumentItem(
//     name: "Obligation Sheet",
//     type: "obligation_sheet",
//     mandatory: false,
//   ),
//   DocumentItem(
//     name: "Sales & Purchase (Monthwise, Tally)",
//     type: "sales_purchase",
//     mandatory: false,
//   ),
//   DocumentItem(
//     name: "PAN & Aadhaar of ALL Partners",
//     type: "PAN_AADHAAR_OF_ALL_PARTNERS",
//     mandatory: false,
//   ),
//   DocumentItem(name: "Company PAN", type: "COMPANY_PAN", mandatory: false),
//   DocumentItem(name: "Debtor Ageing", type: "DEBTOR_AGEING", mandatory: false),
//   DocumentItem(
//     name: "MOA (Memorandum of Association)",
//     type: "MOA",
//     mandatory: false,
//   ),
//   DocumentItem(
//     name: "AOA (Articles of Association)",
//     type: "AOA",
//     mandatory: false,
//   ),
//   DocumentItem(
//     name: "List of Directors & Shareholders",
//     type: "LIST_OF_DIRECTORS_SHAREHOLDERS",
//     mandatory: false,
//   ),
//   DocumentItem(
//     name: "COI (Certificate of Incorporation)",
//     type: "COI",
//     mandatory: false,
//   ),
//   DocumentItem(
//     name: "Partnership Deed / LLP Deed",
//     type: "PARTNERSHIP_DEED_LLP_DEED",
//     mandatory: false,
//   ),
// ];

// /// =======================
// /// DOCUMENT CONFIG
// /// =======================
// ///
// Map<String, List<String>> optionalDocsByCompanyType = {
//   "proprietorship": [
//     "GST Certificate",
//     "MSME Certificate",
//     "Office Electricity Bill",
//     "PAN & Aadhaar of Female Co-Applicant",
//     "Residence Electricity Bill",
//     "Obligation Sheet",
//     "Sales & Purchase (Monthwise, Tally)",
//   ],

//   "partnership": [
//     "GST Certificate",
//     "MSME Certificate",
//     "Office Electricity Bill",
//     "Residence Electricity Bill",
//     "Obligation Sheet",
//     "Sales & Purchase (Monthwise, Tally)",
//   ],

//   "pvt ltd /ltd": [
//     "GST Certificate",
//     "MSME Certificate",
//     "Office Electricity Bill",
//     "Obligation Sheet",
//     "Sales & Purchase (Monthwise, Tally)",
//     "debtor Ageing",
//   ],
//   "llp": [
//     "GST Certificate",
//     "MSME Certificate",
//     "Office Electricity Bill",
//     "Obligation Sheet",
//     "Sales & Purchase (Monthwise, Tally)",
//     "debtor Ageing",
//   ],
// };

// final Map<String, List<String>> mandatoryDocsByCompanyType = {
//   "proprietorship": [
//     "PAN & Aadhaar of Applicant",
//     "Audited Financials (Last 3 Years)",
//     "GSTR-3B (Latest 2 – Required)",
//     "Bank Statement (Last 12 months)",
//   ],

//   "partnership": [
//     "PAN & Aadhaar of ALL Partners",
//     "Audited Financials (Last 3 Years)",
//     "Bank Statement (Last 12 months)",
//     "Partnership Deed / LLP Deed",
//     "GSTR-3B (Latest 2 – Required)",
//     "Company PAN",
//   ],

//   "llp": [
//     "PAN & Aadhaar of ALL Partners",
//     "Partnership Deed / LLP Deed",
//     "Audited Financials (Last 3 Years)",
//     "GSTR-3B (Latest 2 – Required)",
//     "Bank Statement (Last 12 months)",
//     "Company PAN",
//   ],

//   "huf": [
//     "PAN & Aadhaar of Applicant",
//     "Audited Financials (Last 3 Years)",
//     "GSTR-3B (Latest 2 – Required)",
//     "Bank Statement (Last 12 months)",
//   ],

//   "pvt ltd /ltd": [
//     "PAN & Aadhaar of ALL Directors",
//     "Audited Financials (Last 3 Years)",
//     "GSTR-3B (Latest 2 – Required)",
//     "Bank Statement (Last 12 months)",
//     "MOA (Memorandum of Association)",
//     "AOA (Articles of Association)",
//     "List of Directors & Shareholders",
//     "Company PAN",
//     "COI (Certificate of Incorporation)",
//   ],
// };

// /// =======================
// /// DOCUMENTS PAGE
// /// =======================
// class DocumentsPage extends StatefulWidget {
//   final String companyType;
//   final int customerId;

//   const DocumentsPage({
//     super.key,
//     required this.companyType,
//     required this.customerId,
//   });

//   @override
//   State<DocumentsPage> createState() => _DocumentsPageState();
// }

// class _DocumentsPageState extends State<DocumentsPage> {
//   late List<DocumentItem> documents;

//   @override
//   void initState() {
//     print("Company Type from previous screen: ${widget.companyType}");
//     print("Mandatory Map Keys: ${mandatoryDocsByCompanyType.keys}");
//     super.initState();

//     //     documents = allDocuments.map((doc) {
//     // final type = widget.companyType.toLowerCase().trim();

//     // final mandatoryList =
//     //     mandatoryDocsByCompanyType[type] ?? [];

//     //       return DocumentItem(
//     //         name: doc.name,
//     //         mandatory: mandatoryList.contains(doc.name),
//     //       );
//     //     }).toList();

//     final type = widget.companyType.toLowerCase().trim();

//     final mandatoryList = mandatoryDocsByCompanyType[type] ?? [];
//     final optionalList = optionalDocsByCompanyType[type] ?? [];

//     List<DocumentItem> mandatoryDocs = [];
//     List<DocumentItem> optionalDocs = [];

//     /// ✅ Step 1: Separate docs
//     for (var doc in allDocuments) {
//       if (mandatoryList.contains(doc.name)) {
//         mandatoryDocs.add(
//           DocumentItem(name: doc.name, type: doc.type, mandatory: true),
//         );
//       } else if (optionalList.contains(doc.name)) {
//         optionalDocs.add(
//           DocumentItem(name: doc.name, type: doc.type, mandatory: false),
//         );
//       }
//     }

//     /// ✅ Step 2: Final merge
//     documents = [...mandatoryDocs, ...optionalDocs];

//     print("Final Docs: ${documents.map((e) => e.name).toList()}");

//     // documents = allDocuments.map((doc) {
//     //   final type = widget.companyType.toLowerCase().trim();

//     //   final mandatoryList = mandatoryDocsByCompanyType[type] ?? [];

//     //   return DocumentItem(
//     //     name: doc.name,
//     //     mandatory: mandatoryList.contains(doc.name),
//     //   );
//     // }).toList();

//     _fetchUploadedDocuments();
//   }

//   int get totalDocs => documents.length;
//   int get mandatoryDocs => documents.where((d) => d.mandatory).length;
//   int get uploadedDocs => documents.where((d) => d.uploaded).length;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBg,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: Text(
//           "Documents - ${widget.companyType}",
//           style: const TextStyle(
//             fontWeight: FontWeight.w700,
//             color: Colors.black87,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _uploadSummaryCard(),
//             const SizedBox(height: 16),
//             Expanded(child: _documentList()),
//             const SizedBox(height: 12),
//             _bottomButtons(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<int> _loadCustomerId() async {
//     return widget.customerId;
//   }

//   Widget _uploadSummaryCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF1F7FF),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFFB6D4FF)),
//       ),
//       child: Text(
//         "Total: $totalDocs | Mandatory: $mandatoryDocs | Uploaded: $uploadedDocs",
//         style: const TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w600,
//           color: Color(0xFF1E3A8A),
//         ),
//       ),
//     );
//   }

//   Widget _documentList() {
//     return ListView.builder(
//       itemCount: documents.length,
//       itemBuilder: (context, index) {
//         final doc = documents[index];
//         return Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.06)),
//             ],
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       doc.name,
//                       style: const TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       doc.mandatory ? "REQUIRED" : "OPTIONAL",
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: doc.mandatory ? Colors.red : Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Row(
//                 children: [
//                   /// CAMERA ICON (only if not uploaded)
//                   if (!doc.uploaded)
//                     IconButton(
//                       tooltip: "Take Photo",
//                       onPressed: () => _takePhoto(doc),
//                       icon: const Icon(
//                         Icons.camera_alt,
//                         color: Color.fromARGB(255, 7, 29, 74),
//                       ),
//                     ),

//                   /// UPLOAD ICON (only if not uploaded)
//                   if (!doc.uploaded)
//                     IconButton(
//                       tooltip: "Upload File",
//                       onPressed: () => _pickFromDevice(doc),
//                       icon: const Icon(
//                         Icons.upload_file,
//                         color: Color.fromARGB(255, 7, 29, 74),
//                       ),
//                     ),

//                   /// VERIFIED ICON (only if uploaded)
//                   if (doc.uploaded) ...[
//                     const Icon(
//                       Icons.check_circle,
//                       color: Colors.green,
//                       size: 22,
//                     ),
//                     const SizedBox(width: 8),

//                     /// 👁 VIEW
//                     IconButton(
//                       icon: const Icon(Icons.visibility, color: Colors.black),
//                       onPressed: () => _viewDocument(doc.fileUrl),
//                     ),

//                     /// 🗑 DELETE
//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () => _confirmDelete(doc),
//                     ),
//                   ],
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _confirmDelete(DocumentItem doc) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Delete Document"),
//           content: Text("Are you sure you want to delete ${doc.name}?"),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text("Delete"),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirm == true) {
//       await _deleteDocument(doc);
//     }
//   }

//   Future<void> _deleteDocument(DocumentItem doc) async {
//     try {
//       final token = await AuthService().getToken();
//       final customerId = await _loadCustomerId();
//       if (doc.id == null) {
//         throw Exception("Document ID not found");
//       }
//       // final documentType = doc.name.toUpperCase().replaceAll(' ', '_');
//       print("Deleting Document Type: ${doc.type}");
//       final response = await http.delete(
//         Uri.parse("${ApiEndpoints.baseUrl}/documents/${doc.id}"),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data["success"] == true) {
//         setState(() {
//           doc.uploaded = false;
//           doc.fileUrl = null;
//           doc.id = null;
//         });

//         showTopToast(context, "Document deleted successfully", success: true);
//       } else {
//         throw Exception(data["message"] ?? "Delete failed");
//       }
//     } catch (e) {
//       showTopToast(context, e.toString(), success: false);
//     }
//   }

//   Future<void> _viewDocument(String? url) async {
//     if (url == null || url.trim().isEmpty) {
//       showTopToast(context, "Document URL not found", success: false);
//       return;
//     }

//     try {
//       final uri = Uri.parse(url);

//       final ok = await launchUrl(
//         uri,
//         // mode: LaunchMode.externalApplication,
//          // opens in browser/pdf viewer
//                mode: LaunchMode.inAppBrowserView, // 🔥 better than external

//       );

//       if (!ok) {
//         showTopToast(context, "Unable to open document", success: false);
//       }
//     } catch (e) {
//       showTopToast(context, "Invalid document url", success: false);
//     }
//   }

//   Future<void> _fetchUploadedDocuments() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       final customerId = await _loadCustomerId();

//       final token = await AuthService().getToken();

//       final response = await http.get(
//         Uri.parse("${ApiEndpoints.baseUrl}/documents/customer/$customerId"),

//         headers: {"Authorization": "Bearer $token"},
//       );

//       print("FETCH STATUS: ${response.statusCode}");
//       print("FETCH BODY: ${response.body}");

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data["success"] == true) {
//         final List uploadedDocs = data["data"];

//         setState(() {
//           for (var doc in documents) {
//             final backendType = doc.name.toUpperCase().replaceAll(' ', '_');

//             final match = uploadedDocs.firstWhere(
//               (d) => d["documentType"] == backendType,
//               orElse: () => null,
//             );

//             if (match != null) {
//               doc.uploaded = true;
//               // doc.fileUrl = match["fileUrl"];
//               final filePath = match["filePath"];
//               // doc.fileUrl = "${ApiEndpoints.baseUrl}/$filePath";
//               final base = ApiEndpoints.baseUrl.replaceAll("/api", "");
//               doc.fileUrl = "$base/$filePath";
//               doc.id = match["id"]; // ✅ IMPORTANT
//             }
//           }
//         });
//       }
//     } catch (e) {
//       print("FETCH ERROR: $e");
//     }
//   }

//   Future<Map<String, String>?> _showDocumentMetaDialog() async {
//     final issueController = TextEditingController();
//     final expiryController = TextEditingController();

//     Future<void> pickDate(TextEditingController controller) async {
//       final date = await showDatePicker(
//         context: context,
//         firstDate: DateTime(2000),
//         lastDate: DateTime(2100),
//         initialDate: DateTime.now(),
//       );

//       if (date != null) {
//         controller.text = date.toIso8601String().split("T")[0]; // yyyy-mm-dd
//       }
//     }

//     return await showDialog<Map<String, String>>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Enter Document Details"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: issueController,
//                 readOnly: true,
//                 decoration: InputDecoration(
//                   labelText: "Issue Date",
//                   suffixIcon: IconButton(
//                     icon: const Icon(Icons.calendar_today),
//                     onPressed: () => pickDate(issueController),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: expiryController,
//                 readOnly: true,
//                 decoration: InputDecoration(
//                   labelText: "Expiry Date",
//                   suffixIcon: IconButton(
//                     icon: const Icon(Icons.calendar_today),
//                     onPressed: () => pickDate(expiryController),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, null),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
//               onPressed: () {
//                 Navigator.pop(context, {
//                   "issueDate": issueController.text,
//                   "expiryDate": expiryController.text,
//                 });
//               },
//               child: const Text("Submit"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _uploadDocument({
//     required PlatformFile file,
//     required String documentType,
//     Map<String, dynamic> meta = const {},
//   }) async {
//     // print("Customer ID => $CustomerId");
//     if (documentType == "PAN_CARD") {
//       showTopToast(
//         context,
//         "Verify mobile number before saving PAN",
//         success: false,
//       );
//       return;
//     }
//     try {
//       // setState(() => isApiLoading = true);
//       final token = await AuthService().getToken();

//       // final int? storedCustomerId = prefs.getInt("customerId");
//       final storedCustomerId = await _loadCustomerId();

//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.uploadDocument),
//       );

//       // ✅ Headers
//       request.headers.addAll({"Authorization": "Bearer $token"});

//       // ✅ Required Fields
//       request.fields['customerId'] = storedCustomerId.toString();
//       request.fields['documentType'] = documentType;
//       request.fields['applicantType'] = "COMPANY";
//       request.fields['applicantIndex'] = "0";

//       request.fields['issueDate'] = meta['issueDate'] ?? '';
//       request.fields['expiryDate'] = meta['expiryDate'] ?? '';
//       request.fields['remarks'] = meta['remarks'] ?? '';
//       request.fields['rmRemarks'] = meta['rmRemarks'] ?? '';

//       // ✅ File Upload (Web + Mobile Safe)
//       if (file.bytes != null) {
//         final ext = file.extension?.toLowerCase();

//         MediaType contentType;

//         if (ext == 'pdf') {
//           contentType = MediaType('application', 'pdf');
//         } else if (ext == 'jpg' || ext == 'jpeg') {
//           contentType = MediaType('image', 'jpeg');
//         } else if (ext == 'png') {
//           contentType = MediaType('image', 'png');
//         } else {
//           throw Exception(
//             "Invalid file type selected. Only PDF & images allowed.",
//           );
//         }

//         request.files.add(
//           http.MultipartFile.fromBytes(
//             'file',
//             file.bytes as Uint8List,
//             filename: file.name,
//             contentType: contentType,
//           ),
//         );
//       } else if (file.path != null) {
//         request.files.add(
//           await http.MultipartFile.fromPath('file', file.path!),
//         );
//       } else {
//         throw Exception("Unable to read file");
//       }

//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       print("UPLOAD STATUS: ${response.statusCode}");
//       print("UPLOAD BODY: ${response.body}");

//       final data = jsonDecode(response.body);

//       if (response.statusCode >= 200 &&
//           response.statusCode < 300 &&
//           data["success"] == true) {
//         showTopToast(
//           context,
//           data["message"] ?? "Document uploaded successfully",
//           success: true,
//         );
//       } else {
//         final message = data["message"] ?? "Upload failed";
//         throw Exception(message);
//       }
//     } catch (e) {
//       print("UPLOAD ERROR: $e");
//       showTopToast(context, e.toString(), success: false);
//       // } finally {
//       //   setState(() => isApiLoading = false);
//       // }
//     }
//   }

//   Future<void> _pickFromDevice(DocumentItem doc) async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
//       withData: true, // 🔥 IMPORTANT
//     );

//     if (result != null && result.files.isNotEmpty) {
//       final file = result.files.first;

//       final meta = await _showDocumentMetaDialog();
//       if (meta == null) return;

//       await _uploadDocument(
//         file: file,
//         documentType: doc.name.toUpperCase().replaceAll(' ', '_'),
//         meta: {
//           "issueDate": meta["issueDate"],
//           "expiryDate": meta["expiryDate"],
//         },
//       );

//       setState(() {
//         doc.uploaded = true; // ✅ Only after success
//       });
//     }
//   }

//   Future<void> _takePhoto(DocumentItem doc) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const WebCameraCapture()),
//     );

//     if (result != null) {
//       // result is XFile from camera
//       setState(() {
//         doc.uploaded = true;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("${doc.name} captured successfully")),
//       );
//     }
//   }

//   static Future<void> submitCustomer(int customerId) async {
//     try {
//       final token = await AuthService().getToken();

//       final response = await http.post(
//         Uri.parse(
//           ApiEndpoints.baseUrl + ApiEndpoints.submitCustomer(customerId),
//         ),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode != 200 || data["success"] != true) {
//         throw Exception(data["message"] ?? "Failed to submit customer");
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Widget _bottomButtons(BuildContext context) {
//     return ElevatedButton(
//       onPressed: uploadedDocs >= mandatoryDocs
//           ? () async {
//               try {
//                 // setState(() => isApiLoading = true);

//                 final prefs = await SharedPreferences.getInstance();
//                 // final customerId = prefs.getInt("customerId");

//                 final customerId = await _loadCustomerId();

//                 // ✅ CALL SUBMIT API
//                 await submitCustomer(customerId);

//                 // ✅ MOVE DRAFT
//                 await DraftService.moveDraftToSubmitted(customerId);

//                 showTopToast(
//                   context,
//                   "Case Submitted Successfully",
//                   success: true,
//                 );

//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => const RmDashboard()),
//                 );
//               } catch (e) {
//                 showTopToast(context, e.toString(), success: false);
//               }
//               //finally {
//               //   setState(() => isApiLoading = false);
//               // }
//             }
//           : null,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: const Color.fromARGB(255, 22, 61, 145),
//         minimumSize: const Size(double.infinity, 52),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       ),
//       child: const Text(
//         "Submit Case",
//         style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
//       ),
//     );
//   }
// }





 
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
 
  @override
  void initState() {
    print("Company Type from previous screen: ${widget.companyType}");
    print("Mandatory Map Keys: ${mandatoryDocsByCompanyType.keys}");
    super.initState();
 
    //     documents = allDocuments.map((doc) {
    // final type = widget.companyType.toLowerCase().trim();
 
    // final mandatoryList =
    //     mandatoryDocsByCompanyType[type] ?? [];
 
    //       return DocumentItem(
    //         name: doc.name,
    //         mandatory: mandatoryList.contains(doc.name),
    //       );
    //     }).toList();
 
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
 
    // documents = allDocuments.map((doc) {
    //   final type = widget.companyType.toLowerCase().trim();
 
    //   final mandatoryList = mandatoryDocsByCompanyType[type] ?? [];
 
    //   return DocumentItem(
    //     name: doc.name,
    //     mandatory: mandatoryList.contains(doc.name),
    //   );
    // }).toList();
 
    _fetchUploadedDocuments();
  }
 
  int get totalDocs => documents.length;
  int get mandatoryDocs => documents.where((d) => d.mandatory).length;
 int get uploadedDocs =>
    documents.where((d) => d.fileUrls.isNotEmpty).length;
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Documents - ${widget.companyType}",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
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
        color: const Color(0xFFF1F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB6D4FF)),
      ),
      child: Text(
        "Total: $totalDocs | Mandatory: $mandatoryDocs | Uploaded: $uploadedDocs",
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E3A8A),
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
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        blurRadius: 12,
        color: Colors.black.withOpacity(0.06),
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
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
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
              icon: const Icon(Icons.visibility),
              onPressed: () => _showFilesBottomSheet(doc.fileUrls),
            ),
        ],
      ),
    ],
  ),
);
      },
    );
  }
 
  void _showFilesBottomSheet(List<String> files) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView.builder(
          itemCount: files.length,
          itemBuilder: (_, index) {
            final file = files[index];
 
            return ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: Text("Document ${index + 1}"),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _viewDocument(file),
            );
          },
        );
      },
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
        // mode: LaunchMode.externalApplication,
        // opens in browser/pdf viewer
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
      final prefs = await SharedPreferences.getInstance();
 
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
 
    final matches = uploadedDocs.where(
      (d) => d["documentType"] == backendType,
    ).toList();
 
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
        controller.text = date.toIso8601String().split("T")[0]; // yyyy-mm-dd
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
 
 