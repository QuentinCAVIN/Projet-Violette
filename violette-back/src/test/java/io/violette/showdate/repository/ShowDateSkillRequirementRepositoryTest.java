package io.violette.showdate.repository;

import io.quarkus.test.junit.QuarkusTest;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.showdate.model.ShowDateEntity;
import io.violette.showdate.model.ShowDateSkillRequirementEntity;
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
import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

@QuarkusTest
class ShowDateSkillRequirementRepositoryTest {

    @Inject
    ShowDateSkillRequirementRepository skillRequirementRepository;

    @Inject
    ShowDateRepository showDateRepository;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Test
    @Transactional
    @DisplayName("Un besoin artistique persisté est relu avec tous ses champs")
    void givenSkillRequirement_whenPersisted_thenAllFieldsCanBeReloaded() {
        ShowDateEntity showDate = buildAndPersistShowDate("req-mgr-1", "req-mgr-1@test.com");

        ShowDateSkillRequirementEntity req = new ShowDateSkillRequirementEntity();
        req.setShowDate(showDate);
        req.setSkill(ArtistSkill.DANCE);
        req.setRequiredCount(2);
        req.setNetFee(new BigDecimal("120.00"));
        skillRequirementRepository.persistAndFlush(req);

        ShowDateSkillRequirementEntity found = skillRequirementRepository.findById(req.getId());

        assertNotNull(found);
        assertAll(
                () -> assertEquals(ArtistSkill.DANCE, found.getSkill()),
                () -> assertEquals(2, found.getRequiredCount()),
                () -> assertEquals(new BigDecimal("120.00"), found.getNetFee()),
                () -> assertNotNull(found.getShowDate()),
                () -> assertEquals(showDate.getId(), found.getShowDate().getId())
        );
    }

    @Test
    @Transactional
    @DisplayName("Pour une date, findByShowDateId retourne tous les besoins liés")
    void givenMultipleSkillRequirementsForSameDate_whenFindByShowDateId_thenReturnAll() {
        ShowDateEntity showDate = buildAndPersistShowDate("req-mgr-2", "req-mgr-2@test.com");

        ShowDateSkillRequirementEntity dance = buildRequirement(showDate, ArtistSkill.DANCE, 2, "120.00");
        ShowDateSkillRequirementEntity singing = buildRequirement(showDate, ArtistSkill.SINGING, 1, "150.00");
        ShowDateSkillRequirementEntity stilt = buildRequirement(showDate, ArtistSkill.STILT_WALKING, 2, "180.00");
        skillRequirementRepository.persist(dance);
        skillRequirementRepository.persist(singing);
        skillRequirementRepository.persist(stilt);
        skillRequirementRepository.flush();

        List<ShowDateSkillRequirementEntity> list = skillRequirementRepository.findByShowDateId(showDate.getId());

        assertEquals(3, list.size());
        assertTrue(list.stream().anyMatch(r -> r.getSkill() == ArtistSkill.DANCE));
        assertTrue(list.stream().anyMatch(r -> r.getSkill() == ArtistSkill.SINGING));
        assertTrue(list.stream().anyMatch(r -> r.getSkill() == ArtistSkill.STILT_WALKING));
    }

    @Test
    @Transactional
    @DisplayName("Pour deux dates distinctes, findByShowDateId ne mélange pas les besoins")
    void givenTwoDatesWithDifferentRequirements_whenFindByShowDateId_thenReturnOnlyCorrectDate() {
        ShowDateEntity date1 = buildAndPersistShowDate("req-mgr-3", "req-mgr-3@test.com");
        ShowDateEntity date2 = buildAndPersistShowDate("req-mgr-4", "req-mgr-4@test.com");

        skillRequirementRepository.persist(buildRequirement(date1, ArtistSkill.DANCE, 2, "120.00"));
        skillRequirementRepository.persist(buildRequirement(date2, ArtistSkill.SINGING, 1, "150.00"));
        skillRequirementRepository.persist(buildRequirement(date2, ArtistSkill.ACROBATICS, 1, "200.00"));
        skillRequirementRepository.flush();

        List<ShowDateSkillRequirementEntity> date1Requirements = skillRequirementRepository.findByShowDateId(date1.getId());
        List<ShowDateSkillRequirementEntity> date2Requirements = skillRequirementRepository.findByShowDateId(date2.getId());

        assertEquals(1, date1Requirements.size());
        assertEquals(ArtistSkill.DANCE, date1Requirements.get(0).getSkill());

        assertEquals(2, date2Requirements.size());
        assertTrue(date2Requirements.stream().anyMatch(r -> r.getSkill() == ArtistSkill.SINGING));
        assertTrue(date2Requirements.stream().anyMatch(r -> r.getSkill() == ArtistSkill.ACROBATICS));
    }

    @Test
    @Transactional
    @DisplayName("Un besoin avec cachet net à zéro est accepté en persistance")
    void givenSkillRequirementWithNetFeeZero_whenPersisted_thenNetFeeIsAccepted() {
        ShowDateEntity showDate = buildAndPersistShowDate("req-mgr-5", "req-mgr-5@test.com");

        ShowDateSkillRequirementEntity req = buildRequirement(showDate, ArtistSkill.ACROBATICS, 1, "0.00");
        skillRequirementRepository.persistAndFlush(req);

        ShowDateSkillRequirementEntity found = skillRequirementRepository.findById(req.getId());

        assertEquals(new BigDecimal("0.00"), found.getNetFee());
    }

    @Test
    @Transactional
    @DisplayName("sumRequiredCountByShowDateId additionne les effectifs requis de tous les besoins de la date")
    void sumRequiredCountByShowDateId_whenMultipleRequirementsExist_returnsSumOfRequiredCounts() {
        ShowDateEntity showDate = buildAndPersistShowDate("req-mgr-6", "req-mgr-6@test.com");

        skillRequirementRepository.persist(buildRequirement(showDate, ArtistSkill.DANCE, 2, "120.00"));
        skillRequirementRepository.persist(buildRequirement(showDate, ArtistSkill.SINGING, 1, "150.00"));
        skillRequirementRepository.persist(buildRequirement(showDate, ArtistSkill.ACROBATICS, 3, "200.00"));
        skillRequirementRepository.flush();

        int total = skillRequirementRepository.sumRequiredCountByShowDateId(showDate.getId());

        assertEquals(6, total);
    }

    @Test
    @Transactional
    @DisplayName("sumRequiredCountByShowDateId retourne 0 lorsqu'aucun besoin n'existe pour la date")
    void sumRequiredCountByShowDateId_whenNoRequirementsExist_returnsZero() {
        ShowDateEntity showDate = buildAndPersistShowDate("req-mgr-7", "req-mgr-7@test.com");

        int total = skillRequirementRepository.sumRequiredCountByShowDateId(showDate.getId());

        assertEquals(0, total);
    }

    // --- Helpers ---

    private ShowDateEntity buildAndPersistShowDate(String managerUid, String managerEmail) {
        VioletteUserEntity manager = new VioletteUserEntity();
        manager.setFirebaseUid(managerUid);
        manager.setEmail(managerEmail);
        manager.setFirstName("Manager");
        manager.setLastName("Req");
        manager.setRoles(Set.of(UserRole.MANAGER));
        manager.setSkills(Set.of());
        violetteUserRepository.persistAndFlush(manager);

        CabaretCompanyEntity company = new CabaretCompanyEntity();
        company.setName("Compagnie " + managerUid);
        company.setManager(manager);
        cabaretCompanyRepository.persistAndFlush(company);

        ShowDateEntity sd = new ShowDateEntity();
        sd.setCompany(company);
        sd.setEventDate(LocalDate.of(2025, 10, 1));
        sd.setMeetingTime(LocalTime.of(9, 0));
        sd.setLocation("12 avenue de l'Art, Lyon");
        sd.setClientContactName("Marie Dupont");
        sd.setClientContactPhone("0700000001");
        showDateRepository.persistAndFlush(sd);
        return sd;
    }

    private ShowDateSkillRequirementEntity buildRequirement(ShowDateEntity showDate, ArtistSkill skill,
                                                             int requiredCount, String netFee) {
        ShowDateSkillRequirementEntity req = new ShowDateSkillRequirementEntity();
        req.setShowDate(showDate);
        req.setSkill(skill);
        req.setRequiredCount(requiredCount);
        req.setNetFee(new BigDecimal(netFee));
        return req;
    }
}
