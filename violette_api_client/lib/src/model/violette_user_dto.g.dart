// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'violette_user_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VioletteUserDto extends VioletteUserDto {
  @override
  final int? id;
  @override
  final String? firebaseUid;
  @override
  final String? email;
  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final BuiltSet<UserRole>? roles;
  @override
  final BuiltSet<ArtistSkill>? skills;

  factory _$VioletteUserDto([void Function(VioletteUserDtoBuilder)? updates]) =>
      (VioletteUserDtoBuilder()..update(updates))._build();

  _$VioletteUserDto._(
      {this.id,
      this.firebaseUid,
      this.email,
      this.firstName,
      this.lastName,
      this.roles,
      this.skills})
      : super._();
  @override
  VioletteUserDto rebuild(void Function(VioletteUserDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VioletteUserDtoBuilder toBuilder() => VioletteUserDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VioletteUserDto &&
        id == other.id &&
        firebaseUid == other.firebaseUid &&
        email == other.email &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        roles == other.roles &&
        skills == other.skills;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, firebaseUid.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jc(_$hash, roles.hashCode);
    _$hash = $jc(_$hash, skills.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VioletteUserDto')
          ..add('id', id)
          ..add('firebaseUid', firebaseUid)
          ..add('email', email)
          ..add('firstName', firstName)
          ..add('lastName', lastName)
          ..add('roles', roles)
          ..add('skills', skills))
        .toString();
  }
}

class VioletteUserDtoBuilder
    implements Builder<VioletteUserDto, VioletteUserDtoBuilder> {
  _$VioletteUserDto? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _firebaseUid;
  String? get firebaseUid => _$this._firebaseUid;
  set firebaseUid(String? firebaseUid) => _$this._firebaseUid = firebaseUid;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  SetBuilder<UserRole>? _roles;
  SetBuilder<UserRole> get roles => _$this._roles ??= SetBuilder<UserRole>();
  set roles(SetBuilder<UserRole>? roles) => _$this._roles = roles;

  SetBuilder<ArtistSkill>? _skills;
  SetBuilder<ArtistSkill> get skills =>
      _$this._skills ??= SetBuilder<ArtistSkill>();
  set skills(SetBuilder<ArtistSkill>? skills) => _$this._skills = skills;

  VioletteUserDtoBuilder() {
    VioletteUserDto._defaults(this);
  }

  VioletteUserDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _firebaseUid = $v.firebaseUid;
      _email = $v.email;
      _firstName = $v.firstName;
      _lastName = $v.lastName;
      _roles = $v.roles?.toBuilder();
      _skills = $v.skills?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VioletteUserDto other) {
    _$v = other as _$VioletteUserDto;
  }

  @override
  void update(void Function(VioletteUserDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VioletteUserDto build() => _build();

  _$VioletteUserDto _build() {
    _$VioletteUserDto _$result;
    try {
      _$result = _$v ??
          _$VioletteUserDto._(
            id: id,
            firebaseUid: firebaseUid,
            email: email,
            firstName: firstName,
            lastName: lastName,
            roles: _roles?.build(),
            skills: _skills?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'roles';
        _roles?.build();
        _$failedField = 'skills';
        _skills?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'VioletteUserDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
