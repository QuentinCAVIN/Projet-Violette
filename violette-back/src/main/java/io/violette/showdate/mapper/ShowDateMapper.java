package io.violette.showdate.mapper;

import io.violette.showdate.dto.ShowDateDto;
import io.violette.showdate.model.ShowDateEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

/**
 * Convertit ShowDateEntity → ShowDateDto.
 * La compagnie et la revue (nullable) sont aplaties dans le DTO.
 * Les agrégats exposés ({@code displayTitle}, {@code totalRequiredArtists}, {@code selectedCount}) sont fournis par l'appelant.
 */
@Mapper(componentModel = "cdi")
public interface ShowDateMapper {

    @Mapping(target = "companyId", source = "entity.company.id")
    @Mapping(target = "companyName", source = "entity.company.name")
    @Mapping(target = "cabaretShowId", source = "entity.cabaretShow.id")
    @Mapping(target = "cabaretShowTitle", source = "entity.cabaretShow.title")
    @Mapping(target = "location", source = "entity.location")
    @Mapping(target = "displayTitle", source = "displayTitle")
    @Mapping(target = "totalRequiredArtists", source = "totalRequiredArtists")
    @Mapping(target = "selectedCount", source = "selectedCount")
    ShowDateDto toDto(ShowDateEntity entity, String displayTitle, int totalRequiredArtists, int selectedCount);
}
