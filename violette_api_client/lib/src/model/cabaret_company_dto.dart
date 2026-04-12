//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'cabaret_company_dto.g.dart';

/// CabaretCompanyDto
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [description] 
/// * [managerId] 
/// * [managerFirstName] 
/// * [managerLastName] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class CabaretCompanyDto implements Built<CabaretCompanyDto, CabaretCompanyDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  int? get id;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'managerId')
  int? get managerId;

  @BuiltValueField(wireName: r'managerFirstName')
  String? get managerFirstName;

  @BuiltValueField(wireName: r'managerLastName')
  String? get managerLastName;

  @BuiltValueField(wireName: r'createdAt')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime? get updatedAt;

  CabaretCompanyDto._();

  factory CabaretCompanyDto([void updates(CabaretCompanyDtoBuilder b)]) = _$CabaretCompanyDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CabaretCompanyDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CabaretCompanyDto> get serializer => _$CabaretCompanyDtoSerializer();
}

class _$CabaretCompanyDtoSerializer implements PrimitiveSerializer<CabaretCompanyDto> {
  @override
  final Iterable<Type> types = const [CabaretCompanyDto, _$CabaretCompanyDto];

  @override
  final String wireName = r'CabaretCompanyDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CabaretCompanyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(int),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    if (object.managerId != null) {
      yield r'managerId';
      yield serializers.serialize(
        object.managerId,
        specifiedType: const FullType(int),
      );
    }
    if (object.managerFirstName != null) {
      yield r'managerFirstName';
      yield serializers.serialize(
        object.managerFirstName,
        specifiedType: const FullType(String),
      );
    }
    if (object.managerLastName != null) {
      yield r'managerLastName';
      yield serializers.serialize(
        object.managerLastName,
        specifiedType: const FullType(String),
      );
    }
    if (object.createdAt != null) {
      yield r'createdAt';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.updatedAt != null) {
      yield r'updatedAt';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CabaretCompanyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CabaretCompanyDtoBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'managerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.managerId = valueDes;
          break;
        case r'managerFirstName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.managerFirstName = valueDes;
          break;
        case r'managerLastName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.managerLastName = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CabaretCompanyDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CabaretCompanyDtoBuilder();
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

