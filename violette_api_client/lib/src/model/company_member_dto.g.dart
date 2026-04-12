// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_member_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CompanyMemberDto extends CompanyMemberDto {
  @override
  final int? companyId;
  @override
  final int? artistId;
  @override
  final String? artistFirstName;
  @override
  final String? artistLastName;
  @override
  final DateTime? joinedAt;

  factory _$CompanyMemberDto(
          [void Function(CompanyMemberDtoBuilder)? updates]) =>
      (CompanyMemberDtoBuilder()..update(updates))._build();

  _$CompanyMemberDto._(
      {this.companyId,
      this.artistId,
      this.artistFirstName,
      this.artistLastName,
      this.joinedAt})
      : super._();
  @override
  CompanyMemberDto rebuild(void Function(CompanyMemberDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CompanyMemberDtoBuilder toBuilder() =>
      CompanyMemberDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CompanyMemberDto &&
        companyId == other.companyId &&
        artistId == other.artistId &&
        artistFirstName == other.artistFirstName &&
        artistLastName == other.artistLastName &&
        joinedAt == other.joinedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, companyId.hashCode);
    _$hash = $jc(_$hash, artistId.hashCode);
    _$hash = $jc(_$hash, artistFirstName.hashCode);
    _$hash = $jc(_$hash, artistLastName.hashCode);
    _$hash = $jc(_$hash, joinedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CompanyMemberDto')
          ..add('companyId', companyId)
          ..add('artistId', artistId)
          ..add('artistFirstName', artistFirstName)
          ..add('artistLastName', artistLastName)
          ..add('joinedAt', joinedAt))
        .toString();
  }
}

class CompanyMemberDtoBuilder
    implements Builder<CompanyMemberDto, CompanyMemberDtoBuilder> {
  _$CompanyMemberDto? _$v;

  int? _companyId;
  int? get companyId => _$this._companyId;
  set companyId(int? companyId) => _$this._companyId = companyId;

  int? _artistId;
  int? get artistId => _$this._artistId;
  set artistId(int? artistId) => _$this._artistId = artistId;

  String? _artistFirstName;
  String? get artistFirstName => _$this._artistFirstName;
  set artistFirstName(String? artistFirstName) =>
      _$this._artistFirstName = artistFirstName;

  String? _artistLastName;
  String? get artistLastName => _$this._artistLastName;
  set artistLastName(String? artistLastName) =>
      _$this._artistLastName = artistLastName;

  DateTime? _joinedAt;
  DateTime? get joinedAt => _$this._joinedAt;
  set joinedAt(DateTime? joinedAt) => _$this._joinedAt = joinedAt;

  CompanyMemberDtoBuilder() {
    CompanyMemberDto._defaults(this);
  }

  CompanyMemberDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _companyId = $v.companyId;
      _artistId = $v.artistId;
      _artistFirstName = $v.artistFirstName;
      _artistLastName = $v.artistLastName;
      _joinedAt = $v.joinedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CompanyMemberDto other) {
    _$v = other as _$CompanyMemberDto;
  }

  @override
  void update(void Function(CompanyMemberDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CompanyMemberDto build() => _build();

  _$CompanyMemberDto _build() {
    final _$result = _$v ??
        _$CompanyMemberDto._(
          companyId: companyId,
          artistId: artistId,
          artistFirstName: artistFirstName,
          artistLastName: artistLastName,
          joinedAt: joinedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
