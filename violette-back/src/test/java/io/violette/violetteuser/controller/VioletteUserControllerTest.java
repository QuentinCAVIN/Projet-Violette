package io.violette.violetteuser.controller;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;

/**
 * Tests de protection de l'endpoint GET /api/users/me.
 *
 * <p>Stratégie :
 * <ul>
 *   <li>En profil test OIDC est désactivé : pas de validation JWT, toute requête sans
 *       identité sécurisée valide est rejetée (403 Forbidden par Quarkus).</li>
 *   <li>Ce test vérifie que l'endpoint est protégé (appel non authentifié échoue).</li>
 *   <li>Pas de JWT Firebase réel ici : voir le README backend, section « Profil Firebase »,
 *       pour le smoke test manuel avec JWT.</li>
 * </ul>
 */
@QuarkusTest
class VioletteUserControllerTest {

    @Test
    @DisplayName("GET /me without token returns 403")
    void getMe_withoutToken_returns403() {
        given()
            .when().get("/api/users/me")
            .then()
                .statusCode(403);
    }
}
