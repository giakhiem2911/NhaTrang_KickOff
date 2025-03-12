class Field {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String opening_hours;
  final String image_url;

  const Field({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.opening_hours,
    required this.image_url,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'address': this.address,
      'phone': this.phone,
      'opening_hours': this.opening_hours,
      'image_url': this.image_url,
    };
  }

  factory Field.fromMap(Map<String, dynamic> map) {
    return Field(
      id: map['id'] as int,
      name: map['name'] as String,
      address: map['address'] as String,
      phone: map['phone'] as String,
      opening_hours: map['opening_hours'] as String,
      image_url: map['image_url'] as String,
    );
  }
}


