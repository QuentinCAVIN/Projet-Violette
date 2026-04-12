// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist_skill.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ArtistSkill _$DANCE = const ArtistSkill._('DANCE');
const ArtistSkill _$SINGING = const ArtistSkill._('SINGING');
const ArtistSkill _$STILT_WALKING = const ArtistSkill._('STILT_WALKING');
const ArtistSkill _$ACROBATICS = const ArtistSkill._('ACROBATICS');

ArtistSkill _$valueOf(String name) {
  switch (name) {
    case 'DANCE':
      return _$DANCE;
    case 'SINGING':
      return _$SINGING;
    case 'STILT_WALKING':
      return _$STILT_WALKING;
    case 'ACROBATICS':
      return _$ACROBATICS;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ArtistSkill> _$values =
    BuiltSet<ArtistSkill>(const <ArtistSkill>[
  _$DANCE,
  _$SINGING,
  _$STILT_WALKING,
  _$ACROBATICS,
]);

class _$ArtistSkillMeta {
  const _$ArtistSkillMeta();
  ArtistSkill get DANCE => _$DANCE;
  ArtistSkill get SINGING => _$SINGING;
  ArtistSkill get STILT_WALKING => _$STILT_WALKING;
  ArtistSkill get ACROBATICS => _$ACROBATICS;
  ArtistSkill valueOf(String name) => _$valueOf(name);
  BuiltSet<ArtistSkill> get values => _$values;
}

abstract class _$ArtistSkillMixin {
  // ignore: non_constant_identifier_names
  _$ArtistSkillMeta get ArtistSkill => const _$ArtistSkillMeta();
}

Serializer<ArtistSkill> _$artistSkillSerializer = _$ArtistSkillSerializer();

class _$ArtistSkillSerializer implements PrimitiveSerializer<ArtistSkill> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'DANCE': 'DANCE',
    'SINGING': 'SINGING',
    'STILT_WALKING': 'STILT_WALKING',
    'ACROBATICS': 'ACROBATICS',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'DANCE': 'DANCE',
    'SINGING': 'SINGING',
    'STILT_WALKING': 'STILT_WALKING',
    'ACROBATICS': 'ACROBATICS',
  };

  @override
  final Iterable<Type> types = const <Type>[ArtistSkill];
  @override
  final String wireName = 'ArtistSkill';

  @override
  Object serialize(Serializers serializers, ArtistSkill object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ArtistSkill deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ArtistSkill.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
