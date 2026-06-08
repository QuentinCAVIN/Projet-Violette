package io.violette.security;

import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.security.exception.ForbiddenCompanyAccessException;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Optional;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

/**
 * Tests unitaires du {@link ManagerCompanyResolver}.
 * Les dépendances sont mockées via {@link InjectMock} pour isoler la logique de résolution.
 */
@QuarkusTest
class ManagerCompanyResolverTest {

    @Inject
    ManagerCompanyResolver managerCompanyResolver;

    @InjectMock
    CurrentUserContextProvider currentUserContextProvider;

    @InjectMock
    VioletteUserRepository violetteUserRepository;

    @InjectMock
    CabaretCompanyRepository cabaretCompanyRepository;

    @Test
    @Transactional
    @DisplayName("resolveCurrentManagerCompany — lève ForbiddenCompanyAccessException si le principal JWT est absent")
    void resolveCurrentManagerCompany_whenPrincipalAbsent_throwsForbiddenCompanyAccessException() {
        when(currentUserContextProvider.getCurrentPrincipal()).thenReturn(Optional.empty());

        assertThrows(ForbiddenCompanyAccessException.class,
                () -> managerCompanyResolver.resolveCurrentManagerCompany());
    }

    @Test
    @Transactional
    @DisplayName("resolveCurrentManagerCompany — lève ForbiddenCompanyAccessException si l'utilisateur backend est introuvable")
    void resolveCurrentManagerCompany_whenUserNotFound_throwsForbiddenCompanyAccessException() {
        String firebaseUid = "uid-resolver-notfound";
        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(firebaseUid, "notfound@test.com", "Ghost")));
        when(violetteUserRepository.findByFirebaseUid(firebaseUid)).thenReturn(Optional.empty());

        assertThrows(ForbiddenCompanyAccessException.class,
                () -> managerCompanyResolver.resolveCurrentManagerCompany());
    }

    @Test
    @Transactional
    @DisplayName("resolveCurrentManagerCompany — lève ForbiddenCompanyAccessException si l'utilisateur n'a pas le rôle MANAGER")
    void resolveCurrentManagerCompany_whenUserHasNoManagerRole_throwsForbiddenCompanyAccessException() {
        String firebaseUid = "uid-resolver-artist";
        VioletteUserEntity artist = buildUser(1L, firebaseUid, Set.of(UserRole.ARTIST));

        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(firebaseUid, "artist@test.com", "Artiste")));
        when(violetteUserRepository.findByFirebaseUid(firebaseUid)).thenReturn(Optional.of(artist));

        assertThrows(ForbiddenCompanyAccessException.class,
                () -> managerCompanyResolver.resolveCurrentManagerCompany());
    }

    @Test
    @Transactional
    @DisplayName("resolveCurrentManagerCompany — lève ForbiddenCompanyAccessException si le manager n'a aucune compagnie")
    void resolveCurrentManagerCompany_whenManagerHasNoCompany_throwsForbiddenCompanyAccessException() {
        String firebaseUid = "uid-resolver-nocompany";
        VioletteUserEntity manager = buildUser(2L, firebaseUid, Set.of(UserRole.MANAGER));

        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(firebaseUid, "manager-nocompany@test.com", "Manager")));
        when(violetteUserRepository.findByFirebaseUid(firebaseUid)).thenReturn(Optional.of(manager));
        when(cabaretCompanyRepository.findByManagerId(2L)).thenReturn(List.of());

        assertThrows(ForbiddenCompanyAccessException.class,
                () -> managerCompanyResolver.resolveCurrentManagerCompany());
    }

    @Test
    @Transactional
    @DisplayName("resolveCurrentManagerCompany — retourne la compagnie du manager authentifié (cas nominal)")
    void resolveCurrentManagerCompany_whenManagerHasCompany_returnsCompany() {
        String firebaseUid = "uid-resolver-nominal";
        VioletteUserEntity manager = buildUser(3L, firebaseUid, Set.of(UserRole.MANAGER));
        CabaretCompanyEntity company = buildCompany(42L, manager);

        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(firebaseUid, "manager@test.com", "Manager")));
        when(violetteUserRepository.findByFirebaseUid(firebaseUid)).thenReturn(Optional.of(manager));
        when(cabaretCompanyRepository.findByManagerId(3L)).thenReturn(List.of(company));

        CabaretCompanyEntity resolved = managerCompanyResolver.resolveCurrentManagerCompany();

        assertNotNull(resolved);
        assertEquals(42L, resolved.getId());
    }

    @Test
    @Transactional
    @DisplayName("resolveCurrentManagerCompanyId — retourne l'identifiant de la compagnie du manager authentifié (cas nominal)")
    void resolveCurrentManagerCompanyId_whenManagerHasCompany_returnsCompanyId() {
        String firebaseUid = "uid-resolver-id-nominal";
        VioletteUserEntity manager = buildUser(4L, firebaseUid, Set.of(UserRole.MANAGER));
        CabaretCompanyEntity company = buildCompany(99L, manager);

        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(firebaseUid, "manager-id@test.com", "Manager")));
        when(violetteUserRepository.findByFirebaseUid(firebaseUid)).thenReturn(Optional.of(manager));
        when(cabaretCompanyRepository.findByManagerId(4L)).thenReturn(List.of(company));

        Long resolvedId = managerCompanyResolver.resolveCurrentManagerCompanyId();

        assertEquals(99L, resolvedId);
    }

    // --- helpers ---

    private VioletteUserEntity buildUser(Long id, String firebaseUid, Set<UserRole> roles) {
        VioletteUserEntity user = new VioletteUserEntity();
        user.setId(id);
        user.setFirebaseUid(firebaseUid);
        user.setEmail(firebaseUid + "@test.com");
        user.setFirstName("Test");
        user.setLastName("User");
        user.setRoles(roles);
        return user;
    }

    private CabaretCompanyEntity buildCompany(Long id, VioletteUserEntity manager) {
        CabaretCompanyEntity company = new CabaretCompanyEntity();
        company.setId(id);
        company.setName("Compagnie Test");
        company.setManager(manager);
        return company;
    }
}
