package io.violette.artistbooking.controller;

import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.security.TestSecurity;
import io.violette.artistbooking.model.ArtistBookingEntity;
import io.violette.artistbooking.model.BookingStatus;
import io.violette.artistbooking.repository.ArtistBookingRepository;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.security.CurrentUserContextProvider;
import io.violette.security.JwtPrincipalInfo;
import io.violette.showdate.model.ArtistAvailabilityEntity;
import io.violette.showdate.model.ArtistAvailabilityId;
import io.violette.showdate.model.AvailabilityStatus;
import io.violette.showdate.model.ShowDateEntity;
import io.violette.showdate.model.ShowDateSkillRequirementEntity;
import io.violette.showdate.model.ShowDateStatus;
import io.violette.showdate.repository.ArtistAvailabilityRepository;
import io.violette.showdate.repository.ShowDateRepository;
import io.violette.showdate.repository.ShowDateSkillRequirementRepository;
import io.violette.violetteuser.model.ArtistSkill;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.inject.Inject;
import jakarta.transaction.UserTransaction;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Optional;
import java.util.Set;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

/**
 * Tests d'autorisation OWASP A01 (Broken Access Control) sur {@link ArtistBookingController}.
 * Vérifie qu'un manager ne peut agir que sur les bookings des dates de SA compagnie,
 * et qu'un artiste ne peut répondre qu'à SES propres bookings.
 *
 * <p>Le principal JWT est simulé via {@link InjectMock} sur {@link CurrentUserContextProvider}
 * (pas de mock du resolver — la résolution compagnie est réelle).
 */
@QuarkusTest
class ArtistBookingControllerOwnershipTest {

    @InjectMock
    CurrentUserContextProvider currentUserContextProvider;

    @Inject
    ArtistBookingRepository artistBookingRepository;

    @Inject
    ArtistAvailabilityRepository artistAvailabilityRepository;

    @Inject
    ShowDateSkillRequirementRepository showDateSkillRequirementRepository;

    @Inject
    ShowDateRepository showDateRepository;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Inject
    UserTransaction userTransaction;

    // --- POST /api/artist-bookings ---

    @Test
    @TestSecurity(user = "bk-own-create-ok", roles = {"MANAGER"})
    @DisplayName("POST /artist-bookings — manager A sélectionne un artiste sur date compagnie A → 201")
    void createBooking_whenManagerCreatesForOwnCompanyShowDate_returns201() throws Exception {
        BookingOwnershipFixture fx = persistBookingOwnershipFixture("bk-own-create-ok", false);
        mockManagerA(fx);

        try {
            given()
                    .contentType("application/json")
                    .body("""
                            {
                              "showDateId": %d,
                              "artistId": %d,
                              "skillRequirementId": %d
                            }
                            """.formatted(fx.showDateOptionAId, fx.artistId, fx.skillReqOptionAId))
                    .when().post("/api/artist-bookings")
                    .then()
                    .statusCode(201)
                    .body("showDateId", equalTo(fx.showDateOptionAId.intValue()))
                    .body("status", equalTo("SELECTED"));
        } finally {
            deleteBookingOwnershipFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "bk-own-create-403", roles = {"MANAGER"})
    @DisplayName("POST /artist-bookings — manager A tente de sélectionner sur date compagnie B → 403")
    void createBooking_whenManagerCreatesForOtherCompanyShowDate_returns403AndNoBookingCreated() throws Exception {
        BookingOwnershipFixture fx = persistBookingOwnershipFixture("bk-own-create-403", false);
        mockManagerA(fx);
        long bookingsOnBBefore = countBookingsForShowDate(fx.showDateOptionBId);

        try {
            given()
                    .contentType("application/json")
                    .body("""
                            {
                              "showDateId": %d,
                              "artistId": %d,
                              "skillRequirementId": %d
                            }
                            """.formatted(fx.showDateOptionBId, fx.artistId, fx.skillReqOptionBId))
                    .when().post("/api/artist-bookings")
                    .then()
                    .statusCode(403)
                    .body(equalTo("Accès refusé."));

            assertEquals(bookingsOnBBefore, countBookingsForShowDate(fx.showDateOptionBId));
        } finally {
            deleteBookingOwnershipFixture(fx);
        }
    }

    // --- DELETE /api/artist-bookings/{id} ---

    @Test
    @TestSecurity(user = "bk-own-del-ok", roles = {"MANAGER"})
    @DisplayName("DELETE /artist-bookings/{id} — manager A supprime un booking de sa compagnie → 204")
    void deleteBooking_whenManagerDeletesOwnCompanyBooking_returns204() throws Exception {
        BookingOwnershipFixture fx = persistBookingOwnershipFixture("bk-own-del-ok", true);
        mockManagerA(fx);

        try {
            given()
                    .when().delete("/api/artist-bookings/" + fx.bookingOnAId)
                    .then()
                    .statusCode(204);

            assertEquals(0, countBookingById(fx.bookingOnAId));
        } finally {
            deleteBookingOwnershipFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "bk-own-del-403", roles = {"MANAGER"})
    @DisplayName("DELETE /artist-bookings/{id} — manager A tente de supprimer un booking compagnie B → 403")
    void deleteBooking_whenManagerDeletesOtherCompanyBooking_returns403AndBookingRemains() throws Exception {
        BookingOwnershipFixture fx = persistBookingOwnershipFixture("bk-own-del-403", true);
        mockManagerA(fx);

        try {
            given()
                    .when().delete("/api/artist-bookings/" + fx.bookingOnBId)
                    .then()
                    .statusCode(403)
                    .body(equalTo("Accès refusé."));

            assertEquals(1, countBookingById(fx.bookingOnBId));
        } finally {
            deleteBookingOwnershipFixture(fx);
        }
    }

    // --- POST /api/artist-bookings/show-dates/{showDateId}/send-confirmations ---

    @Test
    @TestSecurity(user = "bk-own-send-ok", roles = {"MANAGER"})
    @DisplayName("POST /artist-bookings/show-dates/{id}/send-confirmations — manager A sur date A → 200")
    void sendConfirmationRequests_whenManagerSendsForOwnCompanyShowDate_returns200() throws Exception {
        BookingOwnershipFixture fx = persistBookingOwnershipFixture("bk-own-send-ok", false);
        mockManagerA(fx);

        try {
            given()
                    .when().post("/api/artist-bookings/show-dates/" + fx.showDateConfirmedAId + "/send-confirmations")
                    .then()
                    .statusCode(200);
        } finally {
            deleteBookingOwnershipFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "bk-own-send-403", roles = {"MANAGER"})
    @DisplayName("POST /artist-bookings/show-dates/{id}/send-confirmations — manager A sur date B → 403")
    void sendConfirmationRequests_whenManagerSendsForOtherCompanyShowDate_returns403() throws Exception {
        BookingOwnershipFixture fx = persistBookingOwnershipFixture("bk-own-send-403", false);
        mockManagerA(fx);

        try {
            given()
                    .when().post("/api/artist-bookings/show-dates/" + fx.showDateConfirmedBId + "/send-confirmations")
                    .then()
                    .statusCode(403)
                    .body(equalTo("Accès refusé."));
        } finally {
            deleteBookingOwnershipFixture(fx);
        }
    }

    // --- GET /api/artist-bookings/show-dates/{showDateId} ---

    @Test
    @TestSecurity(user = "bk-own-list-ok", roles = {"MANAGER"})
    @DisplayName("GET /artist-bookings/show-dates/{id} — manager A lit les bookings de sa date → 200")
    void getBookingsForShowDate_whenManagerReadsOwnCompanyShowDate_returns200() throws Exception {
        BookingOwnershipFixture fx = persistBookingOwnershipFixture("bk-own-list-ok", false);
        mockManagerA(fx);

        try {
            given()
                    .when().get("/api/artist-bookings/show-dates/" + fx.showDateOptionAId)
                    .then()
                    .statusCode(200);
        } finally {
            deleteBookingOwnershipFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "bk-own-list-403", roles = {"MANAGER"})
    @DisplayName("GET /artist-bookings/show-dates/{id} — manager A lit les bookings d'une date B → 403")
    void getBookingsForShowDate_whenManagerReadsOtherCompanyShowDate_returns403() throws Exception {
        BookingOwnershipFixture fx = persistBookingOwnershipFixture("bk-own-list-403", false);
        mockManagerA(fx);

        try {
            given()
                    .when().get("/api/artist-bookings/show-dates/" + fx.showDateOptionBId)
                    .then()
                    .statusCode(403)
                    .body(equalTo("Accès refusé."));
        } finally {
            deleteBookingOwnershipFixture(fx);
        }
    }

    // --- PATCH /api/artist-bookings/{id}/respond (ARTIST) ---

    @Test
    @TestSecurity(user = "bk-own-resp-ok", roles = {"ARTIST"})
    @DisplayName("PATCH /artist-bookings/{id}/respond — artiste destinataire accepte → 200 CONFIRMED")
    void respondToRequest_whenDestinationArtistAccepts_returns200() throws Exception {
        ArtistRespondFixture fx = persistArtistRespondFixture("bk-own-resp-ok");
        mockArtist(fx.artistOwnerFirebaseUid);

        try {
            given()
                    .contentType("application/json")
                    .body("{\"accept\":true}")
                    .when().patch("/api/artist-bookings/" + fx.bookingId + "/respond")
                    .then()
                    .statusCode(200)
                    .body("status", equalTo("CONFIRMED"));
        } finally {
            deleteArtistRespondFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "bk-own-resp-403", roles = {"ARTIST"})
    @DisplayName("PATCH /artist-bookings/{id}/respond — artiste tiers tente de répondre → 403")
    void respondToRequest_whenOtherArtistResponds_returns403AndStatusUnchanged() throws Exception {
        ArtistRespondFixture fx = persistArtistRespondFixture("bk-own-resp-403");
        mockArtist(fx.artistOtherFirebaseUid);

        try {
            given()
                    .contentType("application/json")
                    .body("{\"accept\":true}")
                    .when().patch("/api/artist-bookings/" + fx.bookingId + "/respond")
                    .then()
                    .statusCode(403)
                    .body(equalTo("Accès refusé."));

            assertEquals(BookingStatus.PENDING_CONFIRMATION, getBookingStatus(fx.bookingId));
        } finally {
            deleteArtistRespondFixture(fx);
        }
    }

    // --- Fixtures ---

    private void mockArtist(String firebaseUid) {
        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(
                        firebaseUid,
                        firebaseUid + "@test.com",
                        "Artiste Test"
                )));
    }

    private BookingStatus getBookingStatus(Long bookingId) throws Exception {
        userTransaction.begin();
        try {
            BookingStatus status = artistBookingRepository.findByIdOptional(bookingId)
                    .orElseThrow()
                    .getStatus();
            userTransaction.commit();
            return status;
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }
    }

    /**
     * Fixture minimale : booking PENDING_CONFIRMATION destiné à artistOwner, second artiste distinct pour le cas 403.
     */
    private record ArtistRespondFixture(
            Long bookingId,
            String artistOwnerFirebaseUid,
            String artistOtherFirebaseUid,
            Long managerId,
            Long companyId,
            Long showDateId,
            Long artistOwnerId,
            Long artistOtherId
    ) {
    }

    private ArtistRespondFixture persistArtistRespondFixture(String seed) throws Exception {
        userTransaction.begin();
        try {
            VioletteUserEntity manager = buildManager(seed + "-mgr");
            VioletteUserEntity artistOwner = buildArtist(seed + "-art-owner");
            VioletteUserEntity artistOther = buildArtist(seed + "-art-other");
            violetteUserRepository.persist(manager);
            violetteUserRepository.persist(artistOwner);
            violetteUserRepository.persist(artistOther);

            CabaretCompanyEntity company = buildCompany("Compagnie " + seed, manager);
            cabaretCompanyRepository.persist(company);

            ShowDateEntity showDate = buildShowDate(company, LocalDate.of(2026, 9, 1), ShowDateStatus.CONFIRMED, seed);
            showDateRepository.persist(showDate);

            ArtistBookingEntity booking = buildSelectedBooking(showDate, artistOwner);
            booking.setStatus(BookingStatus.PENDING_CONFIRMATION);
            artistBookingRepository.persist(booking);

            showDateRepository.flush();

            userTransaction.commit();
            return new ArtistRespondFixture(
                    booking.getId(),
                    artistOwner.getFirebaseUid(),
                    artistOther.getFirebaseUid(),
                    manager.getId(),
                    company.getId(),
                    showDate.getId(),
                    artistOwner.getId(),
                    artistOther.getId()
            );
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }
    }

    private void deleteArtistRespondFixture(ArtistRespondFixture fx) throws Exception {
        userTransaction.begin();
        try {
            artistBookingRepository.findByIdOptional(fx.bookingId).ifPresent(artistBookingRepository::delete);
            showDateRepository.findByIdOptional(fx.showDateId).ifPresent(showDateRepository::delete);
            cabaretCompanyRepository.findByIdOptional(fx.companyId).ifPresent(cabaretCompanyRepository::delete);
            violetteUserRepository.findByIdOptional(fx.managerId).ifPresent(violetteUserRepository::delete);
            violetteUserRepository.findByIdOptional(fx.artistOwnerId).ifPresent(violetteUserRepository::delete);
            violetteUserRepository.findByIdOptional(fx.artistOtherId).ifPresent(violetteUserRepository::delete);
            userTransaction.commit();
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }
    }

    private void mockManagerA(BookingOwnershipFixture fx) {
        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(
                        fx.managerAFirebaseUid,
                        fx.managerAFirebaseUid + "@test.com",
                        "Manager A"
                )));
    }

    private long countBookingsForShowDate(Long showDateId) throws Exception {
        userTransaction.begin();
        try {
            long count = artistBookingRepository.findByShowDateId(showDateId).size();
            userTransaction.commit();
            return count;
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }
    }

    private long countBookingById(Long bookingId) throws Exception {
        userTransaction.begin();
        try {
            long count = artistBookingRepository.findByIdOptional(bookingId).isPresent() ? 1 : 0;
            userTransaction.commit();
            return count;
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }
    }

    /**
     * Fixture minimale viable : deux compagnies, dates OPTION (sélection) et CONFIRMED (envoi confirmations),
     * artiste avec disponibilité AVAILABLE sur la date OPTION de A, besoins artistiques et bookings SELECTED pré-créés.
     */
    private record BookingOwnershipFixture(
            Long managerAId,
            String managerAFirebaseUid,
            Long companyAId,
            Long showDateOptionAId,
            Long showDateConfirmedAId,
            Long skillReqOptionAId,
            Long skillReqConfirmedAId,
            Long bookingOnAId,
            Long bookingOnBId,
            Long artistId,
            Long managerBId,
            Long companyBId,
            Long showDateOptionBId,
            Long showDateConfirmedBId,
            Long skillReqOptionBId,
            Long skillReqConfirmedBId
    ) {
    }

    private BookingOwnershipFixture persistBookingOwnershipFixture(String seed, boolean withSelectedBookings) throws Exception {
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

            ShowDateEntity showDateOptionA = buildShowDate(companyA, LocalDate.of(2026, 8, 1), ShowDateStatus.OPTION, seed + " opt A");
            ShowDateEntity showDateConfirmedA = buildShowDate(companyA, LocalDate.of(2026, 8, 2), ShowDateStatus.CONFIRMED, seed + " conf A");
            ShowDateEntity showDateOptionB = buildShowDate(companyB, LocalDate.of(2026, 8, 3), ShowDateStatus.OPTION, seed + " opt B");
            ShowDateEntity showDateConfirmedB = buildShowDate(companyB, LocalDate.of(2026, 8, 4), ShowDateStatus.CONFIRMED, seed + " conf B");
            showDateRepository.persist(showDateOptionA);
            showDateRepository.persist(showDateConfirmedA);
            showDateRepository.persist(showDateOptionB);
            showDateRepository.persist(showDateConfirmedB);

            ShowDateSkillRequirementEntity skillReqOptionA = buildSkillRequirement(showDateOptionA);
            ShowDateSkillRequirementEntity skillReqConfirmedA = buildSkillRequirement(showDateConfirmedA);
            ShowDateSkillRequirementEntity skillReqOptionB = buildSkillRequirement(showDateOptionB);
            ShowDateSkillRequirementEntity skillReqConfirmedB = buildSkillRequirement(showDateConfirmedB);
            showDateSkillRequirementRepository.persist(skillReqOptionA);
            showDateSkillRequirementRepository.persist(skillReqConfirmedA);
            showDateSkillRequirementRepository.persist(skillReqOptionB);
            showDateSkillRequirementRepository.persist(skillReqConfirmedB);

            // Disponibilité AVAILABLE sur la date OPTION de A — précondition createBooking nominal
            persistAvailability(showDateOptionA, artist, AvailabilityStatus.AVAILABLE);

            Long bookingOnAId = null;
            Long bookingOnBId = null;
            if (withSelectedBookings) {
                // Bookings SELECTED pré-créés pour les tests delete (ownership, pas via le service)
                ArtistBookingEntity bookingOnA = buildSelectedBooking(showDateOptionA, artist);
                ArtistBookingEntity bookingOnB = buildSelectedBooking(showDateOptionB, artist);
                artistBookingRepository.persist(bookingOnA);
                artistBookingRepository.persist(bookingOnB);
                bookingOnAId = bookingOnA.getId();
                bookingOnBId = bookingOnB.getId();
            }

            showDateRepository.flush();

            userTransaction.commit();
            return new BookingOwnershipFixture(
                    managerA.getId(),
                    managerA.getFirebaseUid(),
                    companyA.getId(),
                    showDateOptionA.getId(),
                    showDateConfirmedA.getId(),
                    skillReqOptionA.getId(),
                    skillReqConfirmedA.getId(),
                    bookingOnAId,
                    bookingOnBId,
                    artist.getId(),
                    managerB.getId(),
                    companyB.getId(),
                    showDateOptionB.getId(),
                    showDateConfirmedB.getId(),
                    skillReqOptionB.getId(),
                    skillReqConfirmedB.getId()
            );
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }
    }

    private void deleteBookingOwnershipFixture(BookingOwnershipFixture fx) throws Exception {
        userTransaction.begin();
        try {
            deleteBookingsForCompany(fx.companyAId);
            deleteBookingsForCompany(fx.companyBId);
            deleteAvailabilitiesForCompany(fx.companyAId);
            deleteAvailabilitiesForCompany(fx.companyBId);
            deleteSkillRequirementsForCompany(fx.companyAId);
            deleteSkillRequirementsForCompany(fx.companyBId);
            showDateRepository.findByCompanyId(fx.companyAId).forEach(showDateRepository::delete);
            showDateRepository.findByCompanyId(fx.companyBId).forEach(showDateRepository::delete);
            cabaretCompanyRepository.findByIdOptional(fx.companyAId).ifPresent(cabaretCompanyRepository::delete);
            cabaretCompanyRepository.findByIdOptional(fx.companyBId).ifPresent(cabaretCompanyRepository::delete);
            violetteUserRepository.findByIdOptional(fx.managerAId).ifPresent(violetteUserRepository::delete);
            violetteUserRepository.findByIdOptional(fx.managerBId).ifPresent(violetteUserRepository::delete);
            violetteUserRepository.findByIdOptional(fx.artistId).ifPresent(violetteUserRepository::delete);
            userTransaction.commit();
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }
    }

    private void deleteBookingsForCompany(Long companyId) {
        showDateRepository.findByCompanyId(companyId).forEach(showDate ->
                artistBookingRepository.findByShowDateId(showDate.getId())
                        .forEach(artistBookingRepository::delete));
    }

    private void deleteAvailabilitiesForCompany(Long companyId) {
        showDateRepository.findByCompanyId(companyId).forEach(showDate ->
                artistAvailabilityRepository.findByShowDateId(showDate.getId())
                        .forEach(artistAvailabilityRepository::delete));
    }

    private void deleteSkillRequirementsForCompany(Long companyId) {
        showDateRepository.findByCompanyId(companyId).forEach(showDate ->
                showDateSkillRequirementRepository.findByShowDateId(showDate.getId())
                        .forEach(showDateSkillRequirementRepository::delete));
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
        company.setManager(manager);
        return company;
    }

    private ShowDateEntity buildShowDate(CabaretCompanyEntity company, LocalDate eventDate,
                                         ShowDateStatus status, String location) {
        ShowDateEntity showDate = new ShowDateEntity();
        showDate.setCompany(company);
        showDate.setEventDate(eventDate);
        showDate.setMeetingTime(LocalTime.of(20, 0));
        showDate.setLocation("Lieu " + location);
        showDate.setClientContactName("Contact Test");
        showDate.setClientContactPhone("0600000000");
        showDate.setStatus(status);
        return showDate;
    }

    private ShowDateSkillRequirementEntity buildSkillRequirement(ShowDateEntity showDate) {
        ShowDateSkillRequirementEntity req = new ShowDateSkillRequirementEntity();
        req.setShowDate(showDate);
        req.setSkill(ArtistSkill.DANCE);
        req.setRequiredCount(2);
        req.setNetFee(new BigDecimal("100.00"));
        return req;
    }

    private void persistAvailability(ShowDateEntity showDate, VioletteUserEntity artist,
                                     AvailabilityStatus status) {
        ArtistAvailabilityId key = new ArtistAvailabilityId(showDate.getId(), artist.getId());
        ArtistAvailabilityEntity availability = new ArtistAvailabilityEntity();
        availability.setId(key);
        availability.setShowDate(showDate);
        availability.setArtist(artist);
        availability.setStatus(status);
        artistAvailabilityRepository.persist(availability);
    }

    private ArtistBookingEntity buildSelectedBooking(ShowDateEntity showDate, VioletteUserEntity artist) {
        ArtistBookingEntity booking = new ArtistBookingEntity();
        booking.setShowDate(showDate);
        booking.setArtist(artist);
        booking.setStatus(BookingStatus.SELECTED);
        return booking;
    }
}
