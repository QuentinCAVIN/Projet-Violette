//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:violette_api_client/src/date_serializer.dart';
import 'package:violette_api_client/src/model/date.dart';

import 'package:violette_api_client/src/model/artist_booking_dto.dart';
import 'package:violette_api_client/src/model/artist_skill.dart';
import 'package:violette_api_client/src/model/authenticated_user_dto.dart';
import 'package:violette_api_client/src/model/booking_status.dart';
import 'package:violette_api_client/src/model/cabaret_company_dto.dart';
import 'package:violette_api_client/src/model/cabaret_show_dto.dart';
import 'package:violette_api_client/src/model/company_member_dto.dart';
import 'package:violette_api_client/src/model/create_booking_request_dto.dart';
import 'package:violette_api_client/src/model/create_show_date_request_dto.dart';
import 'package:violette_api_client/src/model/create_skill_requirement_request_dto.dart';
import 'package:violette_api_client/src/model/create_user_request_dto.dart';
import 'package:violette_api_client/src/model/respond_to_booking_request_dto.dart';
import 'package:violette_api_client/src/model/show_date_dto.dart';
import 'package:violette_api_client/src/model/show_date_skill_requirement_dto.dart';
import 'package:violette_api_client/src/model/show_date_status.dart';
import 'package:violette_api_client/src/model/user_role.dart';
import 'package:violette_api_client/src/model/violette_user_dto.dart';

part 'serializers.g.dart';

@SerializersFor([
  ArtistBookingDto,
  ArtistSkill,
  AuthenticatedUserDto,
  BookingStatus,
  CabaretCompanyDto,
  CabaretShowDto,
  CompanyMemberDto,
  CreateBookingRequestDto,
  CreateShowDateRequestDto,
  CreateSkillRequirementRequestDto,
  CreateUserRequestDto,
  RespondToBookingRequestDto,
  ShowDateDto,
  ShowDateSkillRequirementDto,
  ShowDateStatus,
  UserRole,
  VioletteUserDto,
])
Serializers serializers = (_$serializers.toBuilder()
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
