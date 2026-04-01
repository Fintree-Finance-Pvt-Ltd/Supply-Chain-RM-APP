import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/auth_service.dart';
import 'package:supply_chain/core/services/draft_service.dart';
import 'package:supply_chain/core/theme/app_colors.dart';
import 'package:supply_chain/core/utils/toast_helper.dart';
import 'package:supply_chain/core/widgets/mobile_consent_popup.dart';
import 'package:supply_chain/presentation/role/rm/NewCustomer/address_details.dart';

/// =======================
/// DATA MODEL
/// =======================
class ContactPersonModel {
  final nameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final designationCtrl = TextEditingController();

  String gender = '';

  bool mobileVerified = false;
  bool emailVerified = false;
}

/// =======================
/// MAIN SCREEN
/// =======================
class ContactPerson extends StatefulWidget {
  final int customerId;

  const ContactPerson({super.key, required this.customerId});

  @override
  State<ContactPerson> createState() => _ContactPersonState();
}

class _ContactPersonState extends State<ContactPerson> {
  final List<ContactPersonModel> contacts = [];
  bool isDarkMode = false;

  bool get _canContinue {
    if (contacts.isEmpty) return false;

    for (final c in contacts) {
      if (c.nameCtrl.text.trim().isEmpty) return false;
      if (c.designationCtrl.text.trim().isEmpty) return false;
      if (c.gender.isEmpty) return false;
      // if (!c.mobileVerified) return false;
      // if (!c.emailVerified) return false;
    }
    return true;
  }

  final _formKey = GlobalKey<FormState>();

  bool _isValidEmail(String value) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
  }

  ///
  Future<int> _loadCustomerId() async {
    return widget.customerId;
  }

  int? _expandedIndex;
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

  Future<void> _initPage() async {
    await _loadCustomerContacts(); // load API data
    await _loadDraft();
    // override with draft if exists
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0F172A)
          : const Color(0xFFF6F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 16),

                if (contacts.isEmpty)
                  const Text(
                    "No contact persons added yet",
                    style: TextStyle(color: Colors.grey),
                  ),

                ...List.generate(
                  contacts.length,
                  (i) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _expandedIndex = i;
                      });
                    },
                    child: _contactCard(
                      contacts[i],
                      i,
                      isExpanded: _expandedIndex == i,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (_canContinue) _continueButton(context, _formKey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processContactPerson({
    int? id,
    required int customerId,
    required String name,
    required String mobile,
    required String email,
    required String designation,
    required String gender,
  }) async {
    final token = await AuthService().getToken();

    final response = await http.post(
      Uri.parse("${ApiEndpoints.baseUrl}/kyc/contact-person/process"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "id": id,
        "customerId": customerId,
        "name": name,
        "mobile": mobile,
        "email": email,
        "designation": designation,
        "gender": gender,
      }),
    );

    print("CONTACT STATUS: ${response.statusCode}");
    print("CONTACT BODY: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data["success"] != true) {
      throw Exception(data["message"] ?? "Failed to save contact person");
    }
  }

  Future<void> _loadCustomerContacts() async {
    try {
      final token = await AuthService().getToken();

      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/customers/${widget.customerId}"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        final customer = data["data"];

        final List contactList = customer["contactPersons"] ?? [];

        contacts.clear();

        for (final item in contactList) {
          final model = ContactPersonModel();

          model.nameCtrl.text = item["name"] ?? "";
          model.mobileCtrl.text = item["mobile"] ?? "";
          model.emailCtrl.text = item["email"] ?? "";
          model.designationCtrl.text = item["designation"] ?? "";
          model.gender = item["gender"] ?? "";

          model.mobileVerified = model.mobileCtrl.text.length == 10;
          model.emailVerified = model.emailCtrl.text.contains("@");

          contacts.add(model);
        }

        if (contacts.isEmpty) {
          contacts.add(ContactPersonModel());
        }

        setState(() {
          _expandedIndex = 0;
        });
      }
    } catch (e) {
      debugPrint("Contact load error: $e");
    }
  }

  Future<void> _saveContactPersonsToBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // final customerId = 29;
      // final customerId = prefs.getInt("customerId");
      final customerId = await _loadCustomerId();

      for (final model in contacts) {
        await _processContactPerson(
          id: null, // pass model.id if you store it later
          customerId: customerId,
          name: model.nameCtrl.text.trim(),
          mobile: model.mobileCtrl.text.trim(),
          email: model.emailCtrl.text.trim(),
          designation: model.designationCtrl.text.trim(),
          gender: model.gender,
        );
      }

      showTopToast(
        context,
        "Contact persons saved successfully",
        success: true,
      );
    } catch (e) {
      showTopToast(context, e.toString(), success: false);
    }
  }

  Future<void> _saveContactPersonDraft() async {
    List<Map<String, dynamic>> contactPersonList = contacts.map((model) {
      return {
        "name": model.nameCtrl.text,
        "mobile": model.mobileCtrl.text,
        "email": model.emailCtrl.text,
        "designation": model.designationCtrl.text,
        "gender": model.gender,
        "mobileVerified": model.mobileVerified,
        "emailVerified": model.emailVerified,
      };
    }).toList();

    await DraftService.saveWithStep(widget.customerId, "addressDetails", {
      "contactPerson": contactPersonList,
    });
  }

  Future<void> _loadDraft() async {
    final draft = await DraftService.loadDraft(widget.customerId);

    if (draft == null) return;

    if (draft["contactPerson"] != null && draft["contactPerson"] is List) {
      final savedList = draft["contactPerson"] as List;

      contacts.clear();

      for (final item in savedList) {
        final model = ContactPersonModel();

        model.nameCtrl.text = item["name"] ?? "";
        model.mobileCtrl.text = item["mobile"] ?? "";
        model.emailCtrl.text = item["email"] ?? "";
        model.designationCtrl.text = item["designation"] ?? "";
        model.gender = item["gender"] ?? "";

        model.mobileVerified = item["mobileVerified"] == true;
        model.emailVerified = item["emailVerified"] == true;

        contacts.add(model);
      }

      setState(() {});
    }
  }

  /// =======================
  /// HEADER
  /// =======================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkBlue.withOpacity(0.95),
            AppColors.primary.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// TITLE
              Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Contact Person Details",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Add contact persons",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    ),
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: const [
          //     Text(
          //       "Contact Person Details",
          //       style: TextStyle(
          //         fontSize: 18,
          //         fontWeight: FontWeight.w700,
          //         color: Colors.white,
          //       ),
          //     ),
          //     SizedBox(height: 4),
          //     Text(
          //       "Add contact persons",
          //       style: TextStyle(fontSize: 13, color: Colors.white70),
          //     ),
          //   ],
          // ),

          /// ADD BUTTON
          InkWell(
            onTap: () {
              setState(() {
                contacts.add(ContactPersonModel());
                _expandedIndex = contacts.length - 1; //  open newly added
              });
            },

            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // ✅ prevents overflow
              
                  children: const [
                    Icon(Icons.add, size: 18, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      "Add",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
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

  /// =======================
  /// CONTACT CARD
  /// =======================
  Widget _contactCard(
    ContactPersonModel model,
    int index, {
    required bool isExpanded,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Colors.white,
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.06)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= HEADER =================
          Row(
            children: [
              Expanded(
                child: Text(
                  "Contact Person ${index + 1}",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Color(0xFF1A237E),

                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              /// EXPAND / COLLAPSE ICON
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.textSecondary,
              ),

              const SizedBox(width: 8),

              /// REMOVE CARD
              InkWell(
                onTap: () {
                  setState(() {
                    contacts.removeAt(index);
                    if (_expandedIndex == index) {
                      _expandedIndex = null;
                    }
                  });
                },
                child: const Icon(Icons.close, color: Colors.red),
              ),
            ],
          ),

          /// ================= EXPANDED CONTENT =================
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      _field(
                        "Name *",
                        model.nameCtrl,

                        validator: (v) => v == null || v.trim().isEmpty
                            ? "Name is required"
                            : null,
                      ),

                      _field(
                        "Mobile Number *",
                        model.mobileCtrl,
                        keyboard: TextInputType.phone,
                        maxLength: 10,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Mobile number is required";
                          }

                          if (v.length != 10) {
                            return "Mobile number must be 10 digits";
                          }

                          if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) {
                            return "Mobile number must start with 6–9";
                          }

                          return null;
                        },
                      ),

                      _field(
                        "Email *",
                        model.emailCtrl,
                        keyboard: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Email is required";
                          }
                          if (!_isValidEmail(v.trim())) {
                            return "Enter valid email address";
                          }
                          return null;
                        },
                      ),

                      // AnimatedSize(
                      //   duration: const Duration(milliseconds: 250),
                      //   curve: Curves.easeInOut,
                      //   child: isExpanded
                      //       ? Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             const SizedBox(height: 16),

                      //             _field(
                      //               "Name *",
                      //               model.nameCtrl,
                      //               validator: (v) => v == null || v.trim().isEmpty
                      //                   ? "Name is required"
                      //                   : null,
                      //             ),

                      //             _field(
                      //               "Mobile Number *",
                      //               model.mobileCtrl,
                      //               keyboard: TextInputType.phone,
                      //               maxLength: 10,
                      //               validator: (v) {
                      //                 if (v == null || v.trim().isEmpty) {
                      //                   return "Mobile number is required";
                      //                 }

                      //                 if (v.length != 10) {
                      //                   return "Mobile number must be 10 digits";
                      //                 }

                      //                 if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) {
                      //                   return "Mobile number must start with 6–9";
                      //                 }

                      //                 return null;
                      //               },
                      //               suffix: model.mobileVerified
                      //                   ? _verifiedIcon()
                      //                   : _otpButton(
                      //                       model.mobileCtrl.text.length == 10 &&
                      //                               RegExp(
                      //                                 r'^[6-9]\d{9}$',
                      //                               ).hasMatch(model.mobileCtrl.text)
                      //                           ? () {
                      //                               MobileConsentPopup.show(
                      //                                 context: context,
                      //                                 onVerified: () {
                      //                                   debugPrint("Mobile verified");
                      //                                   setState(
                      //                                     () => model.mobileVerified = true,
                      //                                   );
                      //                                 },
                      //                               );
                      //                             }
                      //                           : null,
                      //                     ),
                      //             ),

                      //             _field(
                      //               "Email *",
                      //               model.emailCtrl,
                      //               keyboard: TextInputType.emailAddress,
                      //               validator: (v) {
                      //                 if (v == null || v.trim().isEmpty) {
                      //                   return "Email is required";
                      //                 }
                      //                 if (!_isValidEmail(v.trim())) {
                      //                   return "Enter valid email address";
                      //                 }
                      //                 return null;
                      //               },
                      //               suffix: model.emailVerified
                      //                   ? _verifiedIcon()
                      //                   : _otpButton(
                      //                       _isValidEmail(model.emailCtrl.text)
                      //                           ? () {
                      //                               EmailVerifyPopup.show(
                      //                                 context: context,
                      //                                 onVerified: () {
                      //                                   debugPrint("Email verified");
                      //                                   setState(
                      //                                     () => model.emailVerified = true,
                      //                                   );
                      //                                 },
                      //                               );
                      //                             }
                      //                           : null,
                      //                     ),
                      //             ),
                      _field(
                        "Designation *",

                        model.designationCtrl,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? "Designation is required"
                            : null,
                      ),

                      const SizedBox(height: 12),

                      /// GENDER
                      const Text("Gender *"),
                      const SizedBox(height: 6),

                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: ["Male", "Female"].map((g) {
                          final bool selected = model.gender == g;

                          return InkWell(
                            onTap: () => setState(() => model.gender = g),
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary.withOpacity(0.12)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.grey.withOpacity(0.4),
                                  width: 1.4,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  /// RADIO CIRCLE
                                  Container(
                                    width: 16,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: selected
                                            ? AppColors.primary
                                            : AppColors.grey,
                                        width: 2,
                                      ),
                                    ),
                                    child: selected
                                        ? Center(
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.darkBlue,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    g,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  /// =======================
  /// INPUT FIELD
  Widget _field(
    String label,
    TextEditingController ctrl, {
    Widget? suffix,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),
          TextFormField(
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
            ),
            controller: ctrl,
            keyboardType: keyboard,
            validator: validator,
            maxLength: maxLength,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              counterText: "", // hide counter
              filled: true,
              // fillColor: const Color(0xFFF1F3F6),
              fillColor: isDarkMode
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF1F3F6),
              suffixIcon: suffix,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.white : const Color(0xFFE5E7EB),
                ),
                borderRadius: BorderRadius.circular(12),
                // borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// =======================
  /// SEND OTP BUTTON
  /// =======================
  Widget _otpButton(VoidCallback? onTap) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        "Send OTP",
        style: TextStyle(
          color: onTap == null ? AppColors.grey : AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _continueButton(BuildContext context, GlobalKey<FormState> formKey) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () async {
          final isValid = formKey.currentState?.validate() ?? false;

          if (!isValid) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(content: Text("Please fix errors")),
            // );
            showTopToast(context, "Please fix errors", success: false);

            return;
          }
          await _saveContactPersonsToBackend();
          await _saveContactPersonDraft();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddressDetails(customerId: widget.customerId),
            ),
          );

          // await _saveContactPersonDraft();  // 👈 await here

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (_) => const AddressDetails()),
          // );
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
        ),
        child: const Text(
          "Continue",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _verifiedIcon() {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.verified, size: 16, color: Colors.green),
          SizedBox(width: 4),
          Text(
            "Verified",
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// OTP DIALOG (REUSABLE)
/// =======================
class _OtpDialog extends StatefulWidget {
  final String title;
  final bool showConsent;
  final VoidCallback onVerified;

  const _OtpDialog({
    required this.title,
    required this.showConsent,
    required this.onVerified,
  });

  @override
  State<_OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<_OtpDialog> {
  int seconds = 30;
  late Timer timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds == 0) {
        t.cancel();
      } else {
        setState(() => seconds--);
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),

            if (widget.showConsent) ...[
              const SizedBox(height: 12),
              const Text(
                CONSENT_TEXT,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12),
              ),
            ],

            const SizedBox(height: 16),

            /// OTP INPUTS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (_) {
                return SizedBox(
                  width: 42,
                  child: TextField(
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(counterText: ""),
                  ),
                );
              }),
            ),

            const SizedBox(height: 12),

            /// TIMER + RESEND
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Resend in 00:${seconds.toString().padLeft(2, '0')}"),
                TextButton(
                  onPressed: seconds == 0 ? () {} : null,
                  child: const Text("Resend"),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                widget.onVerified();
                Navigator.pop(context);
              },
              child: const Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }
}
