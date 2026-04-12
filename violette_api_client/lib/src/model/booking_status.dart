//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'booking_status.g.dart';

class BookingStatus extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SELECTED')
  static const BookingStatus SELECTED = _$SELECTED;
  @BuiltValueEnumConst(wireName: r'PENDING_CONFIRMATION')
  static const BookingStatus PENDING_CONFIRMATION = _$PENDING_CONFIRMATION;
  @BuiltValueEnumConst(wireName: r'CONFIRMED')
  static const BookingStatus CONFIRMED = _$CONFIRMED;
  @BuiltValueEnumConst(wireName: r'REFUSED')
  static const BookingStatus REFUSED = _$REFUSED;
  @BuiltValueEnumConst(wireName: r'CANCELLED')
  static const BookingStatus CANCELLED = _$CANCELLED;

  static Serializer<BookingStatus> get serializer => _$bookingStatusSerializer;

  const BookingStatus._(String name): super(name);

  static BuiltSet<BookingStatus> get values => _$values;
  static BookingStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class BookingStatusMixin = Object with _$BookingStatusMixin;

