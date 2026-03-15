package io.violette.showdate.mapper;

import io.violette.showdate.dto.ShowDateDto;
import io.violette.showdate.model.ShowDateEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

/**
 * Convertit ShowDateEntity → ShowDateDto.
 * La compagnie et la revue (nullable) sont aplaties dans le DTO.
 */
@Mapper(componentModel = "cdi")
public interface ShowDateMapper {

    @Mapping(target = "companyId",       source = "company.id")
    @Mapping(target = "companyName",     source = "company.name")
    @Mapping(target = "cabaretShowId",   source = "cabaretShow.id")
    @Mapping(target = "cabaretShowTitle", source = "cabaretShow.title")
    ShowDateDto toDto(ShowDateEntity entity);
}
