package io.violette.showdate.repository;

import io.quarkus.test.junit.QuarkusTest;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.showdate.model.ArtistAvailabilityEntity;
import io.violette.showdate.model.ArtistAvailabilityId;
import io.violette.showdate.model.AvailabilityStatus;
import io.violette.showdate.model.ShowDateEntity;
import io.violette.showdate.model.ShowDateSkillRequirementEntity;
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
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

@QuarkusTest
class ArtistAvailabilityRepositoryTest {

    @Inject
    ArtistAvailabilityRepository availabilityRepository;

    @Inject
    ShowDateRepository showDateRepository;

    @Inject
    ShowDateSkillRequirementRepository skillRequirementRepository;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Test
    @Transactional
    void givenArtistAvailability_whenPersisted_thenCanBeReloadedByCompositeKey() {
        VioletteUserEntity manager = buildAndPersistUser("avail-mgr-1", "avail-mgr-1@test.com", Set.of(UserRole.MANAGER));
        VioletteUserEntity artist = buildAndPersistUser("avail-artist-1", "avail-artist-1@test.com", Set.of(UserRole.ARTIST));
        CabaretCompanyEntity company = buildAndPersistCompany("Compagnie Avail 1", manager);
        ShowDateEntity showDate = buildAndPersistShowDate(company, LocalDate.of(2025, 6, 1));

        ArtistAvailabilityId key = new ArtistAvailabilityId(showDate.getId(), artist.getId());
        ArtistAvailabilityEntity availability = new ArtistAvailabilityEntity();
        availability.setId(key);
        availability.setShowDate(showDate);
        availability.setArtist(artist);
        availability.setStatus(AvailabilityStatus.AVAILABLE);
        availabilityRepository.persistAndFlush(availability);

        ArtistAvailabilityEntity found = availabilityRepository.findById(key);

        assertNotNull(found);
        assertAll(
                () -> assertEquals(AvailabilityStatus.AVAILABLE, found.getStatus()),
                () -> assertEquals(showDate.getId(), found.getId().getShowDateId()),
                () -> assertEquals(artist.getId(), found.getId().getArtistId()),
                () -> assertNotNull(found.getUpdatedAt()),
                () -> assertNotNull(found.getShowDate()),
                () -> assertNotNull(found.getArtist()),
                () -> assertEquals("avail-artist-1", found.getArtist().getFirebaseUid())
        );
    }

    @Test
    @Transactional
    void givenAvailabilityWithoutExplicitStatus_whenPersisted_thenStatusDefaultsToPending() {
        VioletteUserEntity manager = buildAndPersistUser("avail-mgr-2", "avail-mgr-2@test.com", Set.of(UserRole.MANAGER));
        VioletteUserEntity artist = buildAndPersistUser("avail-artist-2", "avail-artist-2@test.com", Set.of(UserRole.ARTIST));
        CabaretCompanyEntity company = buildAndPersistCompany("Compagnie Avail 2", manager);
        ShowDateEntity showDate = buildAndPersistShowDate(company, LocalDate.of(2025, 6, 2));

        ArtistAvailabilityId key = new ArtistAvailabilityId(showDate.getId(), artist.getId());
        ArtistAvailabilityEntity availability = new ArtistAvailabilityEntity();
        availability.setId(key);
        availability.setShowDate(showDate);
        availability.setArtist(artist);
        // status not set — doit rester PENDING (valeur par défaut de l'entité)
        availabilityRepository.persistAndFlush(availability);

        ArtistAvailabilityEntity found = availabilityRepository.findById(key);

        assertEquals(AvailabilityStatus.PENDING, found.getStatus());
    }

    @Test
    @Transactional
    void givenMultipleArtistsForSameDate_whenFindByShowDateId_thenReturnAll() {
        VioletteUserEntity manager = buildAndPersistUser("avail-mgr-3", "avail-mgr-3@test.com", Set.of(UserRole.MANAGER));
        VioletteUserEntity artist1 = buildAndPersistUser("avail-artist-3a", "avail-artist-3a@test.com", Set.of(UserRole.ARTIST));
        VioletteUserEntity artist2 = buildAndPersistUser("avail-artist-3b", "avail-artist-3b@test.com", Set.of(UserRole.ARTIST));
        VioletteUserEntity artist3 = buildAndPersistUser("avail-artist-3c", "avail-artist-3c@test.com", Set.of(UserRole.ARTIST));
        CabaretCompanyEntity company = buildAndPersistCompany("Compagnie Avail 3", manager);
        ShowDateEntity showDate = buildAndPersistShowDate(company, LocalDate.of(2025, 6, 3));

        persistAvailability(showDate, artist1, AvailabilityStatus.AVAILABLE);
        persistAvailability(showDate, artist2, AvailabilityStatus.IF_NEEDED);
        persistAvailability(showDate, artist3, AvailabilityStatus.UNAVAILABLE);
        availabilityRepository.flush();

        List<ArtistAvailabilityEntity> list = availabilityRepository.findByShowDateId(showDate.getId());

        assertEquals(3, list.size());
        assertTrue(list.stream().anyMatch(a -> a.getStatus() == AvailabilityStatus.AVAILABLE));
        assertTrue(list.stream().anyMatch(a -> a.getStatus() == AvailabilityStatus.IF_NEEDED));
        assertTrue(list.stream().anyMatch(a -> a.getStatus() == AvailabilityStatus.UNAVAILABLE));
    }

    @Test
    @Transactional
    void givenArtistWithAvailabilitiesOnMultipleDates_whenFindByArtistId_thenReturnAllDatesForArtist() {
        VioletteUserEntity manager = buildAndPersistUser("avail-mgr-4", "avail-mgr-4@test.com", Set.of(UserRole.MANAGER));
        VioletteUserEntity artist = buildAndPersistUser("avail-artist-4", "avail-artist-4@test.com", Set.of(UserRole.ARTIST));
        CabaretCompanyEntity company = buildAndPersistCompany("Compagnie Avail 4", manager);
        ShowDateEntity date1 = buildAndPersistShowDate(company, LocalDate.of(2025, 7, 10));
        ShowDateEntity date2 = buildAndPersistShowDate(company, LocalDate.of(2025, 8, 20));

        persistAvailability(date1, artist, AvailabilityStatus.AVAILABLE);
        persistAvailability(date2, artist, AvailabilityStatus.UNAVAILABLE);
        availabilityRepository.flush();

        List<ArtistAvailabilityEntity> list = availabilityRepository.findByArtistId(artist.getId());

        assertEquals(2, list.size());
        assertTrue(list.stream().anyMatch(a -> a.getStatus() == AvailabilityStatus.AVAILABLE));
        assertTrue(list.stream().anyMatch(a -> a.getStatus() == AvailabilityStatus.UNAVAILABLE));
    }

    /**
     * Teste que les besoins par compétence et les disponibilités artistes
     * coexistent sur la même date sans collision de modèle.
     */
    @Test
    @Transactional
    void givenShowDateWithSkillRequirementsAndAvailabilities_whenQueried_thenBothModelsCoexist() {
        VioletteUserEntity manager = buildAndPersistUser("avail-mgr-c1", "avail-mgr-c1@test.com", Set.of(UserRole.MANAGER));
        VioletteUserEntity artist1 = buildAndPersistUser("avail-artist-c1", "avail-artist-c1@test.com", Set.of(UserRole.ARTIST));
        VioletteUserEntity artist2 = buildAndPersistUser("avail-artist-c2", "avail-artist-c2@test.com", Set.of(UserRole.ARTIST));
        CabaretCompanyEntity company = buildAndPersistCompany("Compagnie Combined", manager);
        ShowDateEntity showDate = buildAndPersistShowDate(company, LocalDate.of(2025, 12, 31));

        // 2 besoins par compétence
        ShowDateSkillRequirementEntity dance = new ShowDateSkillRequirementEntity();
        dance.setShowDate(showDate);
        dance.setSkill(ArtistSkill.DANCE);
        dance.setRequiredCount(2);
        dance.setNetFee(new BigDecimal("120.00"));
        skillRequirementRepository.persist(dance);

        ShowDateSkillRequirementEntity singing = new ShowDateSkillRequirementEntity();
        singing.setShowDate(showDate);
        singing.setSkill(ArtistSkill.SINGING);
        singing.setRequiredCount(1);
        singing.setNetFee(new BigDecimal("150.00"));
        skillRequirementRepository.persist(singing);

        // 2 disponibilités artistes
        persistAvailability(showDate, artist1, AvailabilityStatus.AVAILABLE);
        persistAvailability(showDate, artist2, AvailabilityStatus.IF_NEEDED);

        skillRequirementRepository.flush();
        availabilityRepository.flush();

        List<ShowDateSkillRequirementEntity> requirements = skillRequirementRepository.findByShowDateId(showDate.getId());
        List<ArtistAvailabilityEntity> availabilities = availabilityRepository.findByShowDateId(showDate.getId());

        assertAll(
                () -> assertEquals(2, requirements.size()),
                () -> assertEquals(2, availabilities.size()),
                () -> assertTrue(requirements.stream().anyMatch(r -> r.getSkill() == ArtistSkill.DANCE)),
                () -> assertTrue(requirements.stream().anyMatch(r -> r.getSkill() == ArtistSkill.SINGING)),
                () -> assertTrue(availabilities.stream().anyMatch(a -> a.getStatus() == AvailabilityStatus.AVAILABLE)),
                () -> assertTrue(availabilities.stream().anyMatch(a -> a.getStatus() == AvailabilityStatus.IF_NEEDED))
        );
    }

    // --- Helpers ---

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
        sd.setLocation("12 rue du Spectacle, 69001 Lyon");
        sd.setClientContactName("Client Test");
        sd.setClientContactPhone("0600000000");
        showDateRepository.persistAndFlush(sd);
        return sd;
    }

    private void persistAvailability(ShowDateEntity showDate, VioletteUserEntity artist, AvailabilityStatus status) {
        ArtistAvailabilityId key = new ArtistAvailabilityId(showDate.getId(), artist.getId());
        ArtistAvailabilityEntity av = new ArtistAvailabilityEntity();
        av.setId(key);
        av.setShowDate(showDate);
        av.setArtist(artist);
        av.setStatus(status);
        availabilityRepository.persist(av);
    }
}
