// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'show_date_skill_requirement_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShowDateSkillRequirementDto extends ShowDateSkillRequirementDto {
  @override
  final int? id;
  @override
  final int? showDateId;
  @override
  final ArtistSkill? skill;
  @override
  final int? requiredCount;
  @override
  final num? netFee;

  factory _$ShowDateSkillRequirementDto(
          [void Function(ShowDateSkillRequirementDtoBuilder)? updates]) =>
      (ShowDateSkillRequirementDtoBuilder()..update(updates))._build();

  _$ShowDateSkillRequirementDto._(
      {this.id, this.showDateId, this.skill, this.requiredCount, this.netFee})
      : super._();
  @override
  ShowDateSkillRequirementDto rebuild(
          void Function(ShowDateSkillRequirementDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShowDateSkillRequirementDtoBuilder toBuilder() =>
      ShowDateSkillRequirementDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShowDateSkillRequirementDto &&
        id == other.id &&
        showDateId == other.showDateId &&
        skill == other.skill &&
        requiredCount == other.requiredCount &&
        netFee == other.netFee;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, showDateId.hashCode);
    _$hash = $jc(_$hash, skill.hashCode);
    _$hash = $jc(_$hash, requiredCount.hashCode);
    _$hash = $jc(_$hash, netFee.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShowDateSkillRequirementDto')
          ..add('id', id)
          ..add('showDateId', showDateId)
          ..add('skill', skill)
          ..add('requiredCount', requiredCount)
          ..add('netFee', netFee))
        .toString();
  }
}

class ShowDateSkillRequirementDtoBuilder
    implements
        Builder<ShowDateSkillRequirementDto,
            ShowDateSkillRequirementDtoBuilder> {
  _$ShowDateSkillRequirementDto? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  int? _showDateId;
  int? get showDateId => _$this._showDateId;
  set showDateId(int? showDateId) => _$this._showDateId = showDateId;

  ArtistSkill? _skill;
  ArtistSkill? get skill => _$this._skill;
  set skill(ArtistSkill? skill) => _$this._skill = skill;

  int? _requiredCount;
  int? get requiredCount => _$this._requiredCount;
  set requiredCount(int? requiredCount) =>
      _$this._requiredCount = requiredCount;

  num? _netFee;
  num? get netFee => _$this._netFee;
  set netFee(num? netFee) => _$this._netFee = netFee;

  ShowDateSkillRequirementDtoBuilder() {
    ShowDateSkillRequirementDto._defaults(this);
  }

  ShowDateSkillRequirementDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _showDateId = $v.showDateId;
      _skill = $v.skill;
      _requiredCount = $v.requiredCount;
      _netFee = $v.netFee;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShowDateSkillRequirementDto other) {
    _$v = other as _$ShowDateSkillRequirementDto;
  }

  @override
  void update(void Function(ShowDateSkillRequirementDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShowDateSkillRequirementDto build() => _build();

  _$ShowDateSkillRequirementDto _build() {
    final _$result = _$v ??
        _$ShowDateSkillRequirementDto._(
          id: id,
          showDateId: showDateId,
          skill: skill,
          requiredCount: requiredCount,
          netFee: netFee,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
