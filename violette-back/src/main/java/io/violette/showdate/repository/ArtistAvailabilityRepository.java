package io.violette.showdate.repository;

import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import io.violette.showdate.model.ArtistAvailabilityEntity;
import io.violette.showdate.model.ArtistAvailabilityId;
import jakarta.enterprise.context.ApplicationScoped;

import java.util.List;

/**
 * Repository Panache pour ArtistAvailabilityEntity.
 * Utilise PanacheRepositoryBase avec la clé composite ArtistAvailabilityId.
 * Seule couche d'accès BDD pour les disponibilités artistes.
 */
@ApplicationScoped
public class ArtistAvailabilityRepository implements PanacheRepositoryBase<ArtistAvailabilityEntity, ArtistAvailabilityId> {

    /**
     * Retourne toutes les disponibilités déclarées pour une date de spectacle.
     */
    public List<ArtistAvailabilityEntity> findByShowDateId(Long showDateId) {
        return find("id.showDateId", showDateId).list();
    }

    /**
     * Retourne toutes les dates pour lesquelles un artiste a déclaré une disponibilité.
     */
    public List<ArtistAvailabilityEntity> findByArtistId(Long artistId) {
        return find("id.artistId", artistId).list();
    }
}
