class User {
  final String id;
  final String name;
  int followers;

  User({
    required this.id,
    required this.name,
    this.followers = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      followers: json['followers'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'followers': followers,
    };
  }
}
