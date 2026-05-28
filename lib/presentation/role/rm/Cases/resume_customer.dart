 
// import 'package:flutter/material.dart';
// import 'package:supply_chain/core/theme/app_colors.dart';
 
// import 'package:supply_chain/presentation/role/rm/NewCustomer/company_details.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/applicant_details.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/co_applicant.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/contact_person.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/address_details.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/Documents.dart'
//     hide AppColors;
 
// class ResumeDraft extends StatefulWidget {
//   final Map<String, dynamic> draftData;
 
//   const ResumeDraft({super.key, required this.draftData});
 
//   @override
//   State<ResumeDraft> createState() => _ResumeDraftState();
// }
 
// class _ResumeDraftState extends State<ResumeDraft> {
//   late Map<String, dynamic> draft;
 
//   @override
//   void initState() {
//     super.initState();
 
//     /// use API draft directly
//     draft = widget.draftData;
//   }
 
//   /// ================= STEP COMPLETION =================
 
 
// bool get companyDone =>
//     draft["companyName"] == null ||draft["companyName"] == "" || draft["companyName"] != null;
 
// bool get applicantDone =>
//     draft["applicant"] != null &&
//     draft["applicant"]["name"] != null &&
//     draft["applicant"]["name"] != "";
 
// bool get coApplicantDone =>
//     (draft["coApplicants"] as List?)?.isNotEmpty == true;
 
// bool get contactDone =>
//     (draft["contactPersons"] as List?)?.isNotEmpty == true;
 
// bool get addressDone =>
//     (draft["addresses"] as List?)?.isNotEmpty == true;
 
 
//   String? get companyType =>
//     draft["companyType"] == "" ? null : draft["companyType"];
 
//   /// ================= STEP ACCESS =================
 
//   bool canAccessStep(int stepIndex) {
//     final stepsCompleted = [
//       companyDone,
//       applicantDone,
//       coApplicantDone,
//       contactDone,
//       addressDone,
//     ];
 
//     if (stepIndex == 0) return true;
 
//     for (int i = 0; i < stepIndex; i++) {
//       if (!stepsCompleted[i]) return false;
//     }
 
//     return true;
//   }
 
//   /// ================= UI =================
 
//   @override
//   Widget build(BuildContext context) {
//     final customerId = draft["id"];
 
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBg,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Resume Draft",
//           style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
//         ),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           /// COMPANY
//           _draftStepCard(
//             title: "Company Details",
//             completed: companyDone,
//             enabled: canAccessStep(0),
//             onResume: () => _go(
//               CompanyDetails(
//                 isResume: true,
//                 customerId: customerId,
//                 draftData: draft,
//               ),
//             ),
//           ),
 
//           /// APPLICANT
//           _draftStepCard(
//             title: "Applicant Details",
//             completed: applicantDone,
//             enabled: canAccessStep(1),
//             onResume: () => _go(ApplicantDetails(customerId: customerId)),
//           ),
 
//           /// CO APPLICANT
//           _draftStepCard(
//             title: "Co Applicant",
//             completed: coApplicantDone,
//             enabled: canAccessStep(2),
//             onResume: () => _go(CoApplicantPage(customerId: customerId)),
//           ),
 
//           /// CONTACT
//           _draftStepCard(
//             title: "Contact Person",
//             completed: contactDone,
//             enabled: canAccessStep(3),
//             onResume: () => _go(ContactPerson(customerId: customerId)),
//           ),
 
//           /// ADDRESS
//           _draftStepCard(
//             title: "Address Details",
//             completed: addressDone,
//             enabled: canAccessStep(4),
//             onResume: () => _go(AddressDetails(customerId: customerId)),
//           ),
 
//           /// DOCUMENTS
//           if (addressDone && companyType != null)
//             _draftStepCard(
//               title: "Documents",
//               completed: false,
//               enabled: canAccessStep(5),
//               onResume: () => _go(
//                 DocumentsPage(
//                   customerId: customerId,
//                   companyType: companyType!,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
 
//   /// ================= STEP CARD =================
 

 
//  Widget _draftStepCard({
//   required String title,
//   required bool completed,
//   required bool enabled,
//   required VoidCallback onResume,
// }) {
//   final Color statusColor = completed
//       ? Colors.green
//       : enabled
//           ? Colors.orange
//           : Colors.grey;
 
//   final IconData statusIcon = completed
//       ? Icons.check_circle_rounded
//       : enabled
//           ? Icons.edit_note_rounded
//           : Icons.lock_outline_rounded;
 
//   final String actionText = completed ? "View" : "Resume";
 
//   return AnimatedContainer(
//     duration: const Duration(milliseconds: 250),
//     margin: const EdgeInsets.only(bottom: 14),
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(18),
//       border: Border.all(
//         color: statusColor.withOpacity(.25),
//       ),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(.04),
//           blurRadius: 12,
//           offset: const Offset(0, 6),
//         ),
//       ],
//     ),
 
//     child: Row(
//       children: [
//         /// STATUS ICON CIRCLE
//         Container(
//           height: 38,
//           width: 38,
//           decoration: BoxDecoration(
//             color: statusColor.withOpacity(.12),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(
//             statusIcon,
//             color: statusColor,
//             size: 22,
//           ),
//         ),
 
//         const SizedBox(width: 14),
 
//         /// TITLE + STEP LABEL
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 15.5,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
 
//               const SizedBox(height: 4),
 
//               Text(
//                 completed
//                     ? "Completed"
//                     : enabled
//                         ? "Pending action required"
//                         : "Locked",
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: statusColor,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
 
//         /// ACTION BUTTON CHIP
//         GestureDetector(
//           onTap: enabled ? onResume : null,
//           child: Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 14,
//               vertical: 6,
//             ),
//             decoration: BoxDecoration(
//               color: enabled
//                   ? Colors.deepPurple.withOpacity(.08)
//                   : Colors.grey.withOpacity(.08),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               actionText,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: enabled
//                     ? Colors.deepPurple
//                     : Colors.grey,
//               ),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
//    /// ================= NAVIGATION =================
 
//   void _go(Widget page) {
//     Navigator.push(context, MaterialPageRoute(builder: (_) => page));
//   }
// }
 
 import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/auth_service.dart';
import 'package:supply_chain/core/theme/app_colors.dart';

import 'package:supply_chain/presentation/role/rm/NewCustomer/company_details.dart';
import 'package:supply_chain/presentation/role/rm/NewCustomer/applicant_details.dart';
import 'package:supply_chain/presentation/role/rm/NewCustomer/co_applicant.dart';
import 'package:supply_chain/presentation/role/rm/NewCustomer/contact_person.dart';
import 'package:supply_chain/presentation/role/rm/NewCustomer/address_details.dart';
import 'package:supply_chain/presentation/role/rm/NewCustomer/Documents.dart'
    hide AppColors;

class ResumeDraft extends StatefulWidget {
  final Map<String, dynamic> draftData;

  const ResumeDraft({super.key, required this.draftData});

  @override
  State<ResumeDraft> createState() => _ResumeDraftState();
}

class _ResumeDraftState extends State<ResumeDraft> {
  // late Map<String, dynamic> draft;
  Map<String, dynamic> draft = {};
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    draft = widget.draftData;
    loadTheme();
    refreshDraft();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode") ?? false;
    });
  }


Future<void> refreshDraft() async {

  try {

    final customerId = draft["id"];

if (customerId == null) {
  debugPrint("Customer ID is NULL");
  return;
}

    if (customerId == null) {
      debugPrint("Customer ID is NULL");
      return;
    }

    final token = await AuthService().getToken();

    final response = await http.get(

      Uri.parse(
        "${ApiEndpoints.baseUrl}/customers/$customerId/kyc",
      ),

      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    final result = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        result["success"] == true) {

      final apiData = result["data"];
      final profile = apiData["customerProfile"];


         final coApplicantResponse = await http.get(
      Uri.parse(
        "${ApiEndpoints.baseUrl}/co-applicants/customer/$customerId",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    final coApplicantResult =
        jsonDecode(coApplicantResponse.body);

        final contactResponse = await http.get(
  Uri.parse(
    "${ApiEndpoints.baseUrl}/customers/$customerId/contact-persons",
  ),
  headers: {
    "Authorization": "Bearer $token",
    "Content-Type": "application/json",
  },
);

final contactResult =
    jsonDecode(contactResponse.body);


    
        final addressResponse = await http.get(
  Uri.parse(
    "${ApiEndpoints.baseUrl}/customers/$customerId/addresses",
  ),
  headers: {
    "Authorization": "Bearer $token",
    "Content-Type": "application/json",
  },
);

final addressResult =
    jsonDecode(addressResponse.body);

      setState(() {

        draft = {
          "id": profile["id"],
          "companyName":
              profile["companyName"] ?? "",

          "companyType":
              profile["companyType"] ?? "",

          "applicant":
              apiData["applicant"] ?? {},

          "coApplicants":
              (coApplicantResult["data"] ?? []) as List,
         
          // "contactPersons":
          //     apiData["contactPersons"] ?? [],
          "contactPersons":
    contactResult["data"] ?? [],

          "addresses":
              addressResult["data"] ?? [],
        };
      });
    }

  } catch (e) {

    debugPrint("Refresh draft error: $e");
  }
}
  /// ================= STEP COMPLETION =================

  bool get companyDone {
      final companyName =
        draft["companyName"];
  
    return companyName != null &&
        companyName.toString().trim().isNotEmpty;
  }
 
  bool get applicantDone {
      final applicant = draft["applicant"];
              draft["applicant"]["name"] != "" ;

  if (applicant == null || applicant is! Map) {
    return false;
  }

  return applicant["id"] != null;
}
  
  bool get coApplicantDone =>draft["coApplicants"] is List &&
      (draft["coApplicants"] as List).isNotEmpty;

  bool get contactDone =>
      (draft["contactPersons"] as List?)?.isNotEmpty == true;

  bool get addressDone =>
      (draft["addresses"] as List?)?.isNotEmpty == true;

  String? get companyType =>
      draft["companyType"] == "" ? null : draft["companyType"];

  /// ================= STEP ACCESS =================

bool canAccessStep(int stepIndex) {
  /// Company always accessible
  if (stepIndex == 0) {
    return true;
  }

  /// Applicant accessible after company
  if (stepIndex == 1) {
    return companyDone;
  }

  /// Co Applicant accessible after applicant
  if (stepIndex == 2) {
    return applicantDone;
  }

  /// Contact accessible after co applicant
  if (stepIndex == 3) {
    return coApplicantDone;
  }

  /// Address accessible after contact
  if (stepIndex == 4) {
    return contactDone;
  }

  /// Documents accessible after address
  if (stepIndex == 5) {
    return addressDone;
  }

  return false;
}
  // bool canAccessStep(int stepIndex) {
  //   final stepsCompleted = [
  //     companyDone,
  //     applicantDone,
  //     coApplicantDone,
  //     contactDone,
  //     addressDone,
  //   ];

  //   if (stepIndex == 0) return true;

  //   for (int i = 0; i < stepIndex; i++) {
  //     if (!stepsCompleted[i]) return false;
  //   }

  //   return true;
  // }

  /// ================= UI =================

  @override
  Widget build(BuildContext context) {
    // final customerId = draft["id"];
    final customerId =
    widget.draftData["data"]?["customerProfile"]?["id"] ??
    widget.draftData["customerProfile"]?["id"] ??
    draft["id"];

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF0F172A) : AppColors.scaffoldBg,

      appBar: AppBar(
        backgroundColor:
            isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        title: Text(
          "Resume Draft",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _draftStepCard(
            title: "Company Details",
            completed: companyDone,
            enabled: canAccessStep(0),
            onResume: () => _go(
              CompanyDetails(
                isResume: true,
                customerId: customerId,
                draftData: draft,
              ),
            ),
          ),

          _draftStepCard(
            title: "Applicant Details",
            completed:
              draft["applicant"] != null &&
              draft["applicant"]["name"] != "" &&
              draft["applicant"]["id"] != null,
              

            enabled: companyDone,
              // enabled:draft["company"] != null,


            onResume: () => _go(
    ApplicantDetails(
      customerId: customerId,
    ),
  ),
),
          // _draftStepCard(
          //   title: "Applicant Details",
          //   completed: applicantDone,
          //   enabled: canAccessStep(1),
          //   onResume: () =>
          //       _go(ApplicantDetails(customerId: customerId)),
          // ),

          // _draftStepCard(
          //   title: "Co Applicant",
          //   completed: coApplicantDone,
          //   enabled: canAccessStep(2),
          //   // enabled: true,
          //   onResume: () =>
          //       _go(CoApplicantPage(customerId: customerId)),
          // ),


_draftStepCard(
  title: "Co Applicant",

 completed:
    draft["coApplicants"] is List &&

    (draft["coApplicants"] as List).isNotEmpty,

  enabled:
  applicantDone,
      // draft["applicant"] != null,

  onResume: () => _go(
    CoApplicantPage(
      customerId: customerId,
    ),
  ),
),
          // _draftStepCard(
          //   title: "Contact Person",
          //   completed: contactDone,
          //   enabled: canAccessStep(3),
          //   onResume: () =>
          //       _go(ContactPerson(customerId: customerId)),
          // ),

_draftStepCard(
  title: "Contact Person",
  completed: contactDone,
  enabled:
    draft["coApplicants"] is List &&
    (draft["coApplicants"] as List).isNotEmpty,
  onResume: () => _go(
    ContactPerson(
      customerId: customerId,
    ),
  ),
),
          _draftStepCard(
            title: "Address Details",
            completed: addressDone,
            enabled: canAccessStep(4),
            onResume: () =>
                _go(AddressDetails(customerId: customerId)),
          ),

          if (addressDone && companyType != null)
            _draftStepCard(
              title: "Documents",
              completed: false,
              enabled: canAccessStep(5),
              onResume: () => _go(
                DocumentsPage(
                  customerId: customerId,
                  companyType: companyType!,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// ================= STEP CARD =================

  Widget _draftStepCard({
    required String title,
    required bool completed,
    required bool enabled,
    required VoidCallback onResume,
  }) {
    final Color statusColor = completed
        ? Colors.green
        : enabled
            ? Colors.orange
            : Colors.grey;

    final IconData statusIcon = completed
        ? Icons.check_circle_rounded
        : enabled
            ? Icons.edit_note_rounded
            : Icons.lock_outline_rounded;

    final String actionText = completed ? "View" : "Resume";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: statusColor.withOpacity(.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : .04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color:
                        isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  completed
                      ? "Completed"
                      : enabled
                          ? "Pending action required"
                          : "Locked",
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: enabled ? onResume : null,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: enabled
                    ? Colors.deepPurple.withOpacity(
                        isDarkMode ? 0.25 : .08)
                    : Colors.grey.withOpacity(.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                actionText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: enabled
                      ? (isDarkMode
                          ? Colors.deepPurple.shade200
                          : Colors.deepPurple)
                      : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _go(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

//   Future<void> _go(Widget page) async {

//   await Navigator.push(
//     context,
//     MaterialPageRoute(builder: (_) => page),
//   );

//   /// Refresh after returning
//   await refreshDraft();

//   setState(() {});
// }
}