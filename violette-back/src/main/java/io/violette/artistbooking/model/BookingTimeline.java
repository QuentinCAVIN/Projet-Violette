package io.violette.artistbooking.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

import java.time.Instant;

/**
 * Value object représentant les horodatages du cycle de vie d'un booking.
 *
 * <p>Embarqué dans {@link ArtistBookingEntity} via {@code @Embedded}.
 * Toutes les colonnes sont dans la table {@code artist_booking}.
 *
 * <ul>
 *   <li>{@code createdAt} — date de création du booking (sélection initiale)</li>
 *   <li>{@code updatedAt} — date de dernière modification</li>
 *   <li>{@code requestedAt} — date d'envoi de la demande de confirmation (passage à {@code PENDING_CONFIRMATION})</li>
 *   <li>{@code respondedAt} — date de réponse de l'artiste (passage à {@code CONFIRMED} ou {@code REFUSED})</li>
 * </ul>
 */
@Embeddable
public class BookingTimeline {

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    /** Renseigné lors du passage à {@link BookingStatus#PENDING_CONFIRMATION}. */
    @Column(name = "requested_at")
    private Instant requestedAt;

    /**
     * Renseigné lors du passage à {@link BookingStatus#CONFIRMED} ou {@link BookingStatus#REFUSED}.
     * N'est PAS renseigné lors d'un passage à {@link BookingStatus#CANCELLED} —
     * l'annulation est une décision externe (date annulée), pas une réponse de l'artiste.
     * Dans ce cas, {@code updatedAt} trace l'horodatage de l'annulation.
     */
    @Column(name = "responded_at")
    private Instant respondedAt;

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Instant getRequestedAt() {
        return requestedAt;
    }

    public void setRequestedAt(Instant requestedAt) {
        this.requestedAt = requestedAt;
    }

    public Instant getRespondedAt() {
        return respondedAt;
    }

    public void setRespondedAt(Instant respondedAt) {
        this.respondedAt = respondedAt;
    }
}
