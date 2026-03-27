// import 'package:flutter/material.dart';
// import 'package:supply_chain/core/services/draft_service.dart';
// import 'package:supply_chain/core/theme/app_colors.dart';
 
// import 'package:supply_chain/presentation/role/rm/NewCustomer/company_details.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/applicant_details.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/co_applicant.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/contact_person.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/address_details.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/Documents.dart'
//     hide AppColors;
 
// class ResumeDraft extends StatefulWidget {
//   const ResumeDraft({super.key});
 
//   @override
//   State<ResumeDraft> createState() => _ResumeDraftState();
// }
 
// class _ResumeDraftState extends State<ResumeDraft> {
//   Map<String, dynamic>? draft;
//   bool loading = true;
 
//   bool canAccessStep(int stepIndex) {
//     final stepsCompleted = [
//       companyDone,
//       applicantDone,
//       coApplicantDone,
//       contactDone,
//       addressDone,
//     ];
 
//     // First step is always accessible
//     if (stepIndex == 0) return true;
 
//     // All previous steps must be completed
//     for (int i = 0; i < stepIndex; i++) {
//       if (!stepsCompleted[i]) return false;
//     }
//     return true;
//   }
 
//   @override
//   void initState() {
//     super.initState();
//     _loadDraft();
//   }
 
// Future<void> _loadDraft() async {
//   final draftList = await DraftService.loadDraft();

//   if (draftList.isNotEmpty) {
//     draft = draftList.last; // Load latest draft
//   } else {
//     draft = null;
//   }

//   setState(() {
//     loading = false;
//   });
// }
 
//   // ================= COMPLETION CHECKS =================
 
//   bool get companyDone => draft?["company"] != null;
//   bool get applicantDone => draft?["applicant"] != null;
//   bool get coApplicantDone =>
//       (draft?["coApplicants"] as List?)?.isNotEmpty == true;
//   bool get contactDone =>
//       (draft?["contactPerson"] as List?)?.isNotEmpty == true;
//   bool get addressDone => (draft?["addresses"] as List?)?.isNotEmpty == true;
 
//   String? get companyType => draft?["company"]?["companyType"];
 
//   // ================= UI =================
 
//   @override
//   Widget build(BuildContext context) {
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
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : draft == null
//           ? const Center(child: Text("No draft found"))
//           : ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 _draftStepCard(
//                   title: "Company Details",
//                   completed: companyDone,
//                   enabled: canAccessStep(0),
//                   onResume: () => _go(const CompanyDetails(isResume: true)),
//                 ),
 
//                 _draftStepCard(
//                   title: "Applicant Details",
//                   completed: applicantDone,
//                   enabled: canAccessStep(1),
//                   onResume: () => _go(const ApplicantDetails()),
//                 ),
 
//                 _draftStepCard(
//                   title: "Co-Applicant",
//                   completed: coApplicantDone,
//                   enabled: canAccessStep(2),
//                   onResume: () => _go(const CoApplicantPage()),
//                 ),
 
//                 _draftStepCard(
//                   title: "Contact Person",
//                   completed: contactDone,
//                   enabled: canAccessStep(3),
//                   onResume: () => _go(const ContactPerson()),
//                 ),
 
//                 _draftStepCard(
//                   title: "Address Details",
//                   completed: addressDone,
//                   enabled: canAccessStep(4),
//                   onResume: () => _go(const AddressDetails()),
//                 ),
 
//                 if (addressDone && companyType != null)
//                   _draftStepCard(
//                     title: "Documents",
//                     completed: false,
//                     enabled: canAccessStep(5),
//                     onResume: () =>
//                         _go(DocumentsPage(companyType: companyType!)),
//                   ),
//               ],
//             ),
//     );
//   }
 
//   // ================= CARD =================
//   Widget _draftStepCard({
//     required String title,
//     required bool completed,
//     required bool enabled,
//     required VoidCallback onResume,
//   }) {
//     return Opacity(
//       opacity: enabled ? 1 : 0.45,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 14),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 14,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Icon(
//               completed
//                   ? Icons.check_circle
//                   : enabled
//                   ? Icons.pending_actions
//                   : Icons.lock,
//               color: completed
//                   ? Colors.green
//                   : enabled
//                   ? Colors.orange
//                   : Colors.grey,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             TextButton(
//               onPressed: enabled ? onResume : null,
//               child: Text(completed ? "View" : "Resume"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
 
//   void _go(Widget page) {
//     Navigator.push(context, MaterialPageRoute(builder: (_) => page));
//   }
// }
 
 

 // import 'package:flutter/material.dart';
// import 'package:supply_chain/core/services/draft_service.dart';
// import 'package:supply_chain/core/theme/app_colors.dart';
 
// import 'package:supply_chain/presentation/role/rm/NewCustomer/company_details.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/applicant_details.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/co_applicant.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/contact_person.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/address_details.dart';
// import 'package:supply_chain/presentation/role/rm/NewCustomer/Documents.dart'
//     hide AppColors;
 
// class ResumeDraft extends StatefulWidget {
//   const ResumeDraft({super.key, required draftData});
 
//   @override
//   State<ResumeDraft> createState() => _ResumeDraftState();
// }
 
// class _ResumeDraftState extends State<ResumeDraft> {
//   Map<String, dynamic>? draft;
//   bool loading = true;
 
//   bool canAccessStep(int stepIndex) {
//     final stepsCompleted = [
//       companyDone,
//       applicantDone,
//       coApplicantDone,
//       contactDone,
//       addressDone,
//     ];
 
//     // First step is always accessible
//     if (stepIndex == 0) return true;
 
//     // All previous steps must be completed
//     for (int i = 0; i < stepIndex; i++) {
//       if (!stepsCompleted[i]) return false;
//     }
//     return true;
//   }
 
//   @override
//   void initState() {
//     super.initState();
//     _loadDraft();
//   }
 
// Future<void> _loadDraft() async {
//   final draftList = await DraftService.loadDraft();
 
//   if (draftList.isNotEmpty) {
//     draft = draftList.last; // Load latest draft
//   } else {
//     draft = null;
//   }
 
//   setState(() {
//     loading = false;
//   });
// }
 
//   // ================= COMPLETION CHECKS =================
 
//   bool get companyDone => draft?["company"] != null;
//   bool get applicantDone => draft?["applicant"] != null;
//   bool get coApplicantDone =>
//       (draft?["coApplicants"] as List?)?.isNotEmpty == true;
//   bool get contactDone =>
//       (draft?["contactPerson"] as List?)?.isNotEmpty == true;
//   bool get addressDone => (draft?["addresses"] as List?)?.isNotEmpty == true;
 
//   String? get companyType => draft?["company"]?["companyType"];
 
//   // ================= UI =================
 
//   @override
//   Widget build(BuildContext context) {
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
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : draft == null
//           ? const Center(child: Text("No draft found"))
//           : ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 _draftStepCard(
//                   title: "Company Details",
//                   completed: companyDone,
//                   enabled: canAccessStep(0),
//                   onResume: () => _go(const CompanyDetails(isResume: true)),
//                 ),
 
//                 _draftStepCard(
//                   title: "Applicant Details",
//                   completed: applicantDone,
//                   enabled: canAccessStep(1),
//                onResume: () => _go(ApplicantDetails(customerId: draft?["company"]?["customerId"] ?? 0)),
//                 ),
 
//                 _draftStepCard(
//                   title: "Co-Applicant",
//                   completed: coApplicantDone,
//                   enabled: canAccessStep(2),
//                   onResume: () => _go(const CoApplicantPage()),
//                 ),
 
//                 _draftStepCard(
//                   title: "Contact Person",
//                   completed: contactDone,
//                   enabled: canAccessStep(3),
//                   onResume: () => _go(const ContactPerson()),
//                 ),
 
//                 _draftStepCard(
//                   title: "Address Details",
//                   completed: addressDone,
//                   enabled: canAccessStep(4),
//                   onResume: () => _go(const AddressDetails()),
//                 ),
 
//                 if (addressDone && companyType != null)
//                   _draftStepCard(
//                     title: "Documents",
//                     completed: false,
//                     enabled: canAccessStep(5),
//                     onResume: () =>
//                         _go(DocumentsPage(companyType: companyType!)),
//                   ),
//               ],
//             ),
//     );
//   }
 
//   // ================= CARD =================
//   Widget _draftStepCard({
//     required String title,
//     required bool completed,
//     required bool enabled,
//     required VoidCallback onResume,
//   }) {
//     return Opacity(
//       opacity: enabled ? 1 : 0.45,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 14),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 14,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Icon(
//               completed
//                   ? Icons.check_circle
//                   : enabled
//                   ? Icons.pending_actions
//                   : Icons.lock,
//               color: completed
//                   ? Colors.green
//                   : enabled
//                   ? Colors.orange
//                   : Colors.grey,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             TextButton(
//               onPressed: enabled ? onResume : null,
//               child: Text(completed ? "View" : "Resume"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
 
//   void _go(Widget page) {
//     Navigator.push(context, MaterialPageRoute(builder: (_) => page));
//   }
// }
 
import 'package:flutter/material.dart';
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
  late Map<String, dynamic> draft;
 
  @override
  void initState() {
    super.initState();
 
    /// use API draft directly
    draft = widget.draftData;
  }
 
  /// ================= STEP COMPLETION =================
 
  // bool get companyDone =>
  //     draft["companyName"] != null && draft["companyName"] != "";
 
  // bool get applicantDone => draft["name"] != null && draft["name"] != "";
 
  // bool get coApplicantDone => false;
 
  // bool get contactDone => false;
 
  // bool get addressDone =>
  //     draft["bankAccountNo"] != null && draft["bankAccountNo"] != "";
bool get companyDone =>
    draft["companyName"] == null ||draft["companyName"] == "" || draft["companyName"] != null;
 
bool get applicantDone =>
    draft["applicant"] != null &&
    draft["applicant"]["name"] != null &&
    draft["applicant"]["name"] != "";
 
bool get coApplicantDone =>
    (draft["coApplicants"] as List?)?.isNotEmpty == true;
 
bool get contactDone =>
    (draft["contactPersons"] as List?)?.isNotEmpty == true;
 
bool get addressDone =>
    (draft["addresses"] as List?)?.isNotEmpty == true;
 
 
  String? get companyType =>
    draft["companyType"] == "" ? null : draft["companyType"];
 
  /// ================= STEP ACCESS =================
 
  bool canAccessStep(int stepIndex) {
    final stepsCompleted = [
      companyDone,
      applicantDone,
      coApplicantDone,
      contactDone,
      addressDone,
    ];
 
    if (stepIndex == 0) return true;
 
    for (int i = 0; i < stepIndex; i++) {
      if (!stepsCompleted[i]) return false;
    }
 
    return true;
  }
 
  /// ================= UI =================
 
  @override
  Widget build(BuildContext context) {
    final customerId = draft["id"];
 
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Resume Draft",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// COMPANY
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
 
          /// APPLICANT
          _draftStepCard(
            title: "Applicant Details",
            completed: applicantDone,
            enabled: canAccessStep(1),
            onResume: () => _go(ApplicantDetails(customerId: customerId)),
          ),
 
          /// CO APPLICANT
          _draftStepCard(
            title: "Co Applicant",
            completed: coApplicantDone,
            enabled: canAccessStep(2),
            onResume: () => _go(CoApplicantPage(customerId: customerId)),
          ),
 
          /// CONTACT
          _draftStepCard(
            title: "Contact Person",
            completed: contactDone,
            enabled: canAccessStep(3),
            onResume: () => _go(ContactPerson(customerId: customerId)),
          ),
 
          /// ADDRESS
          _draftStepCard(
            title: "Address Details",
            completed: addressDone,
            enabled: canAccessStep(4),
            onResume: () => _go(AddressDetails(customerId: customerId)),
          ),
 
          /// DOCUMENTS
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
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              completed
                  ? Icons.check_circle
                  : enabled
                  ? Icons.pending_actions
                  : Icons.lock,
              color: completed
                  ? Colors.green
                  : enabled
                  ? Colors.orange
                  : Colors.grey,
            ),
 
            const SizedBox(width: 12),
 
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
 
            TextButton(
              onPressed: enabled ? onResume : null,
              child: Text(completed ? "View" : "Resume"),
            ),
          ],
        ),
      ),
    );
  }
 
  /// ================= NAVIGATION =================
 
  void _go(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}
 
 