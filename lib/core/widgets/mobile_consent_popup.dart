import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supply_chain/core/theme/app_colors.dart';

const String CONSENT_TEXT = '''
  I/We hereby authorise Fintree Finance Private Limited (FFPL) (hereinafter referred to as “Lender”) or its associates/subsidiaries affiliates to obtain, verify, exchange, share or part with all the information or otherwise, regarding my/our office/residence and/or contact me/us or my/our family/ employer/Banker/Credit Bureau/ RBI or any third parties as deemed necessary and/or do any such acts till such period as they deem necessary and/or disclose to Reserve bank of India, Credit Information Companies, Banks/NBFCs, or any other authority and institution, including but not limited to current balance, payment history, default, if any, etc. I/We hereby authorise Lender’s employees/agents to access my/our premises during normal office hours for carrying out any verification investigation which includes taking photographs and post disbursement scrutiny. I/We hereby authorise Lender to approach my/our existing bankers or any other prospective lender for any relevant information for consideration of loan and thereafter. I/We hereby provide my/our consent to receive information/services etc for marketing purpose through telephone/mobile/SMS/Email. I/We hereby authorise Lender to market/sell/promote/endorse any other product or service beneficial to me/us. I/We hereby authorise Lender to purge the documents submitted by me/us, if the case is not disbursed/approved for whatever reason within 3 months of application. I/We hereby provide my/our consent to avail information on products and services of other Companies and authorise to cross sell other company’s product and services. I/We hereby authorise Fintree Finance Private Limited(FFPL) or its associates/subsidiaries/affiliates to obtain, verify, exchange, share or part with all the information or otherwise, regarding my/our office/ residence and/or contact me/us or my our family/ employer/Banker/Credit Bureau/ RBI or any third parties as deemed necessary and/or do any such acts till such period as they deem necessary and/or disclose to Reserve bank of India, Credit Information Companies, Banks/NBFCs, or any other authority and institution, including but not limited to current balance, payment history, default, if any, etc. I/We hereby agree to give my/our express consent to Lender to disclose all the information and data furnished by me/us and/or to receive information from Central KYC Registry/third parties including but not limited to vendors, outsourcing agencies, business correspondents for analysing, processing, report generation, storing, record keeping or to various credit information companies/ credit bureaus e.g. Credit Information Bureaus (India) Limited (CIBIL), or to information utilities under the Insolvency Bankruptcy Code 2016 through physical or SMS or email or any other mode.
''';

class MobileConsentPopup {
  // static void show({
  //   required BuildContext context,
  //   required VoidCallback onVerified,
  // })
  static void show({
    required BuildContext context,
    required Function(String otp) onVerified,
  }) {
    final ScrollController scrollController = ScrollController();
    final List<TextEditingController> otpCtrls = List.generate(
      6,
      (_) => TextEditingController(),
    );

    bool scrolledToEnd = false;
    bool consentChecked = false;

    int secondsLeft = 60;
    Timer? timer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            void startTimer() {
              timer?.cancel();
              secondsLeft = 60;

              timer = Timer.periodic(const Duration(seconds: 1), (t) {
                if (secondsLeft == 0) {
                  t.cancel();
                } else {
                  setState(() => secondsLeft--);
                }
              });
            }

            if (timer == null) {
              startTimer();
            }

            scrollController.addListener(() {
              if (scrollController.position.pixels >=
                  scrollController.position.maxScrollExtent - 10) {
                setState(() => scrolledToEnd = true);
              }
            });

            final bool otpFilled = otpCtrls.every(
              (c) => c.text.trim().isNotEmpty,
            );

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// HEADER
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Mobile Verification",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                timer?.cancel();
                                Navigator.pop(context);
                              },
                              child: const Icon(Icons.close),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        /// CONSENT BOX
                        Container(
                          height: 160,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.25),
                            ),
                          ),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: const Text(
                              CONSENT_TEXT,
                              style: TextStyle(fontSize: 13, height: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// CHECKBOX
                        CheckboxListTile(
                          value: consentChecked,
                          onChanged: scrolledToEnd
                              ? (v) =>
                                    setState(() => consentChecked = v ?? false)
                              : null,
                          title: Text(
                            scrolledToEnd
                                ? "I agree to the above consent"
                                : "Please scroll to read full consent",
                            style: const TextStyle(fontSize: 12),
                          ),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),

                        const SizedBox(height: 18),

                        /// OTP BOXES (Responsive + Stable)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final boxWidth = (constraints.maxWidth - 50) / 6;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (i) {
                                return SizedBox(
                                  width: boxWidth,
                                  height: 54,
                                  child: TextField(
                                    controller: otpCtrls[i],
                                    maxLength: 1,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: "",
                                      filled: true,
                                      fillColor: AppColors.inputFill,
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                          color: AppColors.darkBlue.withOpacity(
                                            0.35,
                                          ),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(
                                          color: AppColors.darkBlue,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onChanged: (v) {
                                      if (v.length > 1) {
                                        otpCtrls[i].text = v.substring(0, 1);
                                      }

                                      if (v.isNotEmpty && i < 5) {
                                        FocusScope.of(context).nextFocus();
                                      }

                                      if (v.isEmpty && i > 0) {
                                        FocusScope.of(context).previousFocus();
                                      }

                                      setState(() {});
                                    },
                                  ),
                                );
                              }),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        /// TIMER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              secondsLeft > 0
                                  ? "Resend OTP in 00:${secondsLeft.toString().padLeft(2, '0')}"
                                  : "Didn’t receive OTP?",
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: secondsLeft == 0
                                  ? () {
                                      startTimer();
                                    }
                                  : null,
                              child: Text(
                                "Resend",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: secondsLeft == 0
                                      ? AppColors.primary
                                      : AppColors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        /// VERIFY BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: consentChecked && otpFilled
                                ? () async {
                                    final otp = otpCtrls
                                        .map((c) => c.text)
                                        .join();

                                    final success = await onVerified(otp);

                                    if (success) {
                                      timer?.cancel();
                                      Navigator.of(context).pop();
                                      // Navigator.pop(context); // ✅ close only if verified
                                    } else {
                                      // ❌ keep popup open
                                      // Optional: clear OTP
                                      for (var c in otpCtrls) {
                                        c.clear();
                                      }
                                      setState(() {});
                                    }
                                  }
                                // {
                                //     timer?.cancel();
                                //     Navigator.pop(context);
                                //     // onVerified();
                                //     final otp = otpCtrls
                                //         .map((c) => c.text)
                                //         .join();
                                //     onVerified(otp);
                                //   }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              "Verify Mobile",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
// class MobileConsentPopup {
//   static void show({
//     required BuildContext context,
//     required VoidCallback onVerified,
//   }) {
//     final ScrollController scrollController = ScrollController();
//     final List<TextEditingController> otpCtrls =
//         List.generate(6, (_) => TextEditingController());

//     bool scrolledToEnd = false;
//     bool consentChecked = false;

//     int secondsLeft = 60;
//     Timer? timer;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             void startTimer() {
//               timer?.cancel();
//               secondsLeft = 60;

//               timer = Timer.periodic(
//                 const Duration(seconds: 1),
//                 (t) {
//                   if (secondsLeft == 0) {
//                     t.cancel();
//                   } else {
//                     setState(() => secondsLeft--);
//                   }
//                 },
//               );
//             }

//             if (timer == null) {
//               startTimer();
//             }

//             scrollController.addListener(() {
//               if (scrollController.position.pixels >=
//                   scrollController.position.maxScrollExtent - 10) {
//                 setState(() => scrolledToEnd = true);
//               }
//             });

//             final bool otpFilled =
//                 otpCtrls.every((c) => c.text.trim().isNotEmpty);

//             return Dialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(22),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [

//                     /// HEADER
//                     Row(
//                       children: [
//                         const Expanded(
//                           child: Text(
//                             "Mobile Verification",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ),
//                         InkWell(
//                           onTap: () {
//                             timer?.cancel();
//                             Navigator.pop(context);
//                           },
//                           child: const Icon(Icons.close),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 16),

//                     /// CONSENT BOX
//                     Container(
//                       height: 160,
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: AppColors.primary.withOpacity(0.25),
//                         ),
//                       ),
//                       child: SingleChildScrollView(
//                         controller: scrollController,
//                         child: const Text(
//                           CONSENT_TEXT,
//                           style: TextStyle(fontSize: 13, height: 1.5),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     /// CHECKBOX
//                     CheckboxListTile(
//                       value: consentChecked,
//                       onChanged: scrolledToEnd
//                           ? (v) =>
//                               setState(() => consentChecked = v ?? false)
//                           : null,
//                       title: Text(
//                         scrolledToEnd
//                             ? "I agree to the above consent"
//                             : "Please scroll to read full consent",
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                       contentPadding: EdgeInsets.zero,
//                       controlAffinity:
//                           ListTileControlAffinity.leading,
//                     ),

//                     const SizedBox(height: 18),

//                     /// OTP BOXES
//                     Row(
//                       mainAxisAlignment:
//                           MainAxisAlignment.spaceBetween,
//                       children: List.generate(6, (i) {
//                         return SizedBox(
//                           width: 44,
//                           height: 52,
//                           child: TextField(
//                             controller: otpCtrls[i],
//                             maxLength: 1,
//                             keyboardType:
//                                 TextInputType.number,
//                             textAlign: TextAlign.center,
//                             decoration: InputDecoration(
//                               counterText: "",
//                               filled: true,
//                               fillColor: Colors.white,
//                               enabledBorder:
//                                   OutlineInputBorder(
//                                 borderRadius:
//                                     BorderRadius.circular(14),
//                                 borderSide: BorderSide(
//                                   color: AppColors.primary
//                                       .withOpacity(0.35),
//                                   width: 1.2,
//                                 ),
//                               ),
//                               focusedBorder:
//                                   OutlineInputBorder(
//                                 borderRadius:
//                                     BorderRadius.circular(14),
//                                 borderSide:
//                                     const BorderSide(
//                                   color: AppColors.primary,
//                                   width: 1.8,
//                                 ),
//                               ),
//                             ),
//                             onChanged: (v) {
//                               if (v.isNotEmpty && i < 5) {
//                                 FocusScope.of(context)
//                                     .nextFocus();
//                               }
//                               setState(() {});
//                             },
//                           ),
//                         );
//                       }),
//                     ),

//                     const SizedBox(height: 18),

//                     /// VERIFY BUTTON
//                     SizedBox(
//                       width: double.infinity,
//                       height: 52,
//                       child: ElevatedButton(
//                         onPressed:
//                             consentChecked && otpFilled
//                                 ? () {
//                                     timer?.cancel();
//                                     Navigator.pop(context);
//                                     onVerified();
//                                   }
//                                 : null,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor:
//                               AppColors.darkBlue,
//                           shape: RoundedRectangleBorder(
//                             borderRadius:
//                                 BorderRadius.circular(18),
//                           ),
//                         ),
//                         child: const Text(
//                           "Verify Mobile",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

class EmailVerifyPopup {
  static void show({
    required BuildContext context,
    required Future<bool> Function(String otp) onVerify,
  }) {
    final List<TextEditingController> otpCtrls = List.generate(
      6,
      (_) => TextEditingController(),
    );

    int secondsLeft = 60;
    Timer? timer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            final bool otpFilled = otpCtrls.every(
              (c) => c.text.trim().isNotEmpty,
            );

            void startTimer() {
              timer?.cancel();
              secondsLeft = 60;
              timer = Timer.periodic(const Duration(seconds: 1), (t) {
                if (secondsLeft == 0) {
                  t.cancel();
                } else {
                  setState(() => secondsLeft--);
                }
              });
            }

            if (timer == null) startTimer();

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// ICON
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.75),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.email_outlined,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Verify your email",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Enter the 6-digit OTP sent to your email",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 22),

                    /// OTP BOXES

                    /// OTP BOXES (Perfect Fit – One Row, FIXED)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final boxWidth = (constraints.maxWidth - 50) / 6;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (i) {
                            return SizedBox(
                              width: boxWidth,
                              height: 54,
                              child: TextField(
                                controller: otpCtrls[i],
                                maxLength: 1,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                textAlignVertical:
                                    TextAlignVertical.center, // ✅ FIX
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  counterText: "",
                                  filled: true,
                                  fillColor: AppColors.inputFill,
                                  isDense: true, // ✅ FIX
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14, // ✅ FIX (important)
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: AppColors.darkBlue.withOpacity(
                                        0.35,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: AppColors.darkBlue,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (v) {
                                  // allow only 1 digit
                                  if (v.length > 1) {
                                    otpCtrls[i].text = v.substring(0, 1);
                                  }

                                  if (v.isNotEmpty && i < 5) {
                                    FocusScope.of(context).nextFocus();
                                  }

                                  if (v.isEmpty && i > 0) {
                                    FocusScope.of(context).previousFocus();
                                  }

                                  setState(() {});
                                },
                              ),
                            );
                          }),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    /// TIMER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          secondsLeft > 0
                              ? "Resend OTP in 00:${secondsLeft.toString().padLeft(2, '0')}"
                              : "Didn’t receive OTP?",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: secondsLeft == 0
                              ? () {
                                  startTimer();
                                }
                              : null,
                          child: Text(
                            "Resend",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: secondsLeft == 0
                                  ? AppColors.primary
                                  : AppColors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    /// VERIFY BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                                            onPressed: otpFilled
                        ? () async {
                            final otp = otpCtrls.map((e) => e.text).join();

                            final success = await onVerify(otp);

                            if (success) {
                              timer?.cancel();
                              Navigator.of(context).pop();   // ✅ close only if verified
                            } else {
                              // ❌ keep popup open
                              for (var c in otpCtrls) {
                                c.clear();
                              }
                              setState(() {});
                            }
                          }
                        : null,
                        // onPressed: otpFilled
                        //     ? () async {
                        //         final otp = otpCtrls.map((e) => e.text).join();

                        //         timer?.cancel();

                        //         Navigator.pop(context);

                        //         await onVerify(otp);
                        //       }
                        //     : null,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "Verify Email",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
