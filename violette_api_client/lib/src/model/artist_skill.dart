//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'artist_skill.g.dart';

class ArtistSkill extends EnumClass {

  @BuiltValueEnumConst(wireName: r'DANCE')
  static const ArtistSkill DANCE = _$DANCE;
  @BuiltValueEnumConst(wireName: r'SINGING')
  static const ArtistSkill SINGING = _$SINGING;
  @BuiltValueEnumConst(wireName: r'STILT_WALKING')
  static const ArtistSkill STILT_WALKING = _$STILT_WALKING;
  @BuiltValueEnumConst(wireName: r'ACROBATICS')
  static const ArtistSkill ACROBATICS = _$ACROBATICS;

  static Serializer<ArtistSkill> get serializer => _$artistSkillSerializer;

  const ArtistSkill._(String name): super(name);

  static BuiltSet<ArtistSkill> get values => _$values;
  static ArtistSkill valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ArtistSkillMixin = Object with _$ArtistSkillMixin;

