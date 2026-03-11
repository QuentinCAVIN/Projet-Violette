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
}
