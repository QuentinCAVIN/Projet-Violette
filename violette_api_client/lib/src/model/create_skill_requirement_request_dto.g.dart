// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_skill_requirement_request_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateSkillRequirementRequestDto
    extends CreateSkillRequirementRequestDto {
  @override
  final ArtistSkill skill;
  @override
  final int? requiredCount;
  @override
  final num netFee;

  factory _$CreateSkillRequirementRequestDto(
          [void Function(CreateSkillRequirementRequestDtoBuilder)? updates]) =>
      (CreateSkillRequirementRequestDtoBuilder()..update(updates))._build();

  _$CreateSkillRequirementRequestDto._(
      {required this.skill, this.requiredCount, required this.netFee})
      : super._();
  @override
  CreateSkillRequirementRequestDto rebuild(
          void Function(CreateSkillRequirementRequestDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateSkillRequirementRequestDtoBuilder toBuilder() =>
      CreateSkillRequirementRequestDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateSkillRequirementRequestDto &&
        skill == other.skill &&
        requiredCount == other.requiredCount &&
        netFee == other.netFee;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, skill.hashCode);
    _$hash = $jc(_$hash, requiredCount.hashCode);
    _$hash = $jc(_$hash, netFee.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateSkillRequirementRequestDto')
          ..add('skill', skill)
          ..add('requiredCount', requiredCount)
          ..add('netFee', netFee))
        .toString();
  }
}

class CreateSkillRequirementRequestDtoBuilder
    implements
        Builder<CreateSkillRequirementRequestDto,
            CreateSkillRequirementRequestDtoBuilder> {
  _$CreateSkillRequirementRequestDto? _$v;

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

  CreateSkillRequirementRequestDtoBuilder() {
    CreateSkillRequirementRequestDto._defaults(this);
  }

  CreateSkillRequirementRequestDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _skill = $v.skill;
      _requiredCount = $v.requiredCount;
      _netFee = $v.netFee;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateSkillRequirementRequestDto other) {
    _$v = other as _$CreateSkillRequirementRequestDto;
  }

  @override
  void update(void Function(CreateSkillRequirementRequestDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateSkillRequirementRequestDto build() => _build();

  _$CreateSkillRequirementRequestDto _build() {
    final _$result = _$v ??
        _$CreateSkillRequirementRequestDto._(
          skill: BuiltValueNullFieldError.checkNotNull(
              skill, r'CreateSkillRequirementRequestDto', 'skill'),
          requiredCount: requiredCount,
          netFee: BuiltValueNullFieldError.checkNotNull(
              netFee, r'CreateSkillRequirementRequestDto', 'netFee'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
