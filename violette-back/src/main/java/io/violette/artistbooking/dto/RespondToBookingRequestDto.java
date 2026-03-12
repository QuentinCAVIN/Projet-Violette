package io.violette.artistbooking.dto;

import jakarta.validation.constraints.NotNull;

/**
 * Corps de la requête de réponse d'un artiste à une demande de confirmation.
 *
 * @param accept {@code true} pour accepter (→ {@code CONFIRMED}),
 *               {@code false} pour refuser (→ {@code REFUSED})
 */
public record RespondToBookingRequestDto(
        @NotNull Boolean accept
) {}
