//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'show_date_status.g.dart';

class ShowDateStatus extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PENDING')
  static const ShowDateStatus PENDING = _$PENDING;
  @BuiltValueEnumConst(wireName: r'OPTIONAL')
  static const ShowDateStatus OPTIONAL = _$OPTIONAL;
  @BuiltValueEnumConst(wireName: r'CONFIRMED')
  static const ShowDateStatus CONFIRMED = _$CONFIRMED;
  @BuiltValueEnumConst(wireName: r'LOCKED')
  static const ShowDateStatus LOCKED = _$LOCKED;
  @BuiltValueEnumConst(wireName: r'CANCELLED')
  static const ShowDateStatus CANCELLED = _$CANCELLED;

  static Serializer<ShowDateStatus> get serializer => _$showDateStatusSerializer;

  const ShowDateStatus._(String name): super(name);

  static BuiltSet<ShowDateStatus> get values => _$values;
  static ShowDateStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ShowDateStatusMixin = Object with _$ShowDateStatusMixin;

