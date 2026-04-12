// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'show_date_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ShowDateStatus _$PENDING = const ShowDateStatus._('PENDING');
const ShowDateStatus _$OPTIONAL = const ShowDateStatus._('OPTIONAL');
const ShowDateStatus _$CONFIRMED = const ShowDateStatus._('CONFIRMED');
const ShowDateStatus _$LOCKED = const ShowDateStatus._('LOCKED');
const ShowDateStatus _$CANCELLED = const ShowDateStatus._('CANCELLED');

ShowDateStatus _$valueOf(String name) {
  switch (name) {
    case 'PENDING':
      return _$PENDING;
    case 'OPTIONAL':
      return _$OPTIONAL;
    case 'CONFIRMED':
      return _$CONFIRMED;
    case 'LOCKED':
      return _$LOCKED;
    case 'CANCELLED':
      return _$CANCELLED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ShowDateStatus> _$values =
    BuiltSet<ShowDateStatus>(const <ShowDateStatus>[
  _$PENDING,
  _$OPTIONAL,
  _$CONFIRMED,
  _$LOCKED,
  _$CANCELLED,
]);

class _$ShowDateStatusMeta {
  const _$ShowDateStatusMeta();
  ShowDateStatus get PENDING => _$PENDING;
  ShowDateStatus get OPTIONAL => _$OPTIONAL;
  ShowDateStatus get CONFIRMED => _$CONFIRMED;
  ShowDateStatus get LOCKED => _$LOCKED;
  ShowDateStatus get CANCELLED => _$CANCELLED;
  ShowDateStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<ShowDateStatus> get values => _$values;
}

abstract class _$ShowDateStatusMixin {
  // ignore: non_constant_identifier_names
  _$ShowDateStatusMeta get ShowDateStatus => const _$ShowDateStatusMeta();
}

Serializer<ShowDateStatus> _$showDateStatusSerializer =
    _$ShowDateStatusSerializer();

class _$ShowDateStatusSerializer
    implements PrimitiveSerializer<ShowDateStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PENDING': 'PENDING',
    'OPTIONAL': 'OPTIONAL',
    'CONFIRMED': 'CONFIRMED',
    'LOCKED': 'LOCKED',
    'CANCELLED': 'CANCELLED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PENDING': 'PENDING',
    'OPTIONAL': 'OPTIONAL',
    'CONFIRMED': 'CONFIRMED',
    'LOCKED': 'LOCKED',
    'CANCELLED': 'CANCELLED',
  };

  @override
  final Iterable<Type> types = const <Type>[ShowDateStatus];
  @override
  final String wireName = 'ShowDateStatus';

  @override
  Object serialize(Serializers serializers, ShowDateStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ShowDateStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ShowDateStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
