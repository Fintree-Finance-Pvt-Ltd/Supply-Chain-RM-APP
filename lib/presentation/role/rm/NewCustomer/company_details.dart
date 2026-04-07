import 'dart:convert';
import 'package:http_parser/http_parser.dart';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/auth_service.dart';
import 'package:supply_chain/core/services/draft_service.dart';
import 'package:supply_chain/core/services/pan_ocr_service.dart';
import 'package:supply_chain/core/services/web_camera_capture.dart';
import 'package:supply_chain/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:supply_chain/core/utils/toast_helper.dart';
import 'package:supply_chain/core/widgets/app_loader.dart';
import 'package:supply_chain/core/widgets/mobile_consent_popup.dart';
import 'package:supply_chain/presentation/role/rm/NewCustomer/applicant_details.dart';
// 27abcde1234f1z5

// const String CONSENT_TEXT = '''
//   I/We hereby authorise Fintree Finance Private Limited (FFPL) (hereinafter referred to as “Lender”) or its associates/subsidiaries affiliates to obtain, verify, exchange, share or part with all the information or otherwise, regarding my/our office/residence and/or contact me/us or my/our family/ employer/Banker/Credit Bureau/ RBI or any third parties as deemed necessary and/or do any such acts till such period as they deem necessary and/or disclose to Reserve bank of India, Credit Information Companies, Banks/NBFCs, or any other authority and institution, including but not limited to current balance, payment history, default, if any, etc. I/We hereby authorise Lender’s employees/agents to access my/our premises during normal office hours for carrying out any verification investigation which includes taking photographs and post disbursement scrutiny. I/We hereby authorise Lender to approach my/our existing bankers or any other prospective lender for any relevant information for consideration of loan and thereafter. I/We hereby provide my/our consent to receive information/services etc for marketing purpose through telephone/mobile/SMS/Email. I/We hereby authorise Lender to market/sell/promote/endorse any other product or service beneficial to me/us. I/We hereby authorise Lender to purge the documents submitted by me/us, if the case is not disbursed/approved for whatever reason within 3 months of application. I/We hereby provide my/our consent to avail information on products and services of other Companies and authorise to cross sell other company’s product and services. I/We hereby authorise Fintree Finance Private Limited(FFPL) or its associates/subsidiaries/affiliates to obtain, verify, exchange, share or part with all the information or otherwise, regarding my/our office/ residence and/or contact me/us or my our family/ employer/Banker/Credit Bureau/ RBI or any third parties as deemed necessary and/or do any such acts till such period as they deem necessary and/or disclose to Reserve bank of India, Credit Information Companies, Banks/NBFCs, or any other authority and institution, including but not limited to current balance, payment history, default, if any, etc. I/We hereby agree to give my/our express consent to Lender to disclose all the information and data furnished by me/us and/or to receive information from Central KYC Registry/third parties including but not limited to vendors, outsourcing agencies, business correspondents for analysing, processing, report generation, storing, record keeping or to various credit information companies/ credit bureaus e.g. Credit Information Bureaus (India) Limited (CIBIL), or to information utilities under the Insolvency Bankruptcy Code 2016 through physical or SMS or email or any other mode.
// ''';

class CompanyDetails extends StatefulWidget {
  final bool isResume;
  final int? customerId;
  final Map<String, dynamic>? draftData;

  const CompanyDetails({
    super.key,
    this.isResume = false,
    this.customerId,
    this.draftData,
  });

  @override
  State<CompanyDetails> createState() => _CompanyDetailsState();
}

class _CompanyDetailsState extends State<CompanyDetails> {
  String? selectedCompanyType;
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController gstController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  final TextEditingController panController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool isMobileValid = false;
  bool isEmailValid = false;
  bool panVerified = false;
  bool isApiLoading = false;
  bool panOcrCompleted = false;
  bool panNumberVerified = false;
  bool isMobileLoading = false;
  bool isEmailLoading = false;
  bool isDarkMode = false;

  bool isPanOcrDone = false;

  bool isMobileVerified = false;
  bool isEmailVerified = false;
  bool isPanProcessing = false;
  bool isPanVerified = false;
  PlatformFile? selectedPanFile;
  PlatformFile? selectedGstFile;
  bool showContinueButton = false;
  bool isGstInvalid = false;
  bool isGstValidForVerify = false;
  bool isGstProcessing = false;
  bool isGstVerified = false;

  int? customerId;
  // XFile? panFile;
  PlatformFile? panFile;
  XFile? livePhoto;
  List<FocusNode> emailOtpFocusNodes = List.generate(6, (_) => FocusNode());

  List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  final List<String> companyTypes = [
    "Select company type",
    "Proprietorship",
    "HUF",
    "Partnership",
    "Pvt Ltd /Ltd",
    "LLP",
  ];
  // Future<void> _pickPanFile() async {
  //   final XFile? img = await _picker.pickImage(
  //     source: ImageSource.gallery,
  //     imageQuality: 85,
  //   );

  //   if (img != null) {
  //     setState(() {
  //       panFile = img;
  //       panVerified = false;
  //       panOcrCompleted = false;
  //       panNumberVerified = false;
  //     });

  //     _runPanOcr(); // AUTO OCR
  //   }
  // }

  bool get isFormComplete {
    return
    // selectedCompanyType != null &&
    //     selectedCompanyType != "Select company type" &&
    // companyNameController.text.isNotEmpty &&
    // isMobileVerified &&
    // isEmailVerified &&
    // isPanVerified &&
    selectedGstFile != null;
    // isGstVerified;
  }

  // Future<void> _pickPanFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles();

  //   if (result != null) {
  //     setState(() {
  //       selectedPanFile = result.files.first;
  //     });

  //     _runPanOcr(); // if needed
  //   }
  // }

  Future<void> _capturePan() async {
    final XFile? img = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WebCameraCapture()),
    );

    if (img != null) {
      final bytes = await img.readAsBytes();

      final platformFile = PlatformFile(
        name: img.name,
        size: bytes.length,
        bytes: bytes,
      );

      setState(() {
        panFile = platformFile;
        isPanProcessing = true;
      });

      await _uploadDocument(file: platformFile, documentType: "PAN_CARD");

      setState(() {
        isPanProcessing = false;
      });
    }
  }
  // Future<void> _capturePan() async {
  //   final XFile? img = await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (_) => const WebCameraCapture()),
  //   );

  //   if (img != null) {
  //     setState(() {
  //       panFile = img;
  //       panVerified = false;
  //       panOcrCompleted = false;
  //       panNumberVerified = false;
  //     });

  //     _runPanOcr(); // AUTO OCR
  //   }
  // }

  Future<void> _goToApplicantDetails() async {
    final companyData = {
      "companyType": selectedCompanyType,
      "companyName": companyNameController.text,
      "mobile": mobileController.text,
      "email": emailController.text,
      "gst": gstController.text,
      "isMobileVerified": isMobileVerified,
      "isEmailVerified": isEmailVerified,
      "isPanVerified": isPanVerified,
      "isGstVerified": isGstVerified,
      "gstFileName": selectedGstFile?.name,
    };
    await DraftService.saveDraft(customerId ?? 0, {
      "company": companyData,
      "lastStep": "applicantDetails",
    });

    Navigator.push(
      context,

      // MaterialPageRoute(builder: (_) => const AddressDetails()),
      MaterialPageRoute(
        builder: (_) => ApplicantDetails(customerId: customerId ?? 0),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      // Dropdown
      selectedCompanyType = null;

      // Text fields
      companyNameController.clear();
      mobileController.clear();
      emailController.clear();
      gstController.clear();

      // Verification flags
      isMobileVerified = false;
      isEmailVerified = false;
      isPanVerified = false;
      isGstVerified = false;

      // Validation flags
      isMobileValid = false;
      isEmailValid = false;
      isGstValidForVerify = false;

      // Files / media
      selectedGstFile = null;
      panFile = null;
      livePhoto = null;

      // PAN flow
      isPanProcessing = false;
      panVerified = false;
      panOcrCompleted = false;
      panNumberVerified = false;
    });
  }

  Future<void> _loadDraft() async {
    /// API draft passed from Resume page
    if (widget.draftData != null) {
      final data = widget.draftData!;

      setState(() {
        selectedCompanyType =
            (data["companyType"] == null || data["companyType"] == "")
            ? "Select company type"
            : data["companyType"];

        companyNameController.text = data["companyName"] ?? "";

        mobileController.text = data["companyMobile"] ?? "";

        emailController.text = data["companyEmail"] ?? "";

        gstController.text = data["gstNumber"] ?? "";

        isMobileVerified = data["companyMobile"] != null;
        isEmailVerified = data["companyEmail"] != null;
        isGstVerified = data["gstNumber"] != null;

        /// load GST file
        if (data["documents"] != null && data["documents"].isNotEmpty) {
          final documents=data["documents"];
          final gstDoc = data["documents"].firstWhere(
            (doc) => doc["documentType"] == "GST_CERTIFICATE",
            orElse: () => null,
          );


          if (gstDoc != null) {

            selectedGstFile = PlatformFile(name: gstDoc["fileName"], size: 0);
          }

           final panDoc = documents.firstWhere(
            (doc) => doc["documentType"] == "PAN_CARD",
            orElse: () => null,
          );
 
          if (panDoc != null) {
            panFile = PlatformFile(name: panDoc["fileName"], size: 0);
 
            isPanVerified = true;
          }
 
        }
      });

      return;
    }

    /// fallback → local draft
    if (customerId == null) return;

    final draft = await DraftService.loadDraft(customerId!);

    if (draft == null) return;

    final company = draft["company"];

    setState(() {
      selectedCompanyType = company["companyType"];
      companyNameController.text = company["companyName"] ?? "";
      mobileController.text = company["mobile"] ?? "";
      emailController.text = company["email"] ?? "";
      gstController.text = company["gst"] ?? "";

      isMobileVerified = company["isMobileVerified"] == true;
      isEmailVerified = company["isEmailVerified"] == true;
      isPanVerified = company["isPanVerified"] == true;
      isGstVerified = company["isGstVerified"] == true;
    });
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

  Future<void> _pickGstFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true, // ✅ IMPORTANT for Web
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      final file = result.files.first;

      setState(() {
        selectedGstFile = file;
      });

      // 🔥 Immediately upload
      await _uploadDocument(file: file, documentType: "GST_CERTIFICATE");
    }
  }


  @override
  void initState() {
    super.initState();
    loadTheme();

    customerId = widget.customerId;

    //  _loadcustomerId().then((_) {

    if (widget.isResume) {
      _loadDraft();
    } else {
      _resetForm();
    }

    // });

    mobileController.addListener(() {
      final text = mobileController.text;

      setState(() {
        isMobileValid = text.length == 10;

        if (text.length != 10) {
          isMobileVerified = false;
        }
      });
    });

    emailController.addListener(() {
      setState(() {
        isEmailValid = RegExp(
          r'^[^@]+@[^@]+\.[^@]+',
        ).hasMatch(emailController.text);
        if (!isEmailValid) {
          isEmailVerified = false;
        }
      });
    });

    gstController.addListener(() {
      final text = gstController.text.toUpperCase();

      if (gstController.text != text) {
        gstController.value = gstController.value.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }

      setState(() {
        isGstValidForVerify = text.length == 15;
      });
    });
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isDarkMode = prefs.getBool("isDarkMode") ?? false);
  }

  @override
  void dispose() {
    for (var f in otpFocusNodes) {
      f.dispose();
    }
    for (var f in emailOtpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF4F6FA),
      backgroundColor: isDarkMode
          ? const Color(0xFF0F172A)
          : const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.card,
        title: const Text("Company Details"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          /// 🔹 MAIN UI
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildMainCard(),
          ),

          /// GLOBAL APP LOADER (PAN OCR + GST VERIFY)
          if (isApiLoading)
            Container(
              color: Colors.black.withOpacity(0.35),
              child: const Center(child: AppLoader(size: 75)),
            ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // color: Colors.white,
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section Title
          Text(
            "Company Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              // color: Color(0xFF1F3C88),
              color: isDarkMode ? Colors.white : const Color(0xFF1F3C88),
            ),
          ),

          const SizedBox(height: 24),

          /// Company Type
          Text(
            "Company Type *",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF1F3C88),
            ),
          ),
          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            initialValue: companyTypes.contains(selectedCompanyType)
                ? selectedCompanyType
                : null,

            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              // fontSize: 14,
            ),

            dropdownColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,

            decoration: _inputDecoration(),
            hint: Text(
              "Select company type",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xFF1F3C88),
              ),
            ),
            items: companyTypes.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCompanyType = value;
              });
            },
          ),

          const SizedBox(height: 20),

          /// 🔥 KEEP YOUR LOGIC SAME
          _buildDynamicFields(),

          _buildCommonFields(),

          const SizedBox(height: 20),

          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isFormComplete ? 1 : 0.6,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _goToApplicantDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        // color: AppColors.card,
        color: isDarkMode ? const Color(0xFF1E293B) : AppColors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(2, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Future<void> _pickPanFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        panFile = result.files.first;
        isPanVerified = false;
        isPanOcrDone = false;
      });

      // 🔥 Run OCR only
      await _runPanOcr();
    }
  }

  Widget _panUploadCard() {
    return _card(
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: panFile == null ? _panEmptyState() : _panUploadedState(),
      ),
    );
  }

  Widget _panEmptyState() {
    return Row(
      key: const ValueKey("empty"),
      children: [
        const Icon(Icons.upload_file, color: Colors.grey),
        const SizedBox(width: 10),

        const Expanded(
          child: Text("No file selected", style: TextStyle(color: Colors.grey)),
        ),

        IconButton(
          tooltip: "Capture PAN",
          icon: Icon(
            Icons.camera_alt,
            // color: Color(0xFF1A237E)
            color: isDarkMode ? Colors.white : const Color(0xFF1F3C88),
          ),
          onPressed: _capturePan,
        ),

        IconButton(
          tooltip: "Upload from device",
          icon: Icon(
            Icons.upload_file,
            //  color: Color(0xFF1A237E)
            color: isDarkMode ? Colors.white : const Color(0xFF1F3C88),
          ),
          onPressed: _pickPanFile,
        ),
      ],
    );
  }

  Widget _panUploadedState() {
    return Column(
      key: const ValueKey("uploaded"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.description, color: Colors.blue),
            const SizedBox(width: 8),

            Expanded(
              child: Text(
                panFile!.name,
                style:  TextStyle(fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.white : Colors.black,
),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            TextButton(onPressed: _previewPan, child: const Text("Preview")),
            const SizedBox(width: 12),
            TextButton(onPressed: _pickPanFile, child: const Text("Replace")),
          ],
        ),

        if (isPanProcessing)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildCommonFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Company PAN Card *",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xFF1F3C88),
              ),
            ),
            const SizedBox(height: 8),
            _panUploadCard(),
          ],
        ),

        // _panUploadCard(),
        const SizedBox(height: 20),
        _mobileField(), // 👈 USE IT HERE
        const SizedBox(height: 20),

        _verifyField(
          label: "Business Email ID *",
          hint: "Enter business email",
          controller: emailController,
          keyboardType: TextInputType.emailAddress,

          isValid: isEmailValid,
          isLoading: isEmailLoading,
          isVerified: isEmailVerified,
        ),

        const SizedBox(height: 20),

        _fileUploadField(
          label: "GST Certificate Upload *",
          selectedFile: selectedGstFile,
          onPressed: _pickGstFile,
        ),
        const SizedBox(height: 16),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "GST Number *",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xFF1F3C88),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isGstVerified
                            ? Colors.green
                            : isGstInvalid
                            ? Colors.red
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      controller: gstController,
                      maxLength: 15,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: "Enter GST Number",
                        counterText: "",
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.black54,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        suffixIcon: isGstProcessing
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : isGstVerified
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : isGstInvalid
                            ? const Icon(Icons.error, color: Colors.red)
                            : null,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isGstVerified
                        ? Colors.green
                        : AppColors.darkBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                  onPressed: isGstValidForVerify && !isGstProcessing
                      ? _verifyGst
                      : null,
                  child: isGstProcessing
                      ? const Text("Verifying...")
                      : isGstVerified
                      ? const Text("Verified")
                      : const Text("Verify"),
                ),
              ],
            ),

            if (isGstInvalid)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  "Invalid GST Number",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            if (isGstVerified)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  "GST Verified Successfully",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _mobileField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Company Mobile Number *",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF1F3C88),
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: TextField(
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                controller: mobileController,
                keyboardType: TextInputType.number,
                maxLength: 10, // 👈 LIMIT LENGTH
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // 👈 ONLY NUMBERS
                  LengthLimitingTextInputFormatter(10), // 👈 HARD LIMIT
                ],
                decoration: _modernInputDecoration("Enter mobile number")
                    .copyWith(
                      errorText:
                          mobileController.text.isNotEmpty &&
                              mobileController.text.length < 10
                          ? "Mobile number must be 10 digits"
                          : null,
                    ),
              ),
            ),
            const SizedBox(width: 10),

            ///  If Verified → Show ONLY Icon (NOT inside button)
            if (!isMobileVerified && isMobileValid)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: ElevatedButton(
                  key: const ValueKey("mobileVerify"),
                  onPressed: () async {
                    if (!isMobileValid) return;

                    await _verifyMobileOtp("0000");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(110, 48),
                  ),
                  child: isMobileLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Verify"),
                ),
              ),
            if (isMobileVerified)
              SizedBox(
                height: 48,
                width: 48,

                child: const Icon(Icons.verified, color: Colors.green),
              ),
          ],
        ),
      ],
    );
  }

  Widget _verifyField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isValid,
    required bool isLoading,
    required bool isVerified,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF1F3C88),
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: TextField(
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                controller: controller,
                keyboardType: keyboardType,
                decoration: _modernInputDecoration(hint),
              ),
            ),

            const SizedBox(width: 10),

           
            if (!isEmailVerified && isEmailValid)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: ElevatedButton(
                  key: const ValueKey("EmailVerify"),
                  onPressed: () async {
                    if (!isEmailValid) return;

                    await _sendEmailOtp(); // ✅ THIS WILL SAVE EMAIL
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(110, 48),
                  ),
                  child: isEmailLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Verify"),
                ),
              ),

            /// 🟢 If Verified → Show ONLY Icon (NOT inside button)
            if (isEmailVerified)
              SizedBox(
                height: 48,
                width: 48,

                child: const Icon(Icons.verified, color: Colors.green),
              ),
          ],
        ),
      ],
    );
  }

  InputDecoration _modernInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        // color: Color.fromARGB(255, 16, 16, 16),
        color: isDarkMode ? Colors.white70 : Colors.black87,
        fontSize: 14,
      ),

      filled: true,
      // fillColor: const Color(0xFFF8F9FC), // 👈 Light grey background
      fillColor: isDarkMode ? const Color(0xFF334155) : const Color(0xFFF8F9FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.white24 : const Color(0xFFE5E7EB),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.white24 : const Color(0xFFE5E7EB),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // borderSide: BorderSide(color: AppColors.darkBlue, width: 1.5),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.white24 : const Color(0xFFE5E7EB),
        ),
      ),
    );
  }


  Widget _buildDynamicFields() {
    return Column(
      children: [
        Visibility(
          visible: selectedCompanyType == "Proprietorship",
          child: Column(
            children: [
              _simpleField(
                label: "Company Name *",
                hint: "Company name will auto-fill",
                controller: companyNameController,
                enabled:
                    isPanVerified ||
                    true, //during testing, we can allow editing company name even before PAN verification. Change it back to `
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),

        /// ===== PRIVATE LIMITED FIELDS =====
        Visibility(
          visible: selectedCompanyType == "Pvt Ltd /Ltd",
          child: Column(
            children: [
              _simpleField(
                label: "Company Name *",
                hint: "Company name will auto-fill",
                controller: companyNameController,
                enabled:
                    isPanVerified ||
                    true, //during testing, we can allow editing company name even before PAN verification. Change it back to `
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),

        /// ===== PARTNERSHIP FIELDS =====
        Visibility(
          visible: selectedCompanyType == "Partnership",
          child: Column(
            children: [
              _simpleField(
                label: "Company Name *",
                hint: "Company name will auto-fill",
                controller: companyNameController,
                enabled: isPanVerified || true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        /// ===== LLP =====
        Visibility(
          visible: selectedCompanyType == "LLP",
          child: Column(
            children: [
              _simpleField(
                label: "Company Name *",
                hint: "Company name will auto-fill",
                controller: companyNameController,
                enabled: isPanVerified || true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        /// ===== HUF =====
        Visibility(
          visible: selectedCompanyType == "HUF",
          child: Column(
            children: [
              _simpleField(
                label: "Company Name *",
                hint: "Company name will auto-fill",
                controller: companyNameController,
                enabled: isPanVerified || true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> _verifyMobileOtp(String otp) async {
    final prefs = await SharedPreferences.getInstance();
    final rmId = prefs.getInt("rmId");
    setState(() {
      isMobileLoading = true;
    });

    try {
      final token = await AuthService().getToken();
      print("JWT TOKEN IS: $token");
      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.verifyMobileOtp),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          if (customerId != null) "customerId": customerId,
          "otp": "0000",
          "mobileNumber": mobileController.text.trim(),
          "ownerType": "COMPANY",
          "skipOtpValidation": true,
          "companyType": selectedCompanyType,
          "companyName": companyNameController.text,
          "rmId": rmId,
        }),
      );

      print(response.body);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        final int? newCustomerId = data["customerId"];

        if (newCustomerId == null) {
          throw Exception("customerId not returned from backend");
        }

        setState(() {
          customerId = newCustomerId;
          isMobileVerified = true;
        });

        showTopToast(context, "Mobile Verified Successfully", success: true);

        if (isPanOcrDone && panFile != null) {
          // await _uploadPan();
          // await _uploadDocument(file: panFile!, documentType: "PAN_CARD");
          await _uploadDocument(file: panFile!, documentType: "PAN_CARD");
        }
        return true;
      } else {
        showTopToast(context, data["message"] ?? "Invalid OTP", success: false);
        return false;
      }
    } catch (e) {
      showTopToast(context, "Verification Failed", success: false);
      return false;
    } finally {
      setState(() {
        isMobileLoading = false;
      });
    }
  }

  Future<bool> _verifyEmailOtp(String otp) async {
    setState(() {
      isEmailLoading = true;
    });

    try {
      final token = await AuthService().getToken();

      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.verifyEmailOtp),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          if (customerId != null) "customerId": customerId,
          "otp": "0000",
          "email": emailController.text.trim(),
          "ownerType": "COMPANY",
          "skipOtpValidation": true,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          isEmailVerified = true;
        });

        showTopToast(context, "Email Verified Successfully", success: true);
        return true;
      } else {
        showTopToast(context, data["message"] ?? "Invalid OTP", success: false);
        return false;
      }
    } catch (e) {
      showTopToast(context, "Email Verification Failed", success: false);
      return false;
    } finally {
      setState(() {
        isEmailLoading = false;
      });
    }
  }

  Future<bool> _sendEmailOtp() async {
    try {
      setState(() {
        isApiLoading = true;
      });

      final token = await AuthService().getToken();

      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.sendEmailOtp),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "customerId": customerId,
          "email": emailController.text.trim(),
          "ownerType": "COMPANY",
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        // 🔥 IMPORTANT: mark verified manually
        setState(() {
          isEmailVerified = true;
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
      showTopToast(context, "Email Save Failed", success: false);
      return false;
    } finally {
      setState(() {
        isApiLoading = false;
      });
    }
  }

  Future<void> _checkDraft() async {
    final draft = await DraftService.loadDraft(customerId ?? 0);
    _showResumeDialog();
  }

  void _previewPan() {
    if (panFile == null || panFile!.bytes == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Image.memory(panFile!.bytes!, fit: BoxFit.contain),
        );
      },
    );
  }


  void _showResumeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Resume Draft?"),
        content: const Text("You have an incomplete application."),
        actions: [
          TextButton(
            onPressed: () async {
              if (customerId != null) {
                await DraftService.clearDraft(customerId!);
              }
              Navigator.pop(context);
            },
            child: const Text("Start Fresh"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // _loadDraft();
            },
            child: const Text("Resume"),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyGst() async {
    final gstNumber = gstController.text.trim();

    if (gstNumber.length != 15) {
      setState(() => isGstInvalid = true);
      return;
    }

    setState(() {
      isApiLoading = true;
      isGstProcessing = true;
      isGstInvalid = false;
    });

    try {
      final token = await AuthService().getToken();


      final storedCustomerId = customerId;
      if (storedCustomerId == null) {
        throw Exception("Customer ID not found. Verify mobile first.");
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.verifyGst),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "customerId": storedCustomerId,
          "gstNumber": gstNumber,
          "ownerType": "COMPANY",
          "applicantId": null,
          "coApplicantId": null,
        }),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          isGstVerified = true;
          isGstInvalid = false;
        });

        showTopToast(
          context,
          "GST Verified & Saved Successfully",
          success: true,
        );
      } else {
        setState(() {
          isGstVerified = false;
          isGstInvalid = true;
        });

        showTopToast(
          context,
          data["message"] ?? "GST verification failed",
          success: false,
        );
      }
    } catch (e) {
      print("GST ERROR: $e");

      setState(() {
        isGstVerified = false;
        isGstInvalid = true;
      });

      showTopToast(context, "GST verification failed", success: false);
    } finally {
      setState(() {
        isGstProcessing = false;
        isApiLoading = false;
      });
    }
  }

  Widget _simpleField({
    required String hint,
    required String label,
    TextEditingController? controller,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF1F3C88),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          decoration: _inputDecoration(hintText: hint),
        ),
      ],
    );
  }

  // Widget _fieldWithButton(String hint, String buttonText) {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: TextField(decoration: _inputDecoration(hintText: hint)),
  //       ),
  //       const SizedBox(width: 10),
  //       ElevatedButton(
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: AppColors.darkBlue,
  //           foregroundColor: AppColors.card,

  //           elevation: 0,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //         ),
  //         onPressed: () {},
  //         child: Text(
  //           buttonText,
  //           style: const TextStyle(
  //             color: Colors.white, // 🔥 FORCE TEXT COLOR HERE
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //       ),

  //     ],
  //   );
  // }

  Widget _fileUploadField({
    required String label,
    required PlatformFile? selectedFile,
    required VoidCallback onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF1F3C88),
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  // color: AppColors.card,
                  color: isDarkMode
                      ? const Color(0xFF334155)
                      : const Color(0xFFF8F9FC),
                ),
                child: Text(
                  selectedFile?.name ?? "Choose File",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xFF1F3C88),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onPressed,
              child: const Text("Choose File"),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        // color: Colors.black
        // color: isDarkMode ? Colors.white : const Color(0xFF1F3C88),
        color: isDarkMode ? Colors.white54 : Colors.black54,

        fontSize: 14,
      ),

      filled: true,
      // fillColor: Colors.white,
      // fillColor: const Color(0xFFF8F9FC)
      //, // 👈 Light grey background
      fillColor: isDarkMode ? const Color(0xFF334155) : const Color(0xFFF8F9FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkBlue, width: 1.5),
      ),
    );
  }

  Future<int?> _loadcustomerId() async {
    return widget.customerId;
  }

  Future<void> _uploadDocument({
    required PlatformFile file,
    required String documentType,
    Map<String, dynamic> meta = const {},
  }) async {
    if (documentType == "PAN_CARD" && !isMobileVerified) {
      showTopToast(
        context,
        "Verify mobile number before saving PAN",
        success: false,
      );
      return;
    }
    try {
      setState(() => isApiLoading = true);

      final token = await AuthService().getToken();
      // final prefs = await SharedPreferences.getInstance();
      // // final int? storedCustomerId = prefs.getInt("customerId");

      //     final storedCustomerId = await _loadCustomerId();
      //               // final storedCustomerId = await _loadcustomerId();

      final storedCustomerId = customerId;

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
    } finally {
      setState(() => isApiLoading = false);
    }
  }

  // Future<void> _runPanOcr() async {
  //   setState(() {
  //     isPanProcessing = true;
  //     isPanVerified = false;
  //   });

  //   await Future.delayed(const Duration(seconds: 2));

  //   // Simulated OCR response
  //   String fetchedCompanyName = "ABC INDUSTRIES PRIVATE LIMITED";

  //   setState(() {
  //     companyNameController.text = fetchedCompanyName;
  //     isPanProcessing = false;
  //     isPanVerified = true;
  //   });

  //         showTopToast(context, "PAN ocr successfully", success: true);

  // }

  //============ pan ocr production api ===========

  Future<void> _runPanOcr() async {
    if (panFile == null) return;

    setState(() {
      isPanProcessing = true;
      isPanVerified = false;
    });

    try {
      final result = await PanOcrService.scanPan(panFile!);

      if (result == null) {
        throw Exception("No OCR data received");
      }

      final extractedName = result.name?.trim().toUpperCase();

      if (extractedName == null || extractedName.isEmpty) {
        throw Exception("Name not detected");
      }

      setState(() {
        companyNameController.text = extractedName;
        isPanVerified = true;
        isPanOcrDone = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PAN OCR completed successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        isPanVerified = false;
        isPanOcrDone = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("PAN OCR failed: $e")));
    } finally {
      setState(() {
        isPanProcessing = false;
      });
    }
  }

  //    Future<void> _runPanOcr() async {
  //   if (panFile == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please upload PAN image")),
  //     );
  //     return;
  //   }

  //   setState(() {
  //     isPanProcessing = true;
  //     isPanVerified = false;
  //   });

  //   try {
  //     // 🔥 Call updated service (PlatformFile version)
  //     final result = await PanOcrService.scanPan(panFile!);

  //     if (result == null) {
  //       throw Exception("No OCR data received");
  //     }

  //     final extractedName =
  //         result.name?.trim().toUpperCase();

  //     final extractedPan =
  //         result.panNumber?.trim().toUpperCase();

  //     if (extractedName == null || extractedName.isEmpty) {
  //       throw Exception("Company/Name not detected from PAN");
  //     }

  //     setState(() {
  //       companyNameController.text = extractedName;

  //       // Optional: autofill PAN number if you have panController
  //       if (extractedPan != null && extractedPan.isNotEmpty) {
  //         panController.text = extractedPan;
  //       }

  //       isPanVerified = true;
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("PAN OCR completed successfully"),
  //         backgroundColor: Colors.green,
  //       ),
  //     );

  //   } catch (e) {
  //     debugPrint("PAN OCR ERROR: $e");

  //     setState(() {
  //       isPanVerified = false;
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text("PAN OCR failed: $e"),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   } finally {
  //     setState(() {
  //       isPanProcessing = false;
  //     });
  //   }
  // }

  Future<void> _runPanOcr1() async {
    if (panFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please upload PAN image")));
      return;
    }

    setState(() {
      isPanProcessing = true;
      isPanVerified = false;
    });

    try {
      final result = await PanOcrService.scanPan(panFile!);

      if (result == null) {
        throw "No OCR data received";
      }

      // Prefer company name if available, else fallback to name
      final extractedName = result.name?.trim().toUpperCase();

      if (extractedName == null || extractedName.isEmpty) {
        throw "Company/Name not detected from PAN";
      }

      setState(() {
        companyNameController.text = extractedName;
        isPanVerified = true;
        isPanProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PAN OCR completed successfully")),
      );
    } catch (e) {
      setState(() {
        isPanProcessing = false;
        isPanVerified = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("PAN OCR failed: $e")));
    }
  }
}
