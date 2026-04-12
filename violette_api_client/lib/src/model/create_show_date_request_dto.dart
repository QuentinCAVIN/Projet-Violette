//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:violette_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_show_date_request_dto.g.dart';

/// CreateShowDateRequestDto
///
/// Properties:
/// * [companyId] 
/// * [cabaretShowId] 
/// * [eventDate] 
/// * [meetingTime] 
/// * [venueName] 
/// * [address] 
/// * [clientContactName] 
/// * [clientContactPhone] 
/// * [showDetails] 
@BuiltValue()
abstract class CreateShowDateRequestDto implements Built<CreateShowDateRequestDto, CreateShowDateRequestDtoBuilder> {
  @BuiltValueField(wireName: r'companyId')
  int get companyId;

  @BuiltValueField(wireName: r'cabaretShowId')
  int? get cabaretShowId;

  @BuiltValueField(wireName: r'eventDate')
  Date get eventDate;

  @BuiltValueField(wireName: r'meetingTime')
  String get meetingTime;

  @BuiltValueField(wireName: r'venueName')
  String? get venueName;

  @BuiltValueField(wireName: r'address')
  String get address;

  @BuiltValueField(wireName: r'clientContactName')
  String get clientContactName;

  @BuiltValueField(wireName: r'clientContactPhone')
  String get clientContactPhone;

  @BuiltValueField(wireName: r'showDetails')
  String? get showDetails;

  CreateShowDateRequestDto._();

  factory CreateShowDateRequestDto([void updates(CreateShowDateRequestDtoBuilder b)]) = _$CreateShowDateRequestDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateShowDateRequestDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateShowDateRequestDto> get serializer => _$CreateShowDateRequestDtoSerializer();
}

class _$CreateShowDateRequestDtoSerializer implements PrimitiveSerializer<CreateShowDateRequestDto> {
  @override
  final Iterable<Type> types = const [CreateShowDateRequestDto, _$CreateShowDateRequestDto];

  @override
  final String wireName = r'CreateShowDateRequestDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateShowDateRequestDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'companyId';
    yield serializers.serialize(
      object.companyId,
      specifiedType: const FullType(int),
    );
    if (object.cabaretShowId != null) {
      yield r'cabaretShowId';
      yield serializers.serialize(
        object.cabaretShowId,
        specifiedType: const FullType(int),
      );
    }
    yield r'eventDate';
    yield serializers.serialize(
      object.eventDate,
      specifiedType: const FullType(Date),
    );
    yield r'meetingTime';
    yield serializers.serialize(
      object.meetingTime,
      specifiedType: const FullType(String),
    );
    if (object.venueName != null) {
      yield r'venueName';
      yield serializers.serialize(
        object.venueName,
        specifiedType: const FullType(String),
      );
    }
    yield r'address';
    yield serializers.serialize(
      object.address,
      specifiedType: const FullType(String),
    );
    yield r'clientContactName';
    yield serializers.serialize(
      object.clientContactName,
      specifiedType: const FullType(String),
    );
    yield r'clientContactPhone';
    yield serializers.serialize(
      object.clientContactPhone,
      specifiedType: const FullType(String),
    );
    if (object.showDetails != null) {
      yield r'showDetails';
      yield serializers.serialize(
        object.showDetails,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateShowDateRequestDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateShowDateRequestDtoBuilder result,
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
        case r'cabaretShowId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.cabaretShowId = valueDes;
          break;
        case r'eventDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.eventDate = valueDes;
          break;
        case r'meetingTime':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.meetingTime = valueDes;
          break;
        case r'venueName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.venueName = valueDes;
          break;
        case r'address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.address = valueDes;
          break;
        case r'clientContactName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientContactName = valueDes;
          break;
        case r'clientContactPhone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientContactPhone = valueDes;
          break;
        case r'showDetails':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.showDetails = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateShowDateRequestDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateShowDateRequestDtoBuilder();
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

