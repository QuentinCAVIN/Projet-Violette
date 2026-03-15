package io.violette.showdate.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

import java.io.Serializable;
import java.util.Objects;

/**
 * Clé primaire composite de ArtistAvailabilityEntity.
 * Représente l'unicité de la disponibilité (show_date_id, artist_id).
 * Doit implémenter Serializable et redéfinir equals/hashCode (contrat JPA).
 */
@Embeddable
public class ArtistAvailabilityId implements Serializable {

    @Column(name = "show_date_id")
    private Long showDateId;

    @Column(name = "artist_id")
    private Long artistId;

    public ArtistAvailabilityId() {
    }

    public ArtistAvailabilityId(Long showDateId, Long artistId) {
        this.showDateId = showDateId;
        this.artistId = artistId;
    }

    public Long getShowDateId() {
        return showDateId;
    }

    public void setShowDateId(Long showDateId) {
        this.showDateId = showDateId;
    }

    public Long getArtistId() {
        return artistId;
    }

    public void setArtistId(Long artistId) {
        this.artistId = artistId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ArtistAvailabilityId that)) return false;
        return Objects.equals(showDateId, that.showDateId) &&
                Objects.equals(artistId, that.artistId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(showDateId, artistId);
    }
}
