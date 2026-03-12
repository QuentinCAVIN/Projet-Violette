package io.violette.artistbooking.exception;

/**
 * Exception métier : la capacité requise pour la compétence de ce besoin artistique est atteinte.
 * Le nombre de bookings actifs (SELECTED + PENDING_CONFIRMATION + CONFIRMED) est déjà
 * égal au {@code requiredCount} du {@code ShowDateSkillRequirementEntity}.
 * Mappée en HTTP 409 Conflict par {@link mapper.BookingCapacityExceededExceptionMapper}.
 */
public class BookingCapacityExceededException extends RuntimeException {

    public BookingCapacityExceededException() {
        super("La capacité requise pour cette compétence est déjà atteinte.");
    }

    public BookingCapacityExceededException(String message) {
        super(message);
    }
}
