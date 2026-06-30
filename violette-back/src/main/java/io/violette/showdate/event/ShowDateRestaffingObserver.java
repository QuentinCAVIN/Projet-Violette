package io.violette.showdate.event;

import io.violette.artistbooking.event.BookingStatusChangedEvent;
import io.violette.artistbooking.model.BookingStatus;
import io.violette.showdate.model.ShowDateEntity;
import io.violette.showdate.model.ShowDateStatus;
import io.violette.showdate.repository.ShowDateRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.event.Observes;
import jakarta.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Observateur CDI du domaine showdate — repasse une date {@code STAFFED} en {@code CONFIRMED}
 * lorsqu'un booking est annulé, car l'équipe redevient incomplète.
 *
 * <p>Réagit à {@link BookingStatusChangedEvent} publié par {@code ArtistBookingService}
 * sans couplage direct entre les domaines artistbooking et showdate.
 */
@ApplicationScoped
public class ShowDateRestaffingObserver {

    private static final Logger LOG = LoggerFactory.getLogger(ShowDateRestaffingObserver.class);

    @Inject
    ShowDateRepository showDateRepository;

    /**
     * Repasse la date en {@code CONFIRMED} si elle était {@code STAFFED} suite à une annulation de booking.
     *
     * @param event événement de transition de statut de booking
     */
    public void onBookingCancelled(@Observes BookingStatusChangedEvent event) {
        if (event.newStatus() != BookingStatus.CANCELLED) {
            return;
        }

        showDateRepository.findByIdOptional(event.showDateId())
                .ifPresent(showDate -> revertStaffedToConfirmed(showDate, event.bookingId()));
    }

    /**
     * Transition système STAFFED → CONFIRMED : hors périmètre de {@code applyV040StatusTransition}
     * (transitions montantes manager uniquement), donc {@code setStatus} direct ici.
     */
    private void revertStaffedToConfirmed(ShowDateEntity showDate, Long bookingId) {
        if (showDate.getStatus() != ShowDateStatus.STAFFED) {
            return;
        }

        showDate.setStatus(ShowDateStatus.CONFIRMED);
        LOG.info("Date showDateId={} repassée STAFFED → CONFIRMED suite à annulation du booking id={}",
                showDate.getId(), bookingId);
    }
}
