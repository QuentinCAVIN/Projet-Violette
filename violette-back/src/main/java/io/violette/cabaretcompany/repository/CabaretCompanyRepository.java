package io.violette.cabaretcompany.repository;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import jakarta.enterprise.context.ApplicationScoped;

import java.util.List;
import java.util.Optional;

/**
 * Repository Panache pour CabaretCompanyEntity.
 * Seule couche d'accès BDD pour les compagnies.
 */
@ApplicationScoped
public class CabaretCompanyRepository implements PanacheRepository<CabaretCompanyEntity> {

    /**
     * Retourne toutes les compagnies gérées par un manager donné.
     */
    public List<CabaretCompanyEntity> findByManagerId(Long managerId) {
        return find("manager.id", managerId).list();
    }

    /**
     * Recherche une compagnie par son nom exact (sensible à la casse).
     */
    public Optional<CabaretCompanyEntity> findByName(String name) {
        return find("name", name).firstResultOptional();
    }
}
