// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_show_date_request_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateShowDateRequestDto extends CreateShowDateRequestDto {
  @override
  final int companyId;
  @override
  final int? cabaretShowId;
  @override
  final Date eventDate;
  @override
  final String meetingTime;
  @override
  final String? venueName;
  @override
  final String address;
  @override
  final String clientContactName;
  @override
  final String clientContactPhone;
  @override
  final String? showDetails;

  factory _$CreateShowDateRequestDto(
          [void Function(CreateShowDateRequestDtoBuilder)? updates]) =>
      (CreateShowDateRequestDtoBuilder()..update(updates))._build();

  _$CreateShowDateRequestDto._(
      {required this.companyId,
      this.cabaretShowId,
      required this.eventDate,
      required this.meetingTime,
      this.venueName,
      required this.address,
      required this.clientContactName,
      required this.clientContactPhone,
      this.showDetails})
      : super._();
  @override
  CreateShowDateRequestDto rebuild(
          void Function(CreateShowDateRequestDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateShowDateRequestDtoBuilder toBuilder() =>
      CreateShowDateRequestDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateShowDateRequestDto &&
        companyId == other.companyId &&
        cabaretShowId == other.cabaretShowId &&
        eventDate == other.eventDate &&
        meetingTime == other.meetingTime &&
        venueName == other.venueName &&
        address == other.address &&
        clientContactName == other.clientContactName &&
        clientContactPhone == other.clientContactPhone &&
        showDetails == other.showDetails;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, companyId.hashCode);
    _$hash = $jc(_$hash, cabaretShowId.hashCode);
    _$hash = $jc(_$hash, eventDate.hashCode);
    _$hash = $jc(_$hash, meetingTime.hashCode);
    _$hash = $jc(_$hash, venueName.hashCode);
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, clientContactName.hashCode);
    _$hash = $jc(_$hash, clientContactPhone.hashCode);
    _$hash = $jc(_$hash, showDetails.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateShowDateRequestDto')
          ..add('companyId', companyId)
          ..add('cabaretShowId', cabaretShowId)
          ..add('eventDate', eventDate)
          ..add('meetingTime', meetingTime)
          ..add('venueName', venueName)
          ..add('address', address)
          ..add('clientContactName', clientContactName)
          ..add('clientContactPhone', clientContactPhone)
          ..add('showDetails', showDetails))
        .toString();
  }
}

class CreateShowDateRequestDtoBuilder
    implements
        Builder<CreateShowDateRequestDto, CreateShowDateRequestDtoBuilder> {
  _$CreateShowDateRequestDto? _$v;

  int? _companyId;
  int? get companyId => _$this._companyId;
  set companyId(int? companyId) => _$this._companyId = companyId;

  int? _cabaretShowId;
  int? get cabaretShowId => _$this._cabaretShowId;
  set cabaretShowId(int? cabaretShowId) =>
      _$this._cabaretShowId = cabaretShowId;

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

  CreateShowDateRequestDtoBuilder() {
    CreateShowDateRequestDto._defaults(this);
  }

  CreateShowDateRequestDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _companyId = $v.companyId;
      _cabaretShowId = $v.cabaretShowId;
      _eventDate = $v.eventDate;
      _meetingTime = $v.meetingTime;
      _venueName = $v.venueName;
      _address = $v.address;
      _clientContactName = $v.clientContactName;
      _clientContactPhone = $v.clientContactPhone;
      _showDetails = $v.showDetails;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateShowDateRequestDto other) {
    _$v = other as _$CreateShowDateRequestDto;
  }

  @override
  void update(void Function(CreateShowDateRequestDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateShowDateRequestDto build() => _build();

  _$CreateShowDateRequestDto _build() {
    final _$result = _$v ??
        _$CreateShowDateRequestDto._(
          companyId: BuiltValueNullFieldError.checkNotNull(
              companyId, r'CreateShowDateRequestDto', 'companyId'),
          cabaretShowId: cabaretShowId,
          eventDate: BuiltValueNullFieldError.checkNotNull(
              eventDate, r'CreateShowDateRequestDto', 'eventDate'),
          meetingTime: BuiltValueNullFieldError.checkNotNull(
              meetingTime, r'CreateShowDateRequestDto', 'meetingTime'),
          venueName: venueName,
          address: BuiltValueNullFieldError.checkNotNull(
              address, r'CreateShowDateRequestDto', 'address'),
          clientContactName: BuiltValueNullFieldError.checkNotNull(
              clientContactName,
              r'CreateShowDateRequestDto',
              'clientContactName'),
          clientContactPhone: BuiltValueNullFieldError.checkNotNull(
              clientContactPhone,
              r'CreateShowDateRequestDto',
              'clientContactPhone'),
          showDetails: showDetails,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
