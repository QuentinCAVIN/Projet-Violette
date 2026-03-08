package io.violette.violetteuser.repository;

import io.quarkus.test.junit.QuarkusTest;
import io.violette.violetteuser.model.ArtistSkill;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import org.junit.jupiter.api.Test;

import jakarta.inject.Inject;
import jakarta.transaction.Transactional;

import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

@QuarkusTest
class VioletteUserRepositoryTest {

    @Inject
    VioletteUserRepository repository;

    @Test
    @Transactional
    void givenExistingUser_whenFindByFirebaseUid_thenReturnUser() {
        VioletteUserEntity user = buildUser(
                "uid-find-001",
                "repo1@example.com",
                "Alice",
                "Repo",
                Set.of(UserRole.ARTIST),
                Set.of(ArtistSkill.DANCE)
        );
        repository.persistAndFlush(user);

        var found = repository.findByFirebaseUid("uid-find-001");

        assertTrue(found.isPresent());
        VioletteUserEntity result = found.get();

        assertAll(
                () -> assertEquals("uid-find-001", result.getFirebaseUid()),
                () -> assertEquals("repo1@example.com", result.getEmail()),
                () -> assertEquals("Alice", result.getFirstName()),
                () -> assertEquals("Repo", result.getLastName()),
                () -> assertEquals(Set.of(UserRole.ARTIST), result.getRoles()),
                () -> assertEquals(Set.of(ArtistSkill.DANCE), result.getSkills())
        );
    }

    @Test
    @Transactional
    void givenUnknownFirebaseUid_whenFindByFirebaseUid_thenReturnEmpty() {
        var found = repository.findByFirebaseUid("uid-inexistant-12345");
        assertTrue(found.isEmpty());
    }

    @Test
    @Transactional
    void givenExistingUser_whenFindByEmail_thenReturnUser() {
        VioletteUserEntity user = buildUser(
                "uid-email-001",
                "unique-email-repo@example.com",
                "Bob",
                "Email",
                Set.of(UserRole.MANAGER),
                Set.of()
        );
        repository.persistAndFlush(user);

        var found = repository.findByEmail("unique-email-repo@example.com");

        assertTrue(found.isPresent());
        VioletteUserEntity result = found.get();

        assertAll(
                () -> assertEquals("uid-email-001", result.getFirebaseUid()),
                () -> assertEquals("unique-email-repo@example.com", result.getEmail()),
                () -> assertEquals(Set.of(UserRole.MANAGER), result.getRoles())
        );
    }

    @Test
    @Transactional
    void givenUserWithMultipleRolesAndSkills_whenPersisted_thenCollectionsAreStored() {
        VioletteUserEntity user = buildUser(
                "uid-multi-role-001",
                "multi-role@example.com",
                "Jean",
                "Dupont",
                Set.of(UserRole.ARTIST, UserRole.MANAGER),
                Set.of(ArtistSkill.DANCE, ArtistSkill.SINGING)
        );
        repository.persistAndFlush(user);

        var found = repository.findByFirebaseUid("uid-multi-role-001");

        assertTrue(found.isPresent());
        VioletteUserEntity result = found.get();

        assertAll(
                () -> assertEquals(2, result.getRoles().size()),
                () -> assertTrue(result.getRoles().contains(UserRole.ARTIST)),
                () -> assertTrue(result.getRoles().contains(UserRole.MANAGER)),
                () -> assertEquals(2, result.getSkills().size()),
                () -> assertTrue(result.getSkills().contains(ArtistSkill.DANCE)),
                () -> assertTrue(result.getSkills().contains(ArtistSkill.SINGING))
        );
    }

    @Test
    @Transactional
    void givenUnknownEmail_whenFindByEmail_thenReturnEmpty() {
        var found = repository.findByEmail("nobody@nowhere.com");
        assertTrue(found.isEmpty());
    }

    private VioletteUserEntity buildUser(
            String firebaseUid,
            String email,
            String firstName,
            String lastName,
            Set<UserRole> roles,
            Set<ArtistSkill> skills
    ) {
        VioletteUserEntity user = new VioletteUserEntity();
        user.setFirebaseUid(firebaseUid);
        user.setEmail(email);
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setRoles(roles);
        user.setSkills(skills);
        return user;
    }
}
