package io.violette.violetteuser.service;

import io.quarkus.test.junit.QuarkusTest;
import io.violette.artistbooking.repository.ArtistBookingRepository;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.cabaretcompany.repository.CabaretShowRepository;
import io.violette.cabaretcompany.repository.CompanyMemberRepository;
import io.violette.security.JwtPrincipalInfo;
import io.violette.showdate.repository.ArtistAvailabilityRepository;
import io.violette.showdate.repository.ShowDateRepository;
import io.violette.showdate.repository.ShowDateSkillRequirementRepository;
import io.violette.violetteuser.dto.CreateUserRequestDto;
import io.violette.violetteuser.dto.VioletteUserDto;
import io.violette.violetteuser.exception.UserAlreadyExistsException;
import io.violette.violetteuser.exception.UserNotFoundException;
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
import static org.junit.jupiter.api.Assertions.assertTrue;

@QuarkusTest
class VioletteUserServiceTest {

    @Inject
    VioletteUserService violetteUserService;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Inject
    ArtistBookingRepository artistBookingRepository;
    @Inject
    CompanyMemberRepository companyMemberRepository;
    @Inject
    CabaretShowRepository cabaretShowRepository;
    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;
    @Inject
    ArtistAvailabilityRepository artistAvailabilityRepository;
    @Inject
    ShowDateSkillRequirementRepository showDateSkillRequirementRepository;
    @Inject
    ShowDateRepository showDateRepository;

    @Test
    @Transactional
    @DisplayName("createUser — l'utilisateur est créé et le DTO est retourné")
    void whenUserDoesNotExist_thenCreationSucceeds() {
        JwtPrincipalInfo principal = new JwtPrincipalInfo("uid-new-001", "new@example.com", "Jean Dupont");
        CreateUserRequestDto request = new CreateUserRequestDto("Jean", "Dupont", null);

        VioletteUserDto dto = violetteUserService.createUser(principal, request);

        assertNotNull(dto.id());
        assertEquals("uid-new-001", dto.firebaseUid());
        assertEquals("new@example.com", dto.email());
        assertEquals("Jean", dto.firstName());
        assertEquals("Dupont", dto.lastName());
        assertEquals(Set.of(UserRole.ARTIST), dto.roles());
        assertTrue(dto.skills().isEmpty());

        var inDb = violetteUserRepository.findByFirebaseUid("uid-new-001");
        assertTrue(inDb.isPresent());
        assertEquals("Jean", inDb.get().getFirstName());
        assertEquals("Dupont", inDb.get().getLastName());
    }

    @Test
    @Transactional
    @DisplayName("createUser — le rôle ARTIST est appliqué par défaut si aucun rôle n'est fourni")
    void whenRolesOmitted_thenDefaultArtistApplied() {
        JwtPrincipalInfo principal = new JwtPrincipalInfo("uid-default-role", "default-role@example.com", "");
        CreateUserRequestDto request = new CreateUserRequestDto("Alice", "Default", null);

        VioletteUserDto dto = violetteUserService.createUser(principal, request);

        assertEquals(Set.of(UserRole.ARTIST), dto.roles());
    }

    @Test
    @Transactional
    @DisplayName("createUser — les rôles fournis sont persistés")
    void whenRolesProvided_thenTheyArePersisted() {
        JwtPrincipalInfo principal = new JwtPrincipalInfo("uid-with-roles", "roles@example.com", "");
        CreateUserRequestDto request = new CreateUserRequestDto("Bob", "Manager", Set.of(UserRole.MANAGER));

        VioletteUserDto dto = violetteUserService.createUser(principal, request);

        assertAll(
                () -> assertEquals(Set.of(UserRole.MANAGER), dto.roles()),
                () -> assertEquals(Set.of(UserRole.MANAGER), violetteUserRepository.findByFirebaseUid("uid-with-roles").orElseThrow().getRoles())
        );
    }

    @Test
    @Transactional
    @DisplayName("createUser — lève UserAlreadyExistsException si le firebaseUid existe déjà")
    void whenUserExistsByFirebaseUid_thenThrowsUserAlreadyExistsException() {
        persistUser("uid-conflict-001", "conflict-uid@example.com", "Existing", "User", Set.of(UserRole.ARTIST));

        JwtPrincipalInfo principal = new JwtPrincipalInfo("uid-conflict-001", "other@example.com", "");
        CreateUserRequestDto request = new CreateUserRequestDto("Jean", "Dupont", null);

        UserAlreadyExistsException thrown = assertThrows(UserAlreadyExistsException.class,
                () -> violetteUserService.createUser(principal, request));

        assertNotNull(thrown.getMessage());
    }

    @Test
    @Transactional
    @DisplayName("createUser — lève UserAlreadyExistsException si l'email existe déjà")
    void whenUserExistsByEmail_thenThrowsUserAlreadyExistsException() {
        persistUser("uid-other-002", "conflict-email@example.com", "Existing", "User", Set.of(UserRole.ARTIST));

        JwtPrincipalInfo principal = new JwtPrincipalInfo("uid-new-002", "conflict-email@example.com", "");
        CreateUserRequestDto request = new CreateUserRequestDto("Jean", "Dupont", null);

        assertThrows(UserAlreadyExistsException.class,
                () -> violetteUserService.createUser(principal, request));
    }

    @Test
    @Transactional
    @DisplayName("getUserById — retourne le DTO si l'utilisateur existe")
    void whenUserExists_getUserById_returnsDto() {
        VioletteUserEntity entity = persistUser("uid-get-by-id", "getbyid@example.com", "Marie", "Martin", Set.of(UserRole.MANAGER));
        Long id = entity.getId();

        VioletteUserDto dto = violetteUserService.getUserById(id);

        assertNotNull(dto);
        assertEquals(id, dto.id());
        assertEquals("uid-get-by-id", dto.firebaseUid());
        assertEquals("Marie", dto.firstName());
        assertEquals("Martin", dto.lastName());
        assertEquals(Set.of(UserRole.MANAGER), dto.roles());
    }

    @Test
    @Transactional
    @DisplayName("getUserById — lève UserNotFoundException si l'utilisateur n'existe pas")
    void whenUserDoesNotExist_getUserById_throwsUserNotFoundException() {
        assertThrows(UserNotFoundException.class,
                () -> violetteUserService.getUserById(99999L));
    }

    @Test
    @Transactional
    @DisplayName("getUserByFirebaseUid — retourne le DTO si l'utilisateur existe")
    void whenUserExists_getUserByFirebaseUid_returnsDto() {
        persistUser("uid-get-by-uid", "getbyuid@example.com", "Paul", "Dupuis", Set.of(UserRole.ARTIST));

        VioletteUserDto dto = violetteUserService.getUserByFirebaseUid("uid-get-by-uid");

        assertNotNull(dto);
        assertEquals("uid-get-by-uid", dto.firebaseUid());
        assertEquals("Paul", dto.firstName());
        assertEquals("Dupuis", dto.lastName());
    }

    @Test
    @Transactional
    @DisplayName("getUserByFirebaseUid — lève UserNotFoundException si l'utilisateur n'existe pas")
    void whenUserDoesNotExist_getUserByFirebaseUid_throwsUserNotFoundException() {
        assertThrows(UserNotFoundException.class,
                () -> violetteUserService.getUserByFirebaseUid("uid-inexistant-xyz"));
    }

    @Test
    @Transactional
    @DisplayName("getUsers — retourne la liste paginée triée par createdAt DESC")
    void getUsers_returnsPaginatedListSortedByCreatedAtDesc() {
        // Ordre de suppression : artist_booking référence show_date, show_date_skill_requirement et violette_user
        artistBookingRepository.deleteAll();
        artistAvailabilityRepository.deleteAll();
        showDateSkillRequirementRepository.deleteAll();
        showDateRepository.deleteAll();
        companyMemberRepository.deleteAll();
        cabaretShowRepository.deleteAll();
        cabaretCompanyRepository.deleteAll();
        violetteUserRepository.deleteAll();
        violetteUserRepository.flush();
        assertEquals(0, violetteUserRepository.count(), "Base vide après nettoyage pour isoler le test de pagination");
        persistUser("uid-pag-1", "pag1@example.com", "A", "One", Set.of(UserRole.ARTIST));
        persistUser("uid-pag-2", "pag2@example.com", "B", "Two", Set.of(UserRole.ARTIST));
        persistUser("uid-pag-3", "pag3@example.com", "C", "Three", Set.of(UserRole.ARTIST));

        List<VioletteUserDto> page0 = violetteUserService.getUsers(0, 2);
        List<VioletteUserDto> page1 = violetteUserService.getUsers(1, 2);

        assertEquals(2, page0.size());
        assertEquals(1, page1.size());
        Set<String> allUids = java.util.stream.Stream.concat(
                page0.stream().map(VioletteUserDto::firebaseUid),
                page1.stream().map(VioletteUserDto::firebaseUid)
        ).collect(java.util.stream.Collectors.toSet());
        assertTrue(allUids.contains("uid-pag-1"));
        assertTrue(allUids.contains("uid-pag-2"));
        assertTrue(allUids.contains("uid-pag-3"));
    }

    private VioletteUserEntity persistUser(String firebaseUid, String email, String firstName, String lastName, Set<UserRole> roles) {
        VioletteUserEntity entity = new VioletteUserEntity();
        entity.setFirebaseUid(firebaseUid);
        entity.setEmail(email);
        entity.setFirstName(firstName);
        entity.setLastName(lastName);
        entity.setRoles(roles);
        violetteUserRepository.persistAndFlush(entity);
        return entity;
    }
}
