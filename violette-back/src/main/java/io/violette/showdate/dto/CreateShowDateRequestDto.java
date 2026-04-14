package io.violette.showdate.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.time.LocalTime;

/**
 * DTO de création d'une date de spectacle (POST /api/show-dates).
 * La compagnie est identifiée explicitement par companyId dans le body.
 */
public record CreateShowDateRequestDto(

        @NotNull(message = "companyId est obligatoire")
        Long companyId,

        Long cabaretShowId,

        @NotNull(message = "eventDate est obligatoire")
        LocalDate eventDate,

        @NotNull(message = "meetingTime est obligatoire")
        LocalTime meetingTime,

        @NotBlank(message = "location ne doit pas être vide")
        @Size(max = 500)
        String location,

        @NotBlank(message = "clientContactName ne doit pas être vide")
        @Size(max = 255)
        String clientContactName,

        @NotBlank(message = "clientContactPhone ne doit pas être vide")
        @Size(max = 50)
        String clientContactPhone,

        String showDetails
) {
}
