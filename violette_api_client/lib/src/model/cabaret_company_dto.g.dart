// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cabaret_company_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CabaretCompanyDto extends CabaretCompanyDto {
  @override
  final int? id;
  @override
  final String? name;
  @override
  final String? description;
  @override
  final int? managerId;
  @override
  final String? managerFirstName;
  @override
  final String? managerLastName;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  factory _$CabaretCompanyDto(
          [void Function(CabaretCompanyDtoBuilder)? updates]) =>
      (CabaretCompanyDtoBuilder()..update(updates))._build();

  _$CabaretCompanyDto._(
      {this.id,
      this.name,
      this.description,
      this.managerId,
      this.managerFirstName,
      this.managerLastName,
      this.createdAt,
      this.updatedAt})
      : super._();
  @override
  CabaretCompanyDto rebuild(void Function(CabaretCompanyDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CabaretCompanyDtoBuilder toBuilder() =>
      CabaretCompanyDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CabaretCompanyDto &&
        id == other.id &&
        name == other.name &&
        description == other.description &&
        managerId == other.managerId &&
        managerFirstName == other.managerFirstName &&
        managerLastName == other.managerLastName &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, managerId.hashCode);
    _$hash = $jc(_$hash, managerFirstName.hashCode);
    _$hash = $jc(_$hash, managerLastName.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CabaretCompanyDto')
          ..add('id', id)
          ..add('name', name)
          ..add('description', description)
          ..add('managerId', managerId)
          ..add('managerFirstName', managerFirstName)
          ..add('managerLastName', managerLastName)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class CabaretCompanyDtoBuilder
    implements Builder<CabaretCompanyDto, CabaretCompanyDtoBuilder> {
  _$CabaretCompanyDto? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  int? _managerId;
  int? get managerId => _$this._managerId;
  set managerId(int? managerId) => _$this._managerId = managerId;

  String? _managerFirstName;
  String? get managerFirstName => _$this._managerFirstName;
  set managerFirstName(String? managerFirstName) =>
      _$this._managerFirstName = managerFirstName;

  String? _managerLastName;
  String? get managerLastName => _$this._managerLastName;
  set managerLastName(String? managerLastName) =>
      _$this._managerLastName = managerLastName;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  CabaretCompanyDtoBuilder() {
    CabaretCompanyDto._defaults(this);
  }

  CabaretCompanyDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _description = $v.description;
      _managerId = $v.managerId;
      _managerFirstName = $v.managerFirstName;
      _managerLastName = $v.managerLastName;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CabaretCompanyDto other) {
    _$v = other as _$CabaretCompanyDto;
  }

  @override
  void update(void Function(CabaretCompanyDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CabaretCompanyDto build() => _build();

  _$CabaretCompanyDto _build() {
    final _$result = _$v ??
        _$CabaretCompanyDto._(
          id: id,
          name: name,
          description: description,
          managerId: managerId,
          managerFirstName: managerFirstName,
          managerLastName: managerLastName,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
