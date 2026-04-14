package io.violette.showdate.controller;

import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.security.TestSecurity;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.security.CurrentUserContextProvider;
import io.violette.security.JwtPrincipalInfo;
import io.violette.showdate.model.ShowDateEntity;
import io.violette.showdate.repository.ArtistAvailabilityRepository;
import io.violette.showdate.repository.ShowDateRepository;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.inject.Inject;
import jakarta.transaction.UserTransaction;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Optional;
import java.util.Set;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.hasSize;
import static org.mockito.Mockito.when;

/**
 * Tests ciblés des endpoints de disponibilités sur {@link ShowDateController}.
 * Les rôles sont simulés via {@link TestSecurity} ; le principal JWT pour {@code PUT .../me}
 * est fourni par un mock de {@link CurrentUserContextProvider}.
 */
@QuarkusTest
class ShowDateControllerAvailabilitiesTest {

    @InjectMock
    CurrentUserContextProvider currentUserContextProvider;

    @Inject
    ShowDateRepository showDateRepository;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    ArtistAvailabilityRepository artistAvailabilityRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Inject
    UserTransaction userTransaction;

    @Test
    @TestSecurity(user = "ctrl-avail-mgr", roles = {"MANAGER"})
    @DisplayName("GET /show-dates/{id}/availabilities en MANAGER retourne 200 et une liste (vide si aucune dispo)")
    void getAvailabilities_whenRoleIsManager_returns200AndList() throws Exception {
        ShowDateFixture fx = persistShowDateFixture("ctrl-avail-get-mgr");

        try {
            given()
                    .when().get("/api/show-dates/" + fx.showDateId + "/availabilities")
                    .then()
                    .statusCode(200)
                    .body("$", hasSize(0));
        } finally {
            deleteFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "ctrl-avail-art-deny", roles = {"ARTIST"})
    @DisplayName("GET /show-dates/{id}/availabilities en ARTIST retourne 403")
    void getAvailabilities_whenRoleIsArtist_returns403() throws Exception {
        ShowDateFixture fx = persistShowDateFixture("ctrl-avail-get-art");

        try {
            given()
                    .when().get("/api/show-dates/" + fx.showDateId + "/availabilities")
                    .then()
                    .statusCode(403);
        } finally {
            deleteFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "ctrl-avail-art-ok", roles = {"ARTIST"})
    @DisplayName("PUT /show-dates/{id}/availabilities/me en ARTIST avec principal JWT retourne 200")
    void upsertMyAvailability_whenRoleIsArtist_returns200() throws Exception {
        ShowDateFixture fx = persistShowDateFixture("ctrl-avail-put-art");
        VioletteUserEntity artist = violetteUserRepository.findByIdOptional(fx.artistId).orElseThrow();
        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(artist.getFirebaseUid(), artist.getEmail(), "Artiste")));

        try {
            given()
                    .contentType("application/json")
                    .body("{\"status\":\"AVAILABLE\"}")
                    .when().put("/api/show-dates/" + fx.showDateId + "/availabilities/me")
                    .then()
                    .statusCode(200)
                    .body("showDateId", equalTo(fx.showDateId.intValue()))
                    .body("artistId", equalTo(fx.artistId.intValue()))
                    .body("status", equalTo("AVAILABLE"));
        } finally {
            deleteFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "ctrl-avail-mgr-deny", roles = {"MANAGER"})
    @DisplayName("PUT /show-dates/{id}/availabilities/me en MANAGER retourne 403")
    void upsertMyAvailability_whenRoleIsManager_returns403() throws Exception {
        ShowDateFixture fx = persistShowDateFixture("ctrl-avail-put-mgr");

        try {
            given()
                    .contentType("application/json")
                    .body("{\"status\":\"AVAILABLE\"}")
                    .when().put("/api/show-dates/" + fx.showDateId + "/availabilities/me")
                    .then()
                    .statusCode(403);
        } finally {
            deleteFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "ctrl-avail-pending", roles = {"ARTIST"})
    @DisplayName("PUT /show-dates/{id}/availabilities/me avec statut PENDING retourne 400")
    void upsertMyAvailability_whenStatusPending_returns400() throws Exception {
        ShowDateFixture fx = persistShowDateFixture("ctrl-avail-pend");
        VioletteUserEntity artist = violetteUserRepository.findByIdOptional(fx.artistId).orElseThrow();
        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(artist.getFirebaseUid(), artist.getEmail(), "X")));

        try {
            given()
                    .contentType("application/json")
                    .body("{\"status\":\"PENDING\"}")
                    .when().put("/api/show-dates/" + fx.showDateId + "/availabilities/me")
                    .then()
                    .statusCode(400);
        } finally {
            deleteFixture(fx);
        }
    }

    private record ShowDateFixture(Long showDateId, Long artistId, Long managerId, Long companyId) {
    }

    private ShowDateFixture persistShowDateFixture(String seed) throws Exception {
        VioletteUserEntity manager = new VioletteUserEntity();
        manager.setFirebaseUid(seed + "-mgr");
        manager.setEmail(seed + "-mgr@test.com");
        manager.setFirstName("Mgr");
        manager.setLastName("Test");
        manager.setRoles(Set.of(UserRole.MANAGER));
        manager.setSkills(Set.of());

        VioletteUserEntity artist = new VioletteUserEntity();
        artist.setFirebaseUid(seed + "-artist");
        artist.setEmail(seed + "-artist@test.com");
        artist.setFirstName("Art");
        artist.setLastName("Iste");
        artist.setRoles(Set.of(UserRole.ARTIST));
        artist.setSkills(Set.of());

        CabaretCompanyEntity company = new CabaretCompanyEntity();
        company.setName("Compagnie " + seed);
        company.setManager(manager);

        ShowDateEntity showDate = new ShowDateEntity();
        showDate.setCompany(company);
        showDate.setEventDate(LocalDate.of(2025, 9, 1));
        showDate.setMeetingTime(LocalTime.of(20, 0));
        showDate.setLocation("Lieu test " + seed);
        showDate.setClientContactName("Contact");
        showDate.setClientContactPhone("0600000000");

        userTransaction.begin();
        try {
            violetteUserRepository.persist(manager);
            violetteUserRepository.persist(artist);
            cabaretCompanyRepository.persist(company);
            showDateRepository.persist(showDate);
            userTransaction.commit();
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }

        return new ShowDateFixture(showDate.getId(), artist.getId(), manager.getId(), company.getId());
    }

    private void deleteFixture(ShowDateFixture fx) throws Exception {
        userTransaction.begin();
        try {
            artistAvailabilityRepository.findByShowDateId(fx.showDateId).forEach(artistAvailabilityRepository::delete);
            showDateRepository.findByIdOptional(fx.showDateId).ifPresent(showDateRepository::delete);
            cabaretCompanyRepository.findByIdOptional(fx.companyId).ifPresent(cabaretCompanyRepository::delete);
            violetteUserRepository.findByIdOptional(fx.managerId).ifPresent(violetteUserRepository::delete);
            violetteUserRepository.findByIdOptional(fx.artistId).ifPresent(violetteUserRepository::delete);
            userTransaction.commit();
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }
    }
}
