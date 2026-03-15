package io.violette.artistbooking.mapper;

import io.violette.artistbooking.dto.ArtistBookingDto;
import io.violette.artistbooking.model.ArtistBookingEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

/**
 * Convertit ArtistBookingEntity → ArtistBookingDto.
 *
 * <p>Les relations imbriquées (showDate, artist, skillRequirement) sont aplaties.
 * Les champs de BookingTimeline (embedded) sont exposés directement dans le DTO.
 * Les sources nullable (skillRequirement.*) sont gérées null-safe par MapStruct.
 */
@Mapper(componentModel = "cdi")
public interface ArtistBookingMapper {

    @Mapping(target = "showDateId",         source = "showDate.id")
    @Mapping(target = "eventDate",          source = "showDate.eventDate")
    @Mapping(target = "artistId",           source = "artist.id")
    @Mapping(target = "artistFirstName",    source = "artist.firstName")
    @Mapping(target = "artistLastName",     source = "artist.lastName")
    @Mapping(target = "skillRequirementId", source = "skillRequirement.id")
    @Mapping(target = "skill",              source = "skillRequirement.skill")
    @Mapping(target = "createdAt",          source = "timeline.createdAt")
    @Mapping(target = "updatedAt",          source = "timeline.updatedAt")
    @Mapping(target = "requestedAt",        source = "timeline.requestedAt")
    @Mapping(target = "respondedAt",        source = "timeline.respondedAt")
    ArtistBookingDto toDto(ArtistBookingEntity entity);
}
