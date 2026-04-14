package io.violette.showdate.repository;

import io.quarkus.test.junit.QuarkusTest;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.model.CabaretShowEntity;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.cabaretcompany.repository.CabaretShowRepository;
import io.violette.showdate.model.ShowDateEntity;
import io.violette.showdate.model.ShowDateStatus;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;

@QuarkusTest
class ShowDateRepositoryTest {

    @Inject
    ShowDateRepository showDateRepository;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    CabaretShowRepository cabaretShowRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Test
    @Transactional
    void givenShowDateWithAllLogisticsFields_whenPersisted_thenCanBeFullyReloaded() {
        CabaretCompanyEntity company = buildAndPersistCompany("sd-mgr-1", "sd-mgr-1@test.com", "Compagnie Logistics");

        ShowDateEntity showDate = buildShowDate(company, LocalDate.of(2025, 6, 15), LocalTime.of(9, 0));
        showDate.setShowDetails("Grande revue d'été — décor baroque");
        showDateRepository.persistAndFlush(showDate);

        ShowDateEntity found = showDateRepository.findById(showDate.getId());

        assertNotNull(found);
        assertAll(
                () -> assertEquals(LocalDate.of(2025, 6, 15), found.getEventDate()),
                () -> assertEquals(LocalTime.of(9, 0), found.getMeetingTime()),
                () -> assertEquals("42 rue des Arts, 75001 Paris", found.getLocation()),
                () -> assertEquals("Jean Client", found.getClientContactName()),
                () -> assertEquals("0600000001", found.getClientContactPhone()),
                () -> assertEquals("Grande revue d'été — décor baroque", found.getShowDetails()),
                () -> assertEquals(ShowDateStatus.PENDING, found.getStatus()),
                () -> assertNotNull(found.getCreatedAt()),
                () -> assertNotNull(found.getUpdatedAt()),
                () -> assertNotNull(found.getCompany()),
                () -> assertEquals(company.getId(), found.getCompany().getId()),
                () -> assertEquals("Compagnie Logistics", found.getCompany().getName())
        );
    }

    @Test
    @Transactional
    void givenShowDateWithOptionalCabaretShow_whenPersisted_thenCabaretShowIsLinked() {
        CabaretCompanyEntity company = buildAndPersistCompany("sd-mgr-2", "sd-mgr-2@test.com", "Compagnie Revue Liée");

        CabaretShowEntity cabaretShow = new CabaretShowEntity();
        cabaretShow.setCompany(company);
        cabaretShow.setTitle("Revue des Saisons");
        cabaretShowRepository.persistAndFlush(cabaretShow);

        ShowDateEntity showDate = buildShowDate(company, LocalDate.of(2025, 7, 20), LocalTime.of(14, 0));
        showDate.setCabaretShow(cabaretShow);
        showDateRepository.persistAndFlush(showDate);

        ShowDateEntity found = showDateRepository.findById(showDate.getId());

        assertNotNull(found.getCabaretShow());
        assertAll(
                () -> assertEquals(cabaretShow.getId(), found.getCabaretShow().getId()),
                () -> assertEquals("Revue des Saisons", found.getCabaretShow().getTitle())
        );
    }

    @Test
    @Transactional
    void givenShowDateWithoutCabaretShow_whenPersisted_thenCabaretShowIsNull() {
        CabaretCompanyEntity company = buildAndPersistCompany("sd-mgr-3", "sd-mgr-3@test.com", "Compagnie Sans Revue");

        ShowDateEntity showDate = buildShowDate(company, LocalDate.of(2025, 8, 10), LocalTime.of(20, 30));
        showDateRepository.persistAndFlush(showDate);

        ShowDateEntity found = showDateRepository.findById(showDate.getId());

        assertNull(found.getCabaretShow());
    }

    @Test
    @Transactional
    void givenShowDateWithLocation_whenPersisted_thenLocationIsStored() {
        CabaretCompanyEntity company = buildAndPersistCompany("sd-mgr-4", "sd-mgr-4@test.com", "Compagnie Sans Lieu");

        ShowDateEntity showDate = buildShowDate(company, LocalDate.of(2025, 9, 5), LocalTime.of(10, 0));
        showDateRepository.persistAndFlush(showDate);

        ShowDateEntity found = showDateRepository.findById(showDate.getId());

        assertEquals("42 rue des Arts, 75001 Paris", found.getLocation());
    }

    @Test
    @Transactional
    void givenMultipleShowDatesForCompany_whenFindByCompanyId_thenReturnAllOrderedByEventDateAsc() {
        CabaretCompanyEntity company = buildAndPersistCompany("sd-mgr-5", "sd-mgr-5@test.com", "Compagnie Multi-Dates");

        showDateRepository.persist(buildShowDate(company, LocalDate.of(2025, 9, 1), LocalTime.of(9, 0)));
        showDateRepository.persist(buildShowDate(company, LocalDate.of(2025, 7, 1), LocalTime.of(9, 0)));
        showDateRepository.persist(buildShowDate(company, LocalDate.of(2025, 11, 1), LocalTime.of(9, 0)));
        showDateRepository.flush();

        List<ShowDateEntity> list = showDateRepository.findByCompanyId(company.getId());

        assertEquals(3, list.size());
        assertEquals(LocalDate.of(2025, 7, 1), list.get(0).getEventDate());
        assertEquals(LocalDate.of(2025, 9, 1), list.get(1).getEventDate());
        assertEquals(LocalDate.of(2025, 11, 1), list.get(2).getEventDate());
    }

    // --- Helpers ---

    private CabaretCompanyEntity buildAndPersistCompany(String managerUid, String managerEmail, String companyName) {
        VioletteUserEntity manager = new VioletteUserEntity();
        manager.setFirebaseUid(managerUid);
        manager.setEmail(managerEmail);
        manager.setFirstName("Manager");
        manager.setLastName("Test");
        manager.setRoles(Set.of(UserRole.MANAGER));
        manager.setSkills(Set.of());
        violetteUserRepository.persistAndFlush(manager);

        CabaretCompanyEntity company = new CabaretCompanyEntity();
        company.setName(companyName);
        company.setManager(manager);
        cabaretCompanyRepository.persistAndFlush(company);
        return company;
    }

    private ShowDateEntity buildShowDate(CabaretCompanyEntity company, LocalDate date, LocalTime meetingTime) {
        ShowDateEntity sd = new ShowDateEntity();
        sd.setCompany(company);
        sd.setEventDate(date);
        sd.setMeetingTime(meetingTime);
        sd.setLocation("42 rue des Arts, 75001 Paris");
        sd.setClientContactName("Jean Client");
        sd.setClientContactPhone("0600000001");
        return sd;
    }
}
