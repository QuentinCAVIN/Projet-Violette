package io.violette.cabaretcompany.service;

import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import io.violette.artistbooking.repository.ArtistBookingRepository;
import io.violette.cabaretcompany.dto.CabaretShowDto;
import io.violette.cabaretcompany.exception.CabaretCompanyNotFoundException;
import io.violette.cabaretcompany.exception.CabaretShowNotFoundException;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.model.CabaretShowEntity;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.cabaretcompany.repository.CabaretShowRepository;
import io.violette.cabaretcompany.repository.CompanyMemberRepository;
import io.violette.security.ManagerCompanyResolver;
import io.violette.security.exception.ForbiddenCompanyAccessException;
import io.violette.showdate.repository.ArtistAvailabilityRepository;
import io.violette.showdate.repository.ShowDateRepository;
import io.violette.showdate.repository.ShowDateSkillRequirementRepository;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doThrow;

@QuarkusTest
class CabaretShowServiceTest {

    @InjectMock
    ManagerCompanyResolver managerCompanyResolver;

    @Inject
    CabaretShowService cabaretShowService;

    @Inject
    CabaretShowRepository cabaretShowRepository;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Inject
    CompanyMemberRepository companyMemberRepository;

    @Inject
    ShowDateRepository showDateRepository;

    @Inject
    ShowDateSkillRequirementRepository showDateSkillRequirementRepository;

    @Inject
    ArtistAvailabilityRepository artistAvailabilityRepository;

    @Inject
    ArtistBookingRepository artistBookingRepository;

    @Test
    @Transactional
    @DisplayName("getById — retourne la revue si elle existe")
    void getById_whenShowExists_returnsDto() {
        cleanDatabase();
        CabaretShowEntity show = persistShow("Revue Étoile", "Description test");

        CabaretShowDto dto = cabaretShowService.getById(show.getId());

        assertAll(
                () -> assertEquals(show.getId(), dto.id()),
                () -> assertEquals(show.getCompany().getId(), dto.companyId()),
                () -> assertEquals("Revue Étoile", dto.title()),
                () -> assertEquals("Description test", dto.description()),
                () -> assertNotNull(dto.createdAt()),
                () -> assertNotNull(dto.updatedAt())
        );
    }

    @Test
    @Transactional
    @DisplayName("getById — lève CabaretShowNotFoundException si l'id n'existe pas")
    void getById_whenShowDoesNotExist_throwsCabaretShowNotFoundException() {
        cleanDatabase();

        assertThrows(CabaretShowNotFoundException.class,
                () -> cabaretShowService.getById(99_999L));
    }

    @Test
    @Transactional
    @DisplayName("getByCompanyId — lève CabaretCompanyNotFoundException si la compagnie n'existe pas")
    void getByCompanyId_whenCompanyDoesNotExist_throwsCabaretCompanyNotFoundException() {
        cleanDatabase();

        assertThrows(CabaretCompanyNotFoundException.class,
                () -> cabaretShowService.getByCompanyId(99_999L));
    }

    @Test
    @Transactional
    @DisplayName("getByCompanyId — lève ForbiddenCompanyAccessException si le manager courant n'est pas propriétaire")
    void getByCompanyId_whenManagerNotOwner_throwsForbiddenCompanyAccessException() {
        cleanDatabase();
        CabaretCompanyEntity company = persistCompany("Compagnie Accès", "uid-show-mgr-forbidden", "forbidden@test.com");
        doThrow(new ForbiddenCompanyAccessException())
                .when(managerCompanyResolver).assertCurrentManagerOwnsCompany(anyLong());

        assertThrows(ForbiddenCompanyAccessException.class,
                () -> cabaretShowService.getByCompanyId(company.getId()));
    }

    @Test
    @Transactional
    @DisplayName("getByCompanyId — retourne les revues de la compagnie si tout est valide")
    void getByCompanyId_whenValid_returnsCompanyShows() {
        cleanDatabase();
        CabaretShowEntity show = persistShow("Revue Lune", "Grande soirée");
        doNothing().when(managerCompanyResolver).assertCurrentManagerOwnsCompany(anyLong());

        List<CabaretShowDto> shows = cabaretShowService.getByCompanyId(show.getCompany().getId());

        assertEquals(1, shows.size());
        CabaretShowDto dto = shows.getFirst();
        assertAll(
                () -> assertEquals(show.getId(), dto.id()),
                () -> assertEquals(show.getCompany().getId(), dto.companyId()),
                () -> assertEquals("Revue Lune", dto.title()),
                () -> assertEquals("Grande soirée", dto.description())
        );
    }

    private CabaretShowEntity persistShow(String title, String description) {
        CabaretCompanyEntity company = persistCompany(
                "Compagnie Revue",
                "uid-show-mgr-" + title.hashCode(),
                "mgr-" + title.hashCode() + "@test.com"
        );
        CabaretShowEntity show = new CabaretShowEntity();
        show.setCompany(company);
        show.setTitle(title);
        show.setDescription(description);
        cabaretShowRepository.persistAndFlush(show);
        return show;
    }

    private CabaretCompanyEntity persistCompany(String name, String managerUid, String managerEmail) {
        VioletteUserEntity manager = persistUser(managerUid, managerEmail, Set.of(UserRole.MANAGER));
        CabaretCompanyEntity company = new CabaretCompanyEntity();
        company.setName(name);
        company.setDescription("Compagnie de test");
        company.setManager(manager);
        cabaretCompanyRepository.persistAndFlush(company);
        return company;
    }

    private VioletteUserEntity persistUser(String uid, String email, Set<UserRole> roles) {
        VioletteUserEntity user = new VioletteUserEntity();
        user.setFirebaseUid(uid);
        user.setEmail(email);
        user.setFirstName("Manager");
        user.setLastName("Show");
        user.setRoles(roles);
        violetteUserRepository.persistAndFlush(user);
        return user;
    }

    private void cleanDatabase() {
        artistBookingRepository.deleteAll();
        artistAvailabilityRepository.deleteAll();
        showDateSkillRequirementRepository.deleteAll();
        showDateRepository.deleteAll();
        companyMemberRepository.deleteAll();
        cabaretShowRepository.deleteAll();
        cabaretCompanyRepository.deleteAll();
        violetteUserRepository.deleteAll();
        violetteUserRepository.flush();
    }
}
