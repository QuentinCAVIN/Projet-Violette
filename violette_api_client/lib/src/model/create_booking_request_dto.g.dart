// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_booking_request_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateBookingRequestDto extends CreateBookingRequestDto {
  @override
  final int showDateId;
  @override
  final int artistId;
  @override
  final int? skillRequirementId;

  factory _$CreateBookingRequestDto(
          [void Function(CreateBookingRequestDtoBuilder)? updates]) =>
      (CreateBookingRequestDtoBuilder()..update(updates))._build();

  _$CreateBookingRequestDto._(
      {required this.showDateId,
      required this.artistId,
      this.skillRequirementId})
      : super._();
  @override
  CreateBookingRequestDto rebuild(
          void Function(CreateBookingRequestDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateBookingRequestDtoBuilder toBuilder() =>
      CreateBookingRequestDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateBookingRequestDto &&
        showDateId == other.showDateId &&
        artistId == other.artistId &&
        skillRequirementId == other.skillRequirementId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, showDateId.hashCode);
    _$hash = $jc(_$hash, artistId.hashCode);
    _$hash = $jc(_$hash, skillRequirementId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateBookingRequestDto')
          ..add('showDateId', showDateId)
          ..add('artistId', artistId)
          ..add('skillRequirementId', skillRequirementId))
        .toString();
  }
}

class CreateBookingRequestDtoBuilder
    implements
        Builder<CreateBookingRequestDto, CreateBookingRequestDtoBuilder> {
  _$CreateBookingRequestDto? _$v;

  int? _showDateId;
  int? get showDateId => _$this._showDateId;
  set showDateId(int? showDateId) => _$this._showDateId = showDateId;

  int? _artistId;
  int? get artistId => _$this._artistId;
  set artistId(int? artistId) => _$this._artistId = artistId;

  int? _skillRequirementId;
  int? get skillRequirementId => _$this._skillRequirementId;
  set skillRequirementId(int? skillRequirementId) =>
      _$this._skillRequirementId = skillRequirementId;

  CreateBookingRequestDtoBuilder() {
    CreateBookingRequestDto._defaults(this);
  }

  CreateBookingRequestDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _showDateId = $v.showDateId;
      _artistId = $v.artistId;
      _skillRequirementId = $v.skillRequirementId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateBookingRequestDto other) {
    _$v = other as _$CreateBookingRequestDto;
  }

  @override
  void update(void Function(CreateBookingRequestDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateBookingRequestDto build() => _build();

  _$CreateBookingRequestDto _build() {
    final _$result = _$v ??
        _$CreateBookingRequestDto._(
          showDateId: BuiltValueNullFieldError.checkNotNull(
              showDateId, r'CreateBookingRequestDto', 'showDateId'),
          artistId: BuiltValueNullFieldError.checkNotNull(
              artistId, r'CreateBookingRequestDto', 'artistId'),
          skillRequirementId: skillRequirementId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
