package io.violette.violetteuser.repository;

import io.quarkus.test.junit.QuarkusTest;
import io.violette.violetteuser.model.ArtistSkill;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import org.junit.jupiter.api.Test;

import jakarta.inject.Inject;
import jakarta.transaction.Transactional;

import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

@QuarkusTest
class VioletteUserRepositoryTest {

    @Inject
    VioletteUserRepository repository;

    @Test
    @Transactional
    void findByFirebaseUid_devraitRetournerUtilisateurQuandPresent() {
        VioletteUserEntity user = new VioletteUserEntity();
        user.setFirebaseUid("test-uid-repo-1");
        user.setEmail("repo1@example.com");
        user.setFirstName("Alice");
        user.setLastName("Repo");
        user.setRoles(Set.of(UserRole.ARTIST));
        user.setSkills(Set.of(ArtistSkill.DANCE));
        repository.persist(user);

        var found = repository.findByFirebaseUid("test-uid-repo-1");

        assertTrue(found.isPresent());
        assertEquals("repo1@example.com", found.get().getEmail());
        assertTrue(found.get().getRoles().contains(UserRole.ARTIST));
        assertTrue(found.get().getSkills().contains(ArtistSkill.DANCE));
    }

    @Test
    @Transactional
    void findByFirebaseUid_devraitRetournerVideQuandAbsent() {
        var found = repository.findByFirebaseUid("uid-inexistant-12345");
        assertTrue(found.isEmpty());
    }

    @Test
    @Transactional
    void findByEmail_devraitRetournerUtilisateurQuandPresent() {
        VioletteUserEntity user = new VioletteUserEntity();
        user.setFirebaseUid("test-uid-email");
        user.setEmail("unique-email-repo@example.com");
        user.setFirstName("Bob");
        user.setLastName("Email");
        user.setRoles(Set.of(UserRole.MANAGER));
        repository.persist(user);

        var found = repository.findByEmail("unique-email-repo@example.com");

        assertTrue(found.isPresent());
        assertEquals("test-uid-email", found.get().getFirebaseUid());
        assertTrue(found.get().getRoles().contains(UserRole.MANAGER));
    }

    @Test
    @Transactional
    void persist_devraitPersisterPlusieursRoles() {
        VioletteUserEntity user = new VioletteUserEntity();
        user.setFirebaseUid("test-uid-multi-role");
        user.setEmail("multi-role@example.com");
        user.setFirstName("Jean");
        user.setLastName("Dupont");
        user.setRoles(Set.of(UserRole.ARTIST, UserRole.MANAGER));
        user.setSkills(Set.of(ArtistSkill.DANCE, ArtistSkill.SINGING));
        repository.persist(user);

        var found = repository.findByFirebaseUid("test-uid-multi-role");

        assertTrue(found.isPresent());
        assertEquals(2, found.get().getRoles().size());
        assertTrue(found.get().getRoles().contains(UserRole.ARTIST));
        assertTrue(found.get().getRoles().contains(UserRole.MANAGER));
        assertEquals(2, found.get().getSkills().size());
    }

    @Test
    @Transactional
    void findByEmail_devraitRetournerVideQuandAbsent() {
        var found = repository.findByEmail("nobody@nowhere.com");
        assertTrue(found.isEmpty());
    }
}
