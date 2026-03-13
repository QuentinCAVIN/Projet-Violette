package io.violette.integration;

import io.quarkus.test.TestTransaction;
import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.junit.TestProfile;
import io.violette.violetteuser.model.ArtistSkill;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.inject.Inject;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Optional;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests d'intégration du repository VioletteUser sur MySQL réel (Dev Services).
 * Vérifie la persistance, les contraintes de la base et le comportement des callbacks @PrePersist.
 * Chaque test s'exécute dans une transaction annotée @TestTransaction, annulée en fin de test.
 */
@QuarkusTest
@TestProfile(MySQLIntegrationTestProfile.class)
@DisplayName("VioletteUser — persistance MySQL réelle (Dev Services)")
class VioletteUserRepositoryIT {

    @Inject
    VioletteUserRepository repository;

    @Test
    @TestTransaction
    @DisplayName("Créer un utilisateur et le retrouver par firebaseUid sur MySQL")
    void createAndFindByFirebaseUid_onRealMySQL() {
        VioletteUserEntity user = buildUser("it-uid-001", "it-find@test.com");
        repository.persist(user);

        Optional<VioletteUserEntity> found = repository.findByFirebaseUid("it-uid-001");

        assertTrue(found.isPresent(), "L'utilisateur doit être retrouvable par firebaseUid");
        assertEquals("it-find@test.com", found.get().getEmail());
        assertEquals("Integration", found.get().getFirstName());
    }

    @Test
    @TestTransaction
    @DisplayName("Créer un utilisateur et le retrouver par email sur MySQL")
    void createAndFindByEmail_onRealMySQL() {
        VioletteUserEntity user = buildUser("it-uid-002", "it-email@test.com");
        repository.persist(user);

        Optional<VioletteUserEntity> found = repository.findByEmail("it-email@test.com");

        assertTrue(found.isPresent(), "L'utilisateur doit être retrouvable par email");
        assertEquals("it-uid-002", found.get().getFirebaseUid());
    }

    @Test
    @TestTransaction
    @DisplayName("Les timestamps createdAt et updatedAt sont renseignés automatiquement par @PrePersist")
    void createUser_prePersistSetsTimestamps() {
        VioletteUserEntity user = buildUser("it-uid-timestamps", "it-ts@test.com");
        assertNull(user.getCreatedAt(), "createdAt doit être null avant persist");

        repository.persist(user);

        assertNotNull(user.getCreatedAt(), "createdAt doit être renseigné après persist");
        assertNotNull(user.getUpdatedAt(), "updatedAt doit être renseigné après persist");
        assertEquals(user.getCreatedAt(), user.getUpdatedAt(), "createdAt == updatedAt lors de la création");
    }

    @Test
    @TestTransaction
    @DisplayName("Les rôles et compétences d'un artiste sont persistés via les tables user_role et artist_skill")
    void createArtistWithRolesAndSkills_onRealMySQL() {
        VioletteUserEntity artist = buildUser("it-uid-artist", "it-artist@test.com");
        artist.setRoles(Set.of(UserRole.ARTIST));
        artist.setSkills(Set.of(ArtistSkill.DANCE, ArtistSkill.SINGING));
        repository.persist(artist);

        Optional<VioletteUserEntity> found = repository.findByFirebaseUid("it-uid-artist");

        assertTrue(found.isPresent());
        assertTrue(found.get().getRoles().contains(UserRole.ARTIST),
                "Le rôle ARTIST doit être persisté dans user_role");
        assertEquals(2, found.get().getSkills().size(),
                "Les 2 compétences doivent être persistées dans artist_skill");
    }

    @Test
    @TestTransaction
    @DisplayName("countAll() retourne le nombre correct d'utilisateurs persistés")
    void countAll_returnsCorrectCount() {
        long before = repository.countAll();

        repository.persist(buildUser("it-uid-count1", "it-count1@test.com"));
        repository.persist(buildUser("it-uid-count2", "it-count2@test.com"));

        assertEquals(before + 2, repository.countAll(),
                "countAll() doit refléter les 2 nouveaux utilisateurs créés");
    }

    // ─── utilitaire ───────────────────────────────────────────────────────────

    private VioletteUserEntity buildUser(String firebaseUid, String email) {
        VioletteUserEntity user = new VioletteUserEntity();
        user.setFirebaseUid(firebaseUid);
        user.setEmail(email);
        user.setFirstName("Integration");
        user.setLastName("Test");
        return user;
    }
}
