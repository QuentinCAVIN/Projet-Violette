package io.violette.violetteuser.mapper;

import io.quarkus.test.junit.QuarkusTest;
import io.violette.violetteuser.dto.VioletteUserDto;
import io.violette.violetteuser.model.ArtistSkill;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import org.junit.jupiter.api.Test;

import jakarta.inject.Inject;
import java.time.Instant;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

@QuarkusTest
class VioletteUserMapperTest {

    @Inject
    VioletteUserMapper mapper;

    @Test
    void toDto_devraitMapperEntiteVersDto_avecRolesEtSkills() {
        VioletteUserEntity entity = new VioletteUserEntity();
        entity.setId(1L);
        entity.setFirebaseUid("firebase-123");
        entity.setEmail("artist@example.com");
        entity.setFirstName("Jean");
        entity.setLastName("Dupont");
        entity.setRoles(Set.of(UserRole.ARTIST));
        entity.setCreatedAt(Instant.now());
        entity.setUpdatedAt(Instant.now());
        entity.setSkills(Set.of(ArtistSkill.DANCE, ArtistSkill.SINGING));

        VioletteUserDto dto = mapper.toDto(entity);

        assertEquals(1L, dto.id());
        assertEquals("firebase-123", dto.firebaseUid());
        assertEquals("artist@example.com", dto.email());
        assertEquals("Jean", dto.firstName());
        assertEquals("Dupont", dto.lastName());
        assertTrue(dto.roles().contains(UserRole.ARTIST));
        assertEquals(1, dto.roles().size());
        assertTrue(dto.skills().contains(ArtistSkill.DANCE));
        assertTrue(dto.skills().contains(ArtistSkill.SINGING));
        assertEquals(2, dto.skills().size());
    }

    @Test
    void toDto_devraitMapperEntiteAvecPlusieursRoles() {
        VioletteUserEntity entity = new VioletteUserEntity();
        entity.setId(2L);
        entity.setFirebaseUid("firebase-multi");
        entity.setEmail("both@example.com");
        entity.setFirstName("Marie");
        entity.setLastName("Martin");
        entity.setRoles(Set.of(UserRole.ARTIST, UserRole.MANAGER));
        entity.setSkills(Set.of(ArtistSkill.ACROBATICS));

        VioletteUserDto dto = mapper.toDto(entity);

        assertEquals(2, dto.roles().size());
        assertTrue(dto.roles().contains(UserRole.ARTIST));
        assertTrue(dto.roles().contains(UserRole.MANAGER));
        assertEquals(1, dto.skills().size());
    }

    @Test
    void toEntity_devraitMapperDtoVersEntite_avecRolesEtSkills() {
        VioletteUserDto dto = new VioletteUserDto(
                3L,
                "firebase-456",
                "manager@example.com",
                "Marie",
                "Martin",
                Set.of(UserRole.MANAGER),
                Set.of(ArtistSkill.ACROBATICS)
        );

        VioletteUserEntity entity = mapper.toEntity(dto);

        assertEquals(3L, entity.getId());
        assertEquals("firebase-456", entity.getFirebaseUid());
        assertEquals("manager@example.com", entity.getEmail());
        assertEquals("Marie", entity.getFirstName());
        assertEquals("Martin", entity.getLastName());
        assertTrue(entity.getRoles().contains(UserRole.MANAGER));
        assertEquals(1, entity.getRoles().size());
        assertTrue(entity.getSkills().contains(ArtistSkill.ACROBATICS));
        assertEquals(1, entity.getSkills().size());
        assertNull(entity.getCreatedAt());
        assertNull(entity.getUpdatedAt());
    }

    @Test
    void toEntity_devraitMapperDtoAvecPlusieursRoles() {
        VioletteUserDto dto = new VioletteUserDto(
                4L,
                "uid-4",
                "multi@example.com",
                "A",
                "B",
                Set.of(UserRole.ARTIST, UserRole.MANAGER),
                Set.of()
        );

        VioletteUserEntity entity = mapper.toEntity(dto);

        assertEquals(2, entity.getRoles().size());
        assertTrue(entity.getRoles().contains(UserRole.ARTIST));
        assertTrue(entity.getRoles().contains(UserRole.MANAGER));
        assertTrue(entity.getSkills().isEmpty());
    }

    @Test
    void toDto_entiteSansSkills_devraitRetournerSkillsVide() {
        VioletteUserEntity entity = new VioletteUserEntity();
        entity.setId(5L);
        entity.setFirebaseUid("uid-5");
        entity.setEmail("u@x.com");
        entity.setFirstName("A");
        entity.setLastName("B");
        entity.setRoles(Set.of(UserRole.ARTIST));
        entity.setSkills(Set.of());

        VioletteUserDto dto = mapper.toDto(entity);

        assertTrue(dto.roles().contains(UserRole.ARTIST));
        assertTrue(dto.skills().isEmpty());
    }
}
