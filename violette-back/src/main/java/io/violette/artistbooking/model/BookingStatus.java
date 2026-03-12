package io.violette.artistbooking.model;

/**
 * Cycle de vie d'une réservation artiste.
 *
 * <pre>
 * Workflow nominal :
 *
 *   [Manager sélectionne un artiste]
 *              │
 *              ▼
 *          SELECTED ──── [Manager désélectionne] ──► (suppression du booking)
 *              │
 *              │ [Manager envoie les demandes — sendConfirmationRequests()]
 *              ▼
 *    PENDING_CONFIRMATION
 *         │           │
 *         │           │
 *         ▼           ▼
 *      CONFIRMED    REFUSED
 *    (artiste     (artiste
 *     accepte)     refuse)
 *
 * Annulation de la date :
 *
 *   SELECTED, PENDING_CONFIRMATION, CONFIRMED ──► CANCELLED
 *   REFUSED reste REFUSED (statut terminal).
 * </pre>
 */
public enum BookingStatus {

    /**
     * Artiste sélectionné par le manager pour cette date.
     *
     * <p><b>Déclencheur :</b> le manager appelle {@code createBooking()} depuis l'interface de détail de date.
     * <p><b>Conditions :</b> la disponibilité artiste doit être {@code AVAILABLE},
     * la capacité de la compétence associée ne doit pas être atteinte,
     * et la date ne doit pas être {@code LOCKED} ou {@code CANCELLED}.
     * <p><b>Transitions autorisées :</b>
     * <ul>
     *   <li>{@link #SELECTED} → suppression (manager désélectionne)</li>
     *   <li>{@link #SELECTED} → {@link #PENDING_CONFIRMATION} (manager envoie les demandes)</li>
     *   <li>{@link #SELECTED} → {@link #CANCELLED} (date annulée)</li>
     * </ul>
     */
    SELECTED,

    /**
     * Demande de confirmation envoyée à l'artiste, en attente de réponse.
     *
     * <p><b>Déclencheur :</b> le manager appelle {@code sendConfirmationRequests(showDateId)},
     * qui passe tous les bookings {@code SELECTED} de la date en {@code PENDING_CONFIRMATION}.
     * <p><b>Effet :</b> {@code BookingTimeline.requestedAt} est renseigné.
     * <p><b>Transitions autorisées :</b>
     * <ul>
     *   <li>{@link #PENDING_CONFIRMATION} → {@link #CONFIRMED} (artiste accepte)</li>
     *   <li>{@link #PENDING_CONFIRMATION} → {@link #REFUSED} (artiste refuse)</li>
     *   <li>{@link #PENDING_CONFIRMATION} → {@link #CANCELLED} (date annulée)</li>
     * </ul>
     */
    PENDING_CONFIRMATION,

    /**
     * Artiste confirmé — sa présence sur la date est acquise.
     *
     * <p><b>Déclencheur :</b> l'artiste appelle {@code respondToRequest(bookingId, accept=true)}.
     * <p><b>Effet :</b> {@code BookingTimeline.respondedAt} est renseigné.
     * <p><b>Statut terminal (hors annulation de date).</b>
     * <p><b>Transitions autorisées :</b>
     * <ul>
     *   <li>{@link #CONFIRMED} → {@link #CANCELLED} (date annulée)</li>
     * </ul>
     */
    CONFIRMED,

    /**
     * Artiste refusé — il ne participera pas à cette date.
     *
     * <p><b>Déclencheur :</b> l'artiste appelle {@code respondToRequest(bookingId, accept=false)}.
     * <p><b>Effet :</b> {@code BookingTimeline.respondedAt} est renseigné.
     * Ce statut ne compte pas dans le calcul de capacité par compétence.
     * <p><b>Statut terminal.</b> Un artiste refusé ne peut pas être re-sélectionné
     * sans suppression préalable du booking (décision à valider).
     * <p><b>Transitions autorisées :</b> aucune.
     */
    REFUSED,

    /**
     * Booking annulé suite à l'annulation de la date de spectacle.
     *
     * <p><b>Déclencheur :</b> propagation lors du passage de {@code ShowDate.status} à {@code CANCELLED}.
     * Applicable aux bookings en {@code SELECTED}, {@code PENDING_CONFIRMATION} ou {@code CONFIRMED}.
     * Les bookings déjà {@code REFUSED} restent {@code REFUSED}.
     * <p><b>Statut terminal.</b>
     * <p><b>Transitions autorisées :</b> aucune.
     */
    CANCELLED
}
