package io.violette.cabaretcompany.repository;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.violette.cabaretcompany.model.CabaretShowEntity;
import jakarta.enterprise.context.ApplicationScoped;

import java.util.List;

/**
 * Repository Panache pour CabaretShowEntity (table "revue").
 * Seule couche d'accès BDD pour les revues.
 */
@ApplicationScoped
public class CabaretShowRepository implements PanacheRepository<CabaretShowEntity> {

    /**
     * Retourne toutes les revues d'une compagnie donnée.
     */
    public List<CabaretShowEntity> findByCompanyId(Long companyId) {
        return find("company.id", companyId).list();
    }
}
