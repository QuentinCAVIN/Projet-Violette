package io.violette.showdate.controller;

import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.security.TestSecurity;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.security.CurrentUserContextProvider;
import io.violette.security.JwtPrincipalInfo;
import io.violette.showdate.model.ShowDateEntity;
import io.violette.showdate.model.ShowDateStatus;
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
import static org.mockito.Mockito.when;

/**
 * Tests d'autorisation OWASP A01 (Broken Access Control) sur les endpoints de lecture de {@link ShowDateController}.
 * Vérifie qu'un manager ne peut lire que les dates appartenant à SA compagnie.
 *
 * <p>Chaque test crée deux compagnies distinctes (A et B) avec leurs managers.
 * Le principal JWT est simulé via {@link InjectMock} sur {@link CurrentUserContextProvider}.
 */
@QuarkusTest
class ShowDateControllerOwnershipTest {

    @InjectMock
    CurrentUserContextProvider currentUserContextProvider;

    @Inject
    ShowDateRepository showDateRepository;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Inject
    UserTransaction userTransaction;

    // --- GET /api/show-dates/{id} ---

    @Test
    @TestSecurity(user = "ownership-get-ok", roles = {"MANAGER"})
    @DisplayName("GET /show-dates/{id} — manager de la compagnie A lit sa propre date → 200")
    void getById_whenManagerReadsOwnCompanyDate_returns200() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-get-ok");
        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(fx.managerAFirebaseUid, fx.managerAFirebaseUid + "@test.com", "Manager A")));

        try {
            given()
                    .when().get("/api/show-dates/" + fx.showDateAId)
                    .then()
                    .statusCode(200)
                    .body("id", equalTo(fx.showDateAId.intValue()));
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "ownership-get-403", roles = {"MANAGER"})
    @DisplayName("GET /show-dates/{id} — manager de la compagnie A lit une date de la compagnie B → 403")
    void getById_whenManagerReadsOtherCompanyDate_returns403() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-get-403");
        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(fx.managerAFirebaseUid, fx.managerAFirebaseUid + "@test.com", "Manager A")));

        try {
            given()
                    .when().get("/api/show-dates/" + fx.showDateBId)
                    .then()
                    .statusCode(403)
                    .body(equalTo("Accès refusé."));
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "ownership-get-404", roles = {"MANAGER"})
    @DisplayName("GET /show-dates/{id} — date inexistante → 404 (avant la vérification d'ownership)")
    void getById_whenShowDateDoesNotExist_returns404() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-get-404");
        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(fx.managerAFirebaseUid, fx.managerAFirebaseUid + "@test.com", "Manager A")));

        try {
            given()
                    .when().get("/api/show-dates/999999999")
                    .then()
                    .statusCode(404)
                    .body(equalTo("Date de spectacle introuvable."));
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    // --- GET /api/show-dates/company/{companyId} ---

    @Test
    @TestSecurity(user = "ownership-list-ok", roles = {"MANAGER"})
    @DisplayName("GET /show-dates/company/{companyId} — manager A demande les dates de la compagnie A → 200")
    void getByCompanyId_whenManagerRequestsOwnCompany_returns200() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-list-ok");
        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(fx.managerAFirebaseUid, fx.managerAFirebaseUid + "@test.com", "Manager A")));

        try {
            given()
                    .when().get("/api/show-dates/company/" + fx.companyAId)
                    .then()
                    .statusCode(200);
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "ownership-list-403", roles = {"MANAGER"})
    @DisplayName("GET /show-dates/company/{companyId} — manager A demande les dates de la compagnie B → 403")
    void getByCompanyId_whenManagerRequestsOtherCompany_returns403() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-list-403");
        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(fx.managerAFirebaseUid, fx.managerAFirebaseUid + "@test.com", "Manager A")));

        try {
            given()
                    .when().get("/api/show-dates/company/" + fx.companyBId)
                    .then()
                    .statusCode(403)
                    .body(equalTo("Accès refusé."));
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    // --- Fixtures ---

    private record OwnershipFixture(
            Long managerAId,
            String managerAFirebaseUid,
            Long companyAId,
            Long showDateAId,
            Long managerBId,
            Long companyBId,
            Long showDateBId
    ) {
    }

    private OwnershipFixture persistOwnershipFixture(String seed) throws Exception {
        userTransaction.begin();
        try {
            VioletteUserEntity managerA = buildManager(seed + "-mgr-a");
            VioletteUserEntity managerB = buildManager(seed + "-mgr-b");
            violetteUserRepository.persist(managerA);
            violetteUserRepository.persist(managerB);

            CabaretCompanyEntity companyA = buildCompany("Compagnie A " + seed, managerA);
            CabaretCompanyEntity companyB = buildCompany("Compagnie B " + seed, managerB);
            cabaretCompanyRepository.persist(companyA);
            cabaretCompanyRepository.persist(companyB);

            ShowDateEntity showDateA = buildShowDate(companyA, LocalDate.of(2026, 10, 1), seed + " A");
            ShowDateEntity showDateB = buildShowDate(companyB, LocalDate.of(2026, 10, 2), seed + " B");
            showDateRepository.persist(showDateA);
            showDateRepository.persist(showDateB);
            showDateRepository.flush();

            userTransaction.commit();
            return new OwnershipFixture(
                    managerA.getId(),
                    managerA.getFirebaseUid(),
                    companyA.getId(),
                    showDateA.getId(),
                    managerB.getId(),
                    companyB.getId(),
                    showDateB.getId()
            );
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }
    }

    private void deleteOwnershipFixture(OwnershipFixture fx) throws Exception {
        userTransaction.begin();
        try {
            showDateRepository.findByIdOptional(fx.showDateAId).ifPresent(showDateRepository::delete);
            showDateRepository.findByIdOptional(fx.showDateBId).ifPresent(showDateRepository::delete);
            cabaretCompanyRepository.findByIdOptional(fx.companyAId).ifPresent(cabaretCompanyRepository::delete);
            cabaretCompanyRepository.findByIdOptional(fx.companyBId).ifPresent(cabaretCompanyRepository::delete);
            violetteUserRepository.findByIdOptional(fx.managerAId).ifPresent(violetteUserRepository::delete);
            violetteUserRepository.findByIdOptional(fx.managerBId).ifPresent(violetteUserRepository::delete);
            userTransaction.commit();
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }
    }

    private VioletteUserEntity buildManager(String firebaseUid) {
        VioletteUserEntity manager = new VioletteUserEntity();
        manager.setFirebaseUid(firebaseUid);
        manager.setEmail(firebaseUid + "@test.com");
        manager.setFirstName("Manager");
        manager.setLastName("Test");
        manager.setRoles(Set.of(UserRole.MANAGER));
        manager.setSkills(Set.of());
        return manager;
    }

    private CabaretCompanyEntity buildCompany(String name, VioletteUserEntity manager) {
        CabaretCompanyEntity company = new CabaretCompanyEntity();
        company.setName(name);
        company.setManager(manager);
        return company;
    }

    private ShowDateEntity buildShowDate(CabaretCompanyEntity company, LocalDate eventDate, String location) {
        ShowDateEntity showDate = new ShowDateEntity();
        showDate.setCompany(company);
        showDate.setEventDate(eventDate);
        showDate.setMeetingTime(LocalTime.of(20, 0));
        showDate.setLocation("Lieu " + location);
        showDate.setClientContactName("Contact Test");
        showDate.setClientContactPhone("0600000000");
        showDate.setStatus(ShowDateStatus.INQUIRY);
        return showDate;
    }
}
