import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/auth_service.dart';
import 'package:supply_chain/presentation/role/md/Cases/case_details.dart';

class RejectedCasesPage extends StatefulWidget {
  const RejectedCasesPage({super.key});

  @override
  State<RejectedCasesPage> createState() => _RejectedCasesPageState();
}

class _RejectedCasesPageState extends State<RejectedCasesPage> {

  bool isLoading = true;
  List rejectedList = [];

  @override
  void initState() {
    super.initState();
    fetchRejectedCases();
  }

  Future<void> fetchRejectedCases() async {
    try {

      final token = await AuthService().getToken();

      final response = await http.get(
        Uri.parse(
          "${ApiEndpoints.baseUrl}/workflows/customers/dashboard/executive",
          // "http://localhost:4000/api/workflows/customers/dashboard/executive",
        ),
        headers: {
          "Authorization": "Bearer $token"
        },
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {

        final handled = data["data"]["handled"];

        /// Filter only rejected
        rejectedList = handled.where((e) {
          return (e["currentStatus"] ?? "")
              .toString()
              .toLowerCase() == "rejected";
        }).toList();

        setState(() {
          isLoading = false;
        });
      }

    } catch (e) {

      debugPrint("Rejected cases error: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Rejected Cases"),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : rejectedList.isEmpty
              ? const Center(child: Text("No Rejected Cases"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rejectedList.length,
                  itemBuilder: (context, index) {

                    final item = rejectedList[index];
                    final customer = item["customer"];

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CaseDetailsPage(
                              customerId: item["customerId"],
                            ),
                          ),
                        );
                      },

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                            ),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              customer["companyName"] ?? "N/A",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                const Text(
                                  "Customer Code: ",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Expanded(
                                  child: Text(customer["lanId"] ?? "N/A"),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "REJECTED",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}