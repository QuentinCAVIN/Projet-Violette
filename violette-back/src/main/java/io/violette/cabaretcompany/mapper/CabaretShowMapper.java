package io.violette.cabaretcompany.mapper;

import io.violette.cabaretcompany.dto.CabaretShowDto;
import io.violette.cabaretcompany.model.CabaretShowEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

/** Convertit CabaretShowEntity (table "revue") → CabaretShowDto. */
@Mapper(componentModel = "cdi")
public interface CabaretShowMapper {

    @Mapping(target = "companyId", source = "company.id")
    CabaretShowDto toDto(CabaretShowEntity entity);
}
