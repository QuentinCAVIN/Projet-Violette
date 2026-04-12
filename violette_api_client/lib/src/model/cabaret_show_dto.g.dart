// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cabaret_show_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CabaretShowDto extends CabaretShowDto {
  @override
  final int? id;
  @override
  final int? companyId;
  @override
  final String? title;
  @override
  final String? description;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  factory _$CabaretShowDto([void Function(CabaretShowDtoBuilder)? updates]) =>
      (CabaretShowDtoBuilder()..update(updates))._build();

  _$CabaretShowDto._(
      {this.id,
      this.companyId,
      this.title,
      this.description,
      this.createdAt,
      this.updatedAt})
      : super._();
  @override
  CabaretShowDto rebuild(void Function(CabaretShowDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CabaretShowDtoBuilder toBuilder() => CabaretShowDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CabaretShowDto &&
        id == other.id &&
        companyId == other.companyId &&
        title == other.title &&
        description == other.description &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, companyId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CabaretShowDto')
          ..add('id', id)
          ..add('companyId', companyId)
          ..add('title', title)
          ..add('description', description)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class CabaretShowDtoBuilder
    implements Builder<CabaretShowDto, CabaretShowDtoBuilder> {
  _$CabaretShowDto? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  int? _companyId;
  int? get companyId => _$this._companyId;
  set companyId(int? companyId) => _$this._companyId = companyId;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  CabaretShowDtoBuilder() {
    CabaretShowDto._defaults(this);
  }

  CabaretShowDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _companyId = $v.companyId;
      _title = $v.title;
      _description = $v.description;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CabaretShowDto other) {
    _$v = other as _$CabaretShowDto;
  }

  @override
  void update(void Function(CabaretShowDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CabaretShowDto build() => _build();

  _$CabaretShowDto _build() {
    final _$result = _$v ??
        _$CabaretShowDto._(
          id: id,
          companyId: companyId,
          title: title,
          description: description,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
