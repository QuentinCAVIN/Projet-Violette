package io.violette.violetteuser.repository;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Page;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import jakarta.enterprise.context.ApplicationScoped;

import java.util.List;
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

    /**
     * Liste paginée des utilisateurs, triée par date de création décroissante.
     * L'id sert de second critère pour stabiliser la pagination quand plusieurs lignes
     * partagent le même timestamp.
     */
    public List<VioletteUserEntity> findAllOrderByCreatedAtDesc(Page page) {
        return find("order by createdAt desc, id desc").page(page).list();
    }

    /**
     * Nombre total d'utilisateurs (pour pagination).
     */
    public long countAll() {
        return count();
    }

    /**
     * Retourne le premier utilisateur ayant le rôle demandé, trié par date de création.
     */
    public Optional<VioletteUserEntity> findFirstByRole(UserRole role) {
        return find(
                "select u from VioletteUserEntity u join u.roles r where r = ?1 order by u.createdAt asc",
                role
        ).firstResultOptional();
    }
}
