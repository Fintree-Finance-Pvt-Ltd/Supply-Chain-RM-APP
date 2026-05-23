import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
 
/// ================= SIMPLE FALLBACK TOAST =================
void showToast(
  BuildContext context,
  String message, {
  bool success = true,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: success ? AppColors.secondary : AppColors.danger,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: Text(message),
    ),
  );
}
 
/// ================= VERIFICATION SUCCESS CARD =================
Widget verificationSuccessCard({
  required String message,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.success.withOpacity(.12),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.success),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: AppColors.success),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    ),
  );
}
 
/// ================= SAFE ANIMATED TOP TOAST =================
/// Flutter Web + Mobile safe
void showTopToast(
  BuildContext context,
  String message, {
  bool success = true,
  IconData? icon,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
 
  late OverlayEntry entry;
 
  final controller = AnimationController(
    vsync: Navigator.of(context),
    duration: const Duration(milliseconds: 450),
  );
 
  final animation = Tween<Offset>(
    begin: const Offset(-1.2, 0),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
  );
 
  entry = OverlayEntry(
    builder: (ctx) {
      final topPadding = MediaQuery.maybeOf(ctx)?.padding.top ?? 16;
 
      return Positioned(
        top: topPadding + 12,
        left: 0,
        right: 0,
        child: SlideTransition(
          position: animation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: success
                        ? [
                            AppColors.secondary.withOpacity(.95),
                            AppColors.darkBlue.withOpacity(.95),
                          ]
                        : [
                            AppColors.danger.withOpacity(.95),
                            AppColors.danger.withOpacity(.8),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                      color: Colors.black.withOpacity(.25),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      icon ??
                          (success
                              ? Icons.check_circle_rounded
                              : Icons.error_outline),
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
 
  overlay.insert(entry);
  controller.forward();
 
  /// Auto dismiss
  Future.delayed(const Duration(seconds: 3), () async {
    await controller.reverse();
    entry.remove();
    controller.dispose();
  });
}
 
/// ================= SUCCESS CARD OVERLAY =================
void showSuccessCardToast({
  required BuildContext context,
  required String title,
  required String message,
  required String buttonText,
  required VoidCallback onProceed,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
 
  late OverlayEntry entry;
 
  entry = OverlayEntry(
    builder: (_) => Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.45),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  blurRadius: 30,
                  color: Colors.black.withOpacity(0.25),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 42,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  onPressed: () {
  entry.remove();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    onProceed();
  });
},

                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
 
  overlay.insert(entry);
 
  Future.delayed(const Duration(seconds: 6), () {
    if (entry.mounted) entry.remove();
  });
}
 
 