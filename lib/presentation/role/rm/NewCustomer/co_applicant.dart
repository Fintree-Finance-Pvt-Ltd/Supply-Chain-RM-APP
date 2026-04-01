import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/aadhaar_kyc_service.dart';
import 'package:supply_chain/core/services/auth_service.dart';
import 'package:supply_chain/core/services/draft_service.dart';
import 'package:supply_chain/core/services/pan_ocr_service.dart';
import 'package:supply_chain/core/services/pan_verify_service.dart';
import 'package:supply_chain/core/services/web_camera_capture.dart';
import 'package:supply_chain/core/theme/app_colors.dart';
import 'package:supply_chain/core/utils/toast_helper.dart';
// import 'package:supply_chain/core/utils/tost_healper.dart';
import 'package:supply_chain/core/widgets/app_loader.dart';
import 'package:supply_chain/core/widgets/mobile_consent_popup.dart';
import 'package:supply_chain/presentation/role/rm/NewCustomer/contact_person.dart';

enum AadhaarKycStatus { notStarted, initiated, inProgress, completed }

class CoApplicantModel {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController panCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();

  // XFile? panFile; // ADD THIS
  int? coApplicantId;
  int? ApplicantId;

  // OTP controllers
  final List<TextEditingController> mobileOtpCtrls = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> emailOtpCtrls = List.generate(
    6,
    (_) => TextEditingController(),
  );

  String gender = '';
  bool panVerifying = false;

  AadhaarKycStatus aadhaarStatus = AadhaarKycStatus.notStarted;
  PlatformFile? panFile;
  PlatformFile? selectedPanFile;

  XFile? livePhoto;
  int? customerId;
  bool mobileVerified = false;
  bool emailVerified = false;
  bool isMobileValid = false;
  bool panOcrCompleted = false;
  bool panNumberVerified = false;
  bool isMobileLoading = false;
  String? ocrPanNumber;

  bool isEmailLoading = false;

  bool isMobileVerified = false;
  bool isEmailVerified = false;

  bool panUploaded = false;
  bool panOcrDone = false;
  bool panVerified = false;

  bool mobileOtpSent = false;
  bool emailOtpSent = false;

  int otpSeconds = 30;
  bool canResendOtp = false;
  Timer? otpTimer;
  String normalizePan(String pan) {
    return pan.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
  }
}

/// ================= PAGE =================
class CoApplicantPage extends StatefulWidget {
  final int customerId;

  const CoApplicantPage({super.key, required this.customerId});

  @override
  State<CoApplicantPage> createState() => _CoApplicantPageState();
}

class _CoApplicantPageState extends State<CoApplicantPage> {
  final List<CoApplicantModel> coApplicants = [];
  final ImagePicker _picker = ImagePicker();
  int? customerId;

  bool mobileVerified = false;
  bool emailVerified = false;
  bool isMobileLoading = false;

  bool isEmailLoading = false;
    bool isDarkMode = false;


  final nameCtrl = TextEditingController();
  final panCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final gmailCtrl = TextEditingController();

  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  bool _isValidMobile(String mobile) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(mobile);
  }

  int? _expandedIndex;

  String _normalizePan(String pan) {
    return pan.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
  }

  bool _isValidPan(String pan) {
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
    return panRegex.hasMatch(pan);
  }

  bool isApiLoading = false;

  Future<int> _loadCustomerId() async {
    return widget.customerId;
  }

  @override
  void initState() {
    super.initState();
loadTheme();
    _initPage();
  }

Future<void> loadTheme() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() => isDarkMode = prefs.getBool("isDarkMode") ?? false);
}
  Future<void> _restoreApplicantId() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final cid = await _loadCustomerId();

      final applicantId = await _fetchApplicantIdFromKyc(cid);

      if (applicantId != null) {
        await prefs.setInt("applicantId", applicantId);

        debugPrint("♻️ applicantId restored = $applicantId");
      }
    } catch (e) {
      debugPrint("Applicant restore failed: $e");
    }
  }

  Future<int?> _fetchApplicantIdFromKyc(int customerId) async {
    final token = await AuthService().getToken();

    final response = await http.get(
      Uri.parse(
        "${ApiEndpoints.baseUrl}${ApiEndpoints.getVerificationStatuses}/$customerId",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body);

    //  SAFETY CHECK
    if (decoded["success"] != true || decoded["data"] == null) {
      return null;
    }

    final List list = decoded["data"];

    final applicantRows = list
        .where((e) => e["ownerType"] == "APPLICANT" && e["applicantId"] != null)
        .toList();

    if (applicantRows.isEmpty) return null;

    return applicantRows.first["applicantId"];
  }

  Future<void> _initPage() async {
    await _loadCustomerData(); // API load
    await _loadDraft();
    // await _loadApplicantFromStorage();
    await _restoreApplicantId(); // local draft override if exists
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      //  const Color.fromARGB(255, 255, 255, 255),
                isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF4F6FA),

      body: SafeArea(
        child: Stack(
          children: [
            /// MAIN UI
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 20),

                  if (coApplicants.isEmpty)
                     Text(
                      "No co-applicants added yet",
                      style: TextStyle(
                        // color: Colors.grey
                        color: isDarkMode ? Colors.white : Colors.grey,
                        ),
                    )
                  else
                    Column(
                      children: List.generate(
                        coApplicants.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _expandedIndex = i);
                            },
                            child: _coApplicantCard(
                              i,
                              isExpanded: _expandedIndex == i,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            /// 🔥 GLOBAL LOADER OVERLAY
            if (isApiLoading)
              Container(
                color: Colors.black.withOpacity(0.25),
                child: const Center(
                  child: AppLoader(size: 60, color: Color(0xFF0052FF)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final model in coApplicants) {
      model.otpTimer?.cancel();
    }
    super.dispose();
  }

  void _pickPanSource(CoApplicantModel model) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),

              _panOptionTile(
                icon: Icons.camera_alt_outlined,
                title: "Capture PAN using Camera",
                onTap: () {
                  Navigator.pop(context);
                  _capturePan(model);
                },
              ),

              _panOptionTile(
                icon: Icons.photo_library_outlined,
                title: "Upload PAN from Device",
                onTap: () {
                  Navigator.pop(context);
                  _pickPanFromDevice(model);
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadCustomerData() async {
    try {
      setState(() => isApiLoading = true);

      final token = await AuthService().getToken();
      final customerId = await _loadCustomerId();

      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/customers/$customerId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        final customer = data["data"];

        final List coApplicantList = customer["coApplicants"] ?? [];

        coApplicants.clear();

        for (var item in coApplicantList) {
          final model = CoApplicantModel();

          model.coApplicantId = item["id"];
          model.customerId = item["customerId"];

          model.nameCtrl.text = item["name"] ?? "";
          model.mobileCtrl.text = item["mobile"] ?? "";
          model.emailCtrl.text = item["email"] ?? "";
          model.panCtrl.text = item["pan"] ?? "";

          model.mobileVerified = model.mobileCtrl.text.length == 10;
          model.emailVerified = model.emailCtrl.text.contains("@");
          model.panVerified = model.panCtrl.text.isNotEmpty;

          coApplicants.add(model);
        }

        /// If no co applicants exist
        if (coApplicants.isEmpty) {
          coApplicants.add(CoApplicantModel());
        }

        setState(() {
          _expandedIndex = 0;
        });
      }
    } catch (e) {
      debugPrint("Load customer error: $e");
    } finally {
      setState(() => isApiLoading = false);
    }
  }

  Future<void> _uploadDocument({
    required PlatformFile file,
    required String documentType,
    Map<String, dynamic> meta = const {},
  }) async {
    try {
      setState(() => isApiLoading = true);

      final token = await AuthService().getToken();
      final prefs = await SharedPreferences.getInstance();
      final int? storedCustomerId = prefs.getInt("customerId");

      if (storedCustomerId == null) {
        throw Exception("Customer ID not found. Verify mobile first.");
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.uploadDocument),
      );

      // ✅ Headers
      request.headers.addAll({"Authorization": "Bearer $token"});

      // ✅ Required Fields
      request.fields['customerId'] = storedCustomerId.toString();
      request.fields['documentType'] = documentType;
      request.fields['applicantType'] = "CO_APPLICANT";
      request.fields['applicantIndex'] = "0";

      request.fields['issueDate'] = meta['issueDate'] ?? '';
      request.fields['expiryDate'] = meta['expiryDate'] ?? '';
      request.fields['remarks'] = meta['remarks'] ?? '';
      request.fields['rmRemarks'] = meta['rmRemarks'] ?? '';

      // ✅ File Upload (Web + Mobile Safe)
      if (file.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name.isNotEmpty ? file.name : 'pan.jpg',
            contentType: MediaType('image', 'jpeg'), // Always safe
          ),
        );
      } else if (file.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path!,
            contentType: MediaType('image', 'jpeg'),
          ),
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
    } finally {
      setState(() => isApiLoading = false);
    }
  }

  Future<void> _saveCoApplicantsDraft() async {
    List<Map<String, dynamic>> coApplicantList = coApplicants.map((model) {
      return {
        "name": model.nameCtrl.text,
        "pan": model.panCtrl.text,
        "mobile": model.mobileCtrl.text,
        "email": model.emailCtrl.text,
        "gender": model.gender,
        "panVerified": model.panVerified,
        "mobileVerified": model.mobileVerified,
        "emailVerified": model.emailVerified,
      };
    }).toList();

    await DraftService.saveWithStep(widget.customerId, "contactPerson", {
      "coApplicants": coApplicantList,
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPerson(customerId: widget.customerId),
      ),
    );
  }

  Future<void> _loadDraft() async {
    final draft = await DraftService.loadDraft(widget.customerId);

    if (draft == null) return;

    if (draft["coApplicants"] != null && draft["coApplicants"] is List) {
      final savedList = draft["coApplicants"] as List;

      coApplicants.clear();

      for (final item in savedList) {
        final model = CoApplicantModel();

        model.nameCtrl.text = item["name"] ?? "";
        model.panCtrl.text = item["pan"] ?? "";
        model.mobileCtrl.text = item["mobile"] ?? "";
        model.emailCtrl.text = item["email"] ?? "";
        model.gender = item["gender"] ?? "";

        model.mobileVerified = model.mobileCtrl.text.length == 10;
        model.emailVerified = model.emailCtrl.text.contains("@");
        model.panVerified = model.panCtrl.text.isNotEmpty;

        coApplicants.add(model);
      }

      setState(() {});
    }
  }

  // Future<void> _capturePan(CoApplicantModel model) async {
  //   final XFile? img = await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (_) => const WebCameraCapture()),
  //   );

  //   if (img != null) {
  //     _onPanSelected(model, img);
  //   }
  // }

  Future<void> _capturePan(CoApplicantModel model) async {
    final XFile? img = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WebCameraCapture()),
    );

    if (img != null) {
      final bytes = await img.readAsBytes();

      // final file = PlatformFile(
      //   name: img.name,
      //   size: bytes.length,
      //   bytes: bytes,
      // );

      final file = PlatformFile(
        name: img.name,
        size: bytes.length,
        bytes: bytes,
        // extension: img.name.contains('.')
        //     ? img.name.split('.').last.toLowerCase()
        //     : 'jpg',
      );
      setState(() {
        model.panFile = file; // ✅ STORE FILE
        model.panUploaded = true;
        model.panOcrDone = false;
        model.panVerified = false;
      });

      await _hitPanOcr(model);
      // await _uploadDocument(file: file, documentType: "PAN_CARD");
    }
  }
  // Future<void> _pickPanFromDevice(CoApplicantModel model) async {
  //   final XFile? img = await _picker.pickImage(
  //     source: ImageSource.gallery,
  //     imageQuality: 85,
  //   );

  //   if (img != null) {
  //     _onPanSelected(model, img);
  //   }
  // }
  // Future<void> _pickPanFromDevice(CoApplicantModel model) async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
  //   );

  //   if (result != null && result.files.isNotEmpty) {
  //     PlatformFile file = result.files.first;
  //     model.panFile = file; // Store the picked file in the model
  //     _onPanSelected(model, XFile(file.path!)); // Convert to XFile and proceed
  //   }
  // }

  Future<void> _pickPanFromDevice(CoApplicantModel model) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;

      setState(() {
        model.panFile = file; // ✅ STORE FILE
        model.panUploaded = true;
        model.panOcrDone = false;
        model.panVerified = false;
      });

      await _hitPanOcr(model); // ✅ RUN OCR
    }
  }

  void _onPanSelected(CoApplicantModel model, XFile img) {
    setState(() {
      // model.panFile = img;
      model.panUploaded = true;
      model.panOcrDone = false;
      model.panVerified = false;
    });

    _hitPanOcr(model); // AUTO OCR
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        gradient: LinearGradient(
          colors: [
            AppColors.darkBlue.withOpacity(0.9),
            const Color.fromARGB(255, 169, 167, 193),
          ],

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LEFT TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Co-Applicants",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "/ Co-Borrowers",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Add co-applicants for loan processing",
                  style: TextStyle(fontSize: 13, color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          /// ADD BUTTON
          InkWell(
            onTap: _addCoApplicant,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.darkBlue,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.add, size: 18, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    "Add Apllicant",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  void _addCoApplicant() {
    setState(() {
      coApplicants.add(CoApplicantModel());
      _expandedIndex = coApplicants.length - 1; //  open last added
    });
  }

  // ================= CARD =================
  Widget _coApplicantCard(int index, {required bool isExpanded}) {
    final model = coApplicants[index];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        // color: AppColors.card,
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 HEADER
          _cardHeader(index, isExpanded),

          if (isExpanded) ...[
            const SizedBox(height: 18),

            /// 🔹 STEP 1 — MOBILE
            _stepDivider("Mobile Verification"),
            const SizedBox(height: 12),
            _mobileField(model),

            /// 🔹 STEP 2 — EMAIL
            if (model.mobileVerified) ...[
              const SizedBox(height: 28),
              _stepDivider("Email Verification"),
              const SizedBox(height: 12),
              _emailField(model),
            ],

            /// 🔹 STEP 3 — PAN
            if (model.mobileVerified && model.emailVerified) ...[
              const SizedBox(height: 28),
              _stepDivider("PAN Verification"),
              const SizedBox(height: 12),
              _panSection(model),
            ],

            /// 🔹 STEP 4 — CONTINUE + AADHAAR
            if (model.panVerified) ...[
              const SizedBox(height: 32),
              _continueButton(model),
              const SizedBox(height: 18),
              _aadhaarButton(model: model),
            ],
          ],
        ],
      ),
    );
  }

  Widget _cardHeader(int index, bool isExpanded) {
    return Row(
      children: [
        /// TITLE
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Co-Applicant ${index + 1}",
                style:  TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  // color: AppColors.textPrimary,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isExpanded ? "KYC details" : "Tap to complete KYC",
                style: TextStyle(fontSize: 12, 
                // color: AppColors.textSecondary
                color: isDarkMode ? Colors.white : AppColors.textSecondary
                ),
              ),
            ],
          ),
        ),

        /// DELETE
        InkWell(
          onTap: () => setState(() => coApplicants.removeAt(index)),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 18, color: AppColors.danger),
          ),
        ),
      ],
    );
  }

  Widget _stepDivider(String title) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration:  BoxDecoration(
            // color: AppColors.primary,
                            color: isDarkMode ? Colors.white : Color(0xFF1A237E),

            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style:  TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            // color: AppColors.textPrimary,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const Expanded(child: Divider(thickness: 1, indent: 12)),
      ],
    );
  }

  // ================= PAN =================
  Widget _panSection(CoApplicantModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔹 TITLE
        // const Text(
        //   "PAN Verification",
        //   style: TextStyle(
        //     fontSize: 14,
        //     fontWeight: FontWeight.w600,
        //     color: AppColors.textPrimary,
        //   ),
        // ),
        const SizedBox(height: 8),

        /// 🔹 PAN CARD
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: model.panVerified
                ? AppColors.success.withOpacity(0.06)
                : AppColors.inputFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: model.panVerified
                  ? AppColors.success
                  : AppColors.primary.withOpacity(0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 📤 UPLOAD PAN
              GestureDetector(
                onTap: model.panVerified ? null : () => _pickPanSource(model),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.credit_card, color: AppColors.primary),
                      const SizedBox(width: 10),

                      /// TEXT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Upload PAN Card",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              model.panUploaded
                                  ? "PAN uploaded successfully"
                                  : "JPEG, PNG or PDF",
                              style: TextStyle(
                                fontSize: 12,
                                color: model.panUploaded
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// ACTION ICON
                      const Icon(
                        Icons.upload_file_rounded,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),

              /// 🔍 OCR DETAILS
              if (model.panOcrDone) ...[
                const SizedBox(height: 16),

                /// NAME
                TextFormField(
                  controller: model.nameCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "Full Name",
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: const Icon(Icons.lock, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// PAN NUMBER + VERIFY
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: model.panCtrl,
                        readOnly: model.panVerified,
                        decoration: InputDecoration(
                          hintText: "PAN Number",
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: model.panVerified
                              ? const Icon(
                                  Icons.verified,
                                  color: AppColors.success,
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),

                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    if (!model.panVerified) ...[
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _verifyPanNumber(model),
                          child: model.panVerifying
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Verify",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              /// ✅ VERIFIED STATE
              if (model.panVerified) ...[
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "PAN verified successfully",
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _panOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }

  // Widget _iconAction({required IconData icon, required VoidCallback onTap}) {
  //   return InkWell(
  //     onTap: onTap,
  //     borderRadius: BorderRadius.circular(10),
  //     child: Container(
  //       padding: const EdgeInsets.all(8),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       child: Icon(icon, size: 20, color: AppColors.darkBlue),
  //     ),
  //   );
  // }

  Future<void> _hitPanOcr(CoApplicantModel model) async {
    if (model.panFile == null) return;

    setState(() => isApiLoading = true);

    try {
      final result = await PanOcrService.scanPan(model.panFile!);

      if (result == null || result.panNumber == null) {
        throw Exception("PAN not detected");
      }

      final extractedPan = result.panNumber!.trim().toUpperCase().replaceAll(
        RegExp(r'\s+'),
        '',
      );

      setState(() {
        model.panCtrl.text = extractedPan;
        model.ocrPanNumber = extractedPan;
        model.panOcrDone = true;

        if (result.name != null) {
          model.nameCtrl.text = result.name!;
        }
      });
    } catch (e) {
      showTopToast(context, "PAN OCR failed", success: false);
    } finally {
      setState(() => isApiLoading = false);
    }
  }

  Future<void> _initiateCoApplicantAadhaarKyc(CoApplicantModel model) async {
    debugPrint("🪪 Aadhaar start → coApplicantId = ${model.coApplicantId}");
    debugPrint("🪪 Aadhaar start → ApplicantId = ${model.ApplicantId}");
    if (model.coApplicantId == null) {
      showTopToast(
        context,
        "Co-applicant ID not created. Verify PAN first.",
        success: false,
      );
      return;
    }

    if (model.nameCtrl.text.trim().isEmpty) {
      showTopToast(
        context,
        "Full name is required before Aadhaar KYC",
        success: false,
      );
      return;
    }

    final firstName = model.nameCtrl.text.trim().split(RegExp(r'\s+')).first;

    try {
      setState(() {
        isApiLoading = true;
        model.aadhaarStatus = AadhaarKycStatus.inProgress;
      });

      final cid = await _loadCustomerId();
      // final applicantId = await _loadApplicantId();
      final applicantId = await _fetchApplicantIdFromKyc(cid);

      if (applicantId == null) {
        showTopToast(
          context,
          "Applicant ID not found. Verify applicant mobile first.",
          success: false,
        );
        return;
      }

      final result = await AadhaarKycService.verifyAadhaar(
        customerId: cid,
        ownerType: "CO_APPLICANT",
        applicantId: applicantId, // ✅ INT
        coApplicantId: model.coApplicantId!,
      );

      setState(() {
        model.aadhaarStatus = result["status"] == "VERIFIED"
            ? AadhaarKycStatus.completed
            : AadhaarKycStatus.initiated;
      });

      showTopToast(context, "Aadhaar KYC initiated", success: true);
    } catch (e) {
      showTopToast(context, e.toString(), success: false);
    } finally {
      setState(() => isApiLoading = false);
    }
  }

  Future<void> _refreshCoApplicantAadhaarStatus(CoApplicantModel model) async {
    try {
      setState(() => model.aadhaarStatus = AadhaarKycStatus.inProgress);

      final customerId = await _loadCustomerId();

      final List statuses = await AadhaarKycService.getVerificationStatuses(
        customerId,
      );

      // 🔍 Find matching CO_APPLICANT
      final coApplicant = statuses.firstWhere(
        (e) =>
            e["ownerType"] == "CO_APPLICANT" &&
            e["coApplicantId"] == model.coApplicantId,
        orElse: () => null,
      );

      if (coApplicant == null) {
        showTopToast(
          context,
          "Co-applicant KYC status not found",
          success: false,
        );
        return;
      }

      final aadhaarStatus = coApplicant["aadhaarStatus"];

      if (aadhaarStatus == "VERIFIED") {
        setState(() => model.aadhaarStatus = AadhaarKycStatus.completed);
        showTopToast(context, "Aadhaar verified successfully", success: true);
      } else {
        showTopToast(context, "Aadhaar verification pending", success: false);
      }
    } catch (e) {
      showTopToast(context, "Failed to fetch Aadhaar status", success: false);
    }
  }

  // Future<void> _hitPanOcr(CoApplicantModel model, XFile panImage) async {
  //   setState(() => isApiLoading = true);
  //   try {
  //     setState(() {
  //       model.panOcrDone = false;
  //     });

  //     final result = await PanOcrService.scanPan(panImage);

  //     if (result == null || result.panNumber == null) {
  //       throw "PAN not detected";
  //     }

  //     final extractedPan = _normalizePan(result.panNumber!);

  //     setState(() {
  //       model.ocrPanNumber = extractedPan; // ✅ store OCR PAN
  //       model.panCtrl.text = extractedPan;

  //       if (result.name != null) {
  //         model.nameCtrl.text = result.name!;
  //       }

  //       model.panOcrDone = true;
  //       model.panVerified = false;
  //     });
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("PAN OCR failed: $e")));
  //   } finally {
  //     setState(() => isApiLoading = false);
  //   }
  // }

  Future<void> _verifyPanNumber(CoApplicantModel model) async {
    final rawPan = model.panCtrl.text;
    final rawName = model.nameCtrl.text;

    if (rawPan.isEmpty || rawName.isEmpty) {
      showTopToast(context, "PAN and Name are required", success: false);
      return;
    }

    final pan = _normalizePan(rawPan);
    final name = rawName.trim().toUpperCase();

    if (!_isValidPan(pan)) {
      showTopToast(context, "Invalid PAN format", success: false);
      return;
    }

    // ✅ FIXED LINE

    try {
      setState(() {
        isApiLoading = true;
        model.panVerifying = true;
      });

      final customerId = await _loadCustomerId();

      final data = await PanVerifyService.verifyPan(
        customerId: customerId,
        pan: pan,
        name: name,
        ownerType: "CO_APPLICANT",
        coApplicantId: model.coApplicantId,
      );

      if (data["verified"] != true) {
        showTopToast(
          context,
          data["message"] ?? "PAN verification failed",
          success: false,
        );
        return;
      }

      // Capture coApplicantId from the response
      if (data["coApplicantId"] != null) {
        model.coApplicantId = data["coApplicantId"];
      }
      print("PAN VERIFY ID: ${model.coApplicantId}");
      setState(() {
        model.panVerified = true;
        model.mobileVerified = false;
        model.emailVerified = false;
      });

      if (model.panFile != null) {
        await _uploadDocument(file: model.panFile!, documentType: "PAN_CARD");
      }
      showTopToast(context, "PAN verified successfully", success: true);
    } catch (e) {
      showTopToast(context, e.toString(), success: false);
    } finally {
      setState(() {
        isApiLoading = false;
        model.panVerifying = false;
      });
    }
  }

  // ================= FIELDS =================
  Widget _textField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 6),
        TextField(controller: ctrl),
      ],
    );
  }

  Future<bool> _sendMobileOtp(CoApplicantModel model) async {
    try {
      setState(() {
        isApiLoading = true;
      });
      final token = await AuthService().getToken();

      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.sendMobileOtp),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "mobileNumber": model.mobileCtrl.text.trim(),
          "ownerType": "CO_APPLICANT",
          "customerId": await _loadCustomerId(),
          "coApplicantId": model.coApplicantId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        if (data["coApplicantId"] != null) {
          model.coApplicantId = data["coApplicantId"];
        }

        model.mobileOtpSent = true;
        return true;
      }

      showTopToast(context, data["message"] ?? "OTP failed", success: false);
      return false;
    } catch (e) {
      showTopToast(context, "OTP Send Failed", success: false);
      return false;
    } finally {
      setState(() => isApiLoading = false);
    }
  }

  // Future<bool> _verifyMobileOtp(String otp) async {
  //   if (customerId == null) {
  //     showTopToast(context, "Customer not initialized", success: false);
  //     return false;
  //   }

  //   setState(() => isMobileLoading = true);

  //   try {
  //     final token = await AuthService().getToken();

  //     final response = await http.post(
  //       Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.verifyMobileOtp),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer $token",
  //       },
  //       body: jsonEncode({
  //         "customerId": customerId,
  //         "otp": otp,
  //         "mobileNumber": mobileCtrl.text.trim(),
  //         "ownerType": "APPLICANT",
  //       }),
  //     );

  //     final data = jsonDecode(response.body);

  //     if (response.statusCode == 200 && data["success"] == true) {
  //       setState(() {
  //         mobileVerified = true;
  //       });

  //       showTopToast(context, "Mobile Verified Successfully", success: true);
  //       return true;
  //     } else {
  //       showTopToast(context, data["message"], success: false);
  //       return false;
  //     }
  //   } catch (e) {
  //     showTopToast(context, "Mobile verification failed", success: false);
  //     return false;
  //   } finally {
  //     setState(() => isMobileLoading = false);
  //   }
  // }
  Future<int?> _loadApplicantId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("applicantId");
  }

  Future<bool> _verifyMobileOtp(CoApplicantModel model, String otp) async {
    setState(() => model.isMobileLoading = true);

    try {
      final token = await AuthService().getToken();
      final cid = await _loadCustomerId();

      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.verifyMobileOtp),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "customerId": cid,
          "otp": otp,
          "mobileNumber": model.mobileCtrl.text.trim(),
          "ownerType": "CO_APPLICANT",
          "coApplicantId": model.coApplicantId,
        }),
      );

      final data = jsonDecode(response.body);
      if (model.coApplicantId == null) {
        showTopToast(context, "Co-applicant not initialized", success: false);
        return false;
      }

      print("Verifying OTP with ID: ${model.coApplicantId}");
      if (response.statusCode == 200 && data["success"] == true) {
        //    if (data["coApplicantId"] != null) {
        //   model.coApplicantId = data["coApplicantId"];
        // }

        setState(() => model.mobileVerified = true);
        showTopToast(context, "Mobile Verified Successfully", success: true);
        return true;
      } else {
        showTopToast(context, data["message"] ?? "Invalid OTP", success: false);
        return false;
      }
    } catch (e) {
      showTopToast(context, "Mobile OTP verification failed", success: false);
      return false;
    } finally {
      setState(() => model.isMobileLoading = false);
    }
  }

  Future<bool> _sendEmailOtp(CoApplicantModel model) async {
    try {
      setState(() {
        isApiLoading = true;
      });
      final token = await AuthService().getToken();
      final cid = await _loadCustomerId();

      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.sendEmailOtp),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "customerId": cid,
          "email": model.emailCtrl.text.trim(),

          "ownerType": "CO_APPLICANT",
          "coApplicantId": model.coApplicantId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() => model.emailOtpSent = true);
        showTopToast(context, "Email OTP Sent", success: true);
        return true;
      }

      showTopToast(context, data["message"] ?? "OTP failed", success: false);
      return false;
    } catch (e) {
      showTopToast(context, "Email OTP failed", success: false);
      return false;
    } finally {
      setState(() => isApiLoading = false);
    }
  }

  Future<bool> _verifyEmailOtp(CoApplicantModel model, String otp) async {
    setState(() => model.isEmailLoading = true);

    try {
      final token = await AuthService().getToken();
      final cid = await _loadCustomerId();

      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.verifyEmailOtp),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "customerId": cid,
          "otp": otp,
          "email": model.emailCtrl.text.trim(),
          "ownerType": "CO_APPLICANT",
          "coApplicantId": model.coApplicantId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() => model.emailVerified = true);
        showTopToast(context, "Email Verified Successfully", success: true);
        return true;
      } else {
        showTopToast(context, data["message"] ?? "Invalid OTP", success: false);
        return false;
      }
    } finally {
      setState(() => model.isEmailLoading = false);
    }
  }

  Widget _mobileField(CoApplicantModel model) {
    final bool isMobileValid = _isValidMobile(model.mobileCtrl.text.trim());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      
        const SizedBox(height: 8),

        /// MAIN CARD
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            // color: Colors.white,
            
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: model.mobileVerified
                  ? AppColors.success
                  : AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// LEFT ICON
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: model.mobileVerified
                      ? AppColors.success.withOpacity(0.12)
                      : AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.phone_iphone,
                  size: 20,
                  color: model.mobileVerified
                      ? AppColors.success
                      : AppColors.primary,
                ),
              ),

              const SizedBox(width: 12),

              /// +91 PREFIX
              const Text(
                "+91",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(width: 6),

              /// MOBILE INPUT
              Expanded(
                child: TextFormField(
                  controller: model.mobileCtrl,
                  readOnly: model.mobileVerified,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "XXXXXXXXXX",
                    isDense: true,
                    border: InputBorder.none,
                    errorText:
                        (!model.mobileVerified &&
                            model.mobileCtrl.text.isNotEmpty &&
                            !isMobileValid)
                        ? "Invalid mobile number"
                        : null,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              /// ACTION
              if (model.mobileVerified)
                _verifiedPill()
              else
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMobileValid
                          ? AppColors.darkBlue
                          : AppColors.grey,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: (!isMobileValid || model.isMobileLoading)
                        ? null
                        : () async {
                            final sent = await _sendMobileOtp(model);
                            if (sent) {
                              MobileConsentPopup.show(
                                context: context,
                                onVerified: (otp) async {
                                  return await _verifyMobileOtp(model, otp);
                                },
                              );
                            }
                          },
                    child: model.isMobileLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Verify",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
            ],
          ),
        ),

        /// SUCCESS TEXT
        if (model.mobileVerified) ...[
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.check_circle, size: 16, color: AppColors.success),
              SizedBox(width: 6),
              Text(
                "Mobile number verified",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _emailField(CoApplicantModel model) {
    final bool isEmailValid = _isValidEmail(model.emailCtrl.text.trim());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LABEL
        // const Text(
        //   "Email Address",
        //   style: TextStyle(
        //     fontSize: 13,
        //     fontWeight: FontWeight.w600,
        //     color: AppColors.textSecondary,
        //   ),
        // ),
        const SizedBox(height: 8),

        /// MAIN CARD
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: model.emailVerified
                  ? AppColors.success
                  : AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// LEFT ICON
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: model.emailVerified
                      ? AppColors.success.withOpacity(0.12)
                      : AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.email_outlined,
                  color: model.emailVerified
                      ? AppColors.success
                      : AppColors.primary,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              /// EMAIL INPUT
              Expanded(
                child: TextFormField(
                  controller: model.emailCtrl,
                  readOnly: model.emailVerified,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "name@gmail.com",
                    isDense: true,
                    border: InputBorder.none,
                    errorText:
                        (!model.emailVerified &&
                            model.emailCtrl.text.isNotEmpty &&
                            !isEmailValid)
                        ? "Invalid email format"
                        : null,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              /// ACTION
              if (model.emailVerified)
                _verifiedPill()
              else
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEmailValid
                          ? AppColors.darkBlue
                          : AppColors.grey,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isEmailValid
                        ? () async {
                            final sent = await _sendEmailOtp(model);
                            if (sent) {
                              EmailVerifyPopup.show(
                                context: context,
                                onVerify: (otp) async {
                                  return await _verifyEmailOtp(model, otp);
                                },
                              );
                            }
                          }
                        : null,
                    child: const Text(
                      "Verify",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        /// SUCCESS TEXT (SUBTLE)
        if (model.emailVerified) ...[
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.check_circle, size: 16, color: AppColors.success),
              SizedBox(width: 6),
              Text(
                "Email verified",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _verifiedPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: const [
          Icon(Icons.verified, size: 14, color: AppColors.success),
          SizedBox(width: 4),
          Text(
            "Verified",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verifiedChip() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.verified, size: 16, color: AppColors.success),
          SizedBox(width: 4),
          Text(
            "Verified",
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderField(CoApplicantModel model) {
    final genders = [
      {"label": "Male", "icon": Icons.male},
      {"label": "Female", "icon": Icons.female},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Gender *", style: _labelStyle()),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: genders.map((g) {
            final bool selected = model.gender == g["label"];

            return ChoiceChip(
              selected: selected,
              onSelected: (_) {
                setState(() => model.gender = g["label"] as String);
              },

              /// CHIP CONTENT
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    g["icon"] as IconData,
                    size: 16,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    g["label"] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              /// BACKGROUND
              backgroundColor: AppColors.inputFill,
              selectedColor: AppColors.primary.withOpacity(0.15),

              /// BORDER
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selected
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.3),
                  width: selected ? 1.5 : 1,
                ),
              ),

              /// TOUCH AREA
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

              elevation: selected ? 1 : 0,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _continueButton(CoApplicantModel model) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () async {
          await _saveCoApplicantsDraft(); // ✅ save draft
        },
        child: const Text(
          "Continue",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _aadhaarStatusBanner(CoApplicantModel model) {
    if (model.aadhaarStatus == AadhaarKycStatus.notStarted) {
      return const SizedBox();
    }

    String text;
    Color color;

    switch (model.aadhaarStatus) {
      case AadhaarKycStatus.initiated:
        text = "Aadhaar KYC Initiated";
        color = AppColors.primary;
        break;
      case AadhaarKycStatus.inProgress:
        text = "Aadhaar KYC In Progress";
        color = Colors.orange;
        break;
      case AadhaarKycStatus.completed:
        text = "Aadhaar KYC Completed";
        color = AppColors.success;
        break;
      default:
        return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _aadhaarButton({required CoApplicantModel model}) {
    String label;
    VoidCallback? onTap;
    Color bgColor;

    switch (model.aadhaarStatus) {
      case AadhaarKycStatus.notStarted:
        label = "Complete Aadhaar KYC";
        bgColor = AppColors.primary;
        onTap = () => _initiateCoApplicantAadhaarKyc(model);
        break;

      case AadhaarKycStatus.initiated:
      case AadhaarKycStatus.inProgress:
        label = "Refresh Aadhaar Status";
        bgColor = AppColors.darkBlue;
        onTap = () => _refreshCoApplicantAadhaarStatus(model);
        break;

      case AadhaarKycStatus.completed:
        label = "Continue";
        bgColor = AppColors.success;
        onTap = _saveCoApplicantsDraft;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _aadhaarStatusBanner(model),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  TextStyle _labelStyle() => const TextStyle(fontWeight: FontWeight.w500);

  InputDecoration _inputDecoration(String hint) =>
      InputDecoration(hintText: hint);
}
