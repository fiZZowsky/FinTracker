class ReceiptModel {
  final int id;
  final String storeName;
  final double totalAmount;
  final DateTime dateShopping;

  ReceiptModel({
    required this.id,
    required this.storeName,
    required this.totalAmount,
    required this.dateShopping,
  });
}
