package io.violette.cabaretcompany.repository;

import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.violetteuser.model.ArtistSkill;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

@QuarkusTest
class CabaretCompanyRepositoryTest {

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Test
    @Transactional
    void givenCompanyWithManager_whenPersisted_thenCanBeReloadedWithManager() {
        VioletteUserEntity manager = buildAndPersistUser("uid-mgr-company-1", "mgr@company.test", "Marie", "Manager", Set.of(UserRole.MANAGER));
        CabaretCompanyEntity company = new CabaretCompanyEntity();
        company.setName("Compagnie Test");
        company.setDescription("Description de la compagnie");
        company.setManager(manager);
        cabaretCompanyRepository.persistAndFlush(company);

        CabaretCompanyEntity found = cabaretCompanyRepository.findById(company.getId());

        assertNotNull(found);
        assertAll(
                () -> assertEquals("Compagnie Test", found.getName()),
                () -> assertEquals("Description de la compagnie", found.getDescription()),
                () -> assertNotNull(found.getManager()),
                () -> assertEquals(manager.getId(), found.getManager().getId()),
                () -> assertEquals("Marie", found.getManager().getFirstName()),
                () -> assertEquals("mgr@company.test", found.getManager().getEmail()),
                () -> assertNotNull(found.getCreatedAt()),
                () -> assertNotNull(found.getUpdatedAt())
        );
    }

    @Test
    @Transactional
    void givenCompaniesWithSameManager_whenFindByManagerId_thenReturnAll() {
        VioletteUserEntity manager = buildAndPersistUser("uid-mgr-multi", "mgr-multi@test.com", "Jean", "Gérant", Set.of(UserRole.MANAGER));
        CabaretCompanyEntity c1 = new CabaretCompanyEntity();
        c1.setName("Compagnie A");
        c1.setManager(manager);
        cabaretCompanyRepository.persist(c1);
        CabaretCompanyEntity c2 = new CabaretCompanyEntity();
        c2.setName("Compagnie B");
        c2.setManager(manager);
        cabaretCompanyRepository.persist(c2);
        cabaretCompanyRepository.flush();

        var list = cabaretCompanyRepository.findByManagerId(manager.getId());

        assertEquals(2, list.size());
        assertTrue(list.stream().anyMatch(e -> "Compagnie A".equals(e.getName())));
        assertTrue(list.stream().anyMatch(e -> "Compagnie B".equals(e.getName())));
    }

    @Test
    @Transactional
    void givenCompany_whenFindByName_thenReturnCompany() {
        VioletteUserEntity manager = buildAndPersistUser("uid-mgr-name", "mgr-name@test.com", "Paul", "Dupont", Set.of(UserRole.MANAGER));
        CabaretCompanyEntity company = new CabaretCompanyEntity();
        company.setName("Compagnie Unique Name");
        company.setManager(manager);
        cabaretCompanyRepository.persistAndFlush(company);

        var found = cabaretCompanyRepository.findByName("Compagnie Unique Name");

        assertTrue(found.isPresent());
        assertEquals("Compagnie Unique Name", found.get().getName());
        assertEquals(manager.getId(), found.get().getManager().getId());
    }

    private VioletteUserEntity buildAndPersistUser(String firebaseUid, String email, String firstName, String lastName, Set<UserRole> roles) {
        VioletteUserEntity user = new VioletteUserEntity();
        user.setFirebaseUid(firebaseUid);
        user.setEmail(email);
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setRoles(roles != null ? roles : Set.of());
        user.setSkills(Set.of(ArtistSkill.DANCE));
        violetteUserRepository.persistAndFlush(user);
        return user;
    }
}
