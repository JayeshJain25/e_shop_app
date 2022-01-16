class UserOrdersModel {
  final String addressID;
  final bool isSuccess;
  final String orderBy;
  final String orderTime;
  final String paymentDetails;
  final List<dynamic> productIDs;
  final double totalAmount;

  const UserOrdersModel(
      {required this.addressID,
      required this.isSuccess,
      required this.orderBy,
      required this.orderTime,
      required this.paymentDetails,
      required this.totalAmount,
      required this.productIDs});

  factory UserOrdersModel.fromJson(Map<String, dynamic> json) {
    return UserOrdersModel(
      addressID: json['addressID'] as String,
      isSuccess: json['isSuccess'] as bool,
      orderBy: json['orderBy'] as String,
      orderTime: json['orderTime'] as String,
      paymentDetails: json['paymentDetails'] as String,
      productIDs: json['productIDs'] as List<dynamic>,
      totalAmount: json['totalAmount'] as double,
    );
  }

  Map<String, dynamic> toJson() => {
        'addressID': addressID,
        'isSuccess': isSuccess,
        'orderBy': orderBy,
        'orderTime': orderTime,
        'paymentDetails': paymentDetails,
        'totalAmount': totalAmount,
        'productIDs': productIDs,
      };
}
