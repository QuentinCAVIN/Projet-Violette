package io.violette.cabaretcompany.repository;

import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.model.CompanyMemberEntity;
import io.violette.cabaretcompany.model.CompanyMemberId;
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
class CompanyMemberRepositoryTest {

    @Inject
    CompanyMemberRepository companyMemberRepository;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Test
    @Transactional
    void givenMemberWithCompositeKey_whenPersisted_thenCanBeReloadedWithCompanyAndArtist() {
        VioletteUserEntity manager = buildAndPersistUser("uid-mgr-member", "mgr-member@test.com", "Manager", "One", Set.of(UserRole.MANAGER));
        VioletteUserEntity artist = buildAndPersistUser("uid-artist-member", "artist-member@test.com", "Alice", "Artist", Set.of(UserRole.ARTIST));
        CabaretCompanyEntity company = new CabaretCompanyEntity();
        company.setName("Compagnie Membres");
        company.setManager(manager);
        cabaretCompanyRepository.persistAndFlush(company);

        CompanyMemberEntity member = new CompanyMemberEntity();
        member.setId(new CompanyMemberId(company.getId(), artist.getId()));
        member.setCompany(company);
        member.setArtist(artist);
        companyMemberRepository.persistAndFlush(member);

        CompanyMemberEntity found = companyMemberRepository.findById(member.getId());

        assertNotNull(found);
        assertNotNull(found.getId());
        assertAll(
                () -> assertEquals(company.getId(), found.getId().getCompanyId()),
                () -> assertEquals(artist.getId(), found.getId().getArtistId()),
                () -> assertEquals(company.getId(), found.getCompany().getId()),
                () -> assertEquals("Compagnie Membres", found.getCompany().getName()),
                () -> assertEquals(artist.getId(), found.getArtist().getId()),
                () -> assertEquals("Alice", found.getArtist().getFirstName()),
                () -> assertEquals("artist-member@test.com", found.getArtist().getEmail()),
                () -> assertNotNull(found.getJoinedAt())
        );
    }

    @Test
    @Transactional
    void givenMembersInCompany_whenFindByCompanyId_thenReturnAll() {
        VioletteUserEntity manager = buildAndPersistUser("uid-mgr-list", "mgr-list@test.com", "Manager", "List", Set.of(UserRole.MANAGER));
        VioletteUserEntity a1 = buildAndPersistUser("uid-a1-list", "a1@list.test", "Artiste", "Un", Set.of(UserRole.ARTIST));
        VioletteUserEntity a2 = buildAndPersistUser("uid-a2-list", "a2@list.test", "Artiste", "Deux", Set.of(UserRole.ARTIST));
        CabaretCompanyEntity company = new CabaretCompanyEntity();
        company.setName("Compagnie Liste");
        company.setManager(manager);
        cabaretCompanyRepository.persistAndFlush(company);

        persistMember(company, a1);
        persistMember(company, a2);
        companyMemberRepository.flush();

        var list = companyMemberRepository.findByCompanyId(company.getId());

        assertEquals(2, list.size());
        assertTrue(list.stream().anyMatch(m -> m.getArtist().getEmail().equals("a1@list.test")));
        assertTrue(list.stream().anyMatch(m -> m.getArtist().getEmail().equals("a2@list.test")));
    }

    @Test
    @Transactional
    void givenArtistInMultipleCompanies_whenFindByArtistId_thenReturnAllMemberships() {
        VioletteUserEntity manager1 = buildAndPersistUser("uid-mgr-multi-1", "mgr-m1@test.com", "M1", "Manager", Set.of(UserRole.MANAGER));
        VioletteUserEntity manager2 = buildAndPersistUser("uid-mgr-multi-2", "mgr-m2@test.com", "M2", "Manager", Set.of(UserRole.MANAGER));
        VioletteUserEntity artist = buildAndPersistUser("uid-artist-multi", "artist-multi@test.com", "Multi", "Artist", Set.of(UserRole.ARTIST));

        CabaretCompanyEntity company1 = new CabaretCompanyEntity();
        company1.setName("Compagnie Alpha");
        company1.setManager(manager1);
        cabaretCompanyRepository.persist(company1);
        CabaretCompanyEntity company2 = new CabaretCompanyEntity();
        company2.setName("Compagnie Beta");
        company2.setManager(manager2);
        cabaretCompanyRepository.persist(company2);
        cabaretCompanyRepository.flush();

        persistMember(company1, artist);
        persistMember(company2, artist);
        companyMemberRepository.flush();

        var memberships = companyMemberRepository.findByArtistId(artist.getId());

        assertEquals(2, memberships.size());
        assertTrue(memberships.stream().anyMatch(m -> "Compagnie Alpha".equals(m.getCompany().getName())));
        assertTrue(memberships.stream().anyMatch(m -> "Compagnie Beta".equals(m.getCompany().getName())));
    }

    private void persistMember(CabaretCompanyEntity company, VioletteUserEntity artist) {
        CompanyMemberEntity member = new CompanyMemberEntity();
        member.setId(new CompanyMemberId(company.getId(), artist.getId()));
        member.setCompany(company);
        member.setArtist(artist);
        companyMemberRepository.persist(member);
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
