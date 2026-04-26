package io.violette.artistbooking.repository;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.violette.artistbooking.model.ArtistBookingEntity;
import io.violette.artistbooking.model.BookingStatus;
import jakarta.enterprise.context.ApplicationScoped;

import java.util.List;
import java.util.Optional;

/**
 * Repository Panache pour ArtistBookingEntity.
 * Seule couche d'accès BDD pour le domaine artistbooking.
 */
@ApplicationScoped
public class ArtistBookingRepository implements PanacheRepository<ArtistBookingEntity> {

    /**
     * Retourne tous les bookings d'une date de spectacle.
     */
    public List<ArtistBookingEntity> findByShowDateId(Long showDateId) {
        return find("showDate.id", showDateId).list();
    }

    /**
     * Retourne tous les bookings d'un artiste.
     * Utilisé par la vue artiste pour connaître ses engagements confirmés.
     */
    public List<ArtistBookingEntity> findByArtistId(Long artistId) {
        return find("artist.id", artistId).list();
    }

    /**
     * Retourne les bookings d'un artiste dans un statut donné.
     * Utilisé notamment pour {@code GET /me/pending} (statut {@code PENDING_CONFIRMATION}).
     */
    public List<ArtistBookingEntity> findByArtistIdAndStatus(Long artistId, BookingStatus status) {
        return find("artist.id = ?1 and status = ?2", artistId, status).list();
    }

    /**
     * Retourne le booking d'un artiste pour une date donnée, s'il existe.
     * Utilisé pour valider la contrainte d'unicité avant création.
     */
    public Optional<ArtistBookingEntity> findByShowDateIdAndArtistId(Long showDateId, Long artistId) {
        return find("showDate.id = ?1 and artist.id = ?2", showDateId, artistId).firstResultOptional();
    }

    /**
     * Retourne tous les bookings d'une date dans un statut donné.
     * Utilisé pour {@code sendConfirmationRequests} (statut {@code SELECTED}).
     */
    public List<ArtistBookingEntity> findByShowDateIdAndStatus(Long showDateId, BookingStatus status) {
        return find("showDate.id = ?1 and status = ?2", showDateId, status).list();
    }

    /**
     * Compte les bookings actifs pour un besoin artistique donné.
     *
     * <p>Les statuts actifs sont : {@code SELECTED}, {@code PENDING_CONFIRMATION}, {@code CONFIRMED}.
     * {@code REFUSED} et {@code CANCELLED} ne comptent pas dans la capacité.
     *
     * <p>Utilisé pour vérifier la règle de capacité par compétence avant de créer un nouveau booking.
     *
     * @param skillRequirementId id du besoin artistique ({@code show_date_skill_requirement})
     * @return nombre de bookings actifs pour ce besoin
     */
    public long countActiveBookingsForSkillRequirement(Long skillRequirementId) {
        return count(
                "skillRequirement.id = ?1 and status in ?2",
                skillRequirementId,
                List.of(BookingStatus.SELECTED, BookingStatus.PENDING_CONFIRMATION, BookingStatus.CONFIRMED)
        );
    }

    /**
     * Compte les bookings actifs d'une date de spectacle.
     *
     * <p>Les statuts actifs sont : {@code SELECTED}, {@code PENDING_CONFIRMATION}, {@code CONFIRMED}.
     * {@code REFUSED} et {@code CANCELLED} ne comptent pas.
     */
    public long countActiveBookingsByShowDateId(Long showDateId) {
        return count(
                "showDate.id = ?1 and status in ?2",
                showDateId,
                List.of(BookingStatus.SELECTED, BookingStatus.PENDING_CONFIRMATION, BookingStatus.CONFIRMED)
        );
    }

    /**
     * Retourne tous les bookings actifs d'une date (hors REFUSED et CANCELLED).
     * Utilisé pour la propagation d'annulation de date (future fonctionnalité V1).
     */
    public List<ArtistBookingEntity> findActiveByShowDateId(Long showDateId) {
        return find(
                "showDate.id = ?1 and status in ?2",
                showDateId,
                List.of(BookingStatus.SELECTED, BookingStatus.PENDING_CONFIRMATION, BookingStatus.CONFIRMED)
        ).list();
    }
}
