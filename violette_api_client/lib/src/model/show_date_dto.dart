//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:violette_api_client/src/model/date.dart';
import 'package:violette_api_client/src/model/show_date_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'show_date_dto.g.dart';

/// ShowDateDto
///
/// Properties:
/// * [id] 
/// * [companyId] 
/// * [companyName] 
/// * [cabaretShowId] 
/// * [cabaretShowTitle] 
/// * [eventDate] 
/// * [meetingTime] 
/// * [venueName] 
/// * [address] 
/// * [clientContactName] 
/// * [clientContactPhone] 
/// * [showDetails] 
/// * [status] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class ShowDateDto implements Built<ShowDateDto, ShowDateDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  int? get id;

  @BuiltValueField(wireName: r'companyId')
  int? get companyId;

  @BuiltValueField(wireName: r'companyName')
  String? get companyName;

  @BuiltValueField(wireName: r'cabaretShowId')
  int? get cabaretShowId;

  @BuiltValueField(wireName: r'cabaretShowTitle')
  String? get cabaretShowTitle;

  @BuiltValueField(wireName: r'eventDate')
  Date? get eventDate;

  @BuiltValueField(wireName: r'meetingTime')
  String? get meetingTime;

  @BuiltValueField(wireName: r'venueName')
  String? get venueName;

  @BuiltValueField(wireName: r'address')
  String? get address;

  @BuiltValueField(wireName: r'clientContactName')
  String? get clientContactName;

  @BuiltValueField(wireName: r'clientContactPhone')
  String? get clientContactPhone;

  @BuiltValueField(wireName: r'showDetails')
  String? get showDetails;

  @BuiltValueField(wireName: r'status')
  ShowDateStatus? get status;
  // enum statusEnum {  PENDING,  OPTIONAL,  CONFIRMED,  LOCKED,  CANCELLED,  };

  @BuiltValueField(wireName: r'createdAt')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime? get updatedAt;

  ShowDateDto._();

  factory ShowDateDto([void updates(ShowDateDtoBuilder b)]) = _$ShowDateDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShowDateDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShowDateDto> get serializer => _$ShowDateDtoSerializer();
}

class _$ShowDateDtoSerializer implements PrimitiveSerializer<ShowDateDto> {
  @override
  final Iterable<Type> types = const [ShowDateDto, _$ShowDateDto];

  @override
  final String wireName = r'ShowDateDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShowDateDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(int),
      );
    }
    if (object.companyId != null) {
      yield r'companyId';
      yield serializers.serialize(
        object.companyId,
        specifiedType: const FullType(int),
      );
    }
    if (object.companyName != null) {
      yield r'companyName';
      yield serializers.serialize(
        object.companyName,
        specifiedType: const FullType(String),
      );
    }
    if (object.cabaretShowId != null) {
      yield r'cabaretShowId';
      yield serializers.serialize(
        object.cabaretShowId,
        specifiedType: const FullType(int),
      );
    }
    if (object.cabaretShowTitle != null) {
      yield r'cabaretShowTitle';
      yield serializers.serialize(
        object.cabaretShowTitle,
        specifiedType: const FullType(String),
      );
    }
    if (object.eventDate != null) {
      yield r'eventDate';
      yield serializers.serialize(
        object.eventDate,
        specifiedType: const FullType(Date),
      );
    }
    if (object.meetingTime != null) {
      yield r'meetingTime';
      yield serializers.serialize(
        object.meetingTime,
        specifiedType: const FullType(String),
      );
    }
    if (object.venueName != null) {
      yield r'venueName';
      yield serializers.serialize(
        object.venueName,
        specifiedType: const FullType(String),
      );
    }
    if (object.address != null) {
      yield r'address';
      yield serializers.serialize(
        object.address,
        specifiedType: const FullType(String),
      );
    }
    if (object.clientContactName != null) {
      yield r'clientContactName';
      yield serializers.serialize(
        object.clientContactName,
        specifiedType: const FullType(String),
      );
    }
    if (object.clientContactPhone != null) {
      yield r'clientContactPhone';
      yield serializers.serialize(
        object.clientContactPhone,
        specifiedType: const FullType(String),
      );
    }
    if (object.showDetails != null) {
      yield r'showDetails';
      yield serializers.serialize(
        object.showDetails,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(ShowDateStatus),
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
    ShowDateDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShowDateDtoBuilder result,
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
        case r'companyId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.companyId = valueDes;
          break;
        case r'companyName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.companyName = valueDes;
          break;
        case r'cabaretShowId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.cabaretShowId = valueDes;
          break;
        case r'cabaretShowTitle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cabaretShowTitle = valueDes;
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShowDateStatus),
          ) as ShowDateStatus;
          result.status = valueDes;
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
  ShowDateDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShowDateDtoBuilder();
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

