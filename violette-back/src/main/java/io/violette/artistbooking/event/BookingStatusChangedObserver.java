package io.violette.artistbooking.event;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.event.Observes;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Observateur CDI du pattern <b>Observer</b> pour les changements de statut de réservation.
 *
 * <p>Réagit à chaque {@link BookingStatusChangedEvent} publié par {@code ArtistBookingService}
 * sans aucun couplage direct avec l'émetteur.
 *
 * <p>Le découplage est total : le service n'a aucune dépendance vers cet observateur.
 * Quarkus CDI route l'événement automatiquement vers tous les observateurs enregistrés.
 *
 * <p>Responsabilité actuelle :
 * <ul>
 *   <li>Journalisation métier structurée de chaque transition de statut</li>
 * </ul>
 *
 * <p>Point d'extension naturel pour les évolutions V2 :
 * <ul>
 *   <li>Notifications push/email à l'artiste lors du passage en {@code PENDING_CONFIRMATION}</li>
 *   <li>Libération d'une place dans {@code showdate} lors d'un {@code REFUSED}</li>
 *   <li>Déclenchement de workflows configurables par compagnie</li>
 * </ul>
 */
@ApplicationScoped
public class BookingStatusChangedObserver {

    private static final Logger LOG = LoggerFactory.getLogger(BookingStatusChangedObserver.class);

    /**
     * Traite un événement de changement de statut de booking.
     *
     * @param event événement contenant les informations du booking et de la transition
     */
    public void onBookingStatusChanged(@Observes BookingStatusChangedEvent event) {
        LOG.info(
                "Booking statut changé — bookingId={} showDateId={} artistId={} : {} → {}",
                event.bookingId(),
                event.showDateId(),
                event.artistId(),
                event.oldStatus(),
                event.newStatus()
        );
    }
}
