//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:violette_api_client/src/model/artist_skill.dart';
import 'package:built_collection/built_collection.dart';
import 'package:violette_api_client/src/model/user_role.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'violette_user_dto.g.dart';

/// VioletteUserDto
///
/// Properties:
/// * [id] 
/// * [firebaseUid] 
/// * [email] 
/// * [firstName] 
/// * [lastName] 
/// * [roles] 
/// * [skills] 
@BuiltValue()
abstract class VioletteUserDto implements Built<VioletteUserDto, VioletteUserDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  int? get id;

  @BuiltValueField(wireName: r'firebaseUid')
  String? get firebaseUid;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'firstName')
  String? get firstName;

  @BuiltValueField(wireName: r'lastName')
  String? get lastName;

  @BuiltValueField(wireName: r'roles')
  BuiltSet<UserRole>? get roles;

  @BuiltValueField(wireName: r'skills')
  BuiltSet<ArtistSkill>? get skills;

  VioletteUserDto._();

  factory VioletteUserDto([void updates(VioletteUserDtoBuilder b)]) = _$VioletteUserDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VioletteUserDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VioletteUserDto> get serializer => _$VioletteUserDtoSerializer();
}

class _$VioletteUserDtoSerializer implements PrimitiveSerializer<VioletteUserDto> {
  @override
  final Iterable<Type> types = const [VioletteUserDto, _$VioletteUserDto];

  @override
  final String wireName = r'VioletteUserDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VioletteUserDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(int),
      );
    }
    if (object.firebaseUid != null) {
      yield r'firebaseUid';
      yield serializers.serialize(
        object.firebaseUid,
        specifiedType: const FullType(String),
      );
    }
    if (object.email != null) {
      yield r'email';
      yield serializers.serialize(
        object.email,
        specifiedType: const FullType(String),
      );
    }
    if (object.firstName != null) {
      yield r'firstName';
      yield serializers.serialize(
        object.firstName,
        specifiedType: const FullType(String),
      );
    }
    if (object.lastName != null) {
      yield r'lastName';
      yield serializers.serialize(
        object.lastName,
        specifiedType: const FullType(String),
      );
    }
    if (object.roles != null) {
      yield r'roles';
      yield serializers.serialize(
        object.roles,
        specifiedType: const FullType(BuiltSet, [FullType(UserRole)]),
      );
    }
    if (object.skills != null) {
      yield r'skills';
      yield serializers.serialize(
        object.skills,
        specifiedType: const FullType(BuiltSet, [FullType(ArtistSkill)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    VioletteUserDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required VioletteUserDtoBuilder result,
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
        case r'firebaseUid':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.firebaseUid = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'firstName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.firstName = valueDes;
          break;
        case r'lastName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lastName = valueDes;
          break;
        case r'roles':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltSet, [FullType(UserRole)]),
          ) as BuiltSet<UserRole>;
          result.roles.replace(valueDes);
          break;
        case r'skills':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltSet, [FullType(ArtistSkill)]),
          ) as BuiltSet<ArtistSkill>;
          result.skills.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VioletteUserDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VioletteUserDtoBuilder();
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

