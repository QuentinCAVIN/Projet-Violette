//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'respond_to_booking_request_dto.g.dart';

/// RespondToBookingRequestDto
///
/// Properties:
/// * [accept] 
@BuiltValue()
abstract class RespondToBookingRequestDto implements Built<RespondToBookingRequestDto, RespondToBookingRequestDtoBuilder> {
  @BuiltValueField(wireName: r'accept')
  bool get accept;

  RespondToBookingRequestDto._();

  factory RespondToBookingRequestDto([void updates(RespondToBookingRequestDtoBuilder b)]) = _$RespondToBookingRequestDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RespondToBookingRequestDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RespondToBookingRequestDto> get serializer => _$RespondToBookingRequestDtoSerializer();
}

class _$RespondToBookingRequestDtoSerializer implements PrimitiveSerializer<RespondToBookingRequestDto> {
  @override
  final Iterable<Type> types = const [RespondToBookingRequestDto, _$RespondToBookingRequestDto];

  @override
  final String wireName = r'RespondToBookingRequestDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RespondToBookingRequestDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'accept';
    yield serializers.serialize(
      object.accept,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RespondToBookingRequestDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RespondToBookingRequestDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'accept':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.accept = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RespondToBookingRequestDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RespondToBookingRequestDtoBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

