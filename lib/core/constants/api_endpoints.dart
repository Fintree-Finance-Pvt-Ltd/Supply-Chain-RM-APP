class ApiEndpoints {
  static const String baseUrl = "https://supplychain-prod.fintreelms.com/api";
  //  static const String baseUrl = "http://localhost:4000/api";
  static const String login = "/auth/login";
  static const String logout = "/auth/logout";

  static const String sendMobileOtp = "/onboarding/mobile/send-otp";
  static const String verifyMobileOtp = "/onboarding/mobile/verify-otp";

  static const String sendEmailOtp = "/onboarding/email/send-otp";
  static const String verifyEmailOtp = "/onboarding/email/verify-otp";

  static const String verifyGst = "/onboarding/kyc/gst";
  static const String uploadDocument = "/documents/upload";

  static const fileBaseUrl = "https://supplychain-prod.fintreelms.com";
  static const String verifyPan = "/onboarding/kyc/pan";
  static const String aadharkyc = "/onboarding/kyc/aadhaar";

  static const String getVerificationStatuses = "/onboarding/kyc/status";

  static String bankDetail(int id) => "/workflows/customers/$id/bank-details";

  static String submitCustomer(int id) => "/workflows/customers/$id/submit";
}
