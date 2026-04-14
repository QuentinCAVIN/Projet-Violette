package io.violette.showdate.repository;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.violette.showdate.model.ShowDateSkillRequirementEntity;
import jakarta.enterprise.context.ApplicationScoped;

import java.util.List;

/**
 * Repository Panache pour ShowDateSkillRequirementEntity.
 * Seule couche d'accès BDD pour les besoins artistiques par compétence.
 */
@ApplicationScoped
public class ShowDateSkillRequirementRepository implements PanacheRepository<ShowDateSkillRequirementEntity> {

    /**
     * Retourne tous les besoins artistiques d'une date de spectacle.
     */
    public List<ShowDateSkillRequirementEntity> findByShowDateId(Long showDateId) {
        return find("showDate.id", showDateId).list();
    }

    /**
     * Calcule le total d'artistes requis pour une date de spectacle.
     * Retourne 0 si aucun besoin artistique n'existe pour cette date.
     */
    public int sumRequiredCountByShowDateId(Long showDateId) {
        Long total = getEntityManager()
                .createQuery(
                        "select coalesce(sum(r.requiredCount), 0) from ShowDateSkillRequirementEntity r where r.showDate.id = :showDateId",
                        Long.class
                )
                .setParameter("showDateId", showDateId)
                .getSingleResult();
        return total.intValue();
    }
}
