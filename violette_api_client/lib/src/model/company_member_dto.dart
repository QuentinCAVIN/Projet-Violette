//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'company_member_dto.g.dart';

/// CompanyMemberDto
///
/// Properties:
/// * [companyId] 
/// * [artistId] 
/// * [artistFirstName] 
/// * [artistLastName] 
/// * [joinedAt] 
@BuiltValue()
abstract class CompanyMemberDto implements Built<CompanyMemberDto, CompanyMemberDtoBuilder> {
  @BuiltValueField(wireName: r'companyId')
  int? get companyId;

  @BuiltValueField(wireName: r'artistId')
  int? get artistId;

  @BuiltValueField(wireName: r'artistFirstName')
  String? get artistFirstName;

  @BuiltValueField(wireName: r'artistLastName')
  String? get artistLastName;

  @BuiltValueField(wireName: r'joinedAt')
  DateTime? get joinedAt;

  CompanyMemberDto._();

  factory CompanyMemberDto([void updates(CompanyMemberDtoBuilder b)]) = _$CompanyMemberDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CompanyMemberDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CompanyMemberDto> get serializer => _$CompanyMemberDtoSerializer();
}

class _$CompanyMemberDtoSerializer implements PrimitiveSerializer<CompanyMemberDto> {
  @override
  final Iterable<Type> types = const [CompanyMemberDto, _$CompanyMemberDto];

  @override
  final String wireName = r'CompanyMemberDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CompanyMemberDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.companyId != null) {
      yield r'companyId';
      yield serializers.serialize(
        object.companyId,
        specifiedType: const FullType(int),
      );
    }
    if (object.artistId != null) {
      yield r'artistId';
      yield serializers.serialize(
        object.artistId,
        specifiedType: const FullType(int),
      );
    }
    if (object.artistFirstName != null) {
      yield r'artistFirstName';
      yield serializers.serialize(
        object.artistFirstName,
        specifiedType: const FullType(String),
      );
    }
    if (object.artistLastName != null) {
      yield r'artistLastName';
      yield serializers.serialize(
        object.artistLastName,
        specifiedType: const FullType(String),
      );
    }
    if (object.joinedAt != null) {
      yield r'joinedAt';
      yield serializers.serialize(
        object.joinedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CompanyMemberDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CompanyMemberDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'companyId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.companyId = valueDes;
          break;
        case r'artistId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.artistId = valueDes;
          break;
        case r'artistFirstName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.artistFirstName = valueDes;
          break;
        case r'artistLastName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.artistLastName = valueDes;
          break;
        case r'joinedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.joinedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CompanyMemberDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CompanyMemberDtoBuilder();
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

