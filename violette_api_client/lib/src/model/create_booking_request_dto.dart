//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_booking_request_dto.g.dart';

/// CreateBookingRequestDto
///
/// Properties:
/// * [showDateId] 
/// * [artistId] 
/// * [skillRequirementId] 
@BuiltValue()
abstract class CreateBookingRequestDto implements Built<CreateBookingRequestDto, CreateBookingRequestDtoBuilder> {
  @BuiltValueField(wireName: r'showDateId')
  int get showDateId;

  @BuiltValueField(wireName: r'artistId')
  int get artistId;

  @BuiltValueField(wireName: r'skillRequirementId')
  int? get skillRequirementId;

  CreateBookingRequestDto._();

  factory CreateBookingRequestDto([void updates(CreateBookingRequestDtoBuilder b)]) = _$CreateBookingRequestDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateBookingRequestDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateBookingRequestDto> get serializer => _$CreateBookingRequestDtoSerializer();
}

class _$CreateBookingRequestDtoSerializer implements PrimitiveSerializer<CreateBookingRequestDto> {
  @override
  final Iterable<Type> types = const [CreateBookingRequestDto, _$CreateBookingRequestDto];

  @override
  final String wireName = r'CreateBookingRequestDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateBookingRequestDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'showDateId';
    yield serializers.serialize(
      object.showDateId,
      specifiedType: const FullType(int),
    );
    yield r'artistId';
    yield serializers.serialize(
      object.artistId,
      specifiedType: const FullType(int),
    );
    if (object.skillRequirementId != null) {
      yield r'skillRequirementId';
      yield serializers.serialize(
        object.skillRequirementId,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateBookingRequestDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateBookingRequestDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'showDateId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.showDateId = valueDes;
          break;
        case r'artistId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.artistId = valueDes;
          break;
        case r'skillRequirementId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.skillRequirementId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateBookingRequestDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateBookingRequestDtoBuilder();
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

