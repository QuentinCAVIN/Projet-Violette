//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:violette_api_client/src/model/user_role.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_user_request_dto.g.dart';

/// CreateUserRequestDto
///
/// Properties:
/// * [firstName] 
/// * [lastName] 
/// * [roles] 
@BuiltValue()
abstract class CreateUserRequestDto implements Built<CreateUserRequestDto, CreateUserRequestDtoBuilder> {
  @BuiltValueField(wireName: r'firstName')
  String get firstName;

  @BuiltValueField(wireName: r'lastName')
  String get lastName;

  @BuiltValueField(wireName: r'roles')
  BuiltSet<UserRole>? get roles;

  CreateUserRequestDto._();

  factory CreateUserRequestDto([void updates(CreateUserRequestDtoBuilder b)]) = _$CreateUserRequestDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateUserRequestDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateUserRequestDto> get serializer => _$CreateUserRequestDtoSerializer();
}

class _$CreateUserRequestDtoSerializer implements PrimitiveSerializer<CreateUserRequestDto> {
  @override
  final Iterable<Type> types = const [CreateUserRequestDto, _$CreateUserRequestDto];

  @override
  final String wireName = r'CreateUserRequestDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateUserRequestDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'firstName';
    yield serializers.serialize(
      object.firstName,
      specifiedType: const FullType(String),
    );
    yield r'lastName';
    yield serializers.serialize(
      object.lastName,
      specifiedType: const FullType(String),
    );
    if (object.roles != null) {
      yield r'roles';
      yield serializers.serialize(
        object.roles,
        specifiedType: const FullType(BuiltSet, [FullType(UserRole)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateUserRequestDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateUserRequestDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateUserRequestDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateUserRequestDtoBuilder();
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

