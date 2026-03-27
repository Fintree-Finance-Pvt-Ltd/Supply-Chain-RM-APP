import 'package:flutter/material.dart';
import 'package:supply_chain/core/services/auth_service.dart';
import 'package:supply_chain/core/utils/toast_helper.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
bool isPasswordVisible = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

//corrected login function 
//  void handleLogin() async {
//   try {
//     final result = await _authService.login(
//       emailController.text.trim(),
//       passwordController.text.trim(),
//     );
 
//     /// Login failed
//     if (result == null) {
//       showTopToast(
//         context,
//         "Invalid email or password",
//         success: false,
//       );
//       return;
//     }
 
//     /// Save RM data
//     final prefs = await SharedPreferences.getInstance();
 
//     final user = result["user"];
 
//     await prefs.setString("rmName", user["name"] ?? "");
//     await prefs.setString("rmEmail", user["email"] ?? "");
//     await prefs.setString("rmMobile", user["mobile"] ?? "");
    
//     // await prefs.setString("role", user["role"] ?? "");
// //  await prefs.setBool("isLoggedIn", true);
//     /// Success Toast
//     showTopToast(
//       context,
//       "Login successful",
//       success: true,
//     );
 
//     String role = user["role"].toLowerCase();
 
//     if (role == "ceo") {
//       Navigator.pushReplacementNamed(context, "/ceoDashboard");
//     } else if (role == "md") {
//       Navigator.pushReplacementNamed(context, "/mdDashboard");
//     } else {
//       Navigator.pushReplacementNamed(context, "/rm");
//     }
//   } catch (e) {
//     showTopToast(
//       context,
//       "Login failed. Please try again",
//       success: false,
//     );
 
//     debugPrint("Login error: $e");
//   }
// }
 

 void handleLogin() async {
  try {
    final result = await _authService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (result == null) {
      showTopToast(context, "Invalid email or password", success: false);
      return;
    }

    showTopToast(context, "Login successful", success: true);

    String role = result["user"]["role"].toLowerCase();

    if (role == "ceo") {
      Navigator.pushReplacementNamed(context, "/ceo");
    } else if (role == "md") {
      Navigator.pushReplacementNamed(context, "/md");
    } else {
      Navigator.pushReplacementNamed(context, "/rm");
    }

  } catch (e) {
    showTopToast(context, "Login failed", success: false);
  }
}
// void handleLogin() async {
//   try {
//     final result = await _authService.login(emailController.text, passwordController.text);

//     if (result != null) {
//       String role = result["user"]["role"].toLowerCase();

//       if (role == "ceo") {
//         Navigator.pushNamed(context, "/ceoDashboard");
//       } else if (role == "md") {
//         Navigator.pushNamed(context, "/mdDashboard");
//       } else {
//         Navigator.pushReplacementNamed(context, "/rm");
//       }
//     }
//   } catch (e) {
//     print("Login failed: $e");
//   }
// }

// void handleLogin() async {
//   String email = emailController.text.trim();
//   String password = passwordController.text.trim();

//   if (email.isEmpty || password.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Enter Email & Password")),
//     );
//     return;
//   }

//   String? role = await AuthService().login(email, password);

//   if (role == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Invalid Email or Password")),
//     );
//     return;
//   }

//   // 🔥 Convert role to lowercase before routing
//   Navigator.pushReplacementNamed(
//     context,
//     "/${role.toLowerCase()}",
//   );
// }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F6),
      body: Center(
        child: Container(
          width: 380,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FBFF),
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.15),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(255, 14, 59, 99),
                ),
              ),

              const SizedBox(height: 36),

              /// EMAIL
              _softInput(
                controller: emailController,
                hint: "E-mail",
                icon: Icons.email_outlined,
                obscure: false,
              ),

              const SizedBox(height: 18),

              /// PASSWORD
              _softPasswordInput(
  controller: passwordController,
),
              // _softInput(
              //   controller: passwordController,
              //   hint: "Password",
              //   icon: Icons.lock_outline,
              //   obscure: true,
              // ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Forgot Password ?",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 26, 65, 150),
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              /// LOGIN BUTTON
              GestureDetector(
                onTap: handleLogin,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: const Color.fromARGB(255, 26, 65, 150),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Or Sign in with",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _softPasswordInput({
  required TextEditingController controller,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.1),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        icon: const Icon(Icons.lock_outline, color: Colors.grey),
        hintText: "Password",
        hintStyle: const TextStyle(color: Colors.grey),
        border: InputBorder.none,

        /// 👁️ TOGGLE ICON
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        ),
      ),
    ),
  );
}
}

/* ---------------- Soft Input Field ---------------- */

Widget _softInput({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  required bool obscure,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.1),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        icon: Icon(icon, color: Colors.grey),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        border: InputBorder.none,
      ),
    ),
  );
}
