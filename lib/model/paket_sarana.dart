class Paketsarana {
  String id;
  String name;
  String cover;
  int price;
  String description;

  Paketsarana({
    required this.id,
    required this.name,
    required this.cover,
    required this.price,
    required this.description,
  });

  factory Paketsarana.fromJson(Map<String, dynamic> json) => Paketsarana(
        id: json["id"],
        name: json["name"],
        cover: json["cover"],
        price: json["price"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "cover": cover,
        "price": price,
        "description": description,
      };
}
