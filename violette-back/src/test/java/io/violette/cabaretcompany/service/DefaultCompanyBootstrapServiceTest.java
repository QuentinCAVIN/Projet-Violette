package io.violette.cabaretcompany.service;

import io.quarkus.test.junit.QuarkusTest;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.model.CompanyMemberEntity;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.cabaretcompany.repository.CompanyMemberRepository;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

@QuarkusTest
class DefaultCompanyBootstrapServiceTest {

    @Inject
    CabaretCompanyService cabaretCompanyService;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Inject
    CompanyMemberRepository companyMemberRepository;

    @Test
    @Transactional
    @DisplayName("Bootstrap compagnie unique : créer Dream's Production si absente")
    void ensureDefaultCompanyExists_whenMissing_createsDefaultCompany() {
        companyMemberRepository.deleteAll();
        cabaretCompanyRepository.deleteAll();
        violetteUserRepository.deleteAll();
        violetteUserRepository.flush();

        VioletteUserEntity manager = persistUser(
                "uid-default-manager-1",
                "manager1@dreams.test",
                Set.of(UserRole.MANAGER)
        );

        CabaretCompanyEntity created = cabaretCompanyService.ensureDefaultCompanyExists();

        assertNotNull(created);
        assertEquals(CabaretCompanyService.DEFAULT_COMPANY_NAME, created.getName());
        assertEquals(manager.getId(), created.getManager().getId());
        assertEquals(1, cabaretCompanyRepository.count());
    }

    @Test
    @Transactional
    @DisplayName("Bootstrap compagnie unique : ne pas dupliquer Dream's Production si déjà présente")
    void ensureDefaultCompanyExists_whenAlreadyPresent_doesNotDuplicate() {
        companyMemberRepository.deleteAll();
        cabaretCompanyRepository.deleteAll();
        violetteUserRepository.deleteAll();
        violetteUserRepository.flush();

        VioletteUserEntity manager = persistUser(
                "uid-default-manager-2",
                "manager2@dreams.test",
                Set.of(UserRole.MANAGER)
        );

        CabaretCompanyEntity company = new CabaretCompanyEntity();
        company.setName(CabaretCompanyService.DEFAULT_COMPANY_NAME);
        company.setDescription("Compagnie existante");
        company.setManager(manager);
        cabaretCompanyRepository.persistAndFlush(company);

        cabaretCompanyService.ensureDefaultCompanyExists();

        assertEquals(1, cabaretCompanyRepository.count());
        assertTrue(cabaretCompanyRepository.findByName(CabaretCompanyService.DEFAULT_COMPANY_NAME).isPresent());
    }

    @Test
    @Transactional
    @DisplayName("Rattachement bootstrap : MANAGER+ARTIST ne crée pas de doublon d'appartenance")
    void ensureUserAttachedToDefaultCompany_whenCalledTwice_createsSingleMembership() {
        cabaretCompanyRepository.deleteAll();
        companyMemberRepository.deleteAll();
        violetteUserRepository.deleteAll();
        violetteUserRepository.flush();

        VioletteUserEntity user = persistUser(
                "uid-dual-role-bootstrap",
                "dual-role@dreams.test",
                Set.of(UserRole.MANAGER, UserRole.ARTIST)
        );

        cabaretCompanyService.ensureUserAttachedToDefaultCompany(user);
        cabaretCompanyService.ensureUserAttachedToDefaultCompany(user);

        CabaretCompanyEntity company = cabaretCompanyRepository.findByName(CabaretCompanyService.DEFAULT_COMPANY_NAME)
                .orElseThrow();
        var memberships = companyMemberRepository.findByArtistId(user.getId());

        assertEquals(1, cabaretCompanyRepository.count());
        assertEquals(user.getId(), company.getManager().getId());
        assertEquals(1, memberships.size());
        CompanyMemberEntity membership = memberships.getFirst();
        assertEquals(company.getId(), membership.getCompany().getId());
    }

    private VioletteUserEntity persistUser(String uid, String email, Set<UserRole> roles) {
        VioletteUserEntity user = new VioletteUserEntity();
        user.setFirebaseUid(uid);
        user.setEmail(email);
        user.setFirstName("Manager");
        user.setLastName("Bootstrap");
        user.setRoles(roles);
        violetteUserRepository.persistAndFlush(user);
        return user;
    }
}
