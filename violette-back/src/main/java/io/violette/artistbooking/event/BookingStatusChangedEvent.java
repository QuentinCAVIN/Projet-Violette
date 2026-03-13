package io.violette.artistbooking.event;

import io.violette.artistbooking.model.BookingStatus;

/**
 * Événement métier publié chaque fois qu'un booking change de statut.
 *
 * <p>Implémente le pattern <b>Observer</b> via le mécanisme d'événements CDI
 * (Jakarta CDI {@link jakarta.enterprise.event.Event} / {@link jakarta.enterprise.event.Observes}).
 *
 * <p>Cet événement est émis par {@code ArtistBookingService} à chaque transition
 * de statut effective, sans couplage direct vers les composants qui y réagissent.
 *
 * <p>Évolutions prévues :
 * <ul>
 *   <li>Notifications artistes lors du passage en {@code PENDING_CONFIRMATION}</li>
 *   <li>Synchronisation avec le domaine {@code showdate} lors d'un {@code REFUSED}</li>
 *   <li>Journalisation métier ou audit trail</li>
 *   <li>Workflows configurables par compagnie en V2</li>
 * </ul>
 *
 * @param bookingId  identifiant du booking concerné
 * @param showDateId identifiant de la date de spectacle associée
 * @param artistId   identifiant de l'artiste concerné
 * @param oldStatus  statut avant la transition
 * @param newStatus  statut après la transition
 */
public record BookingStatusChangedEvent(
        Long bookingId,
        Long showDateId,
        Long artistId,
        BookingStatus oldStatus,
        BookingStatus newStatus
) {}
