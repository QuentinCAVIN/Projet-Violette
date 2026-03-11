package io.violette.showdate.mapper;

import io.violette.showdate.dto.ShowDateSkillRequirementDto;
import io.violette.showdate.model.ShowDateSkillRequirementEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

/** Convertit ShowDateSkillRequirementEntity → ShowDateSkillRequirementDto. */
@Mapper(componentModel = "cdi")
public interface ShowDateSkillRequirementMapper {

    @Mapping(target = "showDateId", source = "showDate.id")
    ShowDateSkillRequirementDto toDto(ShowDateSkillRequirementEntity entity);
}
