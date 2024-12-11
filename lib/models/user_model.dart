import 'package:firereport/models/enums.dart';

class AppUserModel {
  String? id;
  String firstName;
  String lastName;
  UnitType? unitType;
  RoleType? roleType;
  String? email;

  AppUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.unitType,
    this.roleType,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      unitType: json['unit_type'] != null ? UnitType.values[json['unit_type']] : UnitType.unset,
      roleType: json['role_type'] != null ? RoleType.values[json['role_type']] : RoleType.unset,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'unit_type': unitType != null ? unitType!.index : UnitType.unset,
      'role_type': roleType != null ? roleType!.index : RoleType.unset
    };
  }
}