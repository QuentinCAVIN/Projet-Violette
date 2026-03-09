package io.violette.violetteuser.service;

import io.quarkus.test.junit.QuarkusTest;
import io.violette.security.JwtPrincipalInfo;
import io.violette.violetteuser.dto.CreateUserRequestDto;
import io.violette.violetteuser.dto.VioletteUserDto;
import io.violette.violetteuser.exception.UserAlreadyExistsException;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

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

    @Test
    @Transactional
    @DisplayName("createUser - when user does not exist then creation succeeds and returns DTO")
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
    @DisplayName("createUser - when roles omitted then default ARTIST is applied")
    void whenRolesOmitted_thenDefaultArtistApplied() {
        JwtPrincipalInfo principal = new JwtPrincipalInfo("uid-default-role", "default-role@example.com", "");
        CreateUserRequestDto request = new CreateUserRequestDto("Alice", "Default", null);

        VioletteUserDto dto = violetteUserService.createUser(principal, request);

        assertEquals(Set.of(UserRole.ARTIST), dto.roles());
    }

    @Test
    @Transactional
    @DisplayName("createUser - when roles provided then they are persisted")
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
    @DisplayName("createUser - when user already exists by firebaseUid then throws UserAlreadyExistsException")
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
    @DisplayName("createUser - when user already exists by email then throws UserAlreadyExistsException")
    void whenUserExistsByEmail_thenThrowsUserAlreadyExistsException() {
        persistUser("uid-other-002", "conflict-email@example.com", "Existing", "User", Set.of(UserRole.ARTIST));

        JwtPrincipalInfo principal = new JwtPrincipalInfo("uid-new-002", "conflict-email@example.com", "");
        CreateUserRequestDto request = new CreateUserRequestDto("Jean", "Dupont", null);

        assertThrows(UserAlreadyExistsException.class,
                () -> violetteUserService.createUser(principal, request));
    }

    private void persistUser(String firebaseUid, String email, String firstName, String lastName, Set<UserRole> roles) {
        VioletteUserEntity entity = new VioletteUserEntity();
        entity.setFirebaseUid(firebaseUid);
        entity.setEmail(email);
        entity.setFirstName(firstName);
        entity.setLastName(lastName);
        entity.setRoles(roles);
        violetteUserRepository.persistAndFlush(entity);
    }
}
