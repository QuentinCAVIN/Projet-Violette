package io.violette.violetteuser.repository;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.violette.violetteuser.model.VioletteUserEntity;
import jakarta.enterprise.context.ApplicationScoped;

import java.util.Optional;

/**
 * Repository Panache pour l'entité utilisateur.
 * Seule couche d'accès BDD pour le domaine violetteuser.
 */
@ApplicationScoped
public class VioletteUserRepository implements PanacheRepository<VioletteUserEntity> {

    /**
     * Recherche un utilisateur par son UID Firebase (clé de liaison avec le frontend).
     */
    public Optional<VioletteUserEntity> findByFirebaseUid(String firebaseUid) {
        return find("firebaseUid", firebaseUid).firstResultOptional();
    }

    /**
     * Recherche un utilisateur par son email (unique).
     */
    public Optional<VioletteUserEntity> findByEmail(String email) {
        return find("email", email).firstResultOptional();
    }
}
