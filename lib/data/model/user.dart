class User {
  final int id;
  final String userName;
  final String email;
  final String address;
  final String avatarUrl;
  final String fullName;
  final String role;

  User({
    required this.id,
    required this.userName,
    required this.email,
    required this.address,
    required this.avatarUrl,
    required this.fullName,
    required this.role,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        userName: json['userName'] ?? "",
        email: json['email'] ?? "",
        address: json['address'] ?? "",
        avatarUrl: json['avatarUrl'] ?? "",
        fullName: json['fullName'] ?? "",
        role: json['role'] ?? ""
    );
  }

  @override
  String toString() => 'User(id : $id, userName : $userName)';
}