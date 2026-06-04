$path = "c:\Supply-Chain-RM-APP\lib\core\services\auth_service.dart"
$content = Get-Content -Path $path -Raw

$importStr = "import '../constants/api_endpoints.dart';"
$newImportStr = "import '../constants/api_endpoints.dart';`nimport 'package:supply_chain/core/services/notification_service.dart';"

$content = $content.Replace($importStr, $newImportStr)

$oldStr = @"
      await prefs.setString("userEmail", email);

      print("Stored Email: `${prefs.getString("userEmail")}");

      return data;
"@

$newStr = @"
      await prefs.setString("userEmail", email);

      print("Stored Email: `${prefs.getString("userEmail")}");

      // ?? GENERATE AND SEND FCM TOKEN TO BACKEND
      try {
        String? fcmToken = await NotificationService.generateFcmToken();
        if (fcmToken != null) {
          int? userId = data["user"]["id"];
          String? role = data["user"]["role"];
          
          if (userId != null && role != null) {
            await http.post(
              Uri.parse("`${ApiEndpoints.baseUrl}/notifications/save-fcm-token"),
              headers: {
                "Authorization": "Bearer `${data["token"]}",
                "Content-Type": "application/json",
              },
              body: jsonEncode({
                "id": userId,
                "type": role.toLowerCase() == "customer" ? "customer" : "user",
                "fcmToken": fcmToken,
              }),
            );
            print("FCM Token sent successfully on login: `$fcmToken");
          }
        }
      } catch (e) {
        print("Failed to send FCM token on login: `$e");
      }

      return data;
"@

$oldStrCRLF = $oldStr.Replace("`n", "`r`n")
$newStrCRLF = $newStr.Replace("`n", "`r`n")

if ($content.Contains($oldStr)) {
    $content = $content.Replace($oldStr, $newStr)
} elseif ($content.Contains($oldStrCRLF)) {
    $content = $content.Replace($oldStrCRLF, $newStrCRLF)
} else {
    Write-Host "Could not find login replacement target!"
}

Set-Content -Path $path -Value $content -NoNewline
Write-Host "File updated successfully"

