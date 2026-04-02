import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_chain/core/constants/api_endpoints.dart';
import 'package:supply_chain/core/services/auth_service.dart';
import 'package:supply_chain/core/services/draft_service.dart';

import 'package:supply_chain/core/theme/app_colors.dart';
import 'package:supply_chain/presentation/role/rm/NewCustomer/Documents.dart'
    hide AppColors;

class AddressDetails extends StatefulWidget {
  final int customerId;

  const AddressDetails({super.key, required this.customerId});

  @override
  State<AddressDetails> createState() => _AddressDetailsState();
}

class _AddressDetailsState extends State<AddressDetails> {
  List<AddressModel> addresses = [];
  final TextEditingController remarkController = TextEditingController();
  String? companyType;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    loadTheme();

    _initPage();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isDarkMode = prefs.getBool("isDarkMode") ?? false);
  }

  Future<void> _initPage() async {
    await _loadCustomerAddresses(); // load API data
    await _loadDraft(); // override with draft if exists
    await _loadCompanyType();
  }

  void _addAddress() {
    setState(() {
      addresses.add(AddressModel());
    });
  }

  // void _removeAddress(int index) {
  //   setState(() {
  //     addresses.removeAt(index);
  //   });
  // }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _processAddress({
    int? id,
    required String type,
    required String fullAddress,
    required String pincode,
    required String state,
    required String city,
  }) async {
    print("🔥 PROCESSING ADDRESS");
    final customerId = widget.customerId;

    final token = await AuthService().getToken();

    final response = await http.post(
      Uri.parse("${ApiEndpoints.baseUrl}/kyc/address/process"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "id": id,
        "customerId": customerId,
        "type": type,
        "fullAddress": fullAddress,
        "pincode": pincode,
        "state": state,
        "city": city,
      }),
    );

    final data = jsonDecode(response.body);

    print("🔥 STATUS CODE: ${response.statusCode}");
    print("🔥 RESPONSE BODY: ${response.body}");

    if (response.statusCode != 200 || data["success"] != true) {
      throw Exception(data["message"] ?? "Address save failed");
    }
  }

  void _removeAddress(int index) async {
    final model = addresses[index];

    try {
      if (model.id != null) {
        await _deleteAddress(model.id!);
      }

      setState(() {
        addresses.removeAt(index);
      });
    } catch (e) {
      _showError("Failed to delete address");
    }
  }

  Future<void> _loadCustomerAddresses() async {
    try {
      final token = await AuthService().getToken();

      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/customers/${widget.customerId}"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        final customer = data["data"];

        final List addressList = customer["addresses"] ?? [];

        addresses.clear();

        for (final item in addressList) {
          final model = AddressModel();

          model.id = item["id"];
          model.addressType = item["type"] ?? "";
          model.fullAddressController.text = item["fullAddress"] ?? "";
          model.pincodeController.text = item["pincode"] ?? "";
          model.stateController.text = item["state"] ?? "";
          model.cityController.text = item["city"] ?? "";

          model.selectedCity = item["city"];

          addresses.add(model);
          final index = addresses.length - 1;

          if (model.pincodeController.text.length == 6) {
            await _fetchLocationFromPincode(
              model.pincodeController.text,
              index,
            );
          }

          final savedCity = (item["city"] ?? "").toString().trim();

          if (addresses[index].postOffices
              .map((e) => e.name.trim())
              .contains(savedCity)) {
            addresses[index].selectedCity = savedCity;
            addresses[index].cityController.text = savedCity;
          }
        }

        if (addresses.isEmpty) {
          addresses.add(AddressModel());
        }

        setState(() {});
      }
    } catch (e) {
      debugPrint("Address load error: $e");
    }
  }

  Future<void> _deleteAddress(int id) async {
    final token = await AuthService().getToken();

    final response = await http.delete(
      Uri.parse("${ApiEndpoints.baseUrl}/customer/address/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete address");
    }
  }

  Future<void> _saveAddressesToBackend() async {
    try {
      for (int i = 0; i < addresses.length; i++) {
        final model = addresses[i];

        if (!model.validate()) {
          _showError("Please fill all required fields in Address ${i + 1}");
          return;
        }

        await _processAddress(
          id: model.id,
          type: model.addressType,
          fullAddress: model.fullAddressController.text,
          pincode: model.pincodeController.text,
          state: model.stateController.text,
          city: model.cityController.text,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Addresses saved successfully")),
      );

      if (companyType == null) {
        _showError("Company type not found");
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DocumentsPage(
            companyType: companyType!,
            customerId: widget.customerId,
          ),
        ),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _saveDraft() async {
    List<Map<String, dynamic>> addressList = addresses
        .map(
          (e) => {
            "type": e.addressType,
            "address": e.fullAddressController.text,
            "pincode": e.pincodeController.text,
            "state": e.stateController.text,
            "city": e.cityController.text,
          },
        )
        .toList();

    await DraftService.saveWithStep(widget.customerId, "documents", {
      "addresses": addressList,
      "remarks": remarkController.text,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Draft Saved")));

    if (companyType == null) {
      _showError("Company type not found");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentsPage(
          companyType: companyType!,
          customerId: widget.customerId,
        ),
      ),
    );
  }

  Future<int> _loadCustomerId() async {
    return widget.customerId;
  }

  Future<void> _loadDraft() async {
    final draft = await DraftService.loadDraft(widget.customerId);

    if (draft == null) return;

    if (draft["addresses"] != null && draft["addresses"] is List) {
      final savedList = draft["addresses"] as List;

      addresses.clear();

      for (final item in savedList) {
        final model = AddressModel();

        model.addressType = item["type"] ?? "";
        model.fullAddressController.text = item["address"] ?? "";
        model.pincodeController.text = item["pincode"] ?? "";
        model.stateController.text = item["state"] ?? "";
        model.cityController.text = item["city"] ?? "";

        // model.selectedCity = item["city"];

        addresses.add(model);
        final index = addresses.length - 1;

        if (model.pincodeController.text.length == 6) {
          await _fetchLocationFromPincode(model.pincodeController.text, index);
        }

        final savedCity = (item["city"] ?? "").toString().trim();

        if (addresses[index].postOffices
            .map((e) => e.name.trim())
            .contains(savedCity)) {
          addresses[index].selectedCity = savedCity;
          addresses[index].cityController.text = savedCity;
        }
      }

      setState(() {});
    }

    remarkController.text = draft["remarks"] ?? "";
  }

  Future<void> _loadCompanyType() async {
    try {
      final token = await AuthService().getToken();

      final customerId = await _loadCustomerId();

      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/customers/$customerId"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        setState(() {
          companyType = data["data"]["companyType"];
        });
      }
    } catch (e) {
      debugPrint("CompanyType error: $e");
    }
  }

  Future<void> _fetchLocationFromPincode(String pincode, int index) async {
    if (pincode.length != 6) return;

    setState(() {
      addresses[index].isPincodeLoading = true;
      addresses[index].postOffices = [];
      addresses[index].selectedCity = null;
    });

    try {
      final response = await http.get(
        Uri.parse("https://api.postalpincode.in/pincode/$pincode"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data[0]["Status"] == "Success") {
          List offices = data[0]["PostOffice"];

          setState(() {
            addresses[index].postOffices = offices
                .map((e) => PostOfficeModel.fromJson(e))
                .toList();

            addresses[index].stateController.text = offices[0]["State"] ?? "";

            addresses[index].isPincodeLoading = false;
          });
        } else {
          _showError("Invalid Pincode");
          setState(() {
            addresses[index].isPincodeLoading = false;
            addresses[index].postOffices = [];
          });
          // setState(() => addresses[index].isPincodeLoading = false);
        }
      } else {
        _showError("Failed to fetch location");
        setState(() => addresses[index].isPincodeLoading = false);
      }
    } catch (e) {
      _showError("Error fetching pincode");
      setState(() => addresses[index].isPincodeLoading = false);
    }
  }

  /// =======================
  /// HEADER
  /// =======================
  Widget _header() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 40, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkBlue.withOpacity(0.95),
            AppColors.primary.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
  children: [

    /// TITLE
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Address Details",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Add one or more addresses",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    ),

    const SizedBox(width: 10),

    /// ADD BUTTON
    InkWell(
      onTap: _addAddress,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add, size: 18, color: AppColors.primary),
            SizedBox(width: 6),
            Text(
              "Add",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    ),
  ],
),
      // child: Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //   children: [
      //     /// TITLE
      //     Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: const [
      //         Text(
      //           "Address Details",
      //           style: TextStyle(
      //             fontSize: 18,
      //             fontWeight: FontWeight.w700,

      //             // color: Colors.white,
      //           ),
      //         ),
      //         SizedBox(height: 4),
      //         Text(
      //           "Add one or more addresses",
      //           style: TextStyle(fontSize: 13, color: Colors.white70),
      //         ),
      //       ],
      //     ),

      //     /// ADD BUTTON
      //     InkWell(
      //       onTap: _addAddress,
      //       borderRadius: BorderRadius.circular(14),
      //       child: Container(
      //         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      //         decoration: BoxDecoration(
      //           color: Colors.white,
      //           borderRadius: BorderRadius.circular(14),
      //         ),
      //         child: Row(
      //           children: const [
      //             Icon(Icons.add, size: 18, color: AppColors.primary),
      //             SizedBox(width: 6),
      //             Text(
      //               "Add",
      //               style: TextStyle(
      //                 fontWeight: FontWeight.w600,
      //                 color: AppColors.primary,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0F172A)
          : const Color(0xFFF6F8FC),
      body: Column(
        children: [
          _header(),

          /// CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                children: [
                  ...List.generate(
                    addresses.length,
                    (index) => _addressCard(index),
                  ),

                  const SizedBox(height: 20),

                  /// REMARKS
                  _remarksSection(),

                  const SizedBox(height: 24),

                  /// ACTION BUTTONS
                  _bottomButtons(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressTypeDropdown(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Address Type *",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue:
              [
                "Residence",
                "Shop",
                "Godown",
                "Rented",
                "Owned",
              ].contains(addresses[index].addressType)
              ? addresses[index].addressType
              : null,
          hint: Text(
            "Select Address Type",
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 14,
          ),

          dropdownColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          decoration: _inputDecoration(),
          items: const [
            DropdownMenuItem(value: "Residence", child: Text("Residence")),
            DropdownMenuItem(value: "Shop", child: Text("Shop")),
            DropdownMenuItem(value: "Godown", child: Text("Godown")),
            DropdownMenuItem(value: "Rented", child: Text("Rented")),
            DropdownMenuItem(value: "Owned", child: Text("Owned")),
          ],
          onChanged: (value) {
            setState(() {
              addresses[index].addressType = value ?? "";
            });
          },
        ),
        //
      ],
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    int minLines = 1,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label *",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          minLines: minLines,
          maxLines: maxLines,
          onChanged: onChanged,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          decoration: _inputDecoration().copyWith(
            hintText: "Enter $label",
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.white54 : Colors.black54,
            ),
            counterText: "",
            alignLabelWithHint: maxLines > 1, // important for textarea
          ),
        ),
      ],
    );
  }

  Widget _addressCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        // color: Colors.white,
        color: isDarkMode ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            // color: Colors.black.withOpacity(0.05),
            color: isDarkMode
                ? Colors.grey.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              Expanded(
                child: Text(
                  "Address ${index + 1}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Color(0xFF1A237E),
                  ),
                ),
              ),
              if (addresses.length > 1)
                InkWell(
                  onTap: () => _removeAddress(index),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18, color: Colors.red),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          _addressTypeDropdown(index),
          const SizedBox(height: 14),

          _textField(
            label: "Full Address",
            controller: addresses[index].fullAddressController,

            minLines: 3,
            maxLines: 4,
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _textField(
                  label: "Pincode",
                  controller: addresses[index].pincodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  onChanged: (value) {
                    if (value.length == 6) {
                      FocusScope.of(context).unfocus();
                      _fetchLocationFromPincode(value, index);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _textField(
                  label: "State",
                  controller: addresses[index].stateController,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // _textField(
          //   label: "City",
          //   controller: addresses[index].cityController,
          // ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "City",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 8),

              addresses[index].isPincodeLoading
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      initialValue:
                          addresses[index].postOffices
                              .map((e) => e.name)
                              .contains(addresses[index].selectedCity)
                          ? addresses[index].selectedCity
                          : null,
                      hint: Text(
                        "Select City",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),

                      dropdownColor: isDarkMode
                          ? const Color(0xFF1E293B)
                          : Colors.white,

                      decoration: _inputDecoration(),
                      items: addresses[index].postOffices
                          .map(
                            (po) => DropdownMenuItem<String>(
                              value: po.name,
                              child: Text(
                                po.name,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          addresses[index].selectedCity = value;
                          addresses[index].cityController.text = value ?? "";
                        });
                      },
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _remarksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Remarks",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: remarkController,
          maxLines: 3,
          //            style: TextStyle(
          //   color: isDarkMode ? Colors.white : Colors.black,
          // ),
          decoration: _inputDecoration().copyWith(
            hintText: "Add remarks (optional)",
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.white54 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              if (companyType == null) {
                _showError("Company type missing");
                return;
              }

              _saveAddressesToBackend();
            },
            // onPressed: () {
            //   // _saveDraft();
            // },
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.darkBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: AppColors.darkBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              "Save Draft",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.scaffoldBg,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      // fillColor: Colors.white,
      fillColor: isDarkMode ? Colors.black : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          // color: Color.fromARGB(255, 8, 5, 5)
          color: isDarkMode ? Colors.white24 : const Color(0xFFE5E7EB),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      ),
    );
  }
}

/// Model for each address
class PostOfficeModel {
  final String name;
  final String district;
  final String state;

  PostOfficeModel({
    required this.name,
    required this.district,
    required this.state,
  });

  factory PostOfficeModel.fromJson(Map<String, dynamic> json) {
    return PostOfficeModel(
      name: json["Name"] ?? "",
      district: json["District"] ?? "",
      state: json["State"] ?? "",
    );
  }
}

class AddressModel {
  int? id;

  String addressType = "";

  TextEditingController fullAddressController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  List<PostOfficeModel> postOffices = [];
  String? selectedCity;
  bool isPincodeLoading = false;

  bool validate() {
    return fullAddressController.text.isNotEmpty &&
        pincodeController.text.length == 6 &&
        stateController.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        addressType.isNotEmpty;
  }
}
