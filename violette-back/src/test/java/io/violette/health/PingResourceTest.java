package io.violette.health;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.regex.Pattern;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.not;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.hamcrest.Matchers.emptyOrNullString;
import static org.hamcrest.Matchers.matchesPattern;

@QuarkusTest
class PingResourceTest {

    /** Format type Semantic Versioning : MAJOR.MINOR.PATCH (suffixe optionnel, ex. -SNAPSHOT). */
    private static final Pattern SEMVER_LIKE = Pattern.compile("\\d+\\.\\d+\\.\\d+.*");

    @Test
    @DisplayName("GET /api/ping retourne 200 avec status pong et une version au format SemVer")
    void ping_returns200WithPongAndSemver() {
        given()
            .when().get("/api/ping")
            .then()
                .statusCode(200)
                .body("status", is("pong"))
                .body("version", not(nullValue()))
                .body("version", not(emptyOrNullString()))
                .body("version", matchesPattern(SEMVER_LIKE));
    }
}
