package io.violette.showdate.service;

import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.security.ManagerCompanyResolver;
import io.violette.security.JwtPrincipalInfo;
import io.violette.showdate.dto.ArtistAvailabilityDto;
import io.violette.showdate.exception.InvalidAvailabilityStatusException;
import io.violette.showdate.exception.ShowDateNotFoundException;
import io.violette.showdate.model.ArtistAvailabilityEntity;
import io.violette.showdate.model.ArtistAvailabilityId;
import io.violette.showdate.model.AvailabilityStatus;
import io.violette.showdate.model.ShowDateEntity;
import io.violette.showdate.repository.ArtistAvailabilityRepository;
import io.violette.showdate.repository.ShowDateRepository;
import io.violette.violetteuser.exception.UserNotFoundException;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

@QuarkusTest
class ArtistAvailabilityServiceTest {

    @Inject
    ArtistAvailabilityService artistAvailabilityService;

    /** Mocké pour neutraliser la garde d'ownership dans les tests qui ne testent pas l'autorisation manager. */
    @InjectMock
    ManagerCompanyResolver managerCompanyResolver;

    @Inject
    ArtistAvailabilityRepository artistAvailabilityRepository;

    @Inject
    ShowDateRepository showDateRepository;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Test
    @Transactional
    @DisplayName("getAvailabilitiesForShowDate lève une erreur si la date n'existe pas")
    void getAvailabilitiesForShowDate_whenShowDateNotFound_throwsShowDateNotFoundException() {
        assertThrows(ShowDateNotFoundException.class,
                () -> artistAvailabilityService.getAvailabilitiesForShowDate(999_999L));
    }

    @Test
    @Transactional
    @DisplayName("getAvailabilitiesForShowDate retourne une liste vide si aucune disponibilité n'existe")
    void getAvailabilitiesForShowDate_whenNoAvailability_thenReturnsEmptyList() {
        ShowDateFixture fx = buildShowDateFixture("avail-svc-empty");
        when(managerCompanyResolver.resolveCurrentManagerCompany()).thenReturn(fx.company());

        List<ArtistAvailabilityDto> list = artistAvailabilityService.getAvailabilitiesForShowDate(fx.showDate.getId());

        assertTrue(list.isEmpty());
    }

    @Test
    @Transactional
    @DisplayName("getAvailabilitiesForShowDate retourne toutes les disponibilités de la date")
    void getAvailabilitiesForShowDate_whenSeveralExist_thenReturnsAllDtos() {
        ShowDateFixture fx = buildShowDateFixture("avail-svc-list");
        when(managerCompanyResolver.resolveCurrentManagerCompany()).thenReturn(fx.company());
        VioletteUserEntity a1 = buildAndPersistUser("avail-svc-a1", "avail-svc-a1@test.com", Set.of(UserRole.ARTIST));
        VioletteUserEntity a2 = buildAndPersistUser("avail-svc-a2", "avail-svc-a2@test.com", Set.of(UserRole.ARTIST));
        persistAvailability(fx.showDate, a1, AvailabilityStatus.AVAILABLE);
        persistAvailability(fx.showDate, a2, AvailabilityStatus.UNAVAILABLE);
        artistAvailabilityRepository.flush();

        List<ArtistAvailabilityDto> list = artistAvailabilityService.getAvailabilitiesForShowDate(fx.showDate.getId());

        assertEquals(2, list.size());
        assertTrue(list.stream().anyMatch(d -> d.artistId().equals(a1.getId()) && d.status() == AvailabilityStatus.AVAILABLE));
        assertTrue(list.stream().anyMatch(d -> d.artistId().equals(a2.getId()) && d.status() == AvailabilityStatus.UNAVAILABLE));
    }

    @Test
    @Transactional
    @DisplayName("upsertMyAvailability crée une entrée lorsqu'aucune disponibilité n'existe encore")
    void upsertMyAvailability_whenNoExistingRow_thenCreatesAvailability() {
        ShowDateFixture fx = buildShowDateFixture("avail-svc-ins");
        VioletteUserEntity artist = buildAndPersistUser("avail-svc-ins-art", "avail-svc-ins-art@test.com", Set.of(UserRole.ARTIST));
        JwtPrincipalInfo principal = new JwtPrincipalInfo(artist.getFirebaseUid(), artist.getEmail(), "Artiste Ins");

        ArtistAvailabilityDto dto = artistAvailabilityService.upsertMyAvailability(
                fx.showDate.getId(), principal, AvailabilityStatus.AVAILABLE);

        assertAll(
                () -> assertEquals(fx.showDate.getId(), dto.showDateId()),
                () -> assertEquals(artist.getId(), dto.artistId()),
                () -> assertEquals(artist.getFirebaseUid(), dto.artistFirebaseUid()),
                () -> assertEquals(AvailabilityStatus.AVAILABLE, dto.status()),
                () -> assertEquals("User", dto.artistFirstName()),
                () -> assertEquals("Test", dto.artistLastName())
        );
    }

    @Test
    @Transactional
    @DisplayName("upsertMyAvailability met à jour le statut lorsque l'entrée existe déjà")
    void upsertMyAvailability_whenRowExists_thenUpdatesStatus() {
        ShowDateFixture fx = buildShowDateFixture("avail-svc-upd");
        VioletteUserEntity artist = buildAndPersistUser("avail-svc-upd-art", "avail-svc-upd-art@test.com", Set.of(UserRole.ARTIST));
        persistAvailability(fx.showDate, artist, AvailabilityStatus.AVAILABLE);
        artistAvailabilityRepository.flush();
        JwtPrincipalInfo principal = new JwtPrincipalInfo(artist.getFirebaseUid(), artist.getEmail(), "Artiste Upd");

        ArtistAvailabilityDto dto = artistAvailabilityService.upsertMyAvailability(
                fx.showDate.getId(), principal, AvailabilityStatus.UNAVAILABLE);

        assertEquals(AvailabilityStatus.UNAVAILABLE, dto.status());
        assertEquals(AvailabilityStatus.UNAVAILABLE,
                artistAvailabilityRepository.findById(new ArtistAvailabilityId(fx.showDate.getId(), artist.getId())).getStatus());
    }

    @Test
    @Transactional
    @DisplayName("upsertMyAvailability refuse explicitement le statut PENDING")
    void upsertMyAvailability_whenStatusIsPending_thenThrowsInvalidAvailabilityStatusException() {
        ShowDateFixture fx = buildShowDateFixture("avail-svc-pend");
        VioletteUserEntity artist = buildAndPersistUser("avail-svc-pend-art", "avail-svc-pend-art@test.com", Set.of(UserRole.ARTIST));
        JwtPrincipalInfo principal = new JwtPrincipalInfo(artist.getFirebaseUid(), artist.getEmail(), "Artiste Pend");

        assertThrows(InvalidAvailabilityStatusException.class,
                () -> artistAvailabilityService.upsertMyAvailability(fx.showDate.getId(), principal, AvailabilityStatus.PENDING));
    }

    @Test
    @Transactional
    @DisplayName("upsertMyAvailability lève une erreur si la date n'existe pas")
    void upsertMyAvailability_whenShowDateNotFound_throwsShowDateNotFoundException() {
        VioletteUserEntity artist = buildAndPersistUser("avail-svc-sdnf", "avail-svc-sdnf@test.com", Set.of(UserRole.ARTIST));
        JwtPrincipalInfo principal = new JwtPrincipalInfo(artist.getFirebaseUid(), artist.getEmail(), "X");

        assertThrows(ShowDateNotFoundException.class,
                () -> artistAvailabilityService.upsertMyAvailability(999_998L, principal, AvailabilityStatus.AVAILABLE));
    }

    @Test
    @Transactional
    @DisplayName("upsertMyAvailability lève une erreur si aucun profil backend ne correspond au JWT")
    void upsertMyAvailability_whenUserNotFound_throwsUserNotFoundException() {
        ShowDateFixture fx = buildShowDateFixture("avail-svc-unf");
        JwtPrincipalInfo principal = new JwtPrincipalInfo("inexistant-firebase-uid-xyz", "nope@test.com", "");

        assertThrows(UserNotFoundException.class,
                () -> artistAvailabilityService.upsertMyAvailability(fx.showDate.getId(), principal, AvailabilityStatus.AVAILABLE));
    }

    @Test
    @Transactional
    @DisplayName("upsertMyAvailability persiste correctement le statut IF_NEEDED")
    void upsertMyAvailability_whenIfNeeded_thenPersistsIfNeeded() {
        ShowDateFixture fx = buildShowDateFixture("avail-svc-ifn");
        VioletteUserEntity artist = buildAndPersistUser("avail-svc-ifn-art", "avail-svc-ifn-art@test.com", Set.of(UserRole.ARTIST));
        JwtPrincipalInfo principal = new JwtPrincipalInfo(artist.getFirebaseUid(), artist.getEmail(), "Si besoin");

        ArtistAvailabilityDto dto = artistAvailabilityService.upsertMyAvailability(
                fx.showDate.getId(), principal, AvailabilityStatus.IF_NEEDED);

        assertEquals(AvailabilityStatus.IF_NEEDED, dto.status());
        assertEquals(AvailabilityStatus.IF_NEEDED,
                artistAvailabilityRepository.findById(new ArtistAvailabilityId(fx.showDate.getId(), artist.getId())).getStatus());
    }

    @Test
    @Transactional
    @DisplayName("getMyAvailability retourne PENDING si aucune disponibilité n'existe encore")
    void getMyAvailability_whenNoRow_thenReturnsPending() {
        ShowDateFixture fx = buildShowDateFixture("avail-svc-get-me-pending");
        VioletteUserEntity artist = buildAndPersistUser("avail-svc-get-me-artist", "avail-svc-get-me@test.com", Set.of(UserRole.ARTIST));
        JwtPrincipalInfo principal = new JwtPrincipalInfo(artist.getFirebaseUid(), artist.getEmail(), "Artiste");

        ArtistAvailabilityDto dto = artistAvailabilityService.getMyAvailability(fx.showDate.getId(), principal);

        assertAll(
                () -> assertEquals(fx.showDate.getId(), dto.showDateId()),
                () -> assertEquals(artist.getId(), dto.artistId()),
                () -> assertEquals(AvailabilityStatus.PENDING, dto.status())
        );
    }

    private record ShowDateFixture(ShowDateEntity showDate, CabaretCompanyEntity company) {
    }

    private ShowDateFixture buildShowDateFixture(String seed) {
        VioletteUserEntity manager = buildAndPersistUser(seed + "-mgr", seed + "-mgr@test.com", Set.of(UserRole.MANAGER));
        CabaretCompanyEntity company = buildAndPersistCompany("Compagnie " + seed, manager);
        ShowDateEntity showDate = buildAndPersistShowDate(company, LocalDate.of(2025, 8, 20));
        return new ShowDateFixture(showDate, company);
    }

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
        artistAvailabilityRepository.persist(av);
    }
}
