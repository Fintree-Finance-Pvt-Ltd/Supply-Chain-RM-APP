import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as api;
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/presentation/auth/login_screen.dart';

class SignInOptions extends StatefulWidget {
  const SignInOptions({super.key});

  @override
  State<SignInOptions> createState() => _SignInOptionsState();
}

class _SignInOptionsState extends State<SignInOptions> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  String? defaultRole;

  final List<String> roles = ["Relationship Manager"];

  List<String> selectedRoles = [];

  InputDecoration fieldStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xfff1f3f6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await api.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.USERS), // ✅ FIX HERE
        headers: {
          "Content-Type": "application/json",
          // "Authorization": "Bearer $token",
        },
        body: jsonEncode(userData),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201 && responseData["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User created successfully"),
            duration: Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        });
        return {"data": responseData["data"]};
      } else {
        throw Exception(responseData["message"]);
      }
    } catch (error) {
      throw Exception(error.toString());
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        /// Background Gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe6ebf2), Color(0xffcfd8e3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.9),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    /// Title
                    const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff2c4a7a),
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// Name
                    TextFormField(
                      controller: nameController,
                      decoration: fieldStyle("Name", Icons.person_outline),
                      validator: (value) =>
                          value!.isEmpty ? "Enter name" : null,
                    ),

                    const SizedBox(height: 15),

                    /// Email
                    TextFormField(
                      controller: emailController,
                      decoration: fieldStyle("Email", Icons.mail_outline),
                      validator: (value) {
                        if (value!.isEmpty) return "Enter email";
                        if (!value.contains("@")) {
                          return "Enter valid email";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 15),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: "Password",
                        prefixIcon: const Icon(Icons.lock_outline),
                        filled: true,
                        fillColor: const Color(0xfff1f3f6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    /// Mobile
                    TextFormField(
                      controller: mobileController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: fieldStyle("Mobile", Icons.phone_outlined),
                      validator: (value) {
                        if (value!.length != 10) {
                          return "Enter valid 10-digit mobile number";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                


                    /// Submit Button
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color(0xff2c4a7a), Color(0xff284b9b)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(.25),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              final userData = {
                                "name": nameController.text.trim(),
                                "email": emailController.text.trim(),
                                "password": passwordController.text
                                    .trim(), // ✅ added
                                "mobile": mobileController.text.trim(),
                                "defaultRole": "Relationship Manager",
                                "roles": selectedRoles,
                              };

                              final response = await createUser(userData);

                              if (response["data"] != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("User created successfully"),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                        child: const Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // returns to Login page
                      },
                      child: const Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          color: Color(0xff2c4a7a),
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
      ),
    );
  }
}
