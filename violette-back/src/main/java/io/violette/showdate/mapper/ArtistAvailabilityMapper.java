package io.violette.showdate.mapper;

import io.violette.showdate.dto.ArtistAvailabilityDto;
import io.violette.showdate.model.ArtistAvailabilityEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

/**
 * Convertit ArtistAvailabilityEntity → ArtistAvailabilityDto.
 * Les champs de la clé composite sont aplatis, les noms de l'artiste sont dénormalisés.
 */
@Mapper(componentModel = "cdi")
public interface ArtistAvailabilityMapper {

    @Mapping(target = "showDateId",      source = "id.showDateId")
    @Mapping(target = "artistId",        source = "id.artistId")
    @Mapping(target = "artistFirebaseUid", source = "artist.firebaseUid")
    @Mapping(target = "artistFirstName", source = "artist.firstName")
    @Mapping(target = "artistLastName",  source = "artist.lastName")
    ArtistAvailabilityDto toDto(ArtistAvailabilityEntity entity);
}
