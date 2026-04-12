// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'show_date_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShowDateDto extends ShowDateDto {
  @override
  final int? id;
  @override
  final int? companyId;
  @override
  final String? companyName;
  @override
  final int? cabaretShowId;
  @override
  final String? cabaretShowTitle;
  @override
  final Date? eventDate;
  @override
  final String? meetingTime;
  @override
  final String? venueName;
  @override
  final String? address;
  @override
  final String? clientContactName;
  @override
  final String? clientContactPhone;
  @override
  final String? showDetails;
  @override
  final ShowDateStatus? status;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  factory _$ShowDateDto([void Function(ShowDateDtoBuilder)? updates]) =>
      (ShowDateDtoBuilder()..update(updates))._build();

  _$ShowDateDto._(
      {this.id,
      this.companyId,
      this.companyName,
      this.cabaretShowId,
      this.cabaretShowTitle,
      this.eventDate,
      this.meetingTime,
      this.venueName,
      this.address,
      this.clientContactName,
      this.clientContactPhone,
      this.showDetails,
      this.status,
      this.createdAt,
      this.updatedAt})
      : super._();
  @override
  ShowDateDto rebuild(void Function(ShowDateDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShowDateDtoBuilder toBuilder() => ShowDateDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShowDateDto &&
        id == other.id &&
        companyId == other.companyId &&
        companyName == other.companyName &&
        cabaretShowId == other.cabaretShowId &&
        cabaretShowTitle == other.cabaretShowTitle &&
        eventDate == other.eventDate &&
        meetingTime == other.meetingTime &&
        venueName == other.venueName &&
        address == other.address &&
        clientContactName == other.clientContactName &&
        clientContactPhone == other.clientContactPhone &&
        showDetails == other.showDetails &&
        status == other.status &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, companyId.hashCode);
    _$hash = $jc(_$hash, companyName.hashCode);
    _$hash = $jc(_$hash, cabaretShowId.hashCode);
    _$hash = $jc(_$hash, cabaretShowTitle.hashCode);
    _$hash = $jc(_$hash, eventDate.hashCode);
    _$hash = $jc(_$hash, meetingTime.hashCode);
    _$hash = $jc(_$hash, venueName.hashCode);
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, clientContactName.hashCode);
    _$hash = $jc(_$hash, clientContactPhone.hashCode);
    _$hash = $jc(_$hash, showDetails.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShowDateDto')
          ..add('id', id)
          ..add('companyId', companyId)
          ..add('companyName', companyName)
          ..add('cabaretShowId', cabaretShowId)
          ..add('cabaretShowTitle', cabaretShowTitle)
          ..add('eventDate', eventDate)
          ..add('meetingTime', meetingTime)
          ..add('venueName', venueName)
          ..add('address', address)
          ..add('clientContactName', clientContactName)
          ..add('clientContactPhone', clientContactPhone)
          ..add('showDetails', showDetails)
          ..add('status', status)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class ShowDateDtoBuilder implements Builder<ShowDateDto, ShowDateDtoBuilder> {
  _$ShowDateDto? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  int? _companyId;
  int? get companyId => _$this._companyId;
  set companyId(int? companyId) => _$this._companyId = companyId;

  String? _companyName;
  String? get companyName => _$this._companyName;
  set companyName(String? companyName) => _$this._companyName = companyName;

  int? _cabaretShowId;
  int? get cabaretShowId => _$this._cabaretShowId;
  set cabaretShowId(int? cabaretShowId) =>
      _$this._cabaretShowId = cabaretShowId;

  String? _cabaretShowTitle;
  String? get cabaretShowTitle => _$this._cabaretShowTitle;
  set cabaretShowTitle(String? cabaretShowTitle) =>
      _$this._cabaretShowTitle = cabaretShowTitle;

  Date? _eventDate;
  Date? get eventDate => _$this._eventDate;
  set eventDate(Date? eventDate) => _$this._eventDate = eventDate;

  String? _meetingTime;
  String? get meetingTime => _$this._meetingTime;
  set meetingTime(String? meetingTime) => _$this._meetingTime = meetingTime;

  String? _venueName;
  String? get venueName => _$this._venueName;
  set venueName(String? venueName) => _$this._venueName = venueName;

  String? _address;
  String? get address => _$this._address;
  set address(String? address) => _$this._address = address;

  String? _clientContactName;
  String? get clientContactName => _$this._clientContactName;
  set clientContactName(String? clientContactName) =>
      _$this._clientContactName = clientContactName;

  String? _clientContactPhone;
  String? get clientContactPhone => _$this._clientContactPhone;
  set clientContactPhone(String? clientContactPhone) =>
      _$this._clientContactPhone = clientContactPhone;

  String? _showDetails;
  String? get showDetails => _$this._showDetails;
  set showDetails(String? showDetails) => _$this._showDetails = showDetails;

  ShowDateStatus? _status;
  ShowDateStatus? get status => _$this._status;
  set status(ShowDateStatus? status) => _$this._status = status;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  ShowDateDtoBuilder() {
    ShowDateDto._defaults(this);
  }

  ShowDateDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _companyId = $v.companyId;
      _companyName = $v.companyName;
      _cabaretShowId = $v.cabaretShowId;
      _cabaretShowTitle = $v.cabaretShowTitle;
      _eventDate = $v.eventDate;
      _meetingTime = $v.meetingTime;
      _venueName = $v.venueName;
      _address = $v.address;
      _clientContactName = $v.clientContactName;
      _clientContactPhone = $v.clientContactPhone;
      _showDetails = $v.showDetails;
      _status = $v.status;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShowDateDto other) {
    _$v = other as _$ShowDateDto;
  }

  @override
  void update(void Function(ShowDateDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShowDateDto build() => _build();

  _$ShowDateDto _build() {
    final _$result = _$v ??
        _$ShowDateDto._(
          id: id,
          companyId: companyId,
          companyName: companyName,
          cabaretShowId: cabaretShowId,
          cabaretShowTitle: cabaretShowTitle,
          eventDate: eventDate,
          meetingTime: meetingTime,
          venueName: venueName,
          address: address,
          clientContactName: clientContactName,
          clientContactPhone: clientContactPhone,
          showDetails: showDetails,
          status: status,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
