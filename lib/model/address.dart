class AddressModel {
  final String name;
  final String phoneNumber;
  final String flatNumber;
  final String city;
  final String state;
  final String pincode;

  const AddressModel(
      {required this.name,
      required this.phoneNumber,
      required this.flatNumber,
      required this.city,
      required this.state,
      required this.pincode});

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      flatNumber: json['flatNumber'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phoneNumber': phoneNumber,
        'flatNumber': flatNumber,
        'city': city,
        'state': state,
        'pincode': pincode,
      };
}
