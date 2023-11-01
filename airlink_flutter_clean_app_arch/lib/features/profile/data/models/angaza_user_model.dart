import 'package:airlink/features/profile/domain/entities/angaza_user.dart';

class AngazaUserModel extends AngazaUser {
  AngazaUserModel({required super.username, required super.password});

  factory AngazaUserModel.fromEntity(AngazaUser angazaUser) {
    return AngazaUserModel(
      username: angazaUser.username,
      password: angazaUser.password,
    );
  }

  toMap() {
    return {
      'username': username,
      'password': password,
    };
  }

  static AngazaUserModel fromMap(angazaUserModel) {
    return AngazaUserModel(
      username: angazaUserModel['username'],
      password: angazaUserModel['password'],
    );
  }

  AngazaUser toEntity() {
    return AngazaUser(
      username: username,
      password: password,
    );
  }
}
