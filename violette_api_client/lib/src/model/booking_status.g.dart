// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BookingStatus _$SELECTED = const BookingStatus._('SELECTED');
const BookingStatus _$PENDING_CONFIRMATION =
    const BookingStatus._('PENDING_CONFIRMATION');
const BookingStatus _$CONFIRMED = const BookingStatus._('CONFIRMED');
const BookingStatus _$REFUSED = const BookingStatus._('REFUSED');
const BookingStatus _$CANCELLED = const BookingStatus._('CANCELLED');

BookingStatus _$valueOf(String name) {
  switch (name) {
    case 'SELECTED':
      return _$SELECTED;
    case 'PENDING_CONFIRMATION':
      return _$PENDING_CONFIRMATION;
    case 'CONFIRMED':
      return _$CONFIRMED;
    case 'REFUSED':
      return _$REFUSED;
    case 'CANCELLED':
      return _$CANCELLED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BookingStatus> _$values =
    BuiltSet<BookingStatus>(const <BookingStatus>[
  _$SELECTED,
  _$PENDING_CONFIRMATION,
  _$CONFIRMED,
  _$REFUSED,
  _$CANCELLED,
]);

class _$BookingStatusMeta {
  const _$BookingStatusMeta();
  BookingStatus get SELECTED => _$SELECTED;
  BookingStatus get PENDING_CONFIRMATION => _$PENDING_CONFIRMATION;
  BookingStatus get CONFIRMED => _$CONFIRMED;
  BookingStatus get REFUSED => _$REFUSED;
  BookingStatus get CANCELLED => _$CANCELLED;
  BookingStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<BookingStatus> get values => _$values;
}

abstract class _$BookingStatusMixin {
  // ignore: non_constant_identifier_names
  _$BookingStatusMeta get BookingStatus => const _$BookingStatusMeta();
}

Serializer<BookingStatus> _$bookingStatusSerializer =
    _$BookingStatusSerializer();

class _$BookingStatusSerializer implements PrimitiveSerializer<BookingStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'SELECTED': 'SELECTED',
    'PENDING_CONFIRMATION': 'PENDING_CONFIRMATION',
    'CONFIRMED': 'CONFIRMED',
    'REFUSED': 'REFUSED',
    'CANCELLED': 'CANCELLED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'SELECTED': 'SELECTED',
    'PENDING_CONFIRMATION': 'PENDING_CONFIRMATION',
    'CONFIRMED': 'CONFIRMED',
    'REFUSED': 'REFUSED',
    'CANCELLED': 'CANCELLED',
  };

  @override
  final Iterable<Type> types = const <Type>[BookingStatus];
  @override
  final String wireName = 'BookingStatus';

  @override
  Object serialize(Serializers serializers, BookingStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BookingStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BookingStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
