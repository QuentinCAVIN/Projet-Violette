// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'respond_to_booking_request_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RespondToBookingRequestDto extends RespondToBookingRequestDto {
  @override
  final bool accept;

  factory _$RespondToBookingRequestDto(
          [void Function(RespondToBookingRequestDtoBuilder)? updates]) =>
      (RespondToBookingRequestDtoBuilder()..update(updates))._build();

  _$RespondToBookingRequestDto._({required this.accept}) : super._();
  @override
  RespondToBookingRequestDto rebuild(
          void Function(RespondToBookingRequestDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RespondToBookingRequestDtoBuilder toBuilder() =>
      RespondToBookingRequestDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RespondToBookingRequestDto && accept == other.accept;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accept.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RespondToBookingRequestDto')
          ..add('accept', accept))
        .toString();
  }
}

class RespondToBookingRequestDtoBuilder
    implements
        Builder<RespondToBookingRequestDto, RespondToBookingRequestDtoBuilder> {
  _$RespondToBookingRequestDto? _$v;

  bool? _accept;
  bool? get accept => _$this._accept;
  set accept(bool? accept) => _$this._accept = accept;

  RespondToBookingRequestDtoBuilder() {
    RespondToBookingRequestDto._defaults(this);
  }

  RespondToBookingRequestDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accept = $v.accept;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RespondToBookingRequestDto other) {
    _$v = other as _$RespondToBookingRequestDto;
  }

  @override
  void update(void Function(RespondToBookingRequestDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RespondToBookingRequestDto build() => _build();

  _$RespondToBookingRequestDto _build() {
    final _$result = _$v ??
        _$RespondToBookingRequestDto._(
          accept: BuiltValueNullFieldError.checkNotNull(
              accept, r'RespondToBookingRequestDto', 'accept'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
