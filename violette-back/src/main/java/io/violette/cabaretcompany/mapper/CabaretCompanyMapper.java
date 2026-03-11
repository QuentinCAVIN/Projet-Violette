package io.violette.cabaretcompany.mapper;

import io.violette.cabaretcompany.dto.CabaretCompanyDto;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

/** Convertit CabaretCompanyEntity → CabaretCompanyDto. */
@Mapper(componentModel = "cdi")
public interface CabaretCompanyMapper {

    @Mapping(target = "managerId", source = "manager.id")
    @Mapping(target = "managerFirstName", source = "manager.firstName")
    @Mapping(target = "managerLastName", source = "manager.lastName")
    CabaretCompanyDto toDto(CabaretCompanyEntity entity);
}
