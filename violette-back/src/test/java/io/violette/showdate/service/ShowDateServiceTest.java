package io.violette.showdate.service;

import io.quarkus.test.junit.QuarkusTest;
import io.violette.artistbooking.model.ArtistBookingEntity;
import io.violette.artistbooking.model.BookingStatus;
import io.violette.artistbooking.repository.ArtistBookingRepository;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.model.CabaretShowEntity;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.cabaretcompany.repository.CabaretShowRepository;
import io.violette.showdate.dto.CreateShowDateRequestDto;
import io.violette.showdate.dto.CreateSkillRequirementRequestDto;
import io.violette.showdate.dto.ShowDateDto;
import io.violette.showdate.dto.UpdateShowDateRequestDto;
import io.violette.showdate.exception.ShowDateNotFoundException;
import io.violette.showdate.model.ShowDateEntity;
import io.violette.showdate.repository.ShowDateRepository;
import io.violette.violetteuser.model.ArtistSkill;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

@QuarkusTest
class ShowDateServiceTest {

    private static final DateTimeFormatter DISPLAY_TITLE_DATE_FORMAT =
            DateTimeFormatter.ofPattern("d MMMM yyyy", Locale.FRENCH);

    @Inject
    ShowDateService showDateService;

    @Inject
    ShowDateRepository showDateRepository;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    CabaretShowRepository cabaretShowRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Inject
    ArtistBookingRepository artistBookingRepository;

    @Test
    @Transactional
    @DisplayName("Le titre affiché inclut le libellé de la revue lorsque celle-ci est liée")
    void getById_whenCabaretShowLinked_thenDisplayTitleIncludesShowTitleLocationAndFormattedDate() {
        Seed seed = seedCompanyAndManager("svc-dt-1");
        CabaretShowEntity revue = persistCabaretShow(seed.company, "Les Étoiles d'hiver");
        LocalDate eventDate = LocalDate.of(2025, 3, 8);

        ShowDateDto created = showDateService.createShowDate(new CreateShowDateRequestDto(
                seed.company.getId(),
                revue.getId(),
                eventDate,
                LocalTime.of(20, 30),
                "Paris 11e",
                "Contact Titre",
                "0601020304",
                null
        ));

        ShowDateDto dto = showDateService.getById(created.id());

        String expected = "Les Étoiles d'hiver — Paris 11e — " + DISPLAY_TITLE_DATE_FORMAT.format(eventDate);
        assertEquals(expected, dto.displayTitle());
    }

    @Test
    @Transactional
    @DisplayName("Le titre affiché ne contient pas de libellé de revue lorsqu'aucune revue n'est liée")
    void getById_whenCabaretShowAbsent_thenDisplayTitleIncludesOnlyLocationAndFormattedDate() {
        Seed seed = seedCompanyAndManager("svc-dt-2");
        LocalDate eventDate = LocalDate.of(2026, 7, 20);

        ShowDateDto created = showDateService.createShowDate(new CreateShowDateRequestDto(
                seed.company.getId(),
                null,
                eventDate,
                LocalTime.of(19, 0),
                "Lille — salle municipale",
                "Contact Sans Revue",
                "0607080910",
                null
        ));

        ShowDateDto dto = showDateService.getById(created.id());

        String expected = "Lille — salle municipale — " + DISPLAY_TITLE_DATE_FORMAT.format(eventDate);
        assertEquals(expected, dto.displayTitle());
    }

    @Test
    @Transactional
    @DisplayName("totalRequiredArtists est la somme des effectifs requis des besoins artistiques")
    void getById_whenMultipleSkillRequirementsExist_thenTotalRequiredArtistsEqualsSum() {
        Seed seed = seedCompanyAndManager("svc-tr-1");

        ShowDateDto created = showDateService.createShowDate(new CreateShowDateRequestDto(
                seed.company.getId(),
                null,
                LocalDate.of(2025, 11, 1),
                LocalTime.of(10, 0),
                "Lyon",
                "Contact Req",
                "0611121314",
                null
        ));

        showDateService.addSkillRequirement(created.id(), new CreateSkillRequirementRequestDto(
                ArtistSkill.DANCE, 2, new BigDecimal("100.00")));
        showDateService.addSkillRequirement(created.id(), new CreateSkillRequirementRequestDto(
                ArtistSkill.SINGING, 3, new BigDecimal("120.00")));

        ShowDateDto dto = showDateService.getById(created.id());
        assertEquals(5, dto.totalRequiredArtists());
    }

    @Test
    @Transactional
    @DisplayName("totalRequiredArtists vaut 0 lorsqu'aucun besoin artistique n'est défini")
    void createShowDate_whenNoSkillRequirements_thenTotalRequiredArtistsIsZero() {
        Seed seed = seedCompanyAndManager("svc-tr-0");

        ShowDateDto dto = showDateService.createShowDate(new CreateShowDateRequestDto(
                seed.company.getId(),
                null,
                LocalDate.of(2025, 4, 2),
                LocalTime.of(14, 0),
                "Marseille",
                "Contact Zéro",
                "0699988776",
                null
        ));

        assertEquals(0, dto.totalRequiredArtists());
    }

    @Test
    @Transactional
    @DisplayName("selectedCount ne compte que les réservations sélectionnées, en attente ou confirmées")
    void getById_whenBookingsHaveMixedStatuses_thenSelectedCountCountsOnlyActiveOnes() {
        Seed seed = seedCompanyAndManager("svc-sc-1");

        ShowDateDto created = showDateService.createShowDate(new CreateShowDateRequestDto(
                seed.company.getId(),
                null,
                LocalDate.of(2025, 12, 15),
                LocalTime.of(21, 0),
                "Bordeaux",
                "Contact Book",
                "0655443322",
                null
        ));

        ShowDateEntity showDate = showDateRepository.findByIdOptional(created.id()).orElseThrow();

        persistBooking(showDate, persistArtist("svc-sc-a1"), BookingStatus.SELECTED);
        persistBooking(showDate, persistArtist("svc-sc-a2"), BookingStatus.PENDING_CONFIRMATION);
        persistBooking(showDate, persistArtist("svc-sc-a3"), BookingStatus.CONFIRMED);
        persistBooking(showDate, persistArtist("svc-sc-a4"), BookingStatus.REFUSED);
        persistBooking(showDate, persistArtist("svc-sc-a5"), BookingStatus.CANCELLED);
        artistBookingRepository.flush();

        ShowDateDto dto = showDateService.getById(created.id());
        assertEquals(3, dto.selectedCount());
    }

    @Test
    @Transactional
    @DisplayName("deleteShowDate supprime la date existante par id")
    void deleteShowDate_whenShowDateExists_thenDeleteRow() {
        Seed seed = seedCompanyAndManager("svc-del-ok");
        ShowDateDto created = showDateService.createShowDate(new CreateShowDateRequestDto(
                seed.company.getId(),
                null,
                LocalDate.of(2026, 3, 8),
                LocalTime.of(18, 0),
                "Nantes",
                "Contact Delete",
                "0600001122",
                null
        ));

        showDateService.deleteShowDate(created.id());

        assertEquals(0, showDateRepository.count("id", created.id()));
    }

    @Test
    @Transactional
    @DisplayName("deleteShowDate lève ShowDateNotFoundException si l'id est introuvable")
    void deleteShowDate_whenShowDateMissing_thenThrowNotFound() {
        assertThrows(ShowDateNotFoundException.class, () -> showDateService.deleteShowDate(999_999L));
    }

    @Test
    @Transactional
    @DisplayName("updateShowDate met à jour uniquement les champs fournis")
    void updateShowDate_whenPartialPayload_thenOnlyProvidedFieldsAreUpdated() {
        Seed seed = seedCompanyAndManager("svc-upd-ok");
        ShowDateDto created = showDateService.createShowDate(new CreateShowDateRequestDto(
                seed.company.getId(),
                null,
                LocalDate.of(2026, 4, 10),
                LocalTime.of(17, 30),
                "Lyon",
                "Contact Initial",
                "0600001111",
                "Détails initiaux"
        ));

        ShowDateDto updated = showDateService.updateShowDate(created.id(), new UpdateShowDateRequestDto(
                LocalDate.of(2026, 4, 11),
                null,
                "Lyon - Centre",
                null,
                null,
                "Détails modifiés"
        ));

        assertEquals(LocalDate.of(2026, 4, 11), updated.eventDate());
        assertEquals(LocalTime.of(17, 30), updated.meetingTime());
        assertEquals("Lyon - Centre", updated.location());
        assertEquals("Contact Initial", updated.clientContactName());
        assertEquals("0600001111", updated.clientContactPhone());
        assertEquals("Détails modifiés", updated.showDetails());
    }

    @Test
    @Transactional
    @DisplayName("updateShowDate lève ShowDateNotFoundException si l'id est introuvable")
    void updateShowDate_whenShowDateMissing_thenThrowNotFound() {
        assertThrows(ShowDateNotFoundException.class, () -> showDateService.updateShowDate(
                999_999L,
                new UpdateShowDateRequestDto(LocalDate.now(), null, null, null, null, null)
        ));
    }

    private record Seed(CabaretCompanyEntity company, VioletteUserEntity manager) {
    }

    private Seed seedCompanyAndManager(String uidPrefix) {
        VioletteUserEntity manager = new VioletteUserEntity();
        manager.setFirebaseUid(uidPrefix + "-mgr");
        manager.setEmail(uidPrefix + "-mgr@test.com");
        manager.setFirstName("Manager");
        manager.setLastName("Test");
        manager.setRoles(Set.of(UserRole.MANAGER));
        manager.setSkills(Set.of());
        violetteUserRepository.persistAndFlush(manager);

        CabaretCompanyEntity company = new CabaretCompanyEntity();
        company.setName("Compagnie " + uidPrefix);
        company.setManager(manager);
        cabaretCompanyRepository.persistAndFlush(company);
        return new Seed(company, manager);
    }

    private CabaretShowEntity persistCabaretShow(CabaretCompanyEntity company, String title) {
        CabaretShowEntity show = new CabaretShowEntity();
        show.setCompany(company);
        show.setTitle(title);
        cabaretShowRepository.persistAndFlush(show);
        return show;
    }

    private VioletteUserEntity persistArtist(String firebaseUid) {
        VioletteUserEntity artist = new VioletteUserEntity();
        artist.setFirebaseUid(firebaseUid);
        artist.setEmail(firebaseUid + "@test.com");
        artist.setFirstName("Artiste");
        artist.setLastName("Test");
        artist.setRoles(Set.of(UserRole.ARTIST));
        artist.setSkills(Set.of());
        violetteUserRepository.persistAndFlush(artist);
        return artist;
    }

    private void persistBooking(ShowDateEntity showDate, VioletteUserEntity artist, BookingStatus status) {
        ArtistBookingEntity booking = new ArtistBookingEntity();
        booking.setShowDate(showDate);
        booking.setArtist(artist);
        booking.setStatus(status);
        artistBookingRepository.persist(booking);
    }
}
