//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'authenticated_user_dto.g.dart';

/// AuthenticatedUserDto
///
/// Properties:
/// * [firebaseUid] 
/// * [email] 
/// * [name] 
@BuiltValue()
abstract class AuthenticatedUserDto implements Built<AuthenticatedUserDto, AuthenticatedUserDtoBuilder> {
  @BuiltValueField(wireName: r'firebaseUid')
  String? get firebaseUid;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'name')
  String? get name;

  AuthenticatedUserDto._();

  factory AuthenticatedUserDto([void updates(AuthenticatedUserDtoBuilder b)]) = _$AuthenticatedUserDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthenticatedUserDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthenticatedUserDto> get serializer => _$AuthenticatedUserDtoSerializer();
}

class _$AuthenticatedUserDtoSerializer implements PrimitiveSerializer<AuthenticatedUserDto> {
  @override
  final Iterable<Type> types = const [AuthenticatedUserDto, _$AuthenticatedUserDto];

  @override
  final String wireName = r'AuthenticatedUserDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthenticatedUserDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthenticatedUserDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthenticatedUserDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthenticatedUserDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthenticatedUserDtoBuilder();
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

