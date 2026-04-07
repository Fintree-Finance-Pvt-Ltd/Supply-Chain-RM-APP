import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:file_picker/file_picker.dart';
import 'package:supply_chain/core/services/web_camera_capture.dart';
import 'package:flutter/foundation.dart';
import 'package:supply_chain/core/theme/app_colors.dart';
import 'package:supply_chain/core/utils/toast_helper.dart';
import 'package:supply_chain/core/widgets/app_loader.dart';
import 'package:supply_chain/core/widgets/mobile_consent_popup.dart';
import 'package:supply_chain/presentation/role/rm/NewCustomer/co_applicant.dart';

class ApplicantDetails extends StatefulWidget {
  final int customerId;

  const ApplicantDetails({super.key, required this.customerId});

  @override
  State<ApplicantDetails> createState() => _ApplicantDetailsState();
}

enum AadhaarKycStatus { notStarted, initiated, inProgress, verified, completed }

class _ApplicantDetailsState extends State<ApplicantDetails> {
  // XFile? panFile;
  PlatformFile? panFile;
  XFile? livePhoto;
  int? customerId;

  final nameCtrl = TextEditingController();
  final panCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final gmailCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool mobileVerified = false;
  bool emailVerified = false;
  bool isMobileValid = false;
  bool panOcrCompleted = false;
  bool panNumberVerified = false;
  bool isMobileLoading = false;
  PlatformFile? LivePhoto;

  bool isEmailLoading = false;

  bool isMobileVerified = false;
  bool isEmailVerified = false;
  bool isDarkMode = false;

  bool get isEmailValid {
    final email = gmailCtrl.text.trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  bool panVerified = false;
  AadhaarKycStatus _aadhaarStatus = AadhaarKycStatus.notStarted;

  String? ocrPanNumber;

  bool isApiLoading = false;

  bool get isAllVerified {
    return panOcrCompleted &&
        panNumberVerified &&
        mobileVerified &&
        emailVerified;
    // _aadhaarStatus == AadhaarKycStatus.inProgress;
  }

  String normalizePan(String pan) {
    return pan.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
  }

  bool isValidPan(String pan) {
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
    return panRegex.hasMatch(pan);
  }

  @override
  void initState() {
    super.initState();
    loadTheme();

    _initPage();
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

  Future<void> _initPage() async {
    await _initIds(); // load customerId first
    await _loadCustomerDetails(); // then load draft
    await _loadApplicantFromStorage();
    await _restoreApplicantId();

    mobileCtrl.addListener(() {
      final text = mobileCtrl.text;
      setState(() {
        isMobileValid = text.trim().length == 10;
      });
    });
  }

  Future<void> _initIds() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      customerId = prefs.getInt("customerId");
    });
    final applicantId = prefs.getInt("applicantId");
    if (applicantId != null) {
      debugPrint("📦 applicantId restored = $applicantId");
    }
  }

  Future<void> _loadApplicantFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt("applicantId");

    if (id != null) {
      debugPrint("📦 Loaded applicantId from storage = $id");
    }
  }

  Future<void> _loadCustomerDetails() async {
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
        final applicant = customer["applicant"];

        if (applicant != null) {
          setState(() {
            nameCtrl.text = applicant["name"] ?? "";
            panCtrl.text = applicant["pan"] ?? "";
            mobileCtrl.text = applicant["mobile"] ?? "";
            gmailCtrl.text = applicant["email"] ?? "";

            panOcrCompleted = panCtrl.text.isNotEmpty;
            panNumberVerified = panCtrl.text.isNotEmpty;
            mobileVerified = mobileCtrl.text.length == 10;
            emailVerified = gmailCtrl.text.contains("@");
          });
        }
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
      request.fields['applicantType'] = "APPLICANT";
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

  Future<int> _loadCustomerId() async {
    return widget.customerId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          //  const Color(0xFFF4F6FA),
          isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF4F6FA),

      body: SafeArea(
        child: Stack(
          children: [
            /// MAIN UI
            Column(
              children: [
                // CUSTOM HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: isDarkMode
                                ? Colors.white
                                : Color(0xFF1A237E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Application Details",
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode ? Colors.white : Color(0xFF1A237E),

                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _sectionTitle("PAN Card Verification"),
                        _panUploadCard(),
                        const SizedBox(height: 20),
                        _sectionTitle("Application Information"),
                        _applicationInfoCard(),
                        const SizedBox(height: 20),
                        _aadhaarButton(),
                        const SizedBox(height: 20),
                        _sectionTitle("Live Photo"),
                        _livePhotoCard(),
                        const SizedBox(height: 24),
                        if (isAllVerified) _continueButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            ///  GLOBAL APP LOADER
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

  Widget _continueButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _goToApplicantDetails,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          "Continue",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _goToApplicantDetails() async {
    await DraftService.saveWithStep(widget.customerId, "coApplicantDetails", {
      "applicant": {
        "name": nameCtrl.text,
        "pan": panCtrl.text,
        "mobile": mobileCtrl.text,
        "email": gmailCtrl.text,
        "panVerified": panNumberVerified,
        "mobileVerified": mobileVerified,
        "emailVerified": emailVerified,
        "aadhaarStatus": _aadhaarStatus.name,
      },
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoApplicantPage(customerId: widget.customerId),
      ),
    );
  }

  Future<void> _pickPanFromDevice() async {
    final XFile? img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (img != null) {
      final bytes = await img.readAsBytes();

      setState(() {
        panFile = PlatformFile(
          name: img.name,
          size: bytes.length,
          bytes: bytes,
          path: img.path,
        );

        panVerified = false;
        panOcrCompleted = false;
        panNumberVerified = false;
      });

      _hitPanOcr();
    }
  }

  // ---------------- PAN CARD ----------------
  Widget _panUploadCard() {
    return _card(
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Upload PAN Card",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,

                    color: isDarkMode ? Colors.white : Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  panFile == null ? "No file selected" : "PAN Selected",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // CAMERA BUTTON
          IconButton(
            tooltip: "Capture PAN",
            icon: Icon(
              Icons.camera_alt,
              // color: Color(0xFF1A237E)
              color: isDarkMode ? Colors.white : Color(0xFF1A237E),
            ),
            onPressed: _capturePan,
          ),

          // UPLOAD BUTTON
          IconButton(
            tooltip: "Upload from device",
            icon: Icon(
              Icons.upload_file,
              //  color: Color(0xFF1A237E)
              color: isDarkMode ? Colors.white : Color(0xFF1A237E),
            ),
            onPressed: _pickPanFromDevice,
          ),
        ],
      ),
    );
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isDarkMode = prefs.getBool("isDarkMode") ?? false);
  }

  Future<void> _verifyPanNumber() async {
    final rawPan = panCtrl.text;
    final rawName = nameCtrl.text;

    if (rawPan.isEmpty || rawName.isEmpty) {
      showTopToast(context, "PAN and Name are required", success: false);
      return;
    }

    final pan = normalizePan(rawPan);
    final name = rawName.trim().toUpperCase();

    if (!isValidPan(pan)) {
      showTopToast(context, "Invalid PAN format", success: false);
      return;
    }

    if (ocrPanNumber == null || pan != ocrPanNumber) {
      showTopToast(
        context,
        "PAN does not match uploaded PAN card",
        success: false,
      );
      return;
    }

    try {
      setState(() => isApiLoading = true);

      final customerId = await _loadCustomerId();
      // final customerId = 29;

      final data = await PanVerifyService.verifyPan(
        customerId: customerId,
        pan: pan,
        name: name,
        ownerType: "APPLICANT",
      );

      if (data["verified"] != true) {
        setState(() => panNumberVerified = false);

        showTopToast(
          context,
          data["message"] ?? "PAN verification failed",
          success: false,
        );
        return;
      }

      setState(() {
        panNumberVerified = true;
        mobileVerified = false;
        emailVerified = false;
      });

      if (panFile != null) {
        await _uploadDocument(file: panFile!, documentType: "PAN_CARD");
      }
      showTopToast(context, "PAN verified successfully", success: true);
    } catch (e) {
      setState(() => panNumberVerified = false);

      // setState(() => panNumberVerified = true);

      showTopToast(
        context,
        e.toString(), //  SHOW REAL ERROR
        success: false,
      );
    } finally {
      setState(() => isApiLoading = false);
    }
  }

Future<bool> _sendEmailOtp() async {
  try {
    setState(() {
      isApiLoading = true;
    });

    final token = await AuthService().getToken();
    final cid = await _loadCustomerId(); // ✅ FIXED

    print("CID: $cid");
    print("EMAIL: ${gmailCtrl.text}");

    final response = await http.post(
      Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.sendEmailOtp),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "customerId": cid, // ✅ FIXED
        "email": gmailCtrl.text.trim(),
        "ownerType": "APPLICANT",
      }),
    );

    final data = jsonDecode(response.body);

    print("RESPONSE: $data");

    if (response.statusCode == 200 && data["success"] == true) {
      setState(() {
        emailVerified = true;
      });

      showTopToast(context, "Email Saved & Verified", success: true);
      return true;
    } else {
      showTopToast(
        context,
        data["message"] ?? "Failed to save email",
        success: false,
      );
      return false;
    }
  } catch (e) {
    print("ERROR: $e");
    showTopToast(context, "Email Save Failed", success: false);
    return false;
  } finally {
    setState(() {
      isApiLoading = false;
    });
  }
}

  // ---------------- APPLICATION INFO ----------------
  Widget _applicationInfoCard() {
    return _card(
      Column(
        children: [
          _textField("Full Name", nameCtrl),
          _divider(),

          // PAN NUMBER
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  controller: panCtrl,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                    labelText: "PAN Number",
                    labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (panOcrCompleted && !panNumberVerified)
                ElevatedButton(
                  onPressed: _verifyPanNumber,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Verify"),
                ),
              if (panNumberVerified)
                const Icon(Icons.verified, color: Colors.green),
            ],
          ),

          _divider(),

          // MOBILE
          // MOBILE
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  controller: mobileCtrl,
                  enabled: panNumberVerified,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: "Mobile Number",
                    labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                    counterText: "",
                    border: InputBorder.none,
                  ),
                ),
              ),

              if (panNumberVerified && !mobileVerified)
                ElevatedButton(
                  key: const ValueKey("mobileOtp"),
                  onPressed: panNumberVerified
                      ? () async {
                          final mobile = mobileCtrl.text.trim();

                          if (mobile.length != 10) {
                            showTopToast(
                              context,
                              "Enter valid mobile",
                              success: false,
                            );
                            return;
                          }

                          await _verifyMobileOtp("0000"); // ✅ DIRECT CALL
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(110, 48),
                  ),
                  child: const Text("Verified"),
                ),

              if (mobileVerified)
                const Icon(Icons.verified, color: Colors.green),
            ],
          ),

          _divider(),

          // EMAIL
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: gmailCtrl,
                  enabled: panNumberVerified,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email ID",
                    labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              /// 🔵 If NOT verified → Show Button
              if (panNumberVerified && !emailVerified)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    key: const ValueKey("EmailVerify"),
                    onPressed: () async {
                      if (!isEmailValid) return;

                      await _sendEmailOtp(); 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(110, 48),
                    ),
                    child: const Text("Verified"),
                  ),
                ),

              /// 🟢 If Verified → Show ONLY Icon (NOT inside button)
              if (emailVerified)
                SizedBox(
                  height: 48,
                  width: 48,

                  child: const Icon(Icons.verified, color: Colors.green),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<int?> getApplicantId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("applicantId");
  }

  Future<bool> _sendMobileOtp() async {
    try {
      setState(() {
        isApiLoading = true;
      });
      final token = await AuthService().getToken();
      final cid = await _loadCustomerId(); // ✅ REQUIRED

      debugPrint("TOKEN: $token");
      debugPrint("MOBILE: ${mobileCtrl.text}");

      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.sendMobileOtp),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "customerId": cid, // 🔥 THIS WAS MISSING
          "mobileNumber": mobileCtrl.text.trim(),
          "ownerType": "APPLICANT",
          "applicantId": null,
          "coApplicantId": null,
        }),
      );

      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        showTopToast(context, "OTP Sent Successfully", success: true);
        return true;
      }

      showTopToast(context, data["message"] ?? "OTP failed", success: false);
      return false;
    } catch (e, s) {
      debugPrint("OTP ERROR: $e");
      debugPrintStack(stackTrace: s);
      showTopToast(context, "OTP Send Failed", success: false);
      return false;
    } finally {
      setState(() => isApiLoading = false);
    }
  }

  Future<int?> _fetchApplicantIdWithRetry(int customerId) async {
    for (int i = 0; i < 3; i++) {
      final id = await _fetchApplicantIdFromKyc(customerId);
      if (id != null) return id;
      await Future.delayed(const Duration(milliseconds: 300));
    }
    return null;
  }

  Future<bool> _verifyMobileOtp(String otp) async {
    setState(() => isMobileLoading = true);

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
          "otp": "0000",
          "mobileNumber": mobileCtrl.text.trim(),
          "ownerType": "APPLICANT",
          "skipOtpValidation": true,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          mobileVerified = true;
        });

        showTopToast(context, "Mobile Verified", success: true);
        return true;
      }

      showTopToast(context, data["message"], success: false);
      return false;
    } catch (e) {
      showTopToast(context, "Verification Failed", success: false);
      return false;
    } finally {
      setState(() => isMobileLoading = false);
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

  Future<bool> _verifyEmailOtp(String otp) async {
    setState(() => isEmailLoading = true);

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
          "otp": "0000",
          "email": gmailCtrl.text.trim(),
          "ownerType": "APPLICANT",
          "skipOtpValidation": true,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() => emailVerified = true);

        showTopToast(context, "Email Verified", success: true);
        return true;
      }

      showTopToast(context, data["message"], success: false);
      return false;
    } catch (e) {
      showTopToast(context, "Email verification failed", success: false);
      return false;
    } finally {
      setState(() => isEmailLoading = false);
    }
  }

  Future<void> _loadDraft() async {
    try {
      final draft = await DraftService.loadDraft(widget.customerId);

      if (draft == null) {
        debugPrint("No draft found for customerId ${widget.customerId}");
        return;
      }

      debugPrint("Draft Loaded: $draft");

      final applicant = draft["applicant"];

      if (applicant == null) return;

      setState(() {
        nameCtrl.text = applicant["name"] ?? "";
        panCtrl.text = applicant["pan"] ?? "";
        mobileCtrl.text = applicant["mobile"] ?? "";
        gmailCtrl.text = applicant["email"] ?? "";

        panOcrCompleted = panCtrl.text.isNotEmpty;

        panNumberVerified = applicant["panVerified"] == true;
        mobileVerified = applicant["mobileVerified"] == true;
        emailVerified = applicant["emailVerified"] == true;

        if (applicant["aadhaarStatus"] != null) {
          _aadhaarStatus = AadhaarKycStatus.values.firstWhere(
            (e) => e.name == applicant["aadhaarStatus"],
            orElse: () => AadhaarKycStatus.notStarted,
          );
        } else {
          _aadhaarStatus = AadhaarKycStatus.notStarted;
        }
      });
    } catch (e) {
      debugPrint("Draft load error: $e");
    }
  }

  Future<void> _pickLivePhotoFromDevice() async {
    final XFile? img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (img != null) {
      setState(() {
        livePhoto = img;
      });

      // if (panFile != null) {
      await _uploadDocument(
        file: PlatformFile(
          name: img.name,
          size: await File(img.path).length(),
          path: img.path,
        ),
        documentType: "LIVE_PHOTO",
      );
      // }
      // Optionally, you can directly upload the live photo here
    }
  }

  Widget _aadhaarButton() {
    String label;
    VoidCallback? onTap;
    Color bgColor;

    switch (_aadhaarStatus) {
      case AadhaarKycStatus.notStarted:
        label = "Complete Aadhaar KYC";
        bgColor = AppColors.darkBlue;
        onTap = _initiateAadhaarKyc;
        break;

      case AadhaarKycStatus.initiated:
      case AadhaarKycStatus.inProgress:
        label = "Refresh Aadhaar Status";
        bgColor = AppColors.darkBlue;
        onTap = _checkAadhaarStatus;
        break;

      case AadhaarKycStatus.verified:
        label = "Continue";
        bgColor = AppColors.success;
        onTap = () {
          setState(() {
            _aadhaarStatus = AadhaarKycStatus.completed;
          });
        };
        break;

      case AadhaarKycStatus.completed:
        label = "Continue";
        bgColor = AppColors.success;
        onTap = _goToApplicantDetails;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _aadhaarStatusBanner(),
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

  Widget _previewImage(XFile file, {double height = 160}) {
    if (kIsWeb) {
      return Image.network(file.path, height: height, fit: BoxFit.cover);
    } else {
      return Image.file(File(file.path), height: height, fit: BoxFit.cover);
    }
  }

  // ---------------- LIVE PHOTO ----------------
  Widget _livePhotoCard() {
    return _card(
      Column(
        children: [
          livePhoto == null
              ? const Icon(Icons.camera_alt, size: 60, color: Colors.grey)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _previewImage(livePhoto!),
                ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // CAMERA BUTTON
              ElevatedButton.icon(
                onPressed: _captureLivePhoto,
                icon: const Icon(Icons.camera),
                label: const Text("Capture"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              // UPLOAD BUTTON
              OutlinedButton.icon(
                onPressed: _pickLivePhotoFromDevice,
                icon: Icon(
                  Icons.upload_file,
                  color: isDarkMode ? Colors.white : Color(0xFF1A237E),
                ),
                label: Text(
                  "Upload",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Color(0xFF1A237E),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _checkAadhaarStatus() async {
    try {
      setState(() => _aadhaarStatus = AadhaarKycStatus.inProgress);

      final customerId = await _loadCustomerId();
      // final customerId = 29;
      final List statuses = await AadhaarKycService.getVerificationStatuses(
        customerId,
      );

      // 🔍 Find APPLICANT record
      final applicant = statuses.firstWhere(
        (e) => e["ownerType"] == "APPLICANT",
        orElse: () => null,
      );

      if (applicant == null) {
        showTopToast(context, "Applicant KYC status not found", success: false);
        return;
      }

      final aadhaarStatus = applicant["aadhaarStatus"];

      debugPrint("AADHAAR STATUS: $aadhaarStatus");

      if (aadhaarStatus == "VERIFIED") {
        setState(() => _aadhaarStatus = AadhaarKycStatus.completed);
        showTopToast(context, "Aadhaar verified successfully", success: true);
      } else {
        showTopToast(context, "Aadhaar verification pending", success: false);
      }
    } catch (e) {
      debugPrint("AADHAAR STATUS ERROR: $e");
      showTopToast(context, "Failed to fetch Aadhaar status", success: false);
    }
  }

  Future<void> _capturePan() async {
    final XFile? img = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WebCameraCapture()),
    );

    if (img != null) {
      final bytes = await img.readAsBytes(); // 🔥 convert
      final platformFile = PlatformFile(
        name: img.name,
        size: bytes.length,
        bytes: bytes,
      );
      setState(() {
        panFile = PlatformFile(
          name: img.name,
          size: bytes.length,
          bytes: bytes,
          path: img.path,
        );

        panVerified = false;
        panOcrCompleted = false;
        panNumberVerified = false;
      });

      _hitPanOcr(); // AUTO OCR
      await _uploadDocument(file: platformFile, documentType: "PAN_CARD");
    }
  }

  Future<void> _captureLivePhoto() async {
    final XFile? img = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WebCameraCapture()),
    );

    if (img != null) {
      setState(() {
        livePhoto = img;
      });
    }
  }

  Future<void> _hitPanOcr() async {
    if (panFile == null) return;

    setState(() => isApiLoading = true);

    try {
      final result = await PanOcrService.scanPan(panFile!);

      if (result == null || result.panNumber == null) {
        throw Exception("PAN not detected");
      }

      final normalizedOcrPan = normalizePan(result.panNumber!);

      setState(() {
        ocrPanNumber = normalizedOcrPan; // ✅ IMPORTANT
        panCtrl.text = normalizedOcrPan; // ✅ keep same format
        if (result.name != null) {
          nameCtrl.text = result.name!.trim().toUpperCase();
        }
        panOcrCompleted = true;
        panNumberVerified = false; // ✅ reset
      });

      debugPrint("OCR PAN => $normalizedOcrPan");
    } catch (e) {
      debugPrint("PAN OCR ERROR: $e");
      showTopToast(context, "PAN OCR failed: $e", success: false);
    } finally {
      setState(() => isApiLoading = false);
    }
  }

  Future<void> _initiateAadhaarKyc() async {
    if (!panNumberVerified || !mobileVerified || !emailVerified) {
      showTopToast(
        context,
        "Complete PAN, Mobile & Email verification",
        success: false,
      );
      return;
    }

    try {
      setState(() {
        isApiLoading = true;
        _aadhaarStatus = AadhaarKycStatus.inProgress;
      });
      //  final customerId =  29;
      final customerId = await _loadCustomerId();

      final result = await AadhaarKycService.verifyAadhaar(
        customerId: customerId,
        ownerType: "APPLICANT",
      );

      // Backend decides status
      if (result["status"] == "VERIFIED") {
        setState(() => _aadhaarStatus = AadhaarKycStatus.completed);
        showTopToast(context, "Aadhaar verified successfully", success: true);
      } else {
        setState(() => _aadhaarStatus = AadhaarKycStatus.initiated);
        showTopToast(context, "Aadhaar KYC initiated", success: true);
      }
    } catch (e) {
      showTopToast(context, e.toString(), success: false);
    } finally {
      setState(() => isApiLoading = false);
    }
  }

  Future<T> withMinimumLoader<T>(Future<T> Function() task) async {
    setState(() => isApiLoading = true);
    final start = DateTime.now();

    final result = await task();

    final elapsed = DateTime.now().difference(start);
    if (elapsed.inMilliseconds < 400) {
      await Future.delayed(
        Duration(milliseconds: 400 - elapsed.inMilliseconds),
      );
    }

    setState(() => isApiLoading = false);
    return result;
  }

  // ---------------- UI HELPERS ----------------
  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            // color: Color(0xFF1A237E),
            color: isDarkMode ? Colors.white : Color(0xFF1A237E),
          ),
        ),
      ),
    );
  }

  Widget _aadhaarStatusBanner() {
    if (_aadhaarStatus == AadhaarKycStatus.notStarted) {
      return const SizedBox();
    }

    late String text;
    late Color color;

    switch (_aadhaarStatus) {
      case AadhaarKycStatus.initiated:
        text = "Aadhaar KYC Initiated";
        color = Colors.orange;
        break;
      case AadhaarKycStatus.inProgress:
        text = "Aadhaar KYC In Progress";
        color = Colors.blue;
        break;
      case AadhaarKycStatus.verified:
        text = "Aadhaar Verified";
        color = Colors.green;
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
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_outlined,
            // color: color
            color: isDarkMode ? Colors.white : color,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Colors.white,
        color: isDarkMode ? const Color(0xFF1E293B) : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _textField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
        border: InputBorder.none,
      ),
    );
  }

  Widget _divider() => const Divider(height: 24);
}
