class AppUser {
  String? id;
  String firstName;
  String lastName;
  String? email;

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}