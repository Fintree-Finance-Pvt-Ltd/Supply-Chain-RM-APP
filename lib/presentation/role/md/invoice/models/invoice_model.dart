class InvoiceModel {
  final int id;
  final String invoiceNumber;
  final double invoiceAmount;
  final double disbursementAmount;
  final String status;

  final String? customerName;
  final String? supplierName;

  final double? roiPercentage;
  final double? penalCharges;
  final double? serviceFee;

  final String? invoiceFilePath;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceAmount,
    required this.disbursementAmount,
    required this.status,
    this.customerName,
    this.supplierName,
    this.roiPercentage,
    this.penalCharges,
    this.serviceFee,
    this.invoiceFilePath,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json["id"],
      invoiceNumber: json["invoiceNumber"] ?? "",
      invoiceAmount:
          double.tryParse(
            json["invoiceAmount"].toString(),
          ) ??
          0,
      disbursementAmount:
          double.tryParse(
            json["disbursementAmount"].toString(),
          ) ??
          0,
      status: json["status"] ?? "",

      customerName:
          json["customer"]?["name"] ??
          json["customerName"],

      supplierName:
          json["supplier"]?["supplierName"] ??
          json["supplierName"],

      roiPercentage:
          double.tryParse(
            json["roiPercentage"]
                    ?.toString() ??
                "0",
          ) ??
          0,

      penalCharges:
          double.tryParse(
            json["penalCharges"]
                    ?.toString() ??
                "0",
          ) ??
          0,

      serviceFee:
          double.tryParse(
            json["serviceFee"]
                    ?.toString() ??
                "0",
          ) ??
          0,

      invoiceFilePath:
          json["invoiceFilePath"],
    );
  }

  get loanAccount => null;
}