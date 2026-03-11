package io.violette.cabaretcompany.mapper;

import io.violette.cabaretcompany.dto.CompanyMemberDto;
import io.violette.cabaretcompany.model.CompanyMemberEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

/** Convertit CompanyMemberEntity → CompanyMemberDto. Les champs de la clé composite sont aplatis. */
@Mapper(componentModel = "cdi")
public interface CompanyMemberMapper {

    @Mapping(target = "companyId", source = "id.companyId")
    @Mapping(target = "artistId", source = "id.artistId")
    @Mapping(target = "artistFirstName", source = "artist.firstName")
    @Mapping(target = "artistLastName", source = "artist.lastName")
    CompanyMemberDto toDto(CompanyMemberEntity entity);
}
