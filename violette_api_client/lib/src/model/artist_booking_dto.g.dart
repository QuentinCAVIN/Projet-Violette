// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist_booking_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ArtistBookingDto extends ArtistBookingDto {
  @override
  final int? id;
  @override
  final int? showDateId;
  @override
  final Date? eventDate;
  @override
  final int? artistId;
  @override
  final String? artistFirstName;
  @override
  final String? artistLastName;
  @override
  final int? skillRequirementId;
  @override
  final ArtistSkill? skill;
  @override
  final BookingStatus? status;
  @override
  final num? agreedNetFee;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? requestedAt;
  @override
  final DateTime? respondedAt;

  factory _$ArtistBookingDto(
          [void Function(ArtistBookingDtoBuilder)? updates]) =>
      (ArtistBookingDtoBuilder()..update(updates))._build();

  _$ArtistBookingDto._(
      {this.id,
      this.showDateId,
      this.eventDate,
      this.artistId,
      this.artistFirstName,
      this.artistLastName,
      this.skillRequirementId,
      this.skill,
      this.status,
      this.agreedNetFee,
      this.createdAt,
      this.updatedAt,
      this.requestedAt,
      this.respondedAt})
      : super._();
  @override
  ArtistBookingDto rebuild(void Function(ArtistBookingDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ArtistBookingDtoBuilder toBuilder() =>
      ArtistBookingDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ArtistBookingDto &&
        id == other.id &&
        showDateId == other.showDateId &&
        eventDate == other.eventDate &&
        artistId == other.artistId &&
        artistFirstName == other.artistFirstName &&
        artistLastName == other.artistLastName &&
        skillRequirementId == other.skillRequirementId &&
        skill == other.skill &&
        status == other.status &&
        agreedNetFee == other.agreedNetFee &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        requestedAt == other.requestedAt &&
        respondedAt == other.respondedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, showDateId.hashCode);
    _$hash = $jc(_$hash, eventDate.hashCode);
    _$hash = $jc(_$hash, artistId.hashCode);
    _$hash = $jc(_$hash, artistFirstName.hashCode);
    _$hash = $jc(_$hash, artistLastName.hashCode);
    _$hash = $jc(_$hash, skillRequirementId.hashCode);
    _$hash = $jc(_$hash, skill.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, agreedNetFee.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, requestedAt.hashCode);
    _$hash = $jc(_$hash, respondedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ArtistBookingDto')
          ..add('id', id)
          ..add('showDateId', showDateId)
          ..add('eventDate', eventDate)
          ..add('artistId', artistId)
          ..add('artistFirstName', artistFirstName)
          ..add('artistLastName', artistLastName)
          ..add('skillRequirementId', skillRequirementId)
          ..add('skill', skill)
          ..add('status', status)
          ..add('agreedNetFee', agreedNetFee)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('requestedAt', requestedAt)
          ..add('respondedAt', respondedAt))
        .toString();
  }
}

class ArtistBookingDtoBuilder
    implements Builder<ArtistBookingDto, ArtistBookingDtoBuilder> {
  _$ArtistBookingDto? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  int? _showDateId;
  int? get showDateId => _$this._showDateId;
  set showDateId(int? showDateId) => _$this._showDateId = showDateId;

  Date? _eventDate;
  Date? get eventDate => _$this._eventDate;
  set eventDate(Date? eventDate) => _$this._eventDate = eventDate;

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

  int? _skillRequirementId;
  int? get skillRequirementId => _$this._skillRequirementId;
  set skillRequirementId(int? skillRequirementId) =>
      _$this._skillRequirementId = skillRequirementId;

  ArtistSkill? _skill;
  ArtistSkill? get skill => _$this._skill;
  set skill(ArtistSkill? skill) => _$this._skill = skill;

  BookingStatus? _status;
  BookingStatus? get status => _$this._status;
  set status(BookingStatus? status) => _$this._status = status;

  num? _agreedNetFee;
  num? get agreedNetFee => _$this._agreedNetFee;
  set agreedNetFee(num? agreedNetFee) => _$this._agreedNetFee = agreedNetFee;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DateTime? _requestedAt;
  DateTime? get requestedAt => _$this._requestedAt;
  set requestedAt(DateTime? requestedAt) => _$this._requestedAt = requestedAt;

  DateTime? _respondedAt;
  DateTime? get respondedAt => _$this._respondedAt;
  set respondedAt(DateTime? respondedAt) => _$this._respondedAt = respondedAt;

  ArtistBookingDtoBuilder() {
    ArtistBookingDto._defaults(this);
  }

  ArtistBookingDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _showDateId = $v.showDateId;
      _eventDate = $v.eventDate;
      _artistId = $v.artistId;
      _artistFirstName = $v.artistFirstName;
      _artistLastName = $v.artistLastName;
      _skillRequirementId = $v.skillRequirementId;
      _skill = $v.skill;
      _status = $v.status;
      _agreedNetFee = $v.agreedNetFee;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _requestedAt = $v.requestedAt;
      _respondedAt = $v.respondedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ArtistBookingDto other) {
    _$v = other as _$ArtistBookingDto;
  }

  @override
  void update(void Function(ArtistBookingDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ArtistBookingDto build() => _build();

  _$ArtistBookingDto _build() {
    final _$result = _$v ??
        _$ArtistBookingDto._(
          id: id,
          showDateId: showDateId,
          eventDate: eventDate,
          artistId: artistId,
          artistFirstName: artistFirstName,
          artistLastName: artistLastName,
          skillRequirementId: skillRequirementId,
          skill: skill,
          status: status,
          agreedNetFee: agreedNetFee,
          createdAt: createdAt,
          updatedAt: updatedAt,
          requestedAt: requestedAt,
          respondedAt: respondedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
