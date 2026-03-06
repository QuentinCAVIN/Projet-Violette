package io.violette.health;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;

@QuarkusTest
class PingResourceTest {

    @Test
    void pingDevraitRetournerPong() {
        given()
            .when().get("/api/ping")
            .then()
                .statusCode(200)
                .body("status", is("pong"))
                .body("version", is("1.0.0"));
    }
}
