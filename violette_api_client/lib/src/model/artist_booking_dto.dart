//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:violette_api_client/src/model/artist_skill.dart';
import 'package:violette_api_client/src/model/date.dart';
import 'package:violette_api_client/src/model/booking_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'artist_booking_dto.g.dart';

/// ArtistBookingDto
///
/// Properties:
/// * [id] 
/// * [showDateId] 
/// * [eventDate] 
/// * [artistId] 
/// * [artistFirstName] 
/// * [artistLastName] 
/// * [skillRequirementId] 
/// * [skill] 
/// * [status] 
/// * [agreedNetFee] 
/// * [createdAt] 
/// * [updatedAt] 
/// * [requestedAt] 
/// * [respondedAt] 
@BuiltValue()
abstract class ArtistBookingDto implements Built<ArtistBookingDto, ArtistBookingDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  int? get id;

  @BuiltValueField(wireName: r'showDateId')
  int? get showDateId;

  @BuiltValueField(wireName: r'eventDate')
  Date? get eventDate;

  @BuiltValueField(wireName: r'artistId')
  int? get artistId;

  @BuiltValueField(wireName: r'artistFirstName')
  String? get artistFirstName;

  @BuiltValueField(wireName: r'artistLastName')
  String? get artistLastName;

  @BuiltValueField(wireName: r'skillRequirementId')
  int? get skillRequirementId;

  @BuiltValueField(wireName: r'skill')
  ArtistSkill? get skill;
  // enum skillEnum {  DANCE,  SINGING,  STILT_WALKING,  ACROBATICS,  };

  @BuiltValueField(wireName: r'status')
  BookingStatus? get status;
  // enum statusEnum {  SELECTED,  PENDING_CONFIRMATION,  CONFIRMED,  REFUSED,  CANCELLED,  };

  @BuiltValueField(wireName: r'agreedNetFee')
  num? get agreedNetFee;

  @BuiltValueField(wireName: r'createdAt')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: r'requestedAt')
  DateTime? get requestedAt;

  @BuiltValueField(wireName: r'respondedAt')
  DateTime? get respondedAt;

  ArtistBookingDto._();

  factory ArtistBookingDto([void updates(ArtistBookingDtoBuilder b)]) = _$ArtistBookingDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ArtistBookingDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ArtistBookingDto> get serializer => _$ArtistBookingDtoSerializer();
}

class _$ArtistBookingDtoSerializer implements PrimitiveSerializer<ArtistBookingDto> {
  @override
  final Iterable<Type> types = const [ArtistBookingDto, _$ArtistBookingDto];

  @override
  final String wireName = r'ArtistBookingDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ArtistBookingDto object, {
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
    if (object.eventDate != null) {
      yield r'eventDate';
      yield serializers.serialize(
        object.eventDate,
        specifiedType: const FullType(Date),
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
    if (object.skillRequirementId != null) {
      yield r'skillRequirementId';
      yield serializers.serialize(
        object.skillRequirementId,
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
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(BookingStatus),
      );
    }
    if (object.agreedNetFee != null) {
      yield r'agreedNetFee';
      yield serializers.serialize(
        object.agreedNetFee,
        specifiedType: const FullType(num),
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
    if (object.requestedAt != null) {
      yield r'requestedAt';
      yield serializers.serialize(
        object.requestedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.respondedAt != null) {
      yield r'respondedAt';
      yield serializers.serialize(
        object.respondedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ArtistBookingDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ArtistBookingDtoBuilder result,
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
        case r'eventDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.eventDate = valueDes;
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
        case r'skillRequirementId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.skillRequirementId = valueDes;
          break;
        case r'skill':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ArtistSkill),
          ) as ArtistSkill;
          result.skill = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BookingStatus),
          ) as BookingStatus;
          result.status = valueDes;
          break;
        case r'agreedNetFee':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.agreedNetFee = valueDes;
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
        case r'requestedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.requestedAt = valueDes;
          break;
        case r'respondedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.respondedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ArtistBookingDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ArtistBookingDtoBuilder();
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

