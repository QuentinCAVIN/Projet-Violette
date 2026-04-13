package io.violette.violetteuser.controller;

import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.InjectMock;
import io.quarkus.test.security.TestSecurity;
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
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.notNullValue;
import static org.mockito.Mockito.when;

/**
 * Tests du happy path et des erreurs métier pour {@code GET /api/users/me/profile} avec
 * authentification simulée : la couche HTTP Quarkus est neutralisée par
 * {@link TestSecurity}{@code (authorizationEnabled = false)} et le principal JWT est fourni
 * via un mock de {@link CurrentUserContextProvider}.
 *
 * <p>Complète {@link VioletteUserControllerTest} (requêtes réelles sans token → 401).
 */
@QuarkusTest
class VioletteUserControllerProfileTest {

    @InjectMock
    CurrentUserContextProvider currentUserContextProvider;

    @Inject
    VioletteUserRepository userRepository;

    @Inject
    UserTransaction userTransaction;

    @Test
    @TestSecurity(authorizationEnabled = false)
    @DisplayName("GET /me/profile avec principal JWT mocké et profil backend existant devrait retourner 200 et le DTO complet")
    void getMyProfile_whenBackendProfileExists_returns200AndFullDto() throws Exception {
        String firebaseUid = "ctrl-profile-exists-001";
        VioletteUserEntity user = new VioletteUserEntity();
        user.setFirebaseUid(firebaseUid);
        user.setEmail("ada.profile@test.com");
        user.setFirstName("Ada");
        user.setLastName("Test");
        user.setRoles(Set.of(UserRole.ARTIST, UserRole.MANAGER));
        user.setSkills(Set.of(ArtistSkill.DANCE));

        // Commit explicite : la requête HTTP s'exécute sur un autre thread et ne voit pas une transaction de test ouverte.
        userTransaction.begin();
        try {
            userRepository.persistAndFlush(user);
            userTransaction.commit();
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }

        try {
            when(currentUserContextProvider.getCurrentPrincipal())
                    .thenReturn(Optional.of(new JwtPrincipalInfo(firebaseUid, "ada.profile@test.com", "Ada T")));

            given()
                    .when().get("/api/users/me/profile")
                    .then()
                    .statusCode(200)
                    .body("id", notNullValue())
                    .body("firebaseUid", equalTo(firebaseUid))
                    .body("email", equalTo("ada.profile@test.com"))
                    .body("firstName", equalTo("Ada"))
                    .body("lastName", equalTo("Test"))
                    .body("roles", containsInAnyOrder("ARTIST", "MANAGER"))
                    .body("skills", containsInAnyOrder("DANCE"));
        } finally {
            userTransaction.begin();
            try {
                userRepository.findByFirebaseUid(firebaseUid).ifPresent(userRepository::delete);
                userTransaction.commit();
            } catch (Exception e) {
                userTransaction.rollback();
                throw e;
            }
        }
    }

    @Test
    @TestSecurity(authorizationEnabled = false)
    @DisplayName("GET /me/profile avec principal JWT mocké et sans profil backend devrait retourner 404")
    void getMyProfile_whenBackendProfileMissing_returns404() {
        String firebaseUid = "ctrl-profile-missing-001";
        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(firebaseUid, "ghost@test.com", "Ghost")));

        given()
                .when().get("/api/users/me/profile")
                .then()
                .statusCode(404)
                .body(equalTo("Utilisateur introuvable."));
    }

    @Test
    @TestSecurity(authorizationEnabled = false)
    @DisplayName("GET /me/profile sans principal JWT (mock vide) devrait retourner 401")
    void getMyProfile_whenJwtPrincipalEmpty_returns401() {
        when(currentUserContextProvider.getCurrentPrincipal()).thenReturn(Optional.empty());

        given()
                .when().get("/api/users/me/profile")
                .then()
                .statusCode(401);
    }
}
