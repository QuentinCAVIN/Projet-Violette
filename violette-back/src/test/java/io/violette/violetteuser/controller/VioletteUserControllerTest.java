package io.violette.violetteuser.controller;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;

/**
 * Tests HTTP « sans token » sur les endpoints {@code /api/users/me} et {@code /api/users/me/profile}.
 *
 * <p>Stratégie :
 * <ul>
 *   <li>Requête sans en-tête {@code Authorization} : la pile sécurité Quarkus rejette l'accès
 *       aux ressources {@code @Authenticated} (réponse 401 Unauthorized avec le profil test actuel).</li>
 *   <li>Les scénarios avec principal JWT simulé et accès au contrôleur (200 / 404 / 401 applicatif)
 *       sont dans {@link VioletteUserControllerProfileTest}.</li>
 *   <li>Pas de JWT Firebase réel ici : voir le README backend, section « Profil Firebase »,
 *       pour le smoke test manuel avec JWT.</li>
 * </ul>
 */
@QuarkusTest
class VioletteUserControllerTest {

    @Test
    @DisplayName("GET /me sans token retourne 401")
    void getMe_withoutToken_returns401() {
        given()
            .when().get("/api/users/me")
            .then()
                .statusCode(401);
    }

    @Test
    @DisplayName("GET /me/profile sans token retourne 401")
    void getMyProfile_withoutToken_returns401() {
        given()
            .when().get("/api/users/me/profile")
            .then()
                .statusCode(401);
    }
}
