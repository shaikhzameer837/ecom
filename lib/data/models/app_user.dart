import 'model_utils.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.phone,
    this.name = '',
    this.email = '',
    this.photoUrl = '',
    this.createdAt = 0,
  });

  final String uid;
  final String phone;
  final String name;
  final String email;
  final String photoUrl;
  final int createdAt;

  factory AppUser.fromMap(String uid, Object? raw) {
    final map = ModelUtils.asMap(raw);
    return AppUser(
      uid: uid,
      phone: ModelUtils.asString(map['phone']),
      name: ModelUtils.asString(map['name']),
      email: ModelUtils.asString(map['email']),
      photoUrl: ModelUtils.asString(map['photoUrl']),
      createdAt: ModelUtils.asInt(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'phone': phone,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'createdAt': createdAt,
      };

  AppUser copyWith({String? name, String? email, String? photoUrl}) => AppUser(
        uid: uid,
        phone: phone,
        name: name ?? this.name,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt,
      );
}
