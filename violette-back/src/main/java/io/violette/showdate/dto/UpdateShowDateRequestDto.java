package io.violette.showdate.dto;

import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.time.LocalTime;

/**
 * DTO de mise à jour partielle d'une date de spectacle (PATCH /api/show-dates/{id}).
 *
 * <p>Convention : un champ à {@code null} signifie "ne pas modifier".
 */
public record UpdateShowDateRequestDto(

        LocalDate eventDate,

        LocalTime meetingTime,

        @Size(max = 500)
        String location,

        @Size(max = 255)
        String clientContactName,

        @Size(max = 50)
        String clientContactPhone,

        String showDetails
) {
}

