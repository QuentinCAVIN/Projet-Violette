package io.violette.cabaretcompany.controller;

import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.security.TestSecurity;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.security.CurrentUserContextProvider;
import io.violette.security.JwtPrincipalInfo;
import io.violette.violetteuser.model.ArtistSkill;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.inject.Inject;
import jakarta.transaction.UserTransaction;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Optional;
import java.util.Set;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.mockito.Mockito.when;

/**
 * Tests de {@code GET /api/companies/mine} : même schéma que {@link io.violette.violetteuser.controller.VioletteUserControllerProfileTest}
 * (sécurité neutralisée + principal JWT mocké + commit explicite pour visibilité HTTP).
 */
@QuarkusTest
class CabaretCompanyControllerMineTest {

    @InjectMock
    CurrentUserContextProvider currentUserContextProvider;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    UserTransaction userTransaction;

    @Test
    @TestSecurity(authorizationEnabled = false)
    @DisplayName("GET /companies/mine avec manager et une compagnie en base retourne 200 et l'objet compagnie")
    void getMine_whenManagerHasCompany_returns200AndDto() throws Exception {
        String firebaseUid = "ctrl-companies-mine-ok";
        VioletteUserEntity manager = buildUser(firebaseUid, "mine.ok@test.com", Set.of(UserRole.MANAGER));

        userTransaction.begin();
        try {
            violetteUserRepository.persistAndFlush(manager);
            CabaretCompanyEntity company = new CabaretCompanyEntity();
            company.setName("Compagnie Alpha");
            company.setDescription("Description");
            company.setManager(manager);
            cabaretCompanyRepository.persistAndFlush(company);
            userTransaction.commit();
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }

        try {
            when(currentUserContextProvider.getCurrentPrincipal())
                    .thenReturn(Optional.of(new JwtPrincipalInfo(firebaseUid, "mine.ok@test.com", "Mgr")));

            given()
                    .when().get("/api/companies/mine")
                    .then()
                    .statusCode(200)
                    .body("name", equalTo("Compagnie Alpha"))
                    .body("description", equalTo("Description"));
        } finally {
            userTransaction.begin();
            try {
                violetteUserRepository.findByFirebaseUid(firebaseUid).ifPresent(u -> {
                    cabaretCompanyRepository.findByManagerId(u.getId()).forEach(cabaretCompanyRepository::delete);
                    violetteUserRepository.delete(u);
                });
                userTransaction.commit();
            } catch (Exception e) {
                userTransaction.rollback();
                throw e;
            }
        }
    }

    @Test
    @TestSecurity(authorizationEnabled = false)
    @DisplayName("GET /companies/mine avec manager sans compagnie retourne 404")
    void getMine_whenManagerHasNoCompany_returns404() throws Exception {
        String firebaseUid = "ctrl-companies-mine-empty";
        VioletteUserEntity manager = buildUser(firebaseUid, "mine.empty@test.com", Set.of(UserRole.MANAGER));

        userTransaction.begin();
        try {
            violetteUserRepository.persistAndFlush(manager);
            userTransaction.commit();
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }

        try {
            when(currentUserContextProvider.getCurrentPrincipal())
                    .thenReturn(Optional.of(new JwtPrincipalInfo(firebaseUid, "mine.empty@test.com", "Mgr")));

            given()
                    .when().get("/api/companies/mine")
                    .then()
                    .statusCode(404)
                    .body(equalTo("Compagnie introuvable."));
        } finally {
            userTransaction.begin();
            try {
                violetteUserRepository.findByFirebaseUid(firebaseUid).ifPresent(violetteUserRepository::delete);
                userTransaction.commit();
            } catch (Exception e) {
                userTransaction.rollback();
                throw e;
            }
        }
    }

    @Test
    @TestSecurity(authorizationEnabled = false)
    @DisplayName("GET /companies/mine sans profil backend pour le JWT retourne 404")
    void getMine_whenBackendProfileMissing_returns404() {
        String firebaseUid = "ctrl-companies-mine-noprofile";
        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(firebaseUid, "ghost@test.com", "Ghost")));

        given()
                .when().get("/api/companies/mine")
                .then()
                .statusCode(404)
                .body(equalTo("Utilisateur introuvable."));
    }

    @Test
    @TestSecurity(authorizationEnabled = false)
    @DisplayName("GET /companies/mine sans principal JWT retourne 401")
    void getMine_whenJwtPrincipalEmpty_returns401() {
        when(currentUserContextProvider.getCurrentPrincipal()).thenReturn(Optional.empty());

        given()
                .when().get("/api/companies/mine")
                .then()
                .statusCode(401);
    }

    @Test
    @TestSecurity(user = "ctrl-companies-mine-artist", roles = {"ARTIST"})
    @DisplayName("GET /companies/mine en ARTIST retourne 403")
    void getMine_whenRoleIsArtist_returns403() {
        given()
                .when().get("/api/companies/mine")
                .then()
                .statusCode(403);
    }

    private VioletteUserEntity buildUser(String firebaseUid, String email, Set<UserRole> roles) {
        VioletteUserEntity user = new VioletteUserEntity();
        user.setFirebaseUid(firebaseUid);
        user.setEmail(email);
        user.setFirstName("Test");
        user.setLastName("Manager");
        user.setRoles(roles);
        user.setSkills(Set.of(ArtistSkill.DANCE));
        return user;
    }
}
