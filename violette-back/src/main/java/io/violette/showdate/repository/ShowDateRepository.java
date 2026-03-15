package io.violette.showdate.repository;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.violette.showdate.model.ShowDateEntity;
import jakarta.enterprise.context.ApplicationScoped;

import java.util.List;

/**
 * Repository Panache pour ShowDateEntity.
 * Seule couche d'accès BDD pour les dates de spectacle.
 */
@ApplicationScoped
public class ShowDateRepository implements PanacheRepository<ShowDateEntity> {

    /**
     * Retourne toutes les dates de spectacle d'une compagnie, triées par date croissante.
     */
    public List<ShowDateEntity> findByCompanyId(Long companyId) {
        return find("company.id = ?1 order by eventDate asc", companyId).list();
    }

    /**
     * Retourne toutes les dates de spectacle, triées par date croissante.
     */
    public List<ShowDateEntity> findAllOrderByEventDateAsc() {
        return find("order by eventDate asc").list();
    }
}
