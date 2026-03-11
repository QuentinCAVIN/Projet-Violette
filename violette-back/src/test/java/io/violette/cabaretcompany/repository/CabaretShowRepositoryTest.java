package io.violette.cabaretcompany.repository;

import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.model.CabaretShowEntity;
import io.violette.violetteuser.model.ArtistSkill;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.Test;

import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

@io.quarkus.test.junit.QuarkusTest
class CabaretShowRepositoryTest {

    @Inject
    CabaretShowRepository cabaretShowRepository;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Test
    @Transactional
    void givenShowForCompany_whenPersisted_thenCanBeReloadedWithCompany() {
        CabaretCompanyEntity company = createCompanyWithManager("Compagnie Revues", "uid-mgr-show-1", "mgr-show@test.com");
        cabaretCompanyRepository.persistAndFlush(company);

        CabaretShowEntity show = new CabaretShowEntity();
        show.setCompany(company);
        show.setTitle("Revue 2025");
        show.setDescription("La grande revue");
        cabaretShowRepository.persistAndFlush(show);

        CabaretShowEntity found = cabaretShowRepository.findById(show.getId());

        assertNotNull(found);
        assertAll(
                () -> assertEquals("Revue 2025", found.getTitle()),
                () -> assertEquals("La grande revue", found.getDescription()),
                () -> assertNotNull(found.getCompany()),
                () -> assertEquals(company.getId(), found.getCompany().getId()),
                () -> assertEquals("Compagnie Revues", found.getCompany().getName()),
                () -> assertNotNull(found.getCreatedAt()),
                () -> assertNotNull(found.getUpdatedAt())
        );
    }

    @Test
    @Transactional
    void givenMultipleShowsForSameCompany_whenFindByCompanyId_thenReturnAll() {
        CabaretCompanyEntity company = createCompanyWithManager("Compagnie Multi-Revues", "uid-mgr-multi-show", "mgr-multi-show@test.com");
        cabaretCompanyRepository.persistAndFlush(company);

        CabaretShowEntity s1 = new CabaretShowEntity();
        s1.setCompany(company);
        s1.setTitle("Revue 1");
        cabaretShowRepository.persist(s1);
        CabaretShowEntity s2 = new CabaretShowEntity();
        s2.setCompany(company);
        s2.setTitle("Revue 2");
        cabaretShowRepository.persist(s2);
        cabaretShowRepository.flush();

        var list = cabaretShowRepository.findByCompanyId(company.getId());

        assertEquals(2, list.size());
        assertTrue(list.stream().anyMatch(e -> "Revue 1".equals(e.getTitle())));
        assertTrue(list.stream().anyMatch(e -> "Revue 2".equals(e.getTitle())));
    }

    private CabaretCompanyEntity createCompanyWithManager(String companyName, String managerUid, String managerEmail) {
        VioletteUserEntity manager = new VioletteUserEntity();
        manager.setFirebaseUid(managerUid);
        manager.setEmail(managerEmail);
        manager.setFirstName("Manager");
        manager.setLastName("Show");
        manager.setRoles(Set.of(UserRole.MANAGER));
        manager.setSkills(Set.of(ArtistSkill.DANCE));
        violetteUserRepository.persistAndFlush(manager);
        CabaretCompanyEntity company = new CabaretCompanyEntity();
        company.setName(companyName);
        company.setManager(manager);
        return company;
    }
}
