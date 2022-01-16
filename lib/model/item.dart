class ItemModel {
  final String title;
  final String shortInfo;
  final int publishedDate;
  final List<dynamic> thumbnailUrl;
  final String longDescription;
  final String status;
  final int price;

  const ItemModel({
    required this.title,
    required this.shortInfo,
    required this.publishedDate,
    required this.thumbnailUrl,
    required this.longDescription,
    required this.status,
    required this.price,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
        title: json['title'] as String,
        shortInfo: json['shortInfo'] as String,
        publishedDate: json['publishedDate'] as int,
        thumbnailUrl: json['thumbnailUrl'] as List<dynamic>,
        longDescription: json['longDescription'] as String,
        status: json['status'] as String,
        price: json['price'] as int);
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'shortInfo': shortInfo,
        'price': price,
        'publishedDate': publishedDate,
        'thumbnailUrl': thumbnailUrl,
        'longDescription': longDescription,
        'status': status,
      };
}
