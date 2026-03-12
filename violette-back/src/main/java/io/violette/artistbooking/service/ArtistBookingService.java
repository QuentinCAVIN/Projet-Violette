package io.violette.artistbooking.service;

import io.violette.artistbooking.dto.ArtistBookingDto;
import io.violette.artistbooking.dto.CreateBookingRequestDto;
import io.violette.artistbooking.exception.ArtistBookingNotFoundException;
import io.violette.artistbooking.exception.ArtistNotAvailableException;
import io.violette.artistbooking.exception.BookingAlreadyExistsException;
import io.violette.artistbooking.exception.BookingCapacityExceededException;
import io.violette.artistbooking.exception.InvalidBookingTransitionException;
import io.violette.artistbooking.exception.ShowDateNotModifiableException;
import io.violette.artistbooking.exception.SkillRequirementNotFoundException;
import io.violette.artistbooking.mapper.ArtistBookingMapper;
import io.violette.artistbooking.model.ArtistBookingEntity;
import io.violette.artistbooking.model.BookingStatus;
import io.violette.artistbooking.repository.ArtistBookingRepository;
import io.violette.security.JwtPrincipalInfo;
import io.violette.showdate.model.AvailabilityStatus;
import io.violette.showdate.model.ArtistAvailabilityId;
import io.violette.showdate.model.ShowDateEntity;
import io.violette.showdate.model.ShowDateSkillRequirementEntity;
import io.violette.showdate.model.ShowDateStatus;
import io.violette.showdate.repository.ArtistAvailabilityRepository;
import io.violette.showdate.exception.ShowDateNotFoundException;
import io.violette.showdate.repository.ShowDateRepository;
import io.violette.showdate.repository.ShowDateSkillRequirementRepository;
import io.violette.violetteuser.exception.UserNotFoundException;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.Instant;
import java.util.List;

/**
 * Service du domaine artistbooking.
 *
 * <p>Orchestre le cycle de vie des réservations artistes :
 * sélection, envoi de confirmation, réponse artiste.
 *
 * <p><b>Règles métier appliquées ici :</b>
 * <ol>
 *   <li>La date ne doit pas être {@code LOCKED} ou {@code CANCELLED}</li>
 *   <li>L'artiste doit avoir la disponibilité {@code AVAILABLE} pour être sélectionné</li>
 *   <li>La capacité par compétence ne doit pas être dépassée</li>
 *   <li>Un artiste ne peut être réservé qu'une seule fois par date</li>
 *   <li>Seul un booking {@code SELECTED} peut être supprimé</li>
 *   <li>Seul un booking {@code PENDING_CONFIRMATION} peut recevoir une réponse</li>
 * </ol>
 */
@ApplicationScoped
public class ArtistBookingService {

    private static final Logger LOG = LoggerFactory.getLogger(ArtistBookingService.class);

    @Inject
    ArtistBookingRepository artistBookingRepository;

    @Inject
    ShowDateRepository showDateRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Inject
    ArtistAvailabilityRepository artistAvailabilityRepository;

    @Inject
    ShowDateSkillRequirementRepository skillRequirementRepository;

    @Inject
    ArtistBookingMapper artistBookingMapper;

    // ------------------------------------------------------------------
    // Sélection d'un artiste (MANAGER)
    // ------------------------------------------------------------------

    /**
     * Sélectionne un artiste pour une date — crée un booking en statut {@code SELECTED}.
     *
     * <p><b>Règles vérifiées :</b>
     * <ol>
     *   <li>La date existe</li>
     *   <li>La date n'est pas {@code LOCKED} ou {@code CANCELLED}</li>
     *   <li>L'artiste existe</li>
     *   <li>L'artiste n'a pas déjà un booking actif sur cette date</li>
     *   <li>L'artiste a déclaré sa disponibilité {@code AVAILABLE} pour cette date</li>
     *   <li>Si un besoin artistique est spécifié : la capacité n'est pas atteinte
     *       et le cachet est figé au moment de la sélection</li>
     * </ol>
     *
     * @throws ShowDateNotFoundException         si la date est introuvable
     * @throws ShowDateNotModifiableException    si la date est LOCKED ou CANCELLED
     * @throws UserNotFoundException             si l'artiste est introuvable
     * @throws BookingAlreadyExistsException     si un booking existe déjà pour cet artiste sur cette date
     * @throws ArtistNotAvailableException       si l'artiste n'est pas AVAILABLE
     * @throws BookingCapacityExceededException  si la capacité pour la compétence est atteinte
     */
    @Transactional
    public ArtistBookingDto createBooking(CreateBookingRequestDto request) {
        LOG.info("Sélection de l'artiste id={} pour showDateId={}", request.artistId(), request.showDateId());

        ShowDateEntity showDate = showDateRepository
                .findByIdOptional(request.showDateId())
                .orElseThrow(ShowDateNotFoundException::new);

        validerDateModifiable(showDate);

        VioletteUserEntity artist = violetteUserRepository
                .findByIdOptional(request.artistId())
                .orElseThrow(UserNotFoundException::new);

        validerAbsenceDeBookingExistant(request.showDateId(), request.artistId());

        validerDisponibiliteArtiste(request.showDateId(), request.artistId());

        ShowDateSkillRequirementEntity skillRequirement = null;
        if (request.skillRequirementId() != null) {
            skillRequirement = skillRequirementRepository
                    .findByIdOptional(request.skillRequirementId())
                    .orElseThrow(SkillRequirementNotFoundException::new);

            if (!skillRequirement.getShowDate().getId().equals(showDate.getId())) {
                throw new SkillRequirementNotFoundException(
                        "Le besoin artistique id=" + request.skillRequirementId()
                                + " n'appartient pas à la date showDateId=" + showDate.getId() + "."
                );
            }

            validerCapacite(skillRequirement);
        }

        ArtistBookingEntity booking = new ArtistBookingEntity();
        booking.setShowDate(showDate);
        booking.setArtist(artist);
        booking.setSkillRequirement(skillRequirement);
        booking.setStatus(BookingStatus.SELECTED);

        if (skillRequirement != null) {
            booking.setAgreedNetFee(skillRequirement.getNetFee());
        }

        artistBookingRepository.persist(booking);

        LOG.info("Artiste id={} sélectionné — bookingId={} pour showDateId={}",
                artist.getId(), booking.getId(), showDate.getId());
        return artistBookingMapper.toDto(booking);
    }

    // ------------------------------------------------------------------
    // Désélection (MANAGER)
    // ------------------------------------------------------------------

    /**
     * Désélectionne un artiste — supprime le booking.
     * Uniquement autorisé si le booking est en statut {@code SELECTED}.
     *
     * @throws ArtistBookingNotFoundException    si le booking est introuvable
     * @throws InvalidBookingTransitionException si le statut n'est pas SELECTED
     */
    @Transactional
    public void deleteBooking(Long bookingId) {
        LOG.info("Désélection du booking id={}", bookingId);

        ArtistBookingEntity booking = artistBookingRepository
                .findByIdOptional(bookingId)
                .orElseThrow(ArtistBookingNotFoundException::new);

        if (booking.getStatus() != BookingStatus.SELECTED) {
            throw new InvalidBookingTransitionException(
                    "Seul un booking SELECTED peut être supprimé. Statut actuel : " + booking.getStatus()
            );
        }

        artistBookingRepository.delete(booking);
        LOG.info("Booking id={} supprimé (artiste id={} désélectionné)", bookingId, booking.getArtist().getId());
    }

    // ------------------------------------------------------------------
    // Envoi des demandes de confirmation (MANAGER)
    // ------------------------------------------------------------------

    /**
     * Envoie les demandes de confirmation pour tous les artistes {@code SELECTED} d'une date.
     * Passe tous les bookings {@code SELECTED} en {@code PENDING_CONFIRMATION}
     * et renseigne {@code requestedAt}.
     *
     * @throws ShowDateNotFoundException      si la date est introuvable
     * @throws ShowDateNotModifiableException si la date est LOCKED ou CANCELLED
     * @return liste des bookings mis à jour
     */
    @Transactional
    public List<ArtistBookingDto> sendConfirmationRequests(Long showDateId) {
        LOG.info("Envoi des demandes de confirmation pour showDateId={}", showDateId);

        ShowDateEntity showDate = showDateRepository
                .findByIdOptional(showDateId)
                .orElseThrow(ShowDateNotFoundException::new);

        validerDateModifiable(showDate);

        List<ArtistBookingEntity> selectedBookings =
                artistBookingRepository.findByShowDateIdAndStatus(showDateId, BookingStatus.SELECTED);

        Instant now = Instant.now();
        for (ArtistBookingEntity booking : selectedBookings) {
            booking.setStatus(BookingStatus.PENDING_CONFIRMATION);
            booking.getTimeline().setRequestedAt(now);
        }

        LOG.info("{} demande(s) de confirmation envoyée(s) pour showDateId={}", selectedBookings.size(), showDateId);
        return selectedBookings.stream()
                .map(artistBookingMapper::toDto)
                .toList();
    }

    // ------------------------------------------------------------------
    // Réponse artiste
    // ------------------------------------------------------------------

    /**
     * Enregistre la réponse d'un artiste à une demande de confirmation.
     * Vérifie que l'artiste qui répond est bien le destinataire du booking.
     *
     * <p>Transitions :
     * <ul>
     *   <li>{@code accept=true}  : {@code PENDING_CONFIRMATION} → {@code CONFIRMED}</li>
     *   <li>{@code accept=false} : {@code PENDING_CONFIRMATION} → {@code REFUSED}</li>
     * </ul>
     *
     * @param bookingId identifiant du booking
     * @param accept    {@code true} pour accepter, {@code false} pour refuser
     * @param principal principal JWT de l'artiste qui répond
     * @throws ArtistBookingNotFoundException    si le booking est introuvable
     * @throws UserNotFoundException             si le principal n'a pas de profil backend
     * @throws InvalidBookingTransitionException si le booking n'est pas en PENDING_CONFIRMATION
     *                                           ou si l'artiste ne correspond pas
     */
    @Transactional
    public ArtistBookingDto respondToRequest(Long bookingId, boolean accept, JwtPrincipalInfo principal) {
        LOG.info("Réponse au booking id={} par firebaseUid={} (accept={})",
                bookingId, principal.firebaseUid(), accept);

        ArtistBookingEntity booking = artistBookingRepository
                .findByIdOptional(bookingId)
                .orElseThrow(ArtistBookingNotFoundException::new);

        VioletteUserEntity currentArtist = violetteUserRepository
                .findByFirebaseUid(principal.firebaseUid())
                .orElseThrow(UserNotFoundException::new);

        if (!booking.getArtist().getId().equals(currentArtist.getId())) {
            throw new InvalidBookingTransitionException(
                    "Ce booking ne vous appartient pas."
            );
        }

        if (booking.getStatus() != BookingStatus.PENDING_CONFIRMATION) {
            throw new InvalidBookingTransitionException(
                    "Seul un booking PENDING_CONFIRMATION peut recevoir une réponse. Statut actuel : "
                            + booking.getStatus()
            );
        }

        BookingStatus newStatus = accept ? BookingStatus.CONFIRMED : BookingStatus.REFUSED;
        booking.setStatus(newStatus);
        booking.getTimeline().setRespondedAt(Instant.now());

        LOG.info("Booking id={} → {} (artiste id={})", bookingId, newStatus, currentArtist.getId());
        return artistBookingMapper.toDto(booking);
    }

    // ------------------------------------------------------------------
    // Lecture — artiste courant
    // ------------------------------------------------------------------

    /**
     * Retourne les bookings en attente de réponse pour l'artiste authentifié.
     * Statut filtré : {@code PENDING_CONFIRMATION}.
     *
     * @param principal principal JWT de l'artiste
     * @throws UserNotFoundException si le principal n'a pas de profil backend
     */
    public List<ArtistBookingDto> getPendingBookingsForCurrentArtist(JwtPrincipalInfo principal) {
        LOG.debug("Récupération des demandes en attente pour firebaseUid={}", principal.firebaseUid());

        VioletteUserEntity artist = violetteUserRepository
                .findByFirebaseUid(principal.firebaseUid())
                .orElseThrow(UserNotFoundException::new);

        return artistBookingRepository
                .findByArtistIdAndStatus(artist.getId(), BookingStatus.PENDING_CONFIRMATION)
                .stream()
                .map(artistBookingMapper::toDto)
                .toList();
    }

    // ------------------------------------------------------------------
    // Lecture — manager
    // ------------------------------------------------------------------

    /**
     * Retourne tous les bookings d'une date de spectacle.
     *
     * @throws ShowDateNotFoundException si la date est introuvable
     */
    public List<ArtistBookingDto> getBookingsForShowDate(Long showDateId) {
        LOG.debug("Récupération des bookings pour showDateId={}", showDateId);
        showDateRepository.findByIdOptional(showDateId)
                .orElseThrow(ShowDateNotFoundException::new);
        return artistBookingRepository.findByShowDateId(showDateId).stream()
                .map(artistBookingMapper::toDto)
                .toList();
    }

    // ------------------------------------------------------------------
    // Règles métier — méthodes privées
    // ------------------------------------------------------------------

    /**
     * Vérifie que la date n'est pas LOCKED ou CANCELLED.
     * Toute modification de booking est interdite dans ces états.
     */
    private void validerDateModifiable(ShowDateEntity showDate) {
        if (showDate.getStatus() == ShowDateStatus.LOCKED
                || showDate.getStatus() == ShowDateStatus.CANCELLED) {
            throw new ShowDateNotModifiableException();
        }
    }

    /**
     * Vérifie qu'aucun booking existant (quel que soit son statut) n'existe pour cet artiste sur cette date.
     * Un booking REFUSED bloque également la re-sélection — suppression préalable requise.
     */
    private void validerAbsenceDeBookingExistant(Long showDateId, Long artistId) {
        artistBookingRepository
                .findByShowDateIdAndArtistId(showDateId, artistId)
                .ifPresent(existing -> {
                    throw new BookingAlreadyExistsException();
                });
    }

    /**
     * Vérifie que l'artiste a déclaré sa disponibilité {@code AVAILABLE} pour cette date.
     * Un artiste sans entrée de disponibilité, ou avec un statut autre que {@code AVAILABLE},
     * ne peut pas être sélectionné.
     */
    private void validerDisponibiliteArtiste(Long showDateId, Long artistId) {
        boolean available = artistAvailabilityRepository
                .findByIdOptional(new ArtistAvailabilityId(showDateId, artistId))
                .map(a -> a.getStatus() == AvailabilityStatus.AVAILABLE)
                .orElse(false);

        if (!available) {
            throw new ArtistNotAvailableException();
        }
    }

    /**
     * Vérifie que la capacité requise pour un besoin artistique n'est pas encore atteinte.
     * Les statuts comptant dans la capacité : SELECTED, PENDING_CONFIRMATION, CONFIRMED.
     */
    private void validerCapacite(ShowDateSkillRequirementEntity skillRequirement) {
        long activeCount = artistBookingRepository
                .countActiveBookingsForSkillRequirement(skillRequirement.getId());

        if (activeCount >= skillRequirement.getRequiredCount()) {
            throw new BookingCapacityExceededException(
                    "Capacité atteinte pour la compétence " + skillRequirement.getSkill()
                            + " (" + activeCount + "/" + skillRequirement.getRequiredCount() + ")."
            );
        }
    }
}
