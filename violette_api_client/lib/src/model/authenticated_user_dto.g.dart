// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authenticated_user_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthenticatedUserDto extends AuthenticatedUserDto {
  @override
  final String? firebaseUid;
  @override
  final String? email;
  @override
  final String? name;

  factory _$AuthenticatedUserDto(
          [void Function(AuthenticatedUserDtoBuilder)? updates]) =>
      (AuthenticatedUserDtoBuilder()..update(updates))._build();

  _$AuthenticatedUserDto._({this.firebaseUid, this.email, this.name})
      : super._();
  @override
  AuthenticatedUserDto rebuild(
          void Function(AuthenticatedUserDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthenticatedUserDtoBuilder toBuilder() =>
      AuthenticatedUserDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthenticatedUserDto &&
        firebaseUid == other.firebaseUid &&
        email == other.email &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, firebaseUid.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthenticatedUserDto')
          ..add('firebaseUid', firebaseUid)
          ..add('email', email)
          ..add('name', name))
        .toString();
  }
}

class AuthenticatedUserDtoBuilder
    implements Builder<AuthenticatedUserDto, AuthenticatedUserDtoBuilder> {
  _$AuthenticatedUserDto? _$v;

  String? _firebaseUid;
  String? get firebaseUid => _$this._firebaseUid;
  set firebaseUid(String? firebaseUid) => _$this._firebaseUid = firebaseUid;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  AuthenticatedUserDtoBuilder() {
    AuthenticatedUserDto._defaults(this);
  }

  AuthenticatedUserDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _firebaseUid = $v.firebaseUid;
      _email = $v.email;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthenticatedUserDto other) {
    _$v = other as _$AuthenticatedUserDto;
  }

  @override
  void update(void Function(AuthenticatedUserDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthenticatedUserDto build() => _build();

  _$AuthenticatedUserDto _build() {
    final _$result = _$v ??
        _$AuthenticatedUserDto._(
          firebaseUid: firebaseUid,
          email: email,
          name: name,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
