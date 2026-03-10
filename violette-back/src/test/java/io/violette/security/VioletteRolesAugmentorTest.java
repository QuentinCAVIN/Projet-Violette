package io.violette.security;

import io.quarkus.security.runtime.QuarkusSecurityIdentity;
import io.quarkus.test.junit.QuarkusTest;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.security.Principal;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Vérifie que VioletteRolesAugmentor enrichit la SecurityIdentity avec les rôles
 * chargés depuis la base Violette (source de vérité).
 */
@QuarkusTest
class VioletteRolesAugmentorTest {

    @Inject
    VioletteRolesAugmentor violetteRolesAugmentor;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Test
    @Transactional
    @DisplayName("augment adds MANAGER role when user exists in DB with MANAGER")
    void augment_whenUserHasManagerRole_addsManagerToIdentity() {
        String firebaseUid = "uid-augmentor-manager";
        persistUser(firebaseUid, "manager-aug@example.com", "Manager", "User", java.util.Set.of(UserRole.MANAGER));

        Principal principal = () -> firebaseUid;
        var identity = QuarkusSecurityIdentity.builder().setPrincipal(principal).build();

        var augmented = violetteRolesAugmentor.augment(identity);

        assertTrue(augmented.hasRole("MANAGER"));
        assertTrue(augmented.getRoles().contains("MANAGER"));
    }

    @Test
    @Transactional
    @DisplayName("augment adds ARTIST role when user exists in DB with ARTIST only")
    void augment_whenUserHasArtistRoleOnly_addsArtistToIdentity() {
        String firebaseUid = "uid-augmentor-artist";
        persistUser(firebaseUid, "artist-aug@example.com", "Artist", "User", java.util.Set.of(UserRole.ARTIST));

        Principal principal = () -> firebaseUid;
        var identity = QuarkusSecurityIdentity.builder().setPrincipal(principal).build();

        var augmented = violetteRolesAugmentor.augment(identity);

        assertTrue(augmented.hasRole("ARTIST"));
        assertFalse(augmented.hasRole("MANAGER"));
    }

    @Test
    @Transactional
    @DisplayName("augment adds no role when user does not exist in DB")
    void augment_whenUserNotInDb_identityUnchanged() {
        Principal principal = () -> "uid-inexistant-xyz";
        var identity = QuarkusSecurityIdentity.builder().setPrincipal(principal).build();

        var augmented = violetteRolesAugmentor.augment(identity);

        assertFalse(augmented.hasRole("MANAGER"));
        assertFalse(augmented.hasRole("ARTIST"));
        assertTrue(augmented.getRoles().isEmpty());
    }

    private void persistUser(String firebaseUid, String email, String firstName, String lastName,
                            Set<UserRole> roles) {
        VioletteUserEntity entity = new VioletteUserEntity();
        entity.setFirebaseUid(firebaseUid);
        entity.setEmail(email);
        entity.setFirstName(firstName);
        entity.setLastName(lastName);
        entity.setRoles(roles);
        violetteUserRepository.persistAndFlush(entity);
    }
}
