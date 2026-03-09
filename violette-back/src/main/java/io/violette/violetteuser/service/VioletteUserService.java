package io.violette.violetteuser.service;

import io.violette.security.JwtPrincipalInfo;
import io.violette.violetteuser.dto.AuthenticatedUserDto;
import io.violette.violetteuser.dto.CreateUserRequestDto;
import io.violette.violetteuser.dto.VioletteUserDto;
import io.violette.violetteuser.exception.UserAlreadyExistsException;
import io.violette.violetteuser.mapper.VioletteUserMapper;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;

import java.util.Set;

/**
 * Service utilisateur : contexte /me et création de profil à partir du JWT.
 */
@ApplicationScoped
public class VioletteUserService {

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Inject
    VioletteUserMapper violetteUserMapper;

    /**
     * Construit le DTO de l'utilisateur courant à partir du principal JWT.
     */
    public AuthenticatedUserDto getCurrentUser(JwtPrincipalInfo principal) {
        if (principal == null) {
            return new AuthenticatedUserDto("", "", "");
        }
        return new AuthenticatedUserDto(
                principal.firebaseUid(),
                principal.email(),
                principal.name()
        );
    }

    /**
     * Crée le profil backend à partir du JWT (firebaseUid, email) et des données applicatives (request).
     *
     * @param principal infos JWT (firebaseUid, email)
     * @param request   firstName, lastName, roles (optionnel ; défaut ARTIST)
     * @return DTO utilisateur créé
     * @throws UserAlreadyExistsException si un utilisateur existe déjà avec ce firebaseUid ou cet email
     */
    @Transactional
    public VioletteUserDto createUser(JwtPrincipalInfo principal, CreateUserRequestDto request) {
        if (principal == null) {
            throw new IllegalArgumentException("Principal JWT requis pour créer un utilisateur.");
        }

        violetteUserRepository.findByFirebaseUid(principal.firebaseUid())
                .or(() -> violetteUserRepository.findByEmail(principal.email()))
                .ifPresent(existing -> {
                    throw new UserAlreadyExistsException();
                });

        Set<UserRole> roles = (request.roles() == null || request.roles().isEmpty())
                ? Set.of(UserRole.ARTIST)
                : request.roles();

        VioletteUserEntity entity = new VioletteUserEntity();
        entity.setFirebaseUid(principal.firebaseUid());
        entity.setEmail(principal.email());
        entity.setFirstName(request.firstName());
        entity.setLastName(request.lastName());
        entity.setRoles(roles);

        violetteUserRepository.persist(entity);
        return violetteUserMapper.toDto(entity);
    }
}
