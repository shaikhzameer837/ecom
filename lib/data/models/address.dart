import 'model_utils.dart';

enum AddressType { home, work, other }

class Address {
  const Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.line1,
    this.line2 = '',
    required this.city,
    required this.state,
    required this.pincode,
    this.type = AddressType.home,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String phone;
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String pincode;
  final AddressType type;
  final bool isDefault;

  String get formatted =>
      [line1, if (line2.isNotEmpty) line2, '$city, $state - $pincode'].join(', ');

  factory Address.fromMap(String id, Object? raw) {
    final map = ModelUtils.asMap(raw);
    return Address(
      id: id,
      name: ModelUtils.asString(map['name']),
      phone: ModelUtils.asString(map['phone']),
      line1: ModelUtils.asString(map['line1']),
      line2: ModelUtils.asString(map['line2']),
      city: ModelUtils.asString(map['city']),
      state: ModelUtils.asString(map['state']),
      pincode: ModelUtils.asString(map['pincode']),
      type: AddressType.values.asNameMap()[ModelUtils.asString(map['type'])] ??
          AddressType.home,
      isDefault: ModelUtils.asBool(map['isDefault']),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'line1': line1,
        'line2': line2,
        'city': city,
        'state': state,
        'pincode': pincode,
        'type': type.name,
        'isDefault': isDefault,
      };
}
