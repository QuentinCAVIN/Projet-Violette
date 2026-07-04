package io.violette.showdate.event;

import io.violette.showdate.model.ShowDateStatus;

/**
 * Événement métier publié chaque fois qu'une date de spectacle change de statut.
 *
 * <p>Implémente le pattern <b>Observer</b> via le mécanisme d'événements CDI
 * (Jakarta CDI {@link jakarta.enterprise.event.Event} / {@link jakarta.enterprise.event.Observes}).
 *
 * <p>Cet événement est émis par {@code ShowDateService} à chaque transition
 * de statut effective, sans couplage direct vers les composants qui y réagissent.
 *
 * <p>Évolutions prévues :
 * <ul>
 *   <li>Propagation d'annulation aux bookings actifs</li>
 *   <li>Notifications</li>
 * </ul>
 *
 * @param showDateId identifiant de la date de spectacle concernée
 * @param oldStatus  statut avant la transition
 * @param newStatus  statut après la transition
 */
public record ShowDateStatusChangedEvent(
        Long showDateId,
        ShowDateStatus oldStatus,
        ShowDateStatus newStatus
) {}
