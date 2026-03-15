package io.violette.showdate.model;

import io.violette.violetteuser.model.VioletteUserEntity;
import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

import java.time.Instant;

/**
 * Représente la disponibilité déclarée par un artiste pour une date de spectacle.
 *
 * <p>Clé primaire composite (show_date_id, artist_id) via @EmbeddedId + @MapsId,
 * alignée sur la table SQL artist_availability (Flyway V4).
 *
 * <p>Remplace la Map&lt;String, AvailabilityStatus&gt; dénormalisée du modèle Firestore.
 * Un artiste ne peut avoir qu'une seule entrée par date (contrainte d'unicité portée par la PK composite).
 */
@Entity
@Table(name = "artist_availability")
public class ArtistAvailabilityEntity {

    @EmbeddedId
    private ArtistAvailabilityId id;

    /**
     * Date de spectacle concernée (FK show_date_id → show_date).
     */
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("showDateId")
    @JoinColumn(name = "show_date_id")
    private ShowDateEntity showDate;

    /**
     * Artiste qui déclare sa disponibilité (FK artist_id → violette_user).
     */
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("artistId")
    @JoinColumn(name = "artist_id")
    private VioletteUserEntity artist;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AvailabilityStatus status = AvailabilityStatus.PENDING;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    public ArtistAvailabilityId getId() {
        return id;
    }

    public void setId(ArtistAvailabilityId id) {
        this.id = id;
    }

    public ShowDateEntity getShowDate() {
        return showDate;
    }

    public void setShowDate(ShowDateEntity showDate) {
        this.showDate = showDate;
    }

    public VioletteUserEntity getArtist() {
        return artist;
    }

    public void setArtist(VioletteUserEntity artist) {
        this.artist = artist;
    }

    public AvailabilityStatus getStatus() {
        return status;
    }

    public void setStatus(AvailabilityStatus status) {
        this.status = status;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }

    @PrePersist
    void onPersist() {
        this.updatedAt = Instant.now();
    }

    @PreUpdate
    void onUpdate() {
        this.updatedAt = Instant.now();
    }
}
