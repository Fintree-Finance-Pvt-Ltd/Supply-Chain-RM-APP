// // import 'dart:convert';

// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:supply_chain/core/constants/api_endpoints.dart';

// // class SubmittedCasesPage extends StatefulWidget {
// //   const SubmittedCasesPage({super.key});

// //   @override
// //   State<SubmittedCasesPage> createState() => _SubmittedCasesPageState();
// // }

// // class _SubmittedCasesPageState extends State<SubmittedCasesPage>
// //     with SingleTickerProviderStateMixin {
// //   late TabController _tabController;
// //   List<dynamic> submittedCases = [];

// //   final tabs = ["Submitted"];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: tabs.length, vsync: this);
// //     _loadSubmittedCases();
// //       // fetchSanctionTerms();

// //   }

// // //  Future<void> fetchSanctionTerms() async {
// // //   final response = await http.get(
// // //     Uri.parse("https://yourapi.com/sanction-terms"),
// // //   );

// // //   if (response.statusCode == 200) {
// // //     final data = jsonDecode(response.body);

// // //     sanctionAmountController.text =
// // //         data["sanction_amount"]?.toString() ?? "";

// // //     tenureController.text =
// // //         data["tenure_months"]?.toString() ?? "";

// // //     interestRateController.text =
// // //         data["interest_rate"]?.toString() ?? "";

// // //     penalChargesController.text =
// // //         data["penal_charges"]?.toString() ?? "";

// // //     processingFeesController.text =
// // //         data["processing_fees"]?.toString() ?? "";

// // //     setState(() {});
// // //   }
// // // }
// //   Future<void> _loadSubmittedCases() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final submittedString = prefs.getString("submitted_cases");

// //     if (submittedString == null) return;

// //     final decoded = jsonDecode(submittedString);

// //     final List<Map<String, dynamic>> cleanList = [];

// //     if (decoded is List) {
// //       for (final item in decoded) {
// //         if (item is Map<String, dynamic>) {
// //           cleanList.add(item);
// //         } else if (item is List) {
// //           for (final inner in item) {
// //             if (inner is Map<String, dynamic>) {
// //               cleanList.add(inner);
// //             }
// //           }
// //         }
// //       }
// //     }

// //     setState(() {
// //       submittedCases = cleanList;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF5F7FB),
// //       appBar: AppBar(
// //         elevation: 0,
// //         backgroundColor: Colors.white,
// //         title: const Text(
// //           "Supply Chain Finance",
// //           style: TextStyle(color: Colors.black),
// //         ),
// //       ),
// //       body: Column(
// //         children: [
// //           TabBar(
// //             controller: _tabController,
// //             labelColor: const Color(0xFF2563EB),
// //             unselectedLabelColor: Colors.grey,
// //             tabs: tabs.map((t) => Tab(text: t)).toList(),
// //           ),
// //           Expanded(
// //             child: TabBarView(
// //               controller: _tabController,
// //               children: [_caseList()],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _caseList() {
// //     if (submittedCases.isEmpty) {
// //       return const Center(child: Text("No submitted cases"));
// //     }

// //     return ListView.builder(
// //       padding: const EdgeInsets.all(16),
// //       itemCount: submittedCases.length,
// //       itemBuilder: (context, index) {
// //         final raw = submittedCases[index];
// //         if (raw is! Map<String, dynamic>) return const SizedBox();

// //         final caseData = raw;

// //         return CaseCard(
// //           caseData: caseData,
// //           status: "Submitted",
// //           date: "Completed",
// //         );
// //       },
// //     );
// //   }
// // }

// // // class CaseDetailsPage extends StatelessWidget {
// // //   final Map<String, dynamic> caseData;

// // //   const CaseDetailsPage({super.key, required this.caseData});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final company = caseData["company"] ?? {};
// // //     final applicant = caseData["applicant"] ?? {};
// // //     final coApplicants = caseData["coApplicants"] ?? [];

// // //     // Dummy files list (replace with your API or stored docs)
// // //     final uploadedFiles = [
// // //       {
// // //         "name": "sample-pan-card.jpg",
// // //         "docType": "GST_CERTIFICATE",
// // //         "tag": "APPLICANT",
// // //         "date": "02 Mar 2026",
// // //       },
// // //       {
// // //         "name": "scaled_pan_dummy1.webp",
// // //         "docType": "PAN_CARD",
// // //         "tag": "APPLICANT",
// // //         "date": "02 Mar 2026",
// // //       },
// // //     ];

// // //     final docTypes = const [
// // //       "GST_CERTIFICATE",
// // //       "PAN_CARD",
// // //       "BANK_STATEMENT",
// // //       "CHEQUE",
// // //       "OTHER",
// // //     ];

// // //     return Scaffold(
// // //       backgroundColor: const Color(0xFFF5F7FB),
// // //       appBar: AppBar(title: const Text("Customer Information")),
// // //       body: SingleChildScrollView(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Column(
// // //           children: [
// // //             /// 🏢 COMPANY CARD
// // //             _card(
// // //               title: "Company Details",
// // //               children: [
// // //                 _infoRow("Company Type", company["companyType"]),
// // //                 _infoRow("Company Name", company["companyName"]),
// // //                 _infoRow("Company Mobile", company["mobile"]),
// // //                 _infoRow("Company Email", company["email"]),
// // //                 _infoRow("Company GST", company["gst"]),
// // //               ],
// // //             ),

// // //             const SizedBox(height: 16),

// // //             /// 👤 APPLICANT CARD
// // //             _card(
// // //               title: "Applicant Details",
// // //               children: [
// // //                 _infoRow("Name", applicant["name"]),
// // //                 _infoRow("Mobile", applicant["mobile"]),
// // //                 _infoRow("Email", applicant["email"]),
// // //                 _infoRow("PAN", applicant["pan"]),
// // //               ],
// // //             ),

// // //             const SizedBox(height: 16),

// // //             /// 👥 CO-APPLICANT CARD
// // //             if (coApplicants.isNotEmpty)
// // //               _card(
// // //                 title: "Co-Applicant Details",
// // //                 children: [
// // //                   for (var co in coApplicants)
// // //                     Column(
// // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // //                       children: [
// // //                         _infoRow("Name", co["name"]),
// // //                         _infoRow("Mobile", co["mobile"]),
// // //                         _infoRow("Email", co["email"]),
// // //                         _infoRow("PAN", co["pan"]),
// // //                         const Divider(),
// // //                       ],
// // //                     ),
// // //                 ],
// // //               ),

// // //             // ✅ ADD BELOW CO-APPLICANT CARD
// // //             const SizedBox(height: 16),

// // //             _finalSanctionTermsSection(),

// // //             const SizedBox(height: 16),

// // //             _bankRelatedDocumentsSection(
// // //               docTypes: docTypes,
// // //               uploadedFiles: uploadedFiles,
// // //               onChooseFiles: () {
// // //                 // TODO: integrate file picker
// // //               },
// // //               onUpload: () {
// // //                 // TODO: upload API call
// // //               },
// // //               onViewFile: (file) {
// // //                 // TODO: open file preview
// // //               },
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// //  class CaseDetailsPage extends StatefulWidget {
// //   final Map<String, dynamic> caseData;

// //   const CaseDetailsPage({super.key, required this.caseData});

// //   @override
// //   State<CaseDetailsPage> createState() => _CaseDetailsPageState();
// // }

// // class _CaseDetailsPageState extends State<CaseDetailsPage> {

// //  final TextEditingController sanctionAmountController = TextEditingController();
// // final TextEditingController tenureController = TextEditingController();
// // final TextEditingController interestRateController = TextEditingController();
// // final TextEditingController penalChargesController = TextEditingController();
// // final TextEditingController processingFeesController = TextEditingController();

// //  Future<void> fetchSanctionTerms() async {
// //   final prefs = await SharedPreferences.getInstance();
// //   final token = prefs.getString("token");
// //   final customerId = prefs.getInt("customerId");

// //   final response = await http.get(
// //     // Uri.parse("${ApiEndpoints.baseUrl}/$customerId"),
// //               Uri.parse("${ApiEndpoints.baseUrl}/customers/$customerId"),

// //     headers: {
// //       "Authorization": "Bearer $token",
// //       "Content-Type": "application/json",
// //     },
// //   );

// //   print("STATUS: ${response.statusCode}");
// //   print("BODY: ${response.body}");

// //   if (response.statusCode == 200) {

// //     final responseData = jsonDecode(response.body);
// //     final data = responseData["data"];   // ⭐ VERY IMPORTANT

// //     sanctionAmountController.text =
// //         data["sanctionAmount"]?.toString() ?? "";

// //     tenureController.text =
// //         data["tenure"]?.toString() ?? "";

// //     interestRateController.text =
// //         data["interestRate"]?.toString() ?? "";

// //     penalChargesController.text =
// //         data["penalCharges"]?.toString() ?? "";

// //     processingFeesController.text =
// //         data["processingFees"]?.toString() ?? "";

// //     setState(() {});
// //   }
// // }
// // // Future<void> fetchSanctionTerms() async {
// // //   final prefs = await SharedPreferences.getInstance();
// // //   final token = prefs.getString("token");
// // //   final customerId = prefs.getInt("customerId");

// // //   final response = await http.get(
// // //     // Uri.parse("${ApiEndpoints.baseUrl}/sanction-terms/$customerId"),
// // //           Uri.parse("${ApiEndpoints.baseUrl}/customers/$customerId"),

// // //     headers: {
// // //       "Authorization": "Bearer $token",
// // //       "Content-Type": "application/json",
// // //     },
// // //   );

// // //   print("STATUS: ${response.statusCode}");
// // //   print("BODY: ${response.body}");

// // //   if (response.statusCode == 200) {
// // //     final responseData = jsonDecode(response.body);

// // //     final data = responseData["data"]; // important
// // // sanctionAmountController.text =
// // //     data["sanctionAmount"]?.toString() ?? "";

// // // tenureController.text =
// // //     data["tenure"]?.toString() ?? "";

// // // interestRateController.text =
// // //     data["interestRate"]?.toString() ?? "";

// // // penalChargesController.text =
// // //     data["penalCharges"]?.toString() ?? "";

// // // processingFeesController.text =
// // //     data["processingFees"]?.toString() ?? "";

// // //     setState(() {});
// // //   }
// // // }
// // //  Future<void> fetchSanctionTerms() async {
// // //       final prefs = await SharedPreferences.getInstance();
// // //     final token = prefs.getString("token");
// // //                final customerId = prefs.getInt("customerId");

// // //     final response = await http.get(
// // //       Uri.parse("${ApiEndpoints.baseUrl}/customers/$customerId"),
// // //       headers: {
// // //         "Authorization": "Bearer $token",
// // //         "Content-Type": "application/json",
// // //       },
// // //     );
// // //   // final response = await http.get(
// // //   //   Uri.parse("https://supplychain-prod.fintreelms.com/api/customers/105"),
// // //   // );
// // //  print("API STATUS: ${response.statusCode}");
// // //   print("API BODY: ${response.body}");
// // //   if (response.statusCode == 200) {
// // //     final data = jsonDecode(response.body);

// // //     sanctionAmountController.text =
// // //         data["sanctionAmount"]?.toString() ?? "";

// // //     tenureController.text =
// // //         data["tenure"]?.toString() ?? "";

// // //     interestRateController.text =
// // //         data["interestRate"]?.toString() ?? "";

// // //     penalChargesController.text =
// // //         data["penalCharges"]?.toString() ?? "";

// // //     processingFeesController.text =
// // //         data["processingFees"]?.toString() ?? "";

// // //     setState(() {});
// // //   }
// // // }

// //   @override
// // void initState() {
// //   super.initState();
// //   fetchSanctionTerms();
// // }
// //   Widget build(BuildContext context) {

// //     final company = widget.caseData["company"] ?? {};
// //     final applicant = widget.caseData["applicant"] ?? {};
// //     final coApplicants = widget.caseData["coApplicants"] ?? [];

// //     /// Dummy files list
// //     final uploadedFiles = [
// //       {
// //         "name": "sample-pan-card.jpg",
// //         "docType": "GST_CERTIFICATE",
// //         "tag": "APPLICANT",
// //         "date": "02 Mar 2026",
// //       },
// //       {
// //         "name": "scaled_pan_dummy1.webp",
// //         "docType": "PAN_CARD",
// //         "tag": "APPLICANT",
// //         "date": "02 Mar 2026",
// //       },
// //     ];

// //     final docTypes = const [
// //       "GST_CERTIFICATE",
// //       "PAN_CARD",
// //       "BANK_STATEMENT",
// //       "CHEQUE",
// //       "OTHER",
// //     ];

// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF5F7FB),
// //       appBar: AppBar(title: const Text("Customer Information")),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           children: [

// //             /// COMPANY CARD
// //             _card(
// //               title: "Company Details",
// //               children: [
// //                 _infoRow("Company Type", company["companyType"]),
// //                 _infoRow("Company Name", company["companyName"]),
// //                 _infoRow("Company Mobile", company["mobile"]),
// //                 _infoRow("Company Email", company["email"]),
// //                 _infoRow("Company GST", company["gst"]),
// //               ],
// //             ),

// //             const SizedBox(height: 16),

// //             /// APPLICANT CARD
// //             _card(
// //               title: "Applicant Details",
// //               children: [
// //                 _infoRow("Name", applicant["name"]),
// //                 _infoRow("Mobile", applicant["mobile"]),
// //                 _infoRow("Email", applicant["email"]),
// //                 _infoRow("PAN", applicant["pan"]),
// //               ],
// //             ),

// //             const SizedBox(height: 16),

// //             /// CO APPLICANT
// //             if (coApplicants.isNotEmpty)
// //               _card(
// //                 title: "Co-Applicant Details",
// //                 children: [
// //                   for (var co in coApplicants)
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         _infoRow("Name", co["name"]),
// //                         _infoRow("Mobile", co["mobile"]),
// //                         _infoRow("Email", co["email"]),
// //                         _infoRow("PAN", co["pan"]),
// //                         const Divider(),
// //                       ],
// //                     ),
// //                 ],
// //               ),

// //             const SizedBox(height: 16),

// //             _finalSanctionTermsSection(),

// //             const SizedBox(height: 16),

// //             _bankRelatedDocumentsSection(
// //               docTypes: docTypes,
// //               uploadedFiles: uploadedFiles,
// //               onChooseFiles: () {},
// //               onUpload: () {},
// //               onViewFile: (file) {},
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //    Widget _finalSanctionTermsSection() {
// //   final terms = [
// //     "SANCTION AMOUNT",
// //     "TENURE (MONTHS)",
// //     "INTEREST RATE (%)",
// //     "PENAL CHARGES (%)",
// //     "PROCESSING FEES (%)",
// //   ];

// //   return Container(
// //     padding: const EdgeInsets.all(20),
// //     decoration: BoxDecoration(
// //       color: const Color(0xFFF3F4F6), // light background like screenshot
// //       borderRadius: BorderRadius.circular(18),
// //       border: Border.all(
// //         color: const Color(0xFF4F46E5), // blue border
// //         width: 1.5,
// //       ),
// //     ),
// //     child: Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         /// HEADER
// //         Row(
// //           children: const [
// //             Expanded(
// //               child: Text(
// //                 "Final Sanction Terms",
// //                 style: TextStyle(
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //               ),
// //             ),
// //             Icon(
// //               Icons.send,
// //               size: 18,
// //               color: Color(0xFF4F46E5),
// //             ),
// //           ],
// //         ),
// //         const SizedBox(height: 20),

// //         /// GRID BOXES
// //         LayoutBuilder(
// //           builder: (context, constraints) {
// //             final isWide = constraints.maxWidth > 600;

// //             return GridView.builder(
// //               itemCount: terms.length,
// //               shrinkWrap: true,
// //               physics: const NeverScrollableScrollPhysics(),
// //               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //                 crossAxisCount: isWide ? 3 : 2,
// //                 crossAxisSpacing: 18,
// //                 mainAxisSpacing: 18,
// //                 childAspectRatio: 1.2,
// //               ),
// // itemBuilder: (context, index) {

// //   TextEditingController controller;

// //   switch (index) {
// //     case 0:
// //       controller = sanctionAmountController;
// //       break;
// //     case 1:
// //       controller = tenureController;
// //       break;
// //     case 2:
// //       controller = interestRateController;
// //       break;
// //     case 3:
// //       controller = penalChargesController;
// //       break;
// //     case 4:
// //       controller = processingFeesController;
// //       break;
// //     default:
// //       controller = TextEditingController();
// //   }

// //   return Container(
// //     padding: const EdgeInsets.symmetric(
// //       horizontal: 16,
// //       vertical: 14,
// //     ),
// //     decoration: BoxDecoration(
// //       color: const Color(0xFFDDE2F1),
// //       borderRadius: BorderRadius.circular(14),
// //     ),
// //     child: Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [

// //         /// LABEL
// //         Text(
// //           terms[index],
// //           style: const TextStyle(
// //             fontSize: 12,
// //             fontWeight: FontWeight.w700,
// //             color: Color(0xFF4F46E5),
// //             letterSpacing: 0.5,
// //           ),
// //         ),

// //         /// INPUT FIELD
// //         TextFormField(
// //           controller: controller,   // 👈 controller used here
// //           keyboardType: TextInputType.number,
// //           decoration: const InputDecoration(
// //             hintText: "Enter value",
// //             border: InputBorder.none,
// //             isDense: true,
// //             contentPadding: EdgeInsets.zero,
// //           ),
// //           style: const TextStyle(
// //             fontSize: 16,
// //             fontWeight: FontWeight.w600,
// //             color: Colors.black87,
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// // }
// // //  itemBuilder: (context, index) {
// // //   return Container(
// // //     padding: const EdgeInsets.symmetric(
// // //       horizontal: 16,
// // //       vertical: 14,
// // //     ),
// // //     decoration: BoxDecoration(
// // //       color: const Color(0xFFDDE2F1),
// // //       borderRadius: BorderRadius.circular(14),
// // //     ),
// // //     child: Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //       children: [
// // //         /// LABEL
// // //         Text(
// // //           terms[index],
// // //           style: const TextStyle(
// // //             fontSize: 12,
// // //             fontWeight: FontWeight.w700,
// // //             color: Color(0xFF4F46E5),
// // //             letterSpacing: 0.5,
// // //           ),
// // //         ),

// // //         /// INPUT FIELD
// // //         // TextFormField(
// // //         //   keyboardType: TextInputType.number,
// // //         //   maxLines: 1,
// // //         //   decoration: const InputDecoration(
// // //         //     hintText: "Enter value",
// // //         //     border: InputBorder.none,
// // //         //     isDense: true,
// // //         //     contentPadding: EdgeInsets.zero,
// // //         //   ),
// // //         //   style: const TextStyle(
// // //         //     fontSize: 16,
// // //         //     fontWeight: FontWeight.w600,
// // //         //     color: Colors.black87,
// // //         //   ),
// // //         // ),
// // //         TextFormField(
// // //   controller: sanctionAmountController,
// // //   keyboardType: TextInputType.number,
// // //   decoration: const InputDecoration(
// // //     hintText: "Enter value",
// // //     border: InputBorder.none,
// // //     isDense: true,
// // //     contentPadding: EdgeInsets.zero,
// // //   ),
// // // )
// // //       ],
// // //     ),
// // //   );
// // // }
// //             );
// //           },
// //         ),
// //       ],
// //     ),
// //   );
// // }

// // }

// //   // ---------------------------
// //   // SECTION: Final Sanction Terms (same style as screenshot)
// //   // ---------------------------

// //   // ---------------------------
// //   // SECTION: Bank Related Documents (same layout as screenshot)
// //   // ---------------------------
// //  Widget _bankRelatedDocumentsSection({
// //   required List<String> docTypes,
// //   required List<Map<String, String>> uploadedFiles,
// //   required VoidCallback onChooseFiles,
// //   required VoidCallback onUpload,
// //   required Function(Map<String, String> file) onViewFile,
// // }) {
// //   return Container(
// //     padding: const EdgeInsets.all(18),
// //     decoration: BoxDecoration(
// //       color: Colors.white,
// //       borderRadius: BorderRadius.circular(18),
// //       border: Border.all(color: Colors.grey.shade200),
// //       boxShadow: [
// //         BoxShadow(
// //           color: Colors.black.withOpacity(0.04),
// //           blurRadius: 14,
// //           offset: const Offset(0, 8),
// //         ),
// //       ],
// //     ),
// //     child: LayoutBuilder(
// //       builder: (context, constraints) {
// //         bool isSmallScreen = constraints.maxWidth < 700;

// //         return Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [

// //             /// 🔹 Top Section
// //             isSmallScreen
// //                 ? Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       const Text(
// //                         "Bank Related Documents",
// //                         style: TextStyle(
// //                           fontSize: 20,
// //                           fontWeight: FontWeight.w800,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 16),
// //                       _documentDropdown(docTypes),
// //                     ],
// //                   )
// //                 : Row(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       const Expanded(
// //                         flex: 2,
// //                         child: Text(
// //                           "Bank Related\nDocuments",
// //                           style: TextStyle(
// //                             fontSize: 22,
// //                             fontWeight: FontWeight.w800,
// //                             height: 1.2,
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(width: 16),
// //                       Expanded(
// //                         flex: 3,
// //                         child: _documentDropdown(docTypes),
// //                       ),
// //                     ],
// //                   ),

// //             const SizedBox(height: 18),

// //             /// 🔹 Buttons Row
// //             isSmallScreen
// //                 ? Column(
// //                     children: [
// //                       SizedBox(
// //                         width: double.infinity,
// //                         child: OutlinedButton.icon(
// //                           onPressed: onChooseFiles,
// //                           icon: const Icon(Icons.upload_file),
// //                           label: const Text("Choose Files"),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 12),
// //                       SizedBox(
// //                         width: double.infinity,
// //                         height: 48,
// //                         child: ElevatedButton(
// //                           onPressed: onUpload,
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: const Color(0xFF9DB5FF),
// //                           ),
// //                           child: const Text("Upload"),
// //                         ),
// //                       ),
// //                     ],
// //                   )
// //                 : Row(
// //                     children: [
// //                       Expanded(
// //                         child: OutlinedButton.icon(
// //                           onPressed: onChooseFiles,
// //                           icon: const Icon(Icons.upload_file),
// //                           label: const Text("Choose Files"),
// //                         ),
// //                       ),
// //                       const SizedBox(width: 12),
// //                       SizedBox(
// //                         height: 48,
// //                         child: ElevatedButton(
// //                           onPressed: onUpload,
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: const Color(0xFF9DB5FF),
// //                           ),
// //                           child: const Text("Upload"),
// //                         ),
// //                       ),
// //                     ],
// //                   ),

// //             const SizedBox(height: 18),

// //             /// 🔹 Uploaded Files List
// //             if (uploadedFiles.isEmpty)
// //               const Text(
// //                 "No documents uploaded yet.",
// //                 style: TextStyle(color: Colors.grey),
// //               )
// //             else
// //               ...uploadedFiles.map(
// //                 (f) => Padding(
// //                   padding: const EdgeInsets.only(bottom: 12),
// //                   child: _fileRow(
// //                     name: f["name"] ?? "-",
// //                     type: f["docType"] ?? "-",
// //                     tag: f["tag"] ?? "-",
// //                     date: f["date"] ?? "-",
// //                     onView: () => onViewFile(f),
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         );
// //       },
// //     ),
// //   );
// // }

// // Widget _documentDropdown(List<String> docTypes) {
// //   return Column(
// //     crossAxisAlignment: CrossAxisAlignment.start,
// //     children: [
// //       const Text(
// //         "Document Type",
// //         style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
// //       ),
// //       const SizedBox(height: 8),
// //       Container(
// //         padding: const EdgeInsets.symmetric(horizontal: 12),
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           border: Border.all(color: Colors.grey.shade300),
// //         ),
// //         child: DropdownButtonHideUnderline(
// //           child: DropdownButton<String>(
// //             isExpanded: true,
// //             hint: const Text("Select document type"),
// //             items: docTypes
// //                 .map((e) => DropdownMenuItem<String>(
// //                       value: e,
// //                       child: Text(
// //                         e,
// //                         overflow: TextOverflow.ellipsis,
// //                       ),
// //                     ))
// //                 .toList(),
// //             onChanged: (_) {},
// //           ),
// //         ),
// //       ),
// //     ],
// //   );
// // }

// //   Widget _fileRow({
// //   required String name,
// //   required String type,
// //   required String tag,
// //   required String date,
// //   required VoidCallback onView,
// // }) {
// //   return LayoutBuilder(
// //     builder: (context, constraints) {
// //       bool isSmall = constraints.maxWidth < 600;

// //       return Container(
// //         margin: const EdgeInsets.only(bottom: 12),
// //         padding: const EdgeInsets.all(14),
// //         decoration: BoxDecoration(
// //           color: const Color(0xFFF7F8FC),
// //           borderRadius: BorderRadius.circular(14),
// //           border: Border.all(color: Colors.grey.shade200),
// //         ),
// //         child: isSmall
// //             ? Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     children: [
// //                       Container(
// //                         width: 36,
// //                         height: 36,
// //                         decoration: BoxDecoration(
// //                           color: Colors.white,
// //                           borderRadius: BorderRadius.circular(10),
// //                           border: Border.all(color: Colors.grey.shade200),
// //                         ),
// //                         child: const Icon(
// //                           Icons.insert_drive_file,
// //                           size: 18,
// //                           color: Color(0xFF2563EB),
// //                         ),
// //                       ),
// //                       const SizedBox(width: 10),
// //                       Expanded(
// //                         child: Text(
// //                           name,
// //                           style: const TextStyle(
// //                             fontWeight: FontWeight.w700,
// //                           ),
// //                           overflow: TextOverflow.ellipsis,
// //                         ),
// //                       ),
// //                       IconButton(
// //                         onPressed: onView,
// //                         icon: const Icon(
// //                           Icons.visibility,
// //                           color: Color(0xFF2563EB),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 6),
// //                   Text(
// //                     type,
// //                     style: const TextStyle(
// //                       fontSize: 12,
// //                       color: Colors.grey,
// //                     ),
// //                     overflow: TextOverflow.ellipsis,
// //                   ),
// //                   const SizedBox(height: 8),
// //                   Row(
// //                     children: [
// //                       Container(
// //                         padding: const EdgeInsets.symmetric(
// //                           horizontal: 10,
// //                           vertical: 4,
// //                         ),
// //                         decoration: BoxDecoration(
// //                           color: Colors.white,
// //                           borderRadius: BorderRadius.circular(20),
// //                           border: Border.all(color: Colors.grey.shade300),
// //                         ),
// //                         child: Text(
// //                           tag,
// //                           style: const TextStyle(
// //                             fontSize: 11,
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                         ),
// //                       ),
// //                       const Spacer(),
// //                       Text(
// //                         date,
// //                         style: const TextStyle(
// //                           fontSize: 12,
// //                           color: Colors.grey,
// //                         ),
// //                         overflow: TextOverflow.ellipsis,
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               )
// //             : Row(
// //                 children: [
// //                   Container(
// //                     width: 36,
// //                     height: 36,
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(10),
// //                       border: Border.all(color: Colors.grey.shade200),
// //                     ),
// //                     child: const Icon(
// //                       Icons.insert_drive_file,
// //                       size: 18,
// //                       color: Color(0xFF2563EB),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),

// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           name,
// //                           style: const TextStyle(
// //                             fontWeight: FontWeight.w700,
// //                           ),
// //                           overflow: TextOverflow.ellipsis,
// //                         ),
// //                         const SizedBox(height: 2),
// //                         Text(
// //                           type,
// //                           style: const TextStyle(
// //                             fontSize: 12,
// //                             color: Colors.grey,
// //                           ),
// //                           overflow: TextOverflow.ellipsis,
// //                         ),
// //                       ],
// //                     ),
// //                   ),

// //                   const SizedBox(width: 10),

// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 10,
// //                       vertical: 4,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(20),
// //                       border: Border.all(color: Colors.grey.shade300),
// //                     ),
// //                     child: Text(
// //                       tag,
// //                       style: const TextStyle(
// //                         fontSize: 11,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                     ),
// //                   ),

// //                   const SizedBox(width: 12),

// //                   Flexible(
// //                     child: Text(
// //                       date,
// //                       style: const TextStyle(
// //                         fontSize: 12,
// //                         color: Colors.grey,
// //                       ),
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                   ),

// //                   const SizedBox(width: 6),

// //                   IconButton(
// //                     onPressed: onView,
// //                     icon: const Icon(
// //                       Icons.visibility,
// //                       color: Color(0xFF2563EB),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //       );
// //     },
// //   );
// // }

// //   Widget _chip(String text) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(999),
// //         border: Border.all(color: Colors.grey.shade300),
// //       ),
// //       child: Text(
// //         text,
// //         style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
// //       ),
// //     );
// //   }

// //   Widget _card({required String title, required List<Widget> children}) {
// //     return Container(
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 16,
// //             offset: const Offset(0, 8),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             title,
// //             style: const TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.w600,
// //               color: Color(0xFF2563EB),
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //           ...children,
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _infoRow(String label, dynamic value) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 6),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             flex: 4,
// //             child: Text(
// //               label,
// //               style: const TextStyle(color: Colors.grey, fontSize: 13),
// //             ),
// //           ),
// //           Expanded(
// //             flex: 6,
// //             child: Text(
// //               value?.toString() ?? "N/A",
// //               style: const TextStyle(fontWeight: FontWeight.w500),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// // class _TermBox extends StatelessWidget {
// //   final String title;

// //   const _TermBox({required this.title});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.all(14),
// //       decoration: BoxDecoration(
// //         color: const Color(0xFFEFF4FF),
// //         borderRadius: BorderRadius.circular(14),
// //       ),
// //       child: Align(
// //         alignment: Alignment.topLeft,
// //         child: Text(
// //           title,
// //           style: const TextStyle(
// //             fontSize: 12,
// //             fontWeight: FontWeight.w800,
// //             color: Color(0xFF2563EB),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class CaseCard extends StatelessWidget {
// //   final Map<String, dynamic> caseData;
// //   final String status;
// //   final String date;

// //   const CaseCard({
// //     super.key,
// //     required this.caseData,
// //     required this.status,
// //     required this.date,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     final applicant = caseData["applicant"] ?? {};
// //     final company = caseData["company"] ?? {};

// //     final name = applicant["name"] ?? company["companyName"] ?? "Unknown";
// //     final mobile = applicant["mobile"] ?? company["mobile"] ?? "";
// //     final pan = applicant["pan"] ?? "N/A";
// //     final lan = caseData["lan"] ?? "Pending";

// //     return InkWell(
// //       borderRadius: BorderRadius.circular(16),
// //       onTap: () {
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //             builder: (_) => CaseDetailsPage(caseData: caseData),
// //           ),
// //         );
// //       },
// //       child: Container(
// //         margin: const EdgeInsets.only(bottom: 16),
// //         padding: const EdgeInsets.all(16),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(16),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.05),
// //               blurRadius: 16,
// //               offset: const Offset(0, 8),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Text(
// //                   name,
// //                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
// //                 ),
// //                 _statusChip(status),
// //               ],
// //             ),
// //             const SizedBox(height: 10),
// //             Text("Mobile: $mobile"),
// //             const SizedBox(height: 6),
// //             Text("PAN: $pan | LAN: $lan"),
// //             const SizedBox(height: 6),
// //             Text(date, style: const TextStyle(color: Colors.grey)),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _statusChip(String status) {
// //     Color bg;
// //     Color fg;

// //     switch (status) {
// //       case "Completed":
// //         bg = const Color(0xFFD1FAE5);
// //         fg = const Color(0xFF065F46);
// //         break;
// //       case "Draft":
// //         bg = const Color(0xFFE5E7EB);
// //         fg = const Color(0xFF374151);
// //         break;
// //       case "Ops L1 Approved":
// //         bg = const Color(0xFFDBEAFE);
// //         fg = const Color(0xFF1D4ED8);
// //         break;
// //       case "MD Approved":
// //         bg = const Color(0xFFFDE68A);
// //         fg = const Color(0xFF92400E);
// //         break;
// //       default:
// //         bg = const Color(0xFFE5E7EB);
// //         fg = Colors.black;
// //     }

// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //       decoration: BoxDecoration(
// //         color: bg,
// //         borderRadius: BorderRadius.circular(20),
// //       ),
// //       child: Text(
// //         status,
// //         style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
// //       ),
// //     );
// //   }
// // }

// //  https://supplychain-prod.fintreelms.com/api/customers?status=submitted

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supply_chain/core/constants/api_endpoints.dart';

// class SubmittedCasesPage extends StatefulWidget {
//   const SubmittedCasesPage({super.key});

//   @override
//   State<SubmittedCasesPage> createState() => _SubmittedCasesPageState();
// }

// class _SubmittedCasesPageState extends State<SubmittedCasesPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<dynamic> submittedCases = [];

//   final tabs = ["Submitted"];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: tabs.length, vsync: this);
//     _loadSubmittedCases();
//   }

//   Future<void> _loadSubmittedCases() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString("token");

//       final response = await http.get(
//         Uri.parse("${ApiEndpoints.baseUrl}/customers?status=submitted"),

//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//       );

//       final body = jsonDecode(response.body);

//       if (body["success"] == true) {
//         final List data = body["data"];

//         final submitted = data.where((c) {
//           return c["status"] == "submitted";
//         }).toList();

//         setState(() {
//           submittedCases = submitted;
//         });
//       }
//     } catch (e) {
//       print("Error loading cases: $e");
//     }
//   }

//   // Future<void> _loadSubmittedCases() async {
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final token = prefs.getString("token");

//   //     final response = await http.get(
//   //       Uri.parse("${ApiEndpoints.baseUrl}/customers?status=submitted"),
//   //       headers: {
//   //         "Authorization": "Bearer $token",
//   //         "Content-Type": "application/json",
//   //       },
//   //     );
//   //       print("STATUS: ${response.statusCode}");
//   //     print("BODY: ${response.body}");

//   //     final body = jsonDecode(response.body);

//   //     if (body["success"] == true) {
//   //       final List data = body["data"];

//   //       final submitted = data.where((c) {
//   //         return c["status"] == "completed";
//   //       }).toList();

//   //       setState(() {
//   //         submittedCases = submitted;
//   //       });
//   //     }
//   //   } catch (e) {
//   //     print("Error loading submitted cases: $e");
//   //   }
//   // }

//   // Future<void> _loadSubmittedCases() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final submittedString = prefs.getString("submitted_cases");

//   //   if (submittedString == null) return;

//   //   final decoded = jsonDecode(submittedString);

//   //   final List<Map<String, dynamic>> cleanList = [];

//   //   if (decoded is List) {
//   //     for (final item in decoded) {
//   //       if (item is Map<String, dynamic>) {
//   //         cleanList.add(item);
//   //       } else if (item is List) {
//   //         for (final inner in item) {
//   //           if (inner is Map<String, dynamic>) {
//   //             cleanList.add(inner);
//   //           }
//   //         }
//   //       }
//   //     }
//   //   }

//   //   setState(() {
//   //     submittedCases = cleanList;
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FB),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         title: const Text(
//           "Supply Chain Finance",
//           style: TextStyle(color: Colors.black),
//         ),
//       ),
//       body: Column(
//         children: [
//           TabBar(
//             controller: _tabController,
//             labelColor: const Color(0xFF2563EB),
//             unselectedLabelColor: Colors.grey,
//             tabs: tabs.map((t) => Tab(text: t)).toList(),
//           ),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [_caseList()],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _caseList() {
//     if (submittedCases.isEmpty) {
//       return const Center(child: Text("No submitted cases"));
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: submittedCases.length,
//       itemBuilder: (context, index) {
//         final raw = submittedCases[index];
//         if (raw is! Map<String, dynamic>) return const SizedBox();

//         final caseData = raw;

//         return CaseCard(
//           caseData: caseData,
//           status: "Submitted",
//           date: "Completed",
//         );
//       },
//     );
//   }
// }

// class CaseDetailsPage extends StatefulWidget {
//   // final Map<String, dynamic> caseData;

//   // const CaseDetailsPage({super.key, required this.caseData});
//   final int customerId;

//   const CaseDetailsPage({super.key, required this.customerId});
//   @override
//   State<CaseDetailsPage> createState() => _CaseDetailsPageState();
// }

// class _CaseDetailsPageState extends State<CaseDetailsPage> {
//   Map<String, dynamic>? customerData;
//   bool loading = true;

//   Future<void> fetchCustomerDetails() async {
//     try {
//       print("Calling API for customer: ${widget.customerId}");

//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString("token");

//       final url = "${ApiEndpoints.baseUrl}/customers/${widget.customerId}";
//       print("URL: $url");

//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//       );

//       print("Response status: ${response.statusCode}");
//       print("Response body: ${response.body}");

//       final body = jsonDecode(response.body);

//       if (body["success"] == true) {
//         setState(() {
//           customerData = body["data"];
//         });
//       }
//     } catch (e) {
//       print("Error fetching customer details: $e");
//     } finally {
//       setState(() {
//         loading = false;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();

//     fetchCustomerDetails();
//     print("CaseDetailsPage opened");
//     print("CustomerId: ${widget.customerId}");
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//     // final company = widget.caseData["company"] ?? {};
//     // final applicant = widget.caseData["applicant"] ?? {};
//     // final coApplicants = widget.caseData["coApplicants"] ?? [];
//     final caseData = customerData;
//     final coApplicants = caseData?["coApplicants"] ?? [];
//     final addresses = caseData?["addresses"] ?? [];
//     final contacts = caseData?["contactPersons"] ?? [];

//     /// Dummy files list
//     final uploadedFiles = [
//       {
//         "name": "sample-pan-card.jpg",
//         "docType": "GST_CERTIFICATE",
//         "tag": "APPLICANT",
//         "date": "02 Mar 2026",
//       },
//       {
//         "name": "scaled_pan_dummy1.webp",
//         "docType": "PAN_CARD",
//         "tag": "APPLICANT",
//         "date": "02 Mar 2026",
//       },
//     ];

//     final docTypes = const [
//       "GST_CERTIFICATE",
//       "PAN_CARD",
//       "BANK_STATEMENT",
//       "CHEQUE",
//       "OTHER",
//     ];

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FB),
//       appBar: AppBar(title: const Text("Customer Information")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             /// COMPANY CARD
//             _card(
//               title: "Company Details",
//               children: [
//                 _infoRow("Company Type", caseData?["companyType"]),
//                 _infoRow("Company Name", caseData?["companyName"]),
//                 _infoRow("Company Mobile", caseData?["companyMobile"]),
//                 _infoRow("Company Email", caseData?["companyEmail"]),
//                 _infoRow("Company GST", caseData?["gstNumber"]),
//               ],
//             ),

//             const SizedBox(height: 16),

//             /// APPLICANT CARD
//             if (addresses is List && addresses.isNotEmpty)
//               _card(
//                 title: "Address Details",
//                 children: [
//                   for (final addr in addresses)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _infoRow("Address Line", addr["addressLine1"]),
//                         _infoRow("City", addr["city"]),
//                         _infoRow("State", addr["state"]),
//                         _infoRow("Pincode", addr["pincode"]),
//                         const Divider(),
//                       ],
//                     ),
//                 ],
//               ),

//             const SizedBox(height: 16),

//             /// CO APPLICANT
//             ///
//             if (coApplicants is List && coApplicants.isNotEmpty)
//               _card(
//                 title: "Co-Applicant Details",
//                 children: [
//                   for (final co in coApplicants)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _infoRow("Name", co["name"] ?? "-"),
//                         _infoRow("Mobile", co["mobile"] ?? "-"),
//                         _infoRow("Email", co["email"] ?? "-"),
//                         _infoRow("PAN", co["pan"] ?? "-"),
//                         const Divider(),
//                       ],
//                     ),
//                 ],
//               ),

//             const SizedBox(height: 16),
//             if (contacts is List && contacts.isNotEmpty)
//               _card(
//                 title: "Contact Person Details",
//                 children: [
//                   for (final person in contacts)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _infoRow("Name", person["name"]),
//                         _infoRow("Mobile", person["mobile"]),
//                         _infoRow("Email", person["email"]),
//                         const Divider(),
//                       ],
//                     ),
//                 ],
//               ),
//             // const FinalSanctionTermsSection(),
//             FinalSanctionTermsSection(customerId: widget.customerId),

//             const SizedBox(height: 16),

//             _bankRelatedDocumentsSection(
//               docTypes: docTypes,
//               uploadedFiles: uploadedFiles,
//               onChooseFiles: () {},
//               onUpload: () {},
//               onViewFile: (file) {},
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ---------------------------
// // SECTION: Final Sanction Terms (same style as screenshot)
// // ---------------------------
// class FinalSanctionTermsSection extends StatefulWidget {
//   final int customerId;
//   const FinalSanctionTermsSection({super.key, required this.customerId});
//   // const FinalSanctionTermsSection({super.key});

//   @override
//   State<FinalSanctionTermsSection> createState() =>
//       _FinalSanctionTermsSectionState();
// }

// class _FinalSanctionTermsSectionState extends State<FinalSanctionTermsSection> {
//   Map<String, dynamic>? sanctionData;
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchSanctionTerms();
//   }

//   Future<void> fetchSanctionTerms() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString("token");
//       // final int? customerId = prefs.getInt("customerId");
//       final customerId = widget.customerId;
     
//       final response = await http.get(
//         Uri.parse("${ApiEndpoints.baseUrl}/customers/$customerId"),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//       );

//       final body = jsonDecode(response.body);

//       final sanctions = body["data"]?["creditSanctions"];

//       if (sanctions != null && sanctions.isNotEmpty) {
//         sanctionData = sanctions.last;
//       }

//       setState(() {
//         loading = false;
//       });
//     } catch (e) {
//       loading = false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     final terms = [
//       "SANCTION AMOUNT",
//       "TENURE (MONTHS)",
//       "INTEREST RATE (%)",
//       "PENAL CHARGES (%)",
//       "PROCESSING FEES (%)",
//     ];

//     final controllers = [
//       TextEditingController(
//         text: sanctionData?["sanctionAmount"]?.toString() ?? "",
//       ),
//       TextEditingController(text: sanctionData?["tenure"]?.toString() ?? ""),
//       TextEditingController(
//         text: sanctionData?["interestRate"]?.toString() ?? "",
//       ),
//       TextEditingController(
//         text: sanctionData?["penalCharges"]?.toString() ?? "",
//       ),
//       TextEditingController(
//         text: sanctionData?["processingFees"]?.toString() ?? "",
//       ),
//     ];

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
//           GridView.builder(
//             itemCount: terms.length,
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 18,
//               mainAxisSpacing: 18,
//               childAspectRatio: 1.2,
//             ),
//             itemBuilder: (context, index) {
//               return Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 14,
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFDDE2F1),
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       terms[index],
//                       style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF4F46E5),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     TextFormField(
//                       controller: controllers[index],
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(
//                         hintText: "Enter value",
//                         border: InputBorder.none,
//                         isDense: true,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ---------------------------
// // SECTION: Bank Related Documents (same layout as screenshot)
// // ---------------------------
// Widget _bankRelatedDocumentsSection({
//   required List<String> docTypes,
//   required List<Map<String, String>> uploadedFiles,
//   required VoidCallback onChooseFiles,
//   required VoidCallback onUpload,
//   required Function(Map<String, String> file) onViewFile,
// }) {
//   return Container(
//     padding: const EdgeInsets.all(18),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(18),
//       border: Border.all(color: Colors.grey.shade200),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.04),
//           blurRadius: 14,
//           offset: const Offset(0, 8),
//         ),
//       ],
//     ),
//     child: LayoutBuilder(
//       builder: (context, constraints) {
//         bool isSmallScreen = constraints.maxWidth < 700;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// 🔹 Top Section
//             isSmallScreen
//                 ? Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         "Bank Related Documents",
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       _documentDropdown(docTypes),
//                     ],
//                   )
//                 : Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Expanded(
//                         flex: 2,
//                         child: Text(
//                           "Bank Related\nDocuments",
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.w800,
//                             height: 1.2,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(flex: 3, child: _documentDropdown(docTypes)),
//                     ],
//                   ),

//             const SizedBox(height: 18),

//             /// 🔹 Buttons Row
//             isSmallScreen
//                 ? Column(
//                     children: [
//                       SizedBox(
//                         width: double.infinity,
//                         child: OutlinedButton.icon(
//                           onPressed: onChooseFiles,
//                           icon: const Icon(Icons.upload_file),
//                           label: const Text("Choose Files"),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       SizedBox(
//                         width: double.infinity,
//                         height: 48,
//                         child: ElevatedButton(
//                           onPressed: onUpload,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF9DB5FF),
//                           ),
//                           child: const Text("Upload"),
//                         ),
//                       ),
//                     ],
//                   )
//                 : Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: onChooseFiles,
//                           icon: const Icon(Icons.upload_file),
//                           label: const Text("Choose Files"),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       SizedBox(
//                         height: 48,
//                         child: ElevatedButton(
//                           onPressed: onUpload,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF9DB5FF),
//                           ),
//                           child: const Text("Upload"),
//                         ),
//                       ),
//                     ],
//                   ),

//             const SizedBox(height: 18),

//             /// 🔹 Uploaded Files List
//             if (uploadedFiles.isEmpty)
//               const Text(
//                 "No documents uploaded yet.",
//                 style: TextStyle(color: Colors.grey),
//               )
//             else
//               ...uploadedFiles.map(
//                 (f) => Padding(
//                   padding: const EdgeInsets.only(bottom: 12),
//                   child: _fileRow(
//                     name: f["name"] ?? "-",
//                     type: f["docType"] ?? "-",
//                     tag: f["tag"] ?? "-",
//                     date: f["date"] ?? "-",
//                     onView: () => onViewFile(f),
//                   ),
//                 ),
//               ),
//           ],
//         );
//       },
//     ),
//   );
// }

// Widget _documentDropdown(List<String> docTypes) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       const Text(
//         "Document Type",
//         style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//       ),
//       const SizedBox(height: 8),
//       Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey.shade300),
//         ),
//         child: DropdownButtonHideUnderline(
//           child: DropdownButton<String>(
//             isExpanded: true,
//             hint: const Text("Select document type"),
//             items: docTypes
//                 .map(
//                   (e) => DropdownMenuItem<String>(
//                     value: e,
//                     child: Text(e, overflow: TextOverflow.ellipsis),
//                   ),
//                 )
//                 .toList(),
//             onChanged: (_) {},
//           ),
//         ),
//       ),
//     ],
//   );
// }

// Widget _fileRow({
//   required String name,
//   required String type,
//   required String tag,
//   required String date,
//   required VoidCallback onView,
// }) {
//   return LayoutBuilder(
//     builder: (context, constraints) {
//       bool isSmall = constraints.maxWidth < 600;

//       return Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF7F8FC),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: Colors.grey.shade200),
//         ),
//         child: isSmall
//             ? Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         width: 36,
//                         height: 36,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: Colors.grey.shade200),
//                         ),
//                         child: const Icon(
//                           Icons.insert_drive_file,
//                           size: 18,
//                           color: Color(0xFF2563EB),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Text(
//                           name,
//                           style: const TextStyle(fontWeight: FontWeight.w700),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: onView,
//                         icon: const Icon(
//                           Icons.visibility,
//                           color: Color(0xFF2563EB),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     type,
//                     style: const TextStyle(fontSize: 12, color: Colors.grey),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(color: Colors.grey.shade300),
//                         ),
//                         child: Text(
//                           tag,
//                           style: const TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       const Spacer(),
//                       Text(
//                         date,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ],
//               )
//             : Row(
//                 children: [
//                   Container(
//                     width: 36,
//                     height: 36,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Colors.grey.shade200),
//                     ),
//                     child: const Icon(
//                       Icons.insert_drive_file,
//                       size: 18,
//                       color: Color(0xFF2563EB),
//                     ),
//                   ),
//                   const SizedBox(width: 12),

//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           name,
//                           style: const TextStyle(fontWeight: FontWeight.w700),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           type,
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(width: 10),

//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: Colors.grey.shade300),
//                     ),
//                     child: Text(
//                       tag,
//                       style: const TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(width: 12),

//                   Flexible(
//                     child: Text(
//                       date,
//                       style: const TextStyle(fontSize: 12, color: Colors.grey),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),

//                   const SizedBox(width: 6),

//                   IconButton(
//                     onPressed: onView,
//                     icon: const Icon(
//                       Icons.visibility,
//                       color: Color(0xFF2563EB),
//                     ),
//                   ),
//                 ],
//               ),
//       );
//     },
//   );
// }

// Widget _card({required String title, required List<Widget> children}) {
//   return Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 16,
//           offset: const Offset(0, 8),
//         ),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF2563EB),
//           ),
//         ),
//         const SizedBox(height: 12),
//         ...children,
//       ],
//     ),
//   );
// }

// Widget _infoRow(String label, dynamic value) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 6),
//     child: Row(
//       children: [
//         Expanded(
//           flex: 4,
//           child: Text(
//             label,
//             style: const TextStyle(color: Colors.grey, fontSize: 13),
//           ),
//         ),
//         Expanded(
//           flex: 6,
//           child: Text(
//             value?.toString() ?? "N/A",
//             style: const TextStyle(fontWeight: FontWeight.w500),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// class CaseCard extends StatelessWidget {
//   final Map<String, dynamic> caseData;
//   final String status;
//   final String date;

//   const CaseCard({
//     super.key,
//     required this.caseData,
//     required this.status,
//     required this.date,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final name = caseData["companyName"] ?? "Unknown";
//     final mobile = caseData["companyMobile"] ?? "";
//     final pan = caseData["pan"] ?? "N/A";
//     final lan = caseData["lanId"] ?? "Pending";

//     // 🔹 Get customerId from API response
//     final customerId = caseData["id"];

//     return InkWell(
//       borderRadius: BorderRadius.circular(16),
//       onTap: () {
//         print(caseData);
//         print("Clicked caseData: $caseData");
//         print("CustomerId: $customerId");
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => CaseDetailsPage(customerId: customerId),
//           ),
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 16,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 _statusChip(status),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Text("Mobile: $mobile"),
//             const SizedBox(height: 6),
//             Text("PAN: $pan | LAN: $lan"),
//             const SizedBox(height: 6),
//             Text(date, style: const TextStyle(color: Colors.grey)),
//           ],
//         ),
//       ),
//     );
//   }

 
//   Widget _statusChip(String status) {
//     Color bg;
//     Color fg;

//     switch (status) {
//       case "Completed":
//         bg = const Color(0xFFD1FAE5);
//         fg = const Color(0xFF065F46);
//         break;
//       case "Draft":
//         bg = const Color(0xFFE5E7EB);
//         fg = const Color(0xFF374151);
//         break;
//       case "Ops L1 Approved":
//         bg = const Color(0xFFDBEAFE);
//         fg = const Color(0xFF1D4ED8);
//         break;
//       case "MD Approved":
//         bg = const Color(0xFFFDE68A);
//         fg = const Color(0xFF92400E);
//         break;
//       default:
//         bg = const Color(0xFFE5E7EB);
//         fg = Colors.black;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         status,
//         style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
//       ),
//     );
//   }
// }



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/presentation/role/rm/Cases/case_details.dart';
 
class SubmittedCasesPage extends StatefulWidget {
  const SubmittedCasesPage({super.key});
 
  @override
  State<SubmittedCasesPage> createState() => _SubmittedCasesPageState();
}
 
class _SubmittedCasesPageState extends State<SubmittedCasesPage> {
  List<dynamic> submittedCases = [];
  bool loading = true;
 
  @override
  void initState() {
    super.initState();
    _loadSubmittedCases();
  }
 
  Future<void> _loadSubmittedCases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
    final rmId = prefs.getInt("rmId");

      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/customers"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        
      );


 //https://supplychain-prod.fintreelms.com/api/workflows/customers/111/rm-submit-md



      final body = jsonDecode(response.body);
 
      if (body["success"] == true) {
        final List data = body["data"];
 
  final submitted = data.where((e) {
    return e["status"] == "submitted" && e["rmId"] == rmId;
  }).toList();

  setState(() {
    submittedCases = submitted;
    loading = false;
  });
        // final submitted = data
        //     .where((c) => c["status"] == "submitted")
        //     .toList();
 
        // setState(() {
        //   submittedCases = submitted;
        //   loading = false;
        // });
      }
    } catch (e) {
      print("Submitted cases fetch error: $e");
    }
  }
 
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
 
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Supply Chain Finance"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: submittedCases.length,
        itemBuilder: (context, index) {
          final caseData = submittedCases[index];
 
          final name = caseData["companyName"] ?? "Unknown";
          final mobile = caseData["companyMobile"] ?? "";
          final pan = caseData["companyPan"] ?? "N/A";
          final lan = caseData["lanId"] ?? "Pending";
          final date = caseData["createdAt"] ?? "";
 
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CaseDetailsPage(customerId: caseData["id"]),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// COMPANY ICON
                  Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    child: const Icon(
                      Icons.apartment_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
 
                  const SizedBox(width: 14),
 
                  /// DETAILS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// NAME + STATUS
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name.isEmpty ? "Unknown Company" : name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
 
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Submitted",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
 
                        const SizedBox(height: 6),
 
                        /// MOBILE
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              mobile.isEmpty ? "No mobile" : mobile,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
 
                        const SizedBox(height: 8),
 
                        /// PAN + LAN
                        Wrap(
                          spacing: 8,
                          children: [
                            if (pan != "N/A")
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "PAN $pan",
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
 
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "LAN $lan",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF0369A1),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
 
                        const SizedBox(height: 8),
 
                        /// DATE
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              date.split("T").first,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
 
 