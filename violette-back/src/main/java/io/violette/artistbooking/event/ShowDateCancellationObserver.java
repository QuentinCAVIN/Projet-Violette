package io.violette.artistbooking.event;

import io.violette.artistbooking.service.ArtistBookingService;
import io.violette.showdate.event.ShowDateStatusChangedEvent;
import io.violette.showdate.model.ShowDateStatus;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.event.Observes;
import jakarta.inject.Inject;

/**
 * Observateur CDI du domaine artistbooking — propage l'annulation d'une date
 * vers tous ses bookings actifs.
 *
 * <p>Réagit à {@link ShowDateStatusChangedEvent} publié par {@code ShowDateService}
 * sans couplage direct entre les domaines showdate et artistbooking.
 *
 * <p>Lorsqu'une date passe en {@code CANCELLED}, délègue à
 * {@link ArtistBookingService#cancelAllActiveBookingsForShowDate(Long)} la mise à jour
 * de chaque booking actif ({@code SELECTED}, {@code PENDING_CONFIRMATION}, {@code CONFIRMED}).
 */
@ApplicationScoped
public class ShowDateCancellationObserver {

    @Inject
    ArtistBookingService artistBookingService;

    /**
     * Annule en cascade les bookings actifs lorsque la date passe en {@code CANCELLED}.
     *
     * @param event événement de transition de statut de date
     */
    public void onShowDateCancelled(@Observes ShowDateStatusChangedEvent event) {
        if (event.newStatus() != ShowDateStatus.CANCELLED) {
            return;
        }

        artistBookingService.cancelAllActiveBookingsForShowDate(event.showDateId());
    }
}
