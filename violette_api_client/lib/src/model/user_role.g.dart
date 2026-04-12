// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UserRole _$ARTIST = const UserRole._('ARTIST');
const UserRole _$MANAGER = const UserRole._('MANAGER');

UserRole _$valueOf(String name) {
  switch (name) {
    case 'ARTIST':
      return _$ARTIST;
    case 'MANAGER':
      return _$MANAGER;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UserRole> _$values = BuiltSet<UserRole>(const <UserRole>[
  _$ARTIST,
  _$MANAGER,
]);

class _$UserRoleMeta {
  const _$UserRoleMeta();
  UserRole get ARTIST => _$ARTIST;
  UserRole get MANAGER => _$MANAGER;
  UserRole valueOf(String name) => _$valueOf(name);
  BuiltSet<UserRole> get values => _$values;
}

abstract class _$UserRoleMixin {
  // ignore: non_constant_identifier_names
  _$UserRoleMeta get UserRole => const _$UserRoleMeta();
}

Serializer<UserRole> _$userRoleSerializer = _$UserRoleSerializer();

class _$UserRoleSerializer implements PrimitiveSerializer<UserRole> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ARTIST': 'ARTIST',
    'MANAGER': 'MANAGER',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ARTIST': 'ARTIST',
    'MANAGER': 'MANAGER',
  };

  @override
  final Iterable<Type> types = const <Type>[UserRole];
  @override
  final String wireName = 'UserRole';

  @override
  Object serialize(Serializers serializers, UserRole object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UserRole deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UserRole.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
