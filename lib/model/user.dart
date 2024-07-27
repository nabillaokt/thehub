class User {
  String? id;
  String? name;
  String? balance;
  String? email;
  String? password;
  String? avatarUrl;
  DateTime? dateOfBirth;

  User({
    this.id,
    this.name,
    this.balance,
    this.email,
    this.password,
    this.avatarUrl,
    this.dateOfBirth,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        balance: json["balance"],
        email: json["email"],
        password: json["password"],
        avatarUrl: json["avatarUrl"],
        dateOfBirth: json["date_of_birth"] != null
            ? DateTime.parse(json["date_of_birth"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "balance": balance,
        "email": email,
        "password": password,
        "avatarUrl": avatarUrl,
        "date_of_birth": dateOfBirth?.toIso8601String(),
      };
}
