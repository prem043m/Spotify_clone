class Category {
  final String name;
  final String imageURL;

  const Category(this.name, this.imageURL);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageURL': imageURL,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      map['name'] ?? '',
      map['imageURL'] ?? '',
    );
  }
}