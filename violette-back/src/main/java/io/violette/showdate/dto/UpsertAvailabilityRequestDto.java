package io.violette.showdate.dto;

import io.violette.showdate.model.AvailabilityStatus;
import jakarta.validation.constraints.NotNull;

/**
 * Corps de requête pour la mise à jour de la disponibilité de l'utilisateur courant sur une date de spectacle.
 * Réservé à une utilisation ultérieure côté service / contrôleur (commit suivant).
 */
public record UpsertAvailabilityRequestDto(

        @NotNull(message = "status est obligatoire")
        AvailabilityStatus status
) {
}
