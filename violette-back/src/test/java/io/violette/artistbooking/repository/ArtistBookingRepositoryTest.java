package io.violette.artistbooking.repository;

import io.quarkus.test.junit.QuarkusTest;
import io.violette.artistbooking.model.ArtistBookingEntity;
import io.violette.artistbooking.model.BookingStatus;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.showdate.model.ShowDateEntity;
import io.violette.showdate.model.ShowDateSkillRequirementEntity;
import io.violette.showdate.repository.ArtistAvailabilityRepository;
import io.violette.showdate.repository.ShowDateRepository;
import io.violette.showdate.repository.ShowDateSkillRequirementRepository;
import io.violette.violetteuser.model.ArtistSkill;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

@QuarkusTest
class ArtistBookingRepositoryTest {

    @Inject
    ArtistBookingRepository bookingRepository;

    @Inject
    ShowDateRepository showDateRepository;

    @Inject
    ShowDateSkillRequirementRepository skillRequirementRepository;

    @Inject
    ArtistAvailabilityRepository availabilityRepository;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    // ------------------------------------------------------------------
    // Persistance
    // ------------------------------------------------------------------

    @Test
    @Transactional
    void givenBookingWithAllFields_whenPersisted_thenCanBeFullyReloaded() {
        VioletteUserEntity manager = buildAndPersistUser("bk-mgr-1", "bk-mgr-1@test.com", Set.of(UserRole.MANAGER));
        VioletteUserEntity artist = buildAndPersistUser("bk-artist-1", "bk-artist-1@test.com", Set.of(UserRole.ARTIST));
        CabaretCompanyEntity company = buildAndPersistCompany("Compagnie Booking 1", manager);
        ShowDateEntity showDate = buildAndPersistShowDate(company, LocalDate.of(2025, 6, 10));
        ShowDateSkillRequirementEntity skillReq = buildAndPersistSkillRequirement(showDate, ArtistSkill.DANCE, 2, "120.00");

        ArtistBookingEntity booking = new ArtistBookingEntity();
        booking.setShowDate(showDate);
        booking.setArtist(artist);
        booking.setSkillRequirement(skillReq);
        booking.setAgreedNetFee(new BigDecimal("120.00"));
        bookingRepository.persistAndFlush(booking);

        ArtistBookingEntity found = bookingRepository.findById(booking.getId());

        assertNotNull(found);
        assertAll(
                () -> assertEquals(BookingStatus.SELECTED, found.getStatus()),
                () -> assertEquals(showDate.getId(), found.getShowDate().getId()),
                () -> assertEquals(artist.getId(), found.getArtist().getId()),
                () -> assertEquals(skillReq.getId(), found.getSkillRequirement().getId()),
                () -> assertEquals(new BigDecimal("120.00"), found.getAgreedNetFee()),
                () -> assertNotNull(found.getTimeline().getCreatedAt()),
                () -> assertNotNull(found.getTimeline().getUpdatedAt()),
                () -> assertNull(found.getTimeline().getRequestedAt()),
                () -> assertNull(found.getTimeline().getRespondedAt())
        );
    }

    @Test
    @Transactional
    void givenBookingWithoutSkillRequirement_whenPersisted_thenSkillRequirementIsNull() {
        VioletteUserEntity manager = buildAndPersistUser("bk-mgr-2", "bk-mgr-2@test.com", Set.of(UserRole.MANAGER));
        VioletteUserEntity artist = buildAndPersistUser("bk-artist-2", "bk-artist-2@test.com", Set.of(UserRole.ARTIST));
        CabaretCompanyEntity company = buildAndPersistCompany("Compagnie Booking 2", manager);
        ShowDateEntity showDate = buildAndPersistShowDate(company, LocalDate.of(2025, 6, 11));

        ArtistBookingEntity booking = new ArtistBookingEntity();
        booking.setShowDate(showDate);
        booking.setArtist(artist);
        bookingRepository.persistAndFlush(booking);

        ArtistBookingEntity found = bookingRepository.findById(booking.getId());

        assertNull(found.getSkillRequirement());
        assertNull(found.getAgreedNetFee());
    }

    // ------------------------------------------------------------------
    // Contrainte d'unicité (show_date_id, artist_id)
    // ------------------------------------------------------------------

    @Test
    @Transactional
    void givenExistingBooking_whenFindByShowDateIdAndArtistId_thenReturnsIt() {
        VioletteUserEntity manager = buildAndPersistUser("bk-mgr-3", "bk-mgr-3@test.com", Set.of(UserRole.MANAGER));
        VioletteUserEntity artist = buildAndPersistUser("bk-artist-3", "bk-artist-3@test.com", Set.of(UserRole.ARTIST));
        CabaretCompanyEntity company = buildAndPersistCompany("Compagnie Booking 3", manager);
        ShowDateEntity showDate = buildAndPersistShowDate(company, LocalDate.of(2025, 6, 12));

        ArtistBookingEntity booking = persistBooking(showDate, artist, null, BookingStatus.SELECTED, null);

        Optional<ArtistBookingEntity> found =
                bookingRepository.findByShowDateIdAndArtistId(showDate.getId(), artist.getId());

        assertTrue(found.isPresent());
        assertEquals(booking.getId(), found.get().getId());
    }

    @Test
    @Transactional
    void givenNoBookingForArtistOnDate_whenFindByShowDateIdAndArtistId_thenReturnsEmpty() {
        VioletteUserEntity manager = buildAndPersistUser("bk-mgr-4", "bk-mgr-4@test.com", Set.of(UserRole.MANAGER));
        VioletteUserEntity artist = buildAndPersistUser("bk-artist-4", "bk-artist-4@test.com", Set.of(UserRole.ARTIST));
        CabaretCompanyEntity company = buildAndPersistCompany("Compagnie Booking 4", manager);
        ShowDateEntity showDate = buildAndPersistShowDate(company, LocalDate.of(2025, 6, 13));

        Optional<ArtistBookingEntity> found =
                bookingRepository.findByShowDateIdAndArtistId(showDate.getId(), artist.getId());

        assertTrue(found.isEmpty());
    }

    // ------------------------------------------------------------------
    // findByShowDateId / findByArtistId
    // ------------------------------------------------------------------

    @Test
    @Transactional
    void givenMultipleBookingsForSameDate_whenFindByShowDateId_thenReturnAll() {
        VioletteUserEntity manager = buildAndPersistUser("bk-mgr-5", "bk-mgr-5@test.com", Set.of(UserRole.MANAGER));
        VioletteUserEntity artist1 = buildAndPersistUser("bk-artist-5a", "bk-artist-5a@test.com", Set.of(UserRole.ARTIST));
        VioletteUserEntity artist2 = buildAndPersistUser("bk-artist-5b", "bk-artist-5b@test.com", Set.of(UserRole.ARTIST));
        CabaretCompanyEntity company = buildAndPersistCompany("Compagnie Booking 5", manager);
        ShowDateEntity showDate = buildAndPersistShowDate(company, LocalDate.of(2025, 6, 14));

        persistBooking(showDate, artist1, null, BookingStatus.SELECTED, null);
        persistBooking(showDate, artist2, null, BookingStatus.PENDING_CONFIRMATION, null);
        bookingRepository.flush();

        List<ArtistBookingEntity> bookings = bookingRepository.findByShowDateId(showDate.getId());

        assertEquals(2, bookings.size());
    }

    @Test
    @Transactional
    void givenArtistBookedOnMultipleDates_whenFindByArtistId_thenReturnAllDates() {
        VioletteUserEntity manager = buildAndPersistUser("bk-mgr-6", "bk-mgr-6@test.com", Set.of(UserRole.MANAGER));
        VioletteUserEntity artist = buildAndPersistUser("bk-artist-6", "bk-artist-6@test.com", Set.of(UserRole.ARTIST));
        CabaretCompanyEntity company = buildAndPersistCompany("Compagnie Booking 6", manager);
        ShowDateEntity date1 = buildAndPersistShowDate(company, LocalDate.of(2025, 7, 1));
        ShowDateEntity date2 = buildAndPersistShowDate(company, LocalDate.of(2025, 8, 1));

        persistBooking(date1, artist, null, BookingStatus.CONFIRMED, null);
        persistBooking(date2, artist, null, BookingStatus.SELECTED, null);
        bookingRepository.flush();

        List<ArtistBookingEntity> bookings = bookingRepository.findByArtistId(artist.getId());

        assertEquals(2, bookings.size());
    }

    // ------------------------------------------------------------------
    // findByArtistIdAndStatus — pending requests
    // ------------------------------------------------------------------

    @Test
    @Transactional
    void givenArtistWithMixedBookingStatuses_whenFindByArtistIdAndStatus_thenReturnOnlyMatchingStatus() {
        VioletteUserEntity manager = buildAndPersistUser("bk-mgr-7", "bk-mgr-7@test.com", Set.of(UserRole.MANAGER));
        VioletteUserEntity artist = buildAndPersistUser("bk-artist-7", "bk-artist-7@test.com", Set.of(UserRole.ARTIST));
        CabaretCompanyEntity company = buildAndPersistCompany("Compagnie Booking 7", manager);
        ShowDateEntity date1 = buildAndPersistShowDate(company, LocalDate.of(2025, 9, 1));
        ShowDateEntity date2 = buildAndPersistShowDate(company, LocalDate.of(2025, 9, 2));
        ShowDateEntity date3 = buildAndPersistShowDate(company, LocalDate.of(2025, 9, 3));

        persistBooking(date1, artist, null, BookingStatus.PENDING_CONFIRMATION, null);
        persistBooking(date2, artist, null, BookingStatus.PENDING_CONFIRMATION, null);
        persistBooking(date3, artist, null, BookingStatus.CONFIRMED, null);
        bookingRepository.flush();

        List<ArtistBookingEntity> pending =
                bookingRepository.findByArtistIdAndStatus(artist.getId(), BookingStatus.PENDING_CONFIRMATION);

        assertEquals(2, pending.size());
        assertTrue(pending.stream().allMatch(b -> b.getStatus() == BookingStatus.PENDING_CONFIRMATION));
    }

    // ------------------------------------------------------------------
    // countActiveBookingsForSkillRequirement
    // ------------------------------------------------------------------

    @Test
    @Transactional
    void countActiveBookingsForSkillRequirement_countsSelected() {
        ShowDateSkillRequirementEntity skillReq = buildSkillReqWithDate("bk-cap-1");
        persistBookingForSkillReq(skillReq, "bk-cap-a1", BookingStatus.SELECTED);

        long count = bookingRepository.countActiveBookingsForSkillRequirement(skillReq.getId());

        assertEquals(1, count);
    }

    @Test
    @Transactional
    void countActiveBookingsForSkillRequirement_countsPendingConfirmation() {
        ShowDateSkillRequirementEntity skillReq = buildSkillReqWithDate("bk-cap-2");
        persistBookingForSkillReq(skillReq, "bk-cap-a2", BookingStatus.PENDING_CONFIRMATION);

        long count = bookingRepository.countActiveBookingsForSkillRequirement(skillReq.getId());

        assertEquals(1, count);
    }

    @Test
    @Transactional
    void countActiveBookingsForSkillRequirement_countsConfirmed() {
        ShowDateSkillRequirementEntity skillReq = buildSkillReqWithDate("bk-cap-3");
        persistBookingForSkillReq(skillReq, "bk-cap-a3", BookingStatus.CONFIRMED);

        long count = bookingRepository.countActiveBookingsForSkillRequirement(skillReq.getId());

        assertEquals(1, count);
    }

    @Test
    @Transactional
    void countActiveBookingsForSkillRequirement_excludesRefused() {
        ShowDateSkillRequirementEntity skillReq = buildSkillReqWithDate("bk-cap-4");
        persistBookingForSkillReq(skillReq, "bk-cap-a4", BookingStatus.REFUSED);

        long count = bookingRepository.countActiveBookingsForSkillRequirement(skillReq.getId());

        assertEquals(0, count);
    }

    @Test
    @Transactional
    void countActiveBookingsForSkillRequirement_excludesCancelled() {
        ShowDateSkillRequirementEntity skillReq = buildSkillReqWithDate("bk-cap-5");
        persistBookingForSkillReq(skillReq, "bk-cap-a5", BookingStatus.CANCELLED);

        long count = bookingRepository.countActiveBookingsForSkillRequirement(skillReq.getId());

        assertEquals(0, count);
    }

    @Test
    @Transactional
    void countActiveBookingsForSkillRequirement_withMixedStatuses_countsOnlyActive() {
        ShowDateSkillRequirementEntity skillReq = buildSkillReqWithDate("bk-cap-6");
        persistBookingForSkillReq(skillReq, "bk-cap-a6a", BookingStatus.SELECTED);
        persistBookingForSkillReq(skillReq, "bk-cap-a6b", BookingStatus.PENDING_CONFIRMATION);
        persistBookingForSkillReq(skillReq, "bk-cap-a6c", BookingStatus.CONFIRMED);
        persistBookingForSkillReq(skillReq, "bk-cap-a6d", BookingStatus.REFUSED);
        persistBookingForSkillReq(skillReq, "bk-cap-a6e", BookingStatus.CANCELLED);

        long count = bookingRepository.countActiveBookingsForSkillRequirement(skillReq.getId());

        assertEquals(3, count);
    }

    // ------------------------------------------------------------------
    // findByShowDateIdAndStatus
    // ------------------------------------------------------------------

    @Test
    @Transactional
    void givenBookingsWithMixedStatuses_whenFindByShowDateIdAndStatus_thenReturnOnlySelected() {
        VioletteUserEntity manager = buildAndPersistUser("bk-mgr-8", "bk-mgr-8@test.com", Set.of(UserRole.MANAGER));
        VioletteUserEntity artist1 = buildAndPersistUser("bk-artist-8a", "bk-artist-8a@test.com", Set.of(UserRole.ARTIST));
        VioletteUserEntity artist2 = buildAndPersistUser("bk-artist-8b", "bk-artist-8b@test.com", Set.of(UserRole.ARTIST));
        VioletteUserEntity artist3 = buildAndPersistUser("bk-artist-8c", "bk-artist-8c@test.com", Set.of(UserRole.ARTIST));
        CabaretCompanyEntity company = buildAndPersistCompany("Compagnie Booking 8", manager);
        ShowDateEntity showDate = buildAndPersistShowDate(company, LocalDate.of(2025, 10, 1));

        persistBooking(showDate, artist1, null, BookingStatus.SELECTED, null);
        persistBooking(showDate, artist2, null, BookingStatus.SELECTED, null);
        persistBooking(showDate, artist3, null, BookingStatus.CONFIRMED, null);
        bookingRepository.flush();

        List<ArtistBookingEntity> selected =
                bookingRepository.findByShowDateIdAndStatus(showDate.getId(), BookingStatus.SELECTED);

        assertEquals(2, selected.size());
        assertTrue(selected.stream().allMatch(b -> b.getStatus() == BookingStatus.SELECTED));
    }

    // ------------------------------------------------------------------
    // findActiveByShowDateId
    // ------------------------------------------------------------------

    @Test
    @Transactional
    void findActiveByShowDateId_excludesRefusedAndCancelled() {
        VioletteUserEntity manager = buildAndPersistUser("bk-mgr-9", "bk-mgr-9@test.com", Set.of(UserRole.MANAGER));
        VioletteUserEntity a1 = buildAndPersistUser("bk-artist-9a", "bk-artist-9a@test.com", Set.of(UserRole.ARTIST));
        VioletteUserEntity a2 = buildAndPersistUser("bk-artist-9b", "bk-artist-9b@test.com", Set.of(UserRole.ARTIST));
        VioletteUserEntity a3 = buildAndPersistUser("bk-artist-9c", "bk-artist-9c@test.com", Set.of(UserRole.ARTIST));
        VioletteUserEntity a4 = buildAndPersistUser("bk-artist-9d", "bk-artist-9d@test.com", Set.of(UserRole.ARTIST));
        VioletteUserEntity a5 = buildAndPersistUser("bk-artist-9e", "bk-artist-9e@test.com", Set.of(UserRole.ARTIST));
        CabaretCompanyEntity company = buildAndPersistCompany("Compagnie Booking 9", manager);
        ShowDateEntity showDate = buildAndPersistShowDate(company, LocalDate.of(2025, 11, 1));

        persistBooking(showDate, a1, null, BookingStatus.SELECTED, null);
        persistBooking(showDate, a2, null, BookingStatus.PENDING_CONFIRMATION, null);
        persistBooking(showDate, a3, null, BookingStatus.CONFIRMED, null);
        persistBooking(showDate, a4, null, BookingStatus.REFUSED, null);
        persistBooking(showDate, a5, null, BookingStatus.CANCELLED, null);
        bookingRepository.flush();

        List<ArtistBookingEntity> active = bookingRepository.findActiveByShowDateId(showDate.getId());

        assertEquals(3, active.size());
        assertTrue(active.stream().noneMatch(b -> b.getStatus() == BookingStatus.REFUSED));
        assertTrue(active.stream().noneMatch(b -> b.getStatus() == BookingStatus.CANCELLED));
    }

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------

    private VioletteUserEntity buildAndPersistUser(String firebaseUid, String email, Set<UserRole> roles) {
        VioletteUserEntity user = new VioletteUserEntity();
        user.setFirebaseUid(firebaseUid);
        user.setEmail(email);
        user.setFirstName("User");
        user.setLastName("Test");
        user.setRoles(roles);
        user.setSkills(Set.of());
        violetteUserRepository.persistAndFlush(user);
        return user;
    }

    private CabaretCompanyEntity buildAndPersistCompany(String name, VioletteUserEntity manager) {
        CabaretCompanyEntity company = new CabaretCompanyEntity();
        company.setName(name);
        company.setManager(manager);
        cabaretCompanyRepository.persistAndFlush(company);
        return company;
    }

    private ShowDateEntity buildAndPersistShowDate(CabaretCompanyEntity company, LocalDate eventDate) {
        ShowDateEntity sd = new ShowDateEntity();
        sd.setCompany(company);
        sd.setEventDate(eventDate);
        sd.setMeetingTime(LocalTime.of(10, 0));
        sd.setLocation("12 rue du Spectacle, 75001 Paris");
        sd.setClientContactName("Client Test");
        sd.setClientContactPhone("0600000000");
        showDateRepository.persistAndFlush(sd);
        return sd;
    }

    private ShowDateSkillRequirementEntity buildAndPersistSkillRequirement(
            ShowDateEntity showDate, ArtistSkill skill, int count, String fee) {
        ShowDateSkillRequirementEntity req = new ShowDateSkillRequirementEntity();
        req.setShowDate(showDate);
        req.setSkill(skill);
        req.setRequiredCount(count);
        req.setNetFee(new BigDecimal(fee));
        skillRequirementRepository.persistAndFlush(req);
        return req;
    }

    private ArtistBookingEntity persistBooking(
            ShowDateEntity showDate, VioletteUserEntity artist,
            ShowDateSkillRequirementEntity skillReq, BookingStatus status, BigDecimal fee) {
        ArtistBookingEntity booking = new ArtistBookingEntity();
        booking.setShowDate(showDate);
        booking.setArtist(artist);
        booking.setSkillRequirement(skillReq);
        booking.setStatus(status);
        booking.setAgreedNetFee(fee);
        bookingRepository.persist(booking);
        return booking;
    }

    /**
     * Crée une date + un besoin artistique isolés, utilisés uniquement
     * pour tester le comptage de capacité sans interférence entre tests.
     */
    private ShowDateSkillRequirementEntity buildSkillReqWithDate(String seed) {
        VioletteUserEntity manager = buildAndPersistUser("bk-cap-mgr-" + seed, "bk-cap-mgr-" + seed + "@test.com", Set.of(UserRole.MANAGER));
        CabaretCompanyEntity company = buildAndPersistCompany("Compagnie Cap " + seed, manager);
        ShowDateEntity showDate = buildAndPersistShowDate(company, LocalDate.of(2026, 1, 1).plusDays(seed.hashCode() % 100));
        return buildAndPersistSkillRequirement(showDate, ArtistSkill.DANCE, 3, "100.00");
    }

    /**
     * Persiste un booking pour un besoin artistique donné, avec un artiste dédié (uid unique).
     */
    private void persistBookingForSkillReq(ShowDateSkillRequirementEntity skillReq, String artistSeed, BookingStatus status) {
        VioletteUserEntity artist = buildAndPersistUser(
                "bk-cap-art-" + artistSeed,
                "bk-cap-art-" + artistSeed + "@test.com",
                Set.of(UserRole.ARTIST)
        );
        bookingRepository.persist(buildBookingForSkillReq(skillReq.getShowDate(), artist, skillReq, status));
    }

    private ArtistBookingEntity buildBookingForSkillReq(
            ShowDateEntity showDate, VioletteUserEntity artist,
            ShowDateSkillRequirementEntity skillReq, BookingStatus status) {
        ArtistBookingEntity booking = new ArtistBookingEntity();
        booking.setShowDate(showDate);
        booking.setArtist(artist);
        booking.setSkillRequirement(skillReq);
        booking.setStatus(status);
        return booking;
    }
}
