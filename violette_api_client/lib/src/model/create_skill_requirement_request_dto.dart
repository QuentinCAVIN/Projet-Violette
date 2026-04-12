//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:violette_api_client/src/model/artist_skill.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_skill_requirement_request_dto.g.dart';

/// CreateSkillRequirementRequestDto
///
/// Properties:
/// * [skill] 
/// * [requiredCount] 
/// * [netFee] 
@BuiltValue()
abstract class CreateSkillRequirementRequestDto implements Built<CreateSkillRequirementRequestDto, CreateSkillRequirementRequestDtoBuilder> {
  @BuiltValueField(wireName: r'skill')
  ArtistSkill get skill;
  // enum skillEnum {  DANCE,  SINGING,  STILT_WALKING,  ACROBATICS,  };

  @BuiltValueField(wireName: r'requiredCount')
  int? get requiredCount;

  @BuiltValueField(wireName: r'netFee')
  num get netFee;

  CreateSkillRequirementRequestDto._();

  factory CreateSkillRequirementRequestDto([void updates(CreateSkillRequirementRequestDtoBuilder b)]) = _$CreateSkillRequirementRequestDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateSkillRequirementRequestDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateSkillRequirementRequestDto> get serializer => _$CreateSkillRequirementRequestDtoSerializer();
}

class _$CreateSkillRequirementRequestDtoSerializer implements PrimitiveSerializer<CreateSkillRequirementRequestDto> {
  @override
  final Iterable<Type> types = const [CreateSkillRequirementRequestDto, _$CreateSkillRequirementRequestDto];

  @override
  final String wireName = r'CreateSkillRequirementRequestDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateSkillRequirementRequestDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'skill';
    yield serializers.serialize(
      object.skill,
      specifiedType: const FullType(ArtistSkill),
    );
    if (object.requiredCount != null) {
      yield r'requiredCount';
      yield serializers.serialize(
        object.requiredCount,
        specifiedType: const FullType(int),
      );
    }
    yield r'netFee';
    yield serializers.serialize(
      object.netFee,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateSkillRequirementRequestDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateSkillRequirementRequestDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'skill':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ArtistSkill),
          ) as ArtistSkill;
          result.skill = valueDes;
          break;
        case r'requiredCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.requiredCount = valueDes;
          break;
        case r'netFee':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.netFee = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateSkillRequirementRequestDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateSkillRequirementRequestDtoBuilder();
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

