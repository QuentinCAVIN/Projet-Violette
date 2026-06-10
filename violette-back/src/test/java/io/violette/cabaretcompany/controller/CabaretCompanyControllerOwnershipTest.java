package io.violette.cabaretcompany.controller;

import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.security.TestSecurity;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.model.CabaretShowEntity;
import io.violette.cabaretcompany.model.CompanyMemberEntity;
import io.violette.cabaretcompany.model.CompanyMemberId;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.cabaretcompany.repository.CabaretShowRepository;
import io.violette.cabaretcompany.repository.CompanyMemberRepository;
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
 * Tests d'autorisation OWASP A01 (Broken Access Control) sur les endpoints de lecture
 * de {@link CabaretCompanyController}.
 * Vérifie qu'un manager ne peut lire que SA compagnie, ses membres et ses revues.
 *
 * <p>Le principal JWT est simulé via {@link InjectMock} sur {@link CurrentUserContextProvider}
 * (pas de mock du resolver — la résolution compagnie est réelle).
 */
@QuarkusTest
class CabaretCompanyControllerOwnershipTest {

    @InjectMock
    CurrentUserContextProvider currentUserContextProvider;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    CompanyMemberRepository companyMemberRepository;

    @Inject
    CabaretShowRepository cabaretShowRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Inject
    UserTransaction userTransaction;

    // --- GET /api/companies/{id} ---

    @Test
    @TestSecurity(user = "cc-own-get-ok", roles = {"MANAGER"})
    @DisplayName("GET /companies/{id} — manager A lit sa compagnie A → 200")
    void getById_whenManagerReadsOwnCompany_returns200() throws Exception {
        CompanyOwnershipFixture fx = persistCompanyOwnershipFixture("cc-own-get-ok");
        mockManagerA(fx);

        try {
            given()
                    .when().get("/api/companies/" + fx.companyAId)
                    .then()
                    .statusCode(200)
                    .body("id", equalTo(fx.companyAId.intValue()))
                    .body("name", equalTo("Compagnie A cc-own-get-ok"));
        } finally {
            deleteCompanyOwnershipFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "cc-own-get-403", roles = {"MANAGER"})
    @DisplayName("GET /companies/{id} — manager A lit la compagnie B → 403")
    void getById_whenManagerReadsOtherCompany_returns403() throws Exception {
        CompanyOwnershipFixture fx = persistCompanyOwnershipFixture("cc-own-get-403");
        mockManagerA(fx);

        try {
            given()
                    .when().get("/api/companies/" + fx.companyBId)
                    .then()
                    .statusCode(403)
                    .body(equalTo("Accès refusé."));
        } finally {
            deleteCompanyOwnershipFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "cc-own-get-404", roles = {"MANAGER"})
    @DisplayName("GET /companies/{id} — compagnie inexistante → 404 (avant la vérification d'ownership)")
    void getById_whenCompanyDoesNotExist_returns404() throws Exception {
        CompanyOwnershipFixture fx = persistCompanyOwnershipFixture("cc-own-get-404");
        mockManagerA(fx);

        try {
            given()
                    .when().get("/api/companies/999999999")
                    .then()
                    .statusCode(404)
                    .body(equalTo("Compagnie introuvable."));
        } finally {
            deleteCompanyOwnershipFixture(fx);
        }
    }

    // --- GET /api/companies/{id}/members ---

    @Test
    @TestSecurity(user = "cc-own-mem-ok", roles = {"MANAGER"})
    @DisplayName("GET /companies/{id}/members — manager A lit les membres de sa compagnie → 200")
    void getMembers_whenManagerReadsOwnCompanyMembers_returns200() throws Exception {
        CompanyOwnershipFixture fx = persistCompanyOwnershipFixture("cc-own-mem-ok");
        mockManagerA(fx);

        try {
            given()
                    .when().get("/api/companies/" + fx.companyAId + "/members")
                    .then()
                    .statusCode(200);
        } finally {
            deleteCompanyOwnershipFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "cc-own-mem-403", roles = {"MANAGER"})
    @DisplayName("GET /companies/{id}/members — manager A lit les membres de la compagnie B → 403")
    void getMembers_whenManagerReadsOtherCompanyMembers_returns403() throws Exception {
        CompanyOwnershipFixture fx = persistCompanyOwnershipFixture("cc-own-mem-403");
        mockManagerA(fx);

        try {
            given()
                    .when().get("/api/companies/" + fx.companyBId + "/members")
                    .then()
                    .statusCode(403)
                    .body(equalTo("Accès refusé."));
        } finally {
            deleteCompanyOwnershipFixture(fx);
        }
    }

    // --- GET /api/companies/{id}/shows ---

    @Test
    @TestSecurity(user = "cc-own-shw-ok", roles = {"MANAGER"})
    @DisplayName("GET /companies/{id}/shows — manager A lit les revues de sa compagnie → 200")
    void getShows_whenManagerReadsOwnCompanyShows_returns200() throws Exception {
        CompanyOwnershipFixture fx = persistCompanyOwnershipFixture("cc-own-shw-ok");
        mockManagerA(fx);

        try {
            given()
                    .when().get("/api/companies/" + fx.companyAId + "/shows")
                    .then()
                    .statusCode(200);
        } finally {
            deleteCompanyOwnershipFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "cc-own-shw-403", roles = {"MANAGER"})
    @DisplayName("GET /companies/{id}/shows — manager A lit les revues de la compagnie B → 403")
    void getShows_whenManagerReadsOtherCompanyShows_returns403() throws Exception {
        CompanyOwnershipFixture fx = persistCompanyOwnershipFixture("cc-own-shw-403");
        mockManagerA(fx);

        try {
            given()
                    .when().get("/api/companies/" + fx.companyBId + "/shows")
                    .then()
                    .statusCode(403)
                    .body(equalTo("Accès refusé."));
        } finally {
            deleteCompanyOwnershipFixture(fx);
        }
    }

    // --- Fixtures ---

    private void mockManagerA(CompanyOwnershipFixture fx) {
        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(
                        fx.managerAFirebaseUid,
                        fx.managerAFirebaseUid + "@test.com",
                        "Manager A"
                )));
    }

    private record CompanyOwnershipFixture(
            Long managerAId,
            String managerAFirebaseUid,
            Long companyAId,
            Long managerBId,
            Long companyBId,
            Long artistMemberId
    ) {
    }

    private CompanyOwnershipFixture persistCompanyOwnershipFixture(String seed) throws Exception {
        userTransaction.begin();
        try {
            VioletteUserEntity managerA = buildManager(seed + "-mgr-a");
            VioletteUserEntity managerB = buildManager(seed + "-mgr-b");
            VioletteUserEntity artist = buildArtist(seed + "-art");
            violetteUserRepository.persist(managerA);
            violetteUserRepository.persist(managerB);
            violetteUserRepository.persist(artist);

            CabaretCompanyEntity companyA = buildCompany("Compagnie A " + seed, managerA);
            CabaretCompanyEntity companyB = buildCompany("Compagnie B " + seed, managerB);
            cabaretCompanyRepository.persist(companyA);
            cabaretCompanyRepository.persist(companyB);
            cabaretCompanyRepository.flush();

            CompanyMemberEntity membership = new CompanyMemberEntity();
            membership.setId(new CompanyMemberId(companyA.getId(), artist.getId()));
            membership.setCompany(companyA);
            membership.setArtist(artist);
            companyMemberRepository.persist(membership);

            CabaretShowEntity showA = buildShow(companyA, "Revue " + seed);
            cabaretShowRepository.persist(showA);

            cabaretCompanyRepository.flush();

            userTransaction.commit();
            return new CompanyOwnershipFixture(
                    managerA.getId(),
                    managerA.getFirebaseUid(),
                    companyA.getId(),
                    managerB.getId(),
                    companyB.getId(),
                    artist.getId()
            );
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }
    }

    private void deleteCompanyOwnershipFixture(CompanyOwnershipFixture fx) throws Exception {
        userTransaction.begin();
        try {
            cabaretShowRepository.findByCompanyId(fx.companyAId).forEach(cabaretShowRepository::delete);
            cabaretShowRepository.findByCompanyId(fx.companyBId).forEach(cabaretShowRepository::delete);
            companyMemberRepository.findByCompanyId(fx.companyAId).forEach(companyMemberRepository::delete);
            companyMemberRepository.findByCompanyId(fx.companyBId).forEach(companyMemberRepository::delete);
            cabaretCompanyRepository.findByIdOptional(fx.companyAId).ifPresent(cabaretCompanyRepository::delete);
            cabaretCompanyRepository.findByIdOptional(fx.companyBId).ifPresent(cabaretCompanyRepository::delete);
            violetteUserRepository.findByIdOptional(fx.managerAId).ifPresent(violetteUserRepository::delete);
            violetteUserRepository.findByIdOptional(fx.managerBId).ifPresent(violetteUserRepository::delete);
            violetteUserRepository.findByIdOptional(fx.artistMemberId).ifPresent(violetteUserRepository::delete);
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

    private VioletteUserEntity buildArtist(String firebaseUid) {
        VioletteUserEntity artist = new VioletteUserEntity();
        artist.setFirebaseUid(firebaseUid);
        artist.setEmail(firebaseUid + "@test.com");
        artist.setFirstName("Artiste");
        artist.setLastName("Test");
        artist.setRoles(Set.of(UserRole.ARTIST));
        artist.setSkills(Set.of(ArtistSkill.DANCE));
        return artist;
    }

    private CabaretCompanyEntity buildCompany(String name, VioletteUserEntity manager) {
        CabaretCompanyEntity company = new CabaretCompanyEntity();
        company.setName(name);
        company.setDescription("Description " + name);
        company.setManager(manager);
        return company;
    }

    private CabaretShowEntity buildShow(CabaretCompanyEntity company, String title) {
        CabaretShowEntity show = new CabaretShowEntity();
        show.setCompany(company);
        show.setTitle(title);
        show.setDescription("Description " + title);
        return show;
    }
}
