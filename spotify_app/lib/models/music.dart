class Music {
  final String name;
  final String image;
  final String desc;
  final String audioURL;

  const Music(this.name, this.image, this.desc, this.audioURL);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'desc': desc,
      'audioURL': audioURL,
    };
  }

  factory Music.fromMap(Map<String, dynamic> map) {
    return Music(
      map['name'] ?? '',
      map['image'] ?? '',
      map['desc'] ?? '',
      map['audioURL'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Music && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}