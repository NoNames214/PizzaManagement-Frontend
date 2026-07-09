class OrderDetails {
  final String pizzaName;
  final int quantity;
  final double priceAtPurchase;

  OrderDetails({
   required this.pizzaName,
   required this.quantity,
   required this.priceAtPurchase
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      pizzaName: json['pizzaName'] ?? "",
      quantity: json['quantity'] ?? 0,
      priceAtPurchase: json['priceAtPurchase']?.toDouble() ?? 0.0
    );
  }

  @override
  String toString() => 'OrderDetails('
      'pizzaName : $pizzaName, '
      'quantity : $quantity, '
      'priceAtPurchase : $priceAtPurchase)';
}