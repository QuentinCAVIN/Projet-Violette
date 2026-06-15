package io.violette.security.exception.dto;

/**
 * Corps de réponse neutre pour les erreurs internes non gérées (HTTP 500).
 * Ne contient aucun détail technique exploitable côté client.
 */
public record InternalErrorResponse(String error, String reference) {
}
