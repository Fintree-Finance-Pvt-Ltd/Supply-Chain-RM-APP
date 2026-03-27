// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:supply_chain/core/services/draft_service.dart';
// import 'package:supply_chain/core/services/web_camera_capture.dart';
// import 'package:supply_chain/core/theme/app_colors.dart';
// import 'package:flutter/services.dart';
// import 'package:supply_chain/core/widgets/mobile_consent_popup.dart';
// import 'package:supply_chain/presentation/role/rm/Cases/all_Cases.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/applicant_details.dart';
 
// class CompanyDetails extends StatefulWidget {
//   const CompanyDetails({super.key});
 
//   @override
//   State<CompanyDetails> createState() => _CompanyDetailsState();
// }
 
// class _CompanyDetailsState extends State<CompanyDetails> {
//   String? selectedCompanyType;
//   int selectedBottomIndex = 0;
//   final TextEditingController companyNameController = TextEditingController();
//   final TextEditingController gstController = TextEditingController();
 
//   final ImagePicker _picker = ImagePicker();
 
//   final TextEditingController panController = TextEditingController();
//   final TextEditingController mobileController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController otpController = TextEditingController();
 
//   bool isMobileValid = false;
//   bool isEmailValid = false;
//   bool panVerified = false;
 
//   bool panOcrCompleted = false;
//   bool panNumberVerified = false;
//   bool isMobileLoading = false;
//   bool isEmailLoading = false;
 
//   bool isMobileVerified = false;
//   bool isEmailVerified = false;
//   bool isPanProcessing = false;
//   bool isPanVerified = false;
//   PlatformFile? selectedPanFile;
//   PlatformFile? selectedGstFile;
 
//   bool showContinueButton = false;
 
//   bool isGstValidForVerify = false;
//   bool isGstProcessing = false;
//   bool isGstVerified = false;
//   late final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   XFile? panFile;
//   XFile? livePhoto;
//   List<FocusNode> emailOtpFocusNodes = List.generate(6, (_) => FocusNode());
 
//   List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());
 
//   final List<String> companyTypes = [
//     "Select company type",
//     "Proprietorship",
//     "HUF",
//     "Partnership",
//     "Pvt Ltd /Ltd",
//     "LLP",
//   ];
//   Future<void> _pickPanFile() async {
//     final XFile? img = await _picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 85,
//     );
 
//     if (img != null) {
//       setState(() {
//         panFile = img;
//         panVerified = false;
//         panOcrCompleted = false;
//         panNumberVerified = false;
//       });
 
//       _runPanOcr(); // AUTO OCR
//     }
//   }
 
//   Future<void> _capturePan() async {
//     final XFile? img = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const WebCameraCapture()),
//     );
 
//     if (img != null) {
//       setState(() {
//         panFile = img;
//         panVerified = false;
//         panOcrCompleted = false;
//         panNumberVerified = false;
//       });
 
//       _runPanOcr(); // AUTO OCR
//     }
//   }
 
//   bool get isFormComplete {
//     return selectedCompanyType != null &&
//         selectedCompanyType != "Select company type" &&
//         companyNameController.text.isNotEmpty &&
//         isMobileVerified &&
//         isEmailVerified &&
//         isPanVerified &&
//         selectedGstFile != null &&
//         isGstVerified;
//   }
 
//   Future<void> _goToApplicantDetails() async {
//     final existingDraft = await DraftService.loadDraft() ?? {};
 
//     existingDraft["company"] = {
//       "companyType": selectedCompanyType,
//       "companyName": companyNameController.text,
//       "mobile": mobileController.text,
//       "email": emailController.text,
//       "gst": gstController.text,
 
//       // ✅ SAVE VERIFICATION FLAGS
//       "isMobileVerified": isMobileVerified,
//       "isEmailVerified": isEmailVerified,
//       "isPanVerified": isPanVerified,
//       "isGstVerified": isGstVerified,
 
//       // ✅ SAVE FILE METADATA
//       "gstFileName": selectedGstFile?.name,
//     };
 
//     await DraftService.saveDraft(existingDraft);
 
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const ApplicantDetails()),
//     );
//   }
 
//   Future<void> _loadDraft() async {
//     final draft = await DraftService.loadDraft();
//     if (draft == null || draft["company"] == null) return;
 
//     final company = draft["company"];
 
//     setState(() {
//       selectedCompanyType = company["companyType"];
//       companyNameController.text = company["companyName"] ?? "";
//       mobileController.text = company["mobile"] ?? "";
//       emailController.text = company["email"] ?? "";
//       gstController.text = company["gst"] ?? "";
 
//       // Restore verification flags
//       isMobileVerified = company["isMobileVerified"] == true;
//       isEmailVerified = company["isEmailVerified"] == true;
//       isPanVerified = company["isPanVerified"] == true;
//       isGstVerified = company["isGstVerified"] == true;
 
//       // Restore GST file placeholder
//       if (company["gstFileName"] != null) {
//         selectedGstFile = PlatformFile(name: company["gstFileName"], size: 0);
//       }
//     });
 
//     //  IMPORTANT: trigger button AFTER build
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && isFormComplete) {
//         setState(() {
//           showContinueButton = true;
//         });
//       }
//     });
//   }
 
//   Future<void> _pickGstFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
 
//     if (result != null) {
//       setState(() {
//         selectedGstFile = result.files.first;
//       });
//     }
//   }
 
//   @override
//   void initState() {
//     super.initState();
//     _loadDraft(); //  THIS IS MISSING IN YOUR CODE
 
//     mobileController.addListener(() {
//       final text = mobileController.text;
 
//       setState(() {
//         isMobileValid = text.length == 10;
 
//         if (text.length != 10) {
//           isMobileVerified = false;
//         }
//       });
//     });
 
//     emailController.addListener(() {
//       setState(() {
//         isEmailValid = RegExp(
//           r'^[^@]+@[^@]+\.[^@]+',
//         ).hasMatch(emailController.text);
//         if (!isEmailValid) {
//           isEmailVerified = false;
//         }
//       });
//     });
 
//     gstController.addListener(() {
//       setState(() {
//         isGstValidForVerify = gstController.text.length == 15;
//       });
//     });
//   }
 
//   @override
//   void dispose() {
//     for (var f in otpFocusNodes) {
//       f.dispose();
//     }
//     for (var f in emailOtpFocusNodes) {
//       f.dispose();
//     }
//     super.dispose();
//   }
 
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: const Color(0xFFF4F6FA),
//       endDrawer: _accountDrawer(), //  add drawer
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(18),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 20,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               /// Section Title
//               const Text(
//                 "Company Information",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF1F3C88),
//                 ),
//               ),
 
//               const SizedBox(height: 24),
 
//               /// Company Type
//               const Text(
//                 "Company Type *",
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(height: 8),
 
//               DropdownButtonFormField<String>(
//                 initialValue: selectedCompanyType,
//                 decoration: _inputDecoration(),
//                 hint: const Text("Select company type"),
//                 items: companyTypes.map((type) {
//                   return DropdownMenuItem(value: type, child: Text(type));
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     selectedCompanyType = value;
//                   });
//                 },
//               ),
 
//               const SizedBox(height: 24),
 
//               ///  KEEP YOUR LOGIC SAME
//               _buildDynamicFields(),
 
//               const SizedBox(height: 20),
 
//               _buildCommonFields(),
//             ],
//           ),
//         ),
//       ),
//       bottomSheet: isFormComplete
//           ? AnimatedSlide(
//               duration: const Duration(milliseconds: 350),
//               curve: Curves.easeOutCubic,
//               offset: Offset.zero,
//               child: AnimatedOpacity(
//                 duration: const Duration(milliseconds: 250),
//                 opacity: 1,
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.08),
//                         blurRadius: 10,
//                         offset: const Offset(0, -4),
//                       ),
//                     ],
//                   ),
//                   child: SizedBox(
//                     width: double.infinity,
//                     height: 52,
//                     child: ElevatedButton(
//                       onPressed: _goToApplicantDetails,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.darkBlue,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                       ),
//                       child: const Text(
//                         "Continue",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             )
//           : null,
 
//       bottomNavigationBar: _bottomNav(),
//     );
//   }
 
//   Widget _bottomNav() {
//     return BottomNavigationBar(
//       currentIndex: selectedBottomIndex,
//       selectedItemColor: const Color(0xFF2563EB),
//       unselectedItemColor: Colors.grey,
//       onTap: (index) {
//         // If user taps same tab again → do nothing
//         if (index == selectedBottomIndex) return;
 
//         setState(() {
//           selectedBottomIndex = index;
//         });
 
//         if (index == 0) {
//           //    GO BACK TO PREVIOUS PAGE
//           if (Navigator.canPop(context)) {
//             Navigator.pop(context);
//           }
//         } else if (index == 1) {
//           //  Customers
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => const CasesScreen(role: UserRole.rm),
//             ),
//           );
//         } else if (index == 2) {
//           //  Account  OPEN DRAWER
//           _scaffoldKey.currentState?.openEndDrawer();
//         }
//       },
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.back_hand), label: "Previous"),
//         BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: "Status"),
//         BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
//       ],
//     );
//   }
 
//   Widget _accountDrawer() {
//     return Drawer(
//       width: 280,
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             width: double.infinity,
//             decoration: const BoxDecoration(color: Color(0xFF2563EB)),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 SizedBox(height: 30),
//                 CircleAvatar(
//                   radius: 26,
//                   backgroundColor: Colors.white,
//                   child: Icon(Icons.person, size: 30),
//                 ),
//                 SizedBox(height: 12),
//                 Text(
//                   "Relationship Manager",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 Text(
//                   "rm@company.com",
//                   style: TextStyle(color: Colors.white70, fontSize: 13),
//                 ),
//               ],
//             ),
//           ),
 
//           ListTile(
//             leading: const Icon(Icons.person_outline),
//             title: const Text("Profile"),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.settings),
//             title: const Text("Settings"),
//             onTap: () {},
//           ),
//           const Spacer(),
//           ListTile(
//             leading: const Icon(Icons.logout, color: Colors.red),
//             title: const Text("Logout"),
//             onTap: () {},
//           ),
//         ],
//       ),
//     );
//   }
 
//   Widget _card(Widget child) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(12),
//         color: AppColors.card,
 
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 12,
//             offset: const Offset(2, 6),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
 
//   /* ================= COMMON FIELDS ================= */
//   Widget _panUploadCard() {
//     return _card(
//       Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Upload PAN Card",
//                   style: TextStyle(fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   panFile == null ? "No file selected" : "PAN Selected",
//                   style: const TextStyle(color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
 
//           // CAMERA BUTTON
//           IconButton(
//             tooltip: "Capture PAN",
//             icon: const Icon(Icons.camera_alt, color: Color(0xFF1A237E)),
//             onPressed: _capturePan,
//           ),
 
//           // UPLOAD BUTTON
//           IconButton(
//             tooltip: "Upload from device",
//             icon: const Icon(Icons.upload_file, color: Color(0xFF1A237E)),
//             onPressed: _pickPanFile,
//           ),
//         ],
//       ),
//     );
//   }
 
//   Widget _buildCommonFields() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _mobileField(), //  USE IT HERE
 
//         const SizedBox(height: 20),
//         _verifyField(
//           label: "Business Email ID *",
//           hint: "Enter business email",
//           controller: emailController,
//           keyboardType: TextInputType.emailAddress,
 
//           isValid: isEmailValid,
//           isLoading: isEmailLoading,
//           isVerified: isEmailVerified,
//         ),
 
//         const SizedBox(height: 16),
 
//         _panUploadCard(),
 
//         const SizedBox(height: 16),
 
//         _fileUploadField(
//           label: "GST Certificate Upload *",
//           selectedFile: selectedGstFile,
//           onPressed: _pickGstFile,
//         ),
//         const SizedBox(height: 16),
 
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "GST Number *",
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 8),
 
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: gstController,
//                     maxLength: 15,
//                     decoration: _inputDecoration(hintText: "Enter GST Number"),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.darkBlue,
//                     foregroundColor: AppColors.card,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: isGstValidForVerify && !isGstProcessing
//                       ? _verifyGst
//                       : null,
//                   child: isGstProcessing
//                       ? const SizedBox(
//                           height: 18,
//                           width: 18,
//                           child: CircularProgressIndicator(
//                             color: AppColors.card,
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : const Text("Verify"),
//                 ),
//               ],
//             ),
//           ],
//         ),
 
//         const SizedBox(height: 16),
//       ],
//     );
//   }
 
//   Widget _mobileField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Company Mobile Number *",
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 8),
 
//         Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: mobileController,
//                 keyboardType: TextInputType.number,
//                 maxLength: 10, // 👈 LIMIT LENGTH
//                 inputFormatters: [
//                   FilteringTextInputFormatter.digitsOnly, // 👈 ONLY NUMBERS
//                   LengthLimitingTextInputFormatter(10), // 👈 HARD LIMIT
//                 ],
//                 decoration: _modernInputDecoration("Enter mobile number")
//                     .copyWith(
//                       errorText:
//                           mobileController.text.isNotEmpty &&
//                               mobileController.text.length < 10
//                           ? "Mobile number must be 10 digits"
//                           : null,
//                     ),
//               ),
//             ),
//             const SizedBox(width: 10),
 
//             /// 🔵 If NOT verified → Show Button
//             if (!isMobileVerified)
//               ElevatedButton(
//                 onPressed: isMobileValid
//                     ? () {
//                         MobileConsentPopup.show(
//                           context: context,
//                           onVerified: () {
//                             setState(() {
//                               isMobileVerified = true;
//                             });
//                           },
//                         );
//                       }
//                     : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.darkBlue,
//                   foregroundColor: Colors.white,
//                   minimumSize: const Size(110, 48),
//                 ),
//                 child: const Text("Send OTP"),
//               ),
 
//             /// 🟢 If Verified → Show ONLY Icon (NOT inside button)
//             if (isMobileVerified)
//               SizedBox(
//                 height: 48,
//                 width: 48,
 
//                 child: const Icon(Icons.verified, color: Colors.green),
//               ),
//           ],
//         ),
//       ],
//     );
//   }
 
//   Widget _verifyField({
//     required String label,
//     required String hint,
//     required TextEditingController controller,
//     required bool isValid,
//     required bool isLoading,
//     required bool isVerified,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
//         const SizedBox(height: 8),
 
//         Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: controller,
//                 keyboardType: keyboardType,
//                 decoration: _modernInputDecoration(hint),
//               ),
//             ),
 
//             const SizedBox(width: 10),
 
//             /// 🔵 If NOT verified → Show Button
//             if (!isEmailVerified)
//               ElevatedButton(
//                 onPressed: isMobileValid
//                     ? () {
//                         EmailVerifyPopup.show(
//                           context: context,
//                           onVerified: () {
//                             setState(() {
//                               isEmailVerified = true;
//                             });
//                           },
//                         );
//                       }
//                     : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.darkBlue,
//                   foregroundColor: Colors.white,
//                   minimumSize: const Size(110, 48),
//                 ),
//                 child: const Text("Send OTP"),
//               ),
 
//             /// 🟢 If Verified → Show ONLY Icon (NOT inside button)
//             if (isEmailVerified)
//               SizedBox(
//                 height: 48,
//                 width: 48,
 
//                 child: const Icon(Icons.verified, color: Colors.green),
//               ),
//           ],
//         ),
//       ],
//     );
//   }
 
//   InputDecoration _modernInputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
 
//       filled: true,
//       fillColor: const Color(0xFFF8F9FC), // 👈 Light grey background
 
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
 
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
//       ),
 
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
//       ),
 
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: AppColors.darkBlue, width: 1.5),
//       ),
//     );
//   }
 
//   Widget _buildDynamicFields() {
//     return Column(
//       children: [
//         /// ===== PRIVATE LIMITED FIELDS =====
//         Visibility(
//           visible: selectedCompanyType == "Pvt Ltd /Ltd",
//           child: Column(
//             children: [
//               _simpleField(
//                 label: "Company Name *",
//                 hint: "Company name will auto-fill",
//                 controller: companyNameController,
//                 enabled: isPanVerified,
//               ),
 
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
 
//         /// ===== PARTNERSHIP FIELDS =====
//         Visibility(
//           visible: selectedCompanyType == "Partnership",
//           child: Column(
//             children: [
//               _simpleField(
//                 label: "Company Name *",
//                 hint: "Company name will auto-fill",
//                 controller: companyNameController,
//                 enabled: isPanVerified,
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
 
//         /// ===== LLP =====
//         Visibility(
//           visible: selectedCompanyType == "LLP",
//           child: Column(
//             children: [
//               _simpleField(
//                 label: "Company Name *",
//                 hint: "Company name will auto-fill",
//                 controller: companyNameController,
//                 enabled: isPanVerified,
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
 
//         /// ===== HUF =====
//         Visibility(
//           visible: selectedCompanyType == "HUF",
//           child: Column(
//             children: [
//               _simpleField(
//                 label: "Company Name *",
//                 hint: "Company name will auto-fill",
//                 controller: companyNameController,
//                 enabled: isPanVerified,
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
 
//   /* ================= REUSABLE WIDGETS ================= */
//   Future<void> _verifyGst() async {
//     setState(() {
//       isGstProcessing = true;
//     });
 
//     await Future.delayed(const Duration(seconds: 1));
 
//     setState(() {
//       isGstProcessing = false;
//       isGstVerified = true;
//     });
 
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text("GST Verified Successfully")));
//   }
 
//   Widget _simpleField({
//     required String hint,
//     required String label,
//     TextEditingController? controller,
//     bool enabled = true,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
//         const SizedBox(height: 8),
//         TextField(
//           controller: controller,
//           enabled: enabled,
//           decoration: _inputDecoration(hintText: hint),
//         ),
//       ],
//     );
//   }
 
//   Widget _fileUploadField({
//     required String label,
//     required PlatformFile? selectedFile,
//     required VoidCallback onPressed,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
//         const SizedBox(height: 8),
 
//         Row(
//           children: [
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 16,
//                 ),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(12),
//                   color: AppColors.card,
//                 ),
//                 child: Text(
//                   selectedFile?.name ?? "Choose File",
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ),
 
//             const SizedBox(width: 10),
 
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.darkBlue,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: onPressed,
//               child: const Text("Choose File"),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
 
//   InputDecoration _inputDecoration({String? hintText}) {
//     return InputDecoration(
//       hintText: hintText,
//       hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
 
//       filled: true,
//       fillColor: Colors.white,
 
//       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
 
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
//       ),
 
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
//       ),
 
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: AppColors.darkBlue, width: 1.5),
//       ),
//     );
//   }
 
//   Future<void> _runPanOcr() async {
//     setState(() {
//       isPanProcessing = true;
//       isPanVerified = false;
//     });
 
//     await Future.delayed(const Duration(seconds: 2));
 
//     // Simulated OCR response
//     String fetchedCompanyName = "ABC INDUSTRIES PRIVATE LIMITED";
 
//     setState(() {
//       companyNameController.text = fetchedCompanyName;
//       isPanProcessing = false;
//       isPanVerified = true;
//     });
 
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text("PAN Verified Successfully")));
//   }
// }
 
 