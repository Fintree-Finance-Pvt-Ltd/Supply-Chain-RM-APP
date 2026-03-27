// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class DraftService {
//   static const String _draftKey = "full_application_draft";
// // static const String _completedKey = "completed_cases";

//   // static Future<void> saveDraft(Map<String, dynamic> data) async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   await prefs.setString(_draftKey, jsonEncode(data));
//   // }

//   // static Future<Map<String, dynamic>?> loadDraft() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final draftString = prefs.getString(_draftKey);

//   //   if (draftString == null) return null;

//   //   return jsonDecode(draftString);
//   // }
// static Future<void> saveDraft(Map<String, dynamic> data) async {
//   final prefs = await SharedPreferences.getInstance();

//   final draftString = prefs.getString(_draftKey);

//   List<dynamic> draftList = [];

//   if (draftString != null) {
//     final decoded = jsonDecode(draftString);

//     if (decoded is List) {
//       draftList = decoded;
//     } else {
//       draftList = [decoded]; // convert old single draft to list
//     }
//   }

//   // Generate draftId if not present
//   data["draftId"] ??=
//       DateTime.now().millisecondsSinceEpoch.toString();

//   draftList.add(data);

//   await prefs.setString(_draftKey, jsonEncode(draftList));
// }

// static Future<String> getDraftId() async {
//   final draftList = await loadDraft();
 
//   if (draftList.isNotEmpty) {
//     final lastDraft = draftList.last as Map<String, dynamic>;
 
//     if (lastDraft["draftId"] != null) {
//       return lastDraft["draftId"].toString();
//     }
//   }
 
//   // Fallback (should rarely happen)
//   return DateTime.now().millisecondsSinceEpoch.toString();
// }
 

// static Future<List<dynamic>> loadDraft() async {
//   final prefs = await SharedPreferences.getInstance();
//   final draftString = prefs.getString(_draftKey);

//   if (draftString == null) return [];

//   final decoded = jsonDecode(draftString);

//   if (decoded is List) return decoded;

//   return [decoded]; // backward compatibility
// }

//   Future<void> saveWithStep(String step, Map<String, dynamic> pageData) async {
//   final draftList = await DraftService.loadDraft();

//   Map<String, dynamic> currentDraft = {};

//   if (draftList.isNotEmpty) {
//     currentDraft = draftList.last;
//     draftList.removeLast(); // remove old version
//   }

//   currentDraft.addAll(pageData);
//   currentDraft["lastStep"] = step;

//   draftList.add(currentDraft);

//   await DraftService.saveDraftList(draftList);
// }
// static Future<void> saveDraftList(List<dynamic> list) async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setString(_draftKey, jsonEncode(list));
// }


// // Future<void> saveWithStep(String step, Map<String, dynamic> pageData) async {
// //   final existingDraft = await DraftService.loadDraft() ?? {};

// //   existingDraft.addAll(pageData);
// //   existingDraft["lastStep"] = step;

// //   await DraftService.saveDraft(existingDraft);
// // }

//   static Future<void> clearDraft() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_draftKey);
//   }

// // correct one
// // static Future<void> moveDraftToSubmitted() async {
// //   final prefs = await SharedPreferences.getInstance();

// //   final draftString = prefs.getString(_draftKey);

// //   print("Draft string: $draftString");

// //   if (draftString == null) {
// //     print("No draft found");
// //     return;
// //   }

// //   final draftData = jsonDecode(draftString);

// //   final submittedString = prefs.getString(_completedKey);
// //   List<dynamic> submittedList = [];

// //   if (submittedString != null) {
// //     submittedList = jsonDecode(submittedString);
// //   }

// //   submittedList.add({
// //     ...draftData,
// //     "status": "Submitted",
// //     "submittedAt": DateTime.now().toString(),
// //   });

// //   await prefs.setString(_completedKey, jsonEncode(submittedList));
// //   await prefs.remove(_draftKey);

// //   print("Submitted saved successfully");
// // }




// // =======
// static Future<void> moveDraftToSubmitted() async {
//   final prefs = await SharedPreferences.getInstance();

//   // 🔥 Load current draft
//   final draft = await loadDraft();

//   // 🔥 Load existing submitted list
//   final submittedString = prefs.getString("submitted_cases");

//   List<dynamic> submittedList = [];

//   if (submittedString != null) {
//     final decoded = jsonDecode(submittedString);

//     if (decoded is List) {
//       submittedList = decoded;
//     }
//   }

//   // 🔥 Add new case
//   submittedList.add(draft);

//   // 🔥 Save updated list
//   await prefs.setString(
//     "submitted_cases",
//     jsonEncode(submittedList),
//   );

//   // 🔥 Clear draft
//   await clearDraft();
// }

// }



 
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
 
class DraftService {
 
  static const String _draftKey = "full_application_draft";
 
  /// ================= SAVE DRAFT =================
  static Future<void> saveDraft(
      int customerId,
      Map<String, dynamic> data,
  ) async {
 
    final prefs = await SharedPreferences.getInstance();
 
    final draftString = prefs.getString(_draftKey);
 
    List<dynamic> draftList = [];
 
    if (draftString != null) {
      draftList = jsonDecode(draftString);
    }
 
    /// remove existing draft of same customer
    draftList.removeWhere((d) => d["customerId"] == customerId);
 
    data["customerId"] = customerId;
 
    draftList.add(data);
 
    await prefs.setString(_draftKey, jsonEncode(draftList));
  }
 
  /// ================= LOAD DRAFT BY CUSTOMER =================
  static Future<Map<String, dynamic>?> loadDraft(int customerId) async {
 
    final prefs = await SharedPreferences.getInstance();
 
    final draftString = prefs.getString(_draftKey);
 
    if (draftString == null) return null;
 
    final List draftList = jsonDecode(draftString);
 
    try {
      return draftList.firstWhere(
        (d) => d["customerId"] == customerId,
      );
    } catch (e) {
      return null;
    }
  }
 
  /// ================= LOAD ALL DRAFTS =================
  static Future<List<dynamic>> loadAllDrafts() async {
 
    final prefs = await SharedPreferences.getInstance();
 
    final draftString = prefs.getString(_draftKey);
 
    if (draftString == null) return [];
 
    return jsonDecode(draftString);
  }
 
  /// ================= SAVE WITH STEP =================
  static Future<void> saveWithStep(
      int customerId,
      String step,
      Map<String, dynamic> pageData,
  ) async {
 
    final prefs = await SharedPreferences.getInstance();
 
    final draftString = prefs.getString(_draftKey);
 
    List<dynamic> draftList = [];
 
    if (draftString != null) {
      draftList = jsonDecode(draftString);
    }
 
    Map<String, dynamic> draft = {};
 
    try {
      draft = draftList.firstWhere(
        (d) => d["customerId"] == customerId,
      );
 
      draftList.removeWhere((d) => d["customerId"] == customerId);
 
    } catch (e) {
      draft = {"customerId": customerId};
    }
 
    draft.addAll(pageData);
 
    draft["lastStep"] = step;
 
    draftList.add(draft);
 
    await prefs.setString(_draftKey, jsonEncode(draftList));
  }
 
  /// ================= CLEAR DRAFT =================
  static Future<void> clearDraft(int customerId) async {
 
    final prefs = await SharedPreferences.getInstance();
 
    final draftString = prefs.getString(_draftKey);
 
    if (draftString == null) return;
 
    List draftList = jsonDecode(draftString);
 
    draftList.removeWhere((d) => d["customerId"] == customerId);
 
    await prefs.setString(_draftKey, jsonEncode(draftList));
  }
 
  /// ================= MOVE TO SUBMITTED =================
  static Future<void> moveDraftToSubmitted(int customerId) async {
 
    final prefs = await SharedPreferences.getInstance();
 
    final draft = await loadDraft(customerId);
 
    if (draft == null) return;
 
    final submittedString = prefs.getString("submitted_cases");
 
    List submittedList = [];
 
    if (submittedString != null) {
      submittedList = jsonDecode(submittedString);
    }
 
    submittedList.add(draft);
 
    await prefs.setString(
      "submitted_cases",
      jsonEncode(submittedList),
    );
 
    await clearDraft(customerId);
  }
 
}
 