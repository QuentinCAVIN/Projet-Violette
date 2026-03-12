package io.violette.artistbooking.exception;

/**
 * Exception métier : besoin artistique introuvable (show_date_skill_requirement).
 * Levée dans le domaine artistbooking lors de la validation du skillRequirementId fourni.
 * Mappée en HTTP 404 Not Found par {@link mapper.SkillRequirementNotFoundExceptionMapper}.
 */
public class SkillRequirementNotFoundException extends RuntimeException {

    public SkillRequirementNotFoundException() {
        super("Besoin artistique introuvable.");
    }

    public SkillRequirementNotFoundException(String message) {
        super(message);
    }
}
