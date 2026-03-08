package io.violette.violetteuser.mapper;

import io.violette.violetteuser.dto.VioletteUserDto;
import io.violette.violetteuser.model.VioletteUserEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

/** Convertit VioletteUserEntity ↔ VioletteUserDto. */
@Mapper(componentModel = "default")
public interface VioletteUserMapper {

    VioletteUserDto toDto(VioletteUserEntity entity);

    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    VioletteUserEntity toEntity(VioletteUserDto dto);
}
