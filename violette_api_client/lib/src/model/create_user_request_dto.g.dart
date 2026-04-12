// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_user_request_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateUserRequestDto extends CreateUserRequestDto {
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final BuiltSet<UserRole>? roles;

  factory _$CreateUserRequestDto(
          [void Function(CreateUserRequestDtoBuilder)? updates]) =>
      (CreateUserRequestDtoBuilder()..update(updates))._build();

  _$CreateUserRequestDto._(
      {required this.firstName, required this.lastName, this.roles})
      : super._();
  @override
  CreateUserRequestDto rebuild(
          void Function(CreateUserRequestDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateUserRequestDtoBuilder toBuilder() =>
      CreateUserRequestDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateUserRequestDto &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        roles == other.roles;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jc(_$hash, roles.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateUserRequestDto')
          ..add('firstName', firstName)
          ..add('lastName', lastName)
          ..add('roles', roles))
        .toString();
  }
}

class CreateUserRequestDtoBuilder
    implements Builder<CreateUserRequestDto, CreateUserRequestDtoBuilder> {
  _$CreateUserRequestDto? _$v;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  SetBuilder<UserRole>? _roles;
  SetBuilder<UserRole> get roles => _$this._roles ??= SetBuilder<UserRole>();
  set roles(SetBuilder<UserRole>? roles) => _$this._roles = roles;

  CreateUserRequestDtoBuilder() {
    CreateUserRequestDto._defaults(this);
  }

  CreateUserRequestDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _firstName = $v.firstName;
      _lastName = $v.lastName;
      _roles = $v.roles?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateUserRequestDto other) {
    _$v = other as _$CreateUserRequestDto;
  }

  @override
  void update(void Function(CreateUserRequestDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateUserRequestDto build() => _build();

  _$CreateUserRequestDto _build() {
    _$CreateUserRequestDto _$result;
    try {
      _$result = _$v ??
          _$CreateUserRequestDto._(
            firstName: BuiltValueNullFieldError.checkNotNull(
                firstName, r'CreateUserRequestDto', 'firstName'),
            lastName: BuiltValueNullFieldError.checkNotNull(
                lastName, r'CreateUserRequestDto', 'lastName'),
            roles: _roles?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'roles';
        _roles?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CreateUserRequestDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
