//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:violette_api_client/src/model/artist_skill.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'show_date_skill_requirement_dto.g.dart';

/// ShowDateSkillRequirementDto
///
/// Properties:
/// * [id] 
/// * [showDateId] 
/// * [skill] 
/// * [requiredCount] 
/// * [netFee] 
@BuiltValue()
abstract class ShowDateSkillRequirementDto implements Built<ShowDateSkillRequirementDto, ShowDateSkillRequirementDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  int? get id;

  @BuiltValueField(wireName: r'showDateId')
  int? get showDateId;

  @BuiltValueField(wireName: r'skill')
  ArtistSkill? get skill;
  // enum skillEnum {  DANCE,  SINGING,  STILT_WALKING,  ACROBATICS,  };

  @BuiltValueField(wireName: r'requiredCount')
  int? get requiredCount;

  @BuiltValueField(wireName: r'netFee')
  num? get netFee;

  ShowDateSkillRequirementDto._();

  factory ShowDateSkillRequirementDto([void updates(ShowDateSkillRequirementDtoBuilder b)]) = _$ShowDateSkillRequirementDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShowDateSkillRequirementDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShowDateSkillRequirementDto> get serializer => _$ShowDateSkillRequirementDtoSerializer();
}

class _$ShowDateSkillRequirementDtoSerializer implements PrimitiveSerializer<ShowDateSkillRequirementDto> {
  @override
  final Iterable<Type> types = const [ShowDateSkillRequirementDto, _$ShowDateSkillRequirementDto];

  @override
  final String wireName = r'ShowDateSkillRequirementDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShowDateSkillRequirementDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(int),
      );
    }
    if (object.showDateId != null) {
      yield r'showDateId';
      yield serializers.serialize(
        object.showDateId,
        specifiedType: const FullType(int),
      );
    }
    if (object.skill != null) {
      yield r'skill';
      yield serializers.serialize(
        object.skill,
        specifiedType: const FullType(ArtistSkill),
      );
    }
    if (object.requiredCount != null) {
      yield r'requiredCount';
      yield serializers.serialize(
        object.requiredCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.netFee != null) {
      yield r'netFee';
      yield serializers.serialize(
        object.netFee,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ShowDateSkillRequirementDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShowDateSkillRequirementDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.id = valueDes;
          break;
        case r'showDateId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.showDateId = valueDes;
          break;
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
  ShowDateSkillRequirementDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShowDateSkillRequirementDtoBuilder();
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

