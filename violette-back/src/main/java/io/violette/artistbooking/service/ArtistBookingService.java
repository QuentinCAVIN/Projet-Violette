package io.violette.artistbooking.service;

import io.violette.artistbooking.dto.ArtistBookingDto;
import io.violette.artistbooking.dto.CreateBookingRequestDto;
import io.violette.artistbooking.event.BookingStatusChangedEvent;
import io.violette.artistbooking.exception.ArtistBookingNotFoundException;
import io.violette.artistbooking.exception.ArtistNotAvailableException;
import io.violette.artistbooking.exception.BookingAlreadyExistsException;
import io.violette.artistbooking.exception.BookingCapacityExceededException;
import io.violette.artistbooking.exception.ForbiddenBookingAccessException;
import io.violette.artistbooking.exception.InvalidBookingTransitionException;
import io.violette.artistbooking.exception.ShowDateNotModifiableException;
import io.violette.artistbooking.exception.SkillRequirementNotFoundException;
import io.violette.artistbooking.mapper.ArtistBookingMapper;
import io.violette.artistbooking.model.ArtistBookingEntity;
import io.violette.artistbooking.model.BookingStatus;
import io.violette.artistbooking.repository.ArtistBookingRepository;
import io.violette.security.JwtPrincipalInfo;
import io.violette.security.ManagerCompanyResolver;
import io.violette.security.exception.ForbiddenCompanyAccessException;
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
import jakarta.enterprise.event.Event;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

/**
 * Service du domaine artistbooking.
 *
 * <p>Orchestre le cycle de vie des réservations artistes :
 * sélection, envoi de confirmation, réponse artiste.
 *
 * <p><b>Workflow V1 — deux phases de booking distinctes :</b>
 * <ul>
 *   <li>{@code OPTION} : le gérant peut <b>présélectionner</b> des artistes ({@code SELECTED}).
 *       Ce n'est pas encore un engagement ferme — l'artiste reste libre d'accepter
 *       une autre date d'une autre compagnie. Les demandes de confirmation ferme
 *       ne peuvent pas être envoyées tant que la date n'est pas {@code CONFIRMED}.</li>
 *   <li>{@code CONFIRMED} : le client a validé la date. Le gérant peut envoyer
 *       les <b>vraies demandes de booking ferme</b> ({@code PENDING_CONFIRMATION}).
 *       L'engagement réel de l'artiste n'intervient qu'après son acceptation.</li>
 * </ul>
 * Le statut {@code INQUIRY} est une phase de prospection : aucune sélection ni présélection.
 *
 * <p><b>Règles métier appliquées ici :</b>
 * <ol>
 *   <li>Présélection/sélection ({@code createBooking}) : la date doit être {@code OPTION} ou {@code CONFIRMED}</li>
 *   <li>Envoi des demandes fermes ({@code sendConfirmationRequests}) : la date doit être {@code CONFIRMED}</li>
 *   <li>Toute mutation : interdite si la date est {@code STAFFED}, {@code CANCELLED} ou {@code ARCHIVED}</li>
 *   <li>L'artiste doit avoir la disponibilité {@code AVAILABLE} ou {@code IF_NEEDED} pour être sélectionné</li>
 *   <li>La capacité par compétence ne doit pas être dépassée</li>
 *   <li>Un artiste ne peut être réservé qu'une seule fois par date</li>
 *   <li>Réponse artiste : date non STAFFED/CANCELLED/ARCHIVED, booking en PENDING_CONFIRMATION, ownership vérifié</li>
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

    /** Événement CDI publié à chaque transition de statut — pattern Observer. */
    @Inject
    Event<BookingStatusChangedEvent> bookingStatusChangedEvent;

    @Inject
    ManagerCompanyResolver managerCompanyResolver;

    // ------------------------------------------------------------------
    // Sélection d'un artiste (MANAGER)
    // ------------------------------------------------------------------

    /**
     * Présélectionne ou sélectionne un artiste pour une date — crée un booking en statut {@code SELECTED}.
     *
     * <p>Le statut {@code SELECTED} a une sémantique différente selon le statut de la date :
     * <ul>
     *   <li><b>Date {@code OPTION}</b> : il s'agit d'une <b>présélection</b>. L'artiste est identifié
     *       comme pertinent mais n'a reçu aucune demande ferme. Il reste libre pour d'autres compagnies.</li>
     *   <li><b>Date {@code CONFIRMED}</b> : il s'agit d'une <b>sélection ferme</b>, précédant l'envoi
     *       d'une demande de confirmation ({@link #sendConfirmationRequests}).</li>
     * </ul>
     *
     * <p><b>Règles vérifiées :</b>
     * <ol>
     *   <li>La date existe</li>
     *   <li>La date est {@code OPTION} ou {@code CONFIRMED} (INQUIRY bloque ; STAFFED, CANCELLED,
     *       ARCHIVED bloquent)</li>
     *   <li>L'artiste existe</li>
     *   <li>L'artiste n'a pas déjà un booking actif sur cette date
     *       (un booking terminal {@code REFUSED} ou {@code CANCELLED} est recyclé)</li>
     *   <li>L'artiste a déclaré sa disponibilité {@code AVAILABLE} ou {@code IF_NEEDED} pour cette date</li>
     *   <li>Si un besoin artistique est spécifié : la capacité n'est pas atteinte
     *       et le cachet est capturé à titre d'estimation (estimation de planification en {@code OPTION},
     *       montant de référence contractuel en {@code CONFIRMED})</li>
     * </ol>
     *
     * @throws ShowDateNotFoundException         si la date est introuvable
     * @throws ForbiddenCompanyAccessException   si la date n'appartient pas à la compagnie du manager courant
     * @throws ShowDateNotModifiableException    si la date n'est ni {@code OPTION}, ni {@code CONFIRMED}
     * @throws UserNotFoundException             si l'artiste est introuvable
     * @throws BookingAlreadyExistsException     si un booking actif existe déjà pour cet artiste sur cette date
     * @throws ArtistNotAvailableException       si l'artiste n'est ni AVAILABLE ni IF_NEEDED
     * @throws BookingCapacityExceededException  si la capacité pour la compétence est atteinte
     */
    @Transactional
    public ArtistBookingDto createBooking(CreateBookingRequestDto request) {
        LOG.info("Sélection de l'artiste id={} pour showDateId={}", request.artistId(), request.showDateId());

        ShowDateEntity showDate = showDateRepository
                .findByIdOptional(request.showDateId())
                .orElseThrow(ShowDateNotFoundException::new);

        managerCompanyResolver.assertCurrentManagerOwnsCompany(showDate.getCompany().getId());

        validerDateBookable(showDate);

        VioletteUserEntity artist = violetteUserRepository
                .findByIdOptional(request.artistId())
                .orElseThrow(UserNotFoundException::new);

        Optional<ArtistBookingEntity> existingBooking = artistBookingRepository
                .findByShowDateIdAndArtistId(request.showDateId(), request.artistId());

        assertNotActivelyBooked(existingBooking);

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

        ArtistBookingEntity booking;
        if (existingBooking.isPresent() && isTerminalBookingStatus(existingBooking.get().getStatus())) {
            booking = resetBookingForReselection(existingBooking.get(), skillRequirement);
            LOG.info("Artiste id={} re-sélectionné (recyclage bookingId={}) pour showDateId={}",
                    artist.getId(), booking.getId(), showDate.getId());
        } else {
            booking = new ArtistBookingEntity();
            booking.setShowDate(showDate);
            booking.setArtist(artist);
            booking.setSkillRequirement(skillRequirement);
            booking.setStatus(BookingStatus.SELECTED);

            if (skillRequirement != null) {
                booking.setAgreedNetFee(skillRequirement.getNetFee());
            }

            artistBookingRepository.persist(booking);

            LOG.info("Artiste id={} présélectionné/sélectionné (statut date={}) — bookingId={} pour showDateId={}",
                    artist.getId(), showDate.getStatus(), booking.getId(), showDate.getId());
        }

        return artistBookingMapper.toDto(booking);
    }

    // ------------------------------------------------------------------
    // Désélection (MANAGER)
    // ------------------------------------------------------------------

    /**
     * Désélectionne ou dépresélectionne un artiste — supprime le booking.
     * Uniquement autorisé si le booking est en statut {@code SELECTED}
     * et si la date n'est pas {@code STAFFED}, {@code CANCELLED} ou {@code ARCHIVED}.
     *
     * @throws ArtistBookingNotFoundException    si le booking est introuvable
     * @throws ForbiddenCompanyAccessException   si la date du booking n'appartient pas à la compagnie du manager courant
     * @throws ShowDateNotModifiableException    si la date est STAFFED, CANCELLED ou ARCHIVED
     * @throws InvalidBookingTransitionException si le statut n'est pas SELECTED
     */
    @Transactional
    public void deleteBooking(Long bookingId) {
        LOG.info("Désélection du booking id={}", bookingId);

        ArtistBookingEntity booking = artistBookingRepository
                .findByIdOptional(bookingId)
                .orElseThrow(ArtistBookingNotFoundException::new);

        managerCompanyResolver.assertCurrentManagerOwnsCompany(booking.getShowDate().getCompany().getId());

        validerDateModifiable(booking.getShowDate());

        if (booking.getStatus() != BookingStatus.SELECTED) {
            throw new InvalidBookingTransitionException(
                    "Seul un booking SELECTED peut être supprimé. Statut actuel : " + booking.getStatus()
            );
        }

        artistBookingRepository.delete(booking);
        LOG.info("Booking id={} supprimé (artiste id={} désélectionné)", bookingId, booking.getArtist().getId());
    }

    // ------------------------------------------------------------------
    // Annulation par le gérant (MANAGER)
    // ------------------------------------------------------------------

    /**
     * Annule un booking en statut {@code PENDING_CONFIRMATION} ou {@code CONFIRMED}.
     * Seul le gérant de la compagnie peut rompre l'engagement.
     *
     * <p>La désélection d'un {@code SELECTED} reste gérée par {@link #deleteBooking}.
     *
     * @throws ArtistBookingNotFoundException    si le booking est introuvable
     * @throws ForbiddenCompanyAccessException   si la date du booking n'appartient pas à la compagnie du manager courant
     * @throws ShowDateNotModifiableException    si la date est CANCELLED ou ARCHIVED
     * @throws InvalidBookingTransitionException si le statut n'est ni PENDING_CONFIRMATION ni CONFIRMED
     */
    @Transactional
    public ArtistBookingDto cancelBooking(Long bookingId) {
        LOG.info("Annulation du booking id={}", bookingId);

        ArtistBookingEntity booking = artistBookingRepository
                .findByIdOptional(bookingId)
                .orElseThrow(ArtistBookingNotFoundException::new);

        managerCompanyResolver.assertCurrentManagerOwnsCompany(booking.getShowDate().getCompany().getId());

        assertShowDateCancellable(booking.getShowDate());

        BookingStatus currentStatus = booking.getStatus();
        if (currentStatus != BookingStatus.PENDING_CONFIRMATION
                && currentStatus != BookingStatus.CONFIRMED) {
            throw new InvalidBookingTransitionException(
                    "Seul un booking PENDING_CONFIRMATION ou CONFIRMED peut être annulé. Statut actuel : "
                            + currentStatus
            );
        }

        BookingStatus oldStatus = currentStatus;
        booking.setStatus(BookingStatus.CANCELLED);

        bookingStatusChangedEvent.fire(new BookingStatusChangedEvent(
                bookingId,
                booking.getShowDate().getId(),
                booking.getArtist().getId(),
                oldStatus,
                BookingStatus.CANCELLED
        ));

        LOG.info("Booking id={} → CANCELLED (artiste id={})", bookingId, booking.getArtist().getId());
        return artistBookingMapper.toDto(booking);
    }

    // ------------------------------------------------------------------
    // Envoi des demandes de confirmation (MANAGER)
    // ------------------------------------------------------------------

    /**
     * Envoie les demandes de confirmation ferme pour tous les artistes {@code SELECTED} d'une date.
     * Passe tous les bookings {@code SELECTED} en {@code PENDING_CONFIRMATION}
     * et renseigne {@code requestedAt}.
     *
     * <p>Cette opération représente l'<b>engagement ferme</b> du gérant vis-à-vis des artistes.
     * Elle n'est autorisée qu'une fois la date {@code CONFIRMED} par le client.
     * Les présélections réalisées pendant la phase {@code OPTION} ne peuvent pas encore
     * être transformées en demandes fermes : attendre la confirmation client d'abord.
     *
     * @throws ShowDateNotFoundException       si la date est introuvable
     * @throws ForbiddenCompanyAccessException si la date n'appartient pas à la compagnie du manager courant
     * @throws ShowDateNotModifiableException  si la date n'est pas {@code CONFIRMED} (workflow V1)
     * @return liste des bookings mis à jour
     */
    @Transactional
    public List<ArtistBookingDto> sendConfirmationRequests(Long showDateId) {
        LOG.info("Envoi des demandes de confirmation pour showDateId={}", showDateId);

        ShowDateEntity showDate = showDateRepository
                .findByIdOptional(showDateId)
                .orElseThrow(ShowDateNotFoundException::new);

        managerCompanyResolver.assertCurrentManagerOwnsCompany(showDate.getCompany().getId());

        validerDateConfirmee(showDate);

        List<ArtistBookingEntity> selectedBookings =
                artistBookingRepository.findByShowDateIdAndStatus(showDateId, BookingStatus.SELECTED);

        Instant now = Instant.now();
        for (ArtistBookingEntity booking : selectedBookings) {
            BookingStatus oldStatus = booking.getStatus();
            booking.setStatus(BookingStatus.PENDING_CONFIRMATION);
            booking.getTimeline().setRequestedAt(now);
            bookingStatusChangedEvent.fire(new BookingStatusChangedEvent(
                    booking.getId(),
                    showDateId,
                    booking.getArtist().getId(),
                    oldStatus,
                    BookingStatus.PENDING_CONFIRMATION
            ));
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
     * <p>La date ne doit pas être {@code STAFFED}, {@code CANCELLED} ou {@code ARCHIVED}.
     * Dans le workflow V1, les réponses artistes interviennent pendant les phases
     * {@code OPTION} ou {@code CONFIRMED}, avant verrouillage de staffing. Si la date est déjà
     * staffée, annulée ou archivée, aucune mutation n'est acceptée.
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
     * @throws ArtistBookingNotFoundException      si le booking est introuvable
     * @throws UserNotFoundException               si le principal n'a pas de profil backend
     * @throws ForbiddenBookingAccessException     si l'artiste authentifié n'est pas le destinataire du booking
     * @throws ShowDateNotModifiableException      si la date est STAFFED, CANCELLED ou ARCHIVED
     * @throws InvalidBookingTransitionException   si le booking n'est pas en PENDING_CONFIRMATION
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
            throw new ForbiddenBookingAccessException();
        }

        validerDateModifiable(booking.getShowDate());

        if (booking.getStatus() != BookingStatus.PENDING_CONFIRMATION) {
            throw new InvalidBookingTransitionException(
                    "Seul un booking PENDING_CONFIRMATION peut recevoir une réponse. Statut actuel : "
                            + booking.getStatus()
            );
        }

        BookingStatus oldStatus = booking.getStatus();
        BookingStatus newStatus = accept ? BookingStatus.CONFIRMED : BookingStatus.REFUSED;
        booking.setStatus(newStatus);
        booking.getTimeline().setRespondedAt(Instant.now());

        bookingStatusChangedEvent.fire(new BookingStatusChangedEvent(
                bookingId,
                booking.getShowDate().getId(),
                currentArtist.getId(),
                oldStatus,
                newStatus
        ));

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

    /**
     * Retourne tous les bookings de l'artiste authentifié.
     * Utilisé côté frontend pour distinguer disponibilité déclarée et engagement réel.
     *
     * @param principal principal JWT de l'artiste
     * @throws UserNotFoundException si le principal n'a pas de profil backend
     */
    public List<ArtistBookingDto> getBookingsForCurrentArtist(JwtPrincipalInfo principal) {
        LOG.debug("Récupération des bookings pour firebaseUid={}", principal.firebaseUid());

        VioletteUserEntity artist = violetteUserRepository
                .findByFirebaseUid(principal.firebaseUid())
                .orElseThrow(UserNotFoundException::new);

        return artistBookingRepository
                .findByArtistId(artist.getId())
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
     * @throws ShowDateNotFoundException       si la date est introuvable
     * @throws ForbiddenCompanyAccessException si la date n'appartient pas à la compagnie du manager courant
     */
    public List<ArtistBookingDto> getBookingsForShowDate(Long showDateId) {
        LOG.debug("Récupération des bookings pour showDateId={}", showDateId);
        ShowDateEntity showDate = showDateRepository.findByIdOptional(showDateId)
                .orElseThrow(ShowDateNotFoundException::new);
        managerCompanyResolver.assertCurrentManagerOwnsCompany(showDate.getCompany().getId());
        return artistBookingRepository.findByShowDateId(showDateId).stream()
                .map(artistBookingMapper::toDto)
                .toList();
    }

    // ------------------------------------------------------------------
    // Règles métier — méthodes privées
    // ------------------------------------------------------------------

    /**
     * Vérifie que la date est en statut {@code OPTION} ou {@code CONFIRMED}.
     * Utilisé pour la présélection/sélection d'artistes ({@code createBooking}).
     *
     * <p>Les statuts {@code INQUIRY}, {@code STAFFED}, {@code CANCELLED} et {@code ARCHIVED}
     * bloquent toute sélection.
     */
    private void validerDateBookable(ShowDateEntity showDate) {
        ShowDateStatus status = showDate.getStatus();
        if (status != ShowDateStatus.OPTION && status != ShowDateStatus.CONFIRMED) {
            throw new ShowDateNotModifiableException(
                    "La présélection/sélection est autorisée uniquement sur une date OPTION ou CONFIRMED. Statut actuel : "
                            + status
            );
        }
    }

    /**
     * Vérifie que la date est en statut {@code CONFIRMED}.
     * Utilisé pour l'envoi des demandes de booking ferme ({@code sendConfirmationRequests}).
     *
     * <p>Les présélections réalisées en phase {@code OPTION} ne peuvent pas encore
     * être transformées en demandes fermes — il faut attendre la confirmation client.
     * Les statuts {@code STAFFED}, {@code CANCELLED} et {@code ARCHIVED} bloquent également.
     */
    private void validerDateConfirmee(ShowDateEntity showDate) {
        if (showDate.getStatus() != ShowDateStatus.CONFIRMED) {
            throw new ShowDateNotModifiableException(
                    "L'envoi de demandes de booking ferme n'est autorisé que sur une date CONFIRMED. Statut actuel : "
                            + showDate.getStatus()
            );
        }
    }

    /**
     * Vérifie que la date n'est pas {@code STAFFED}, {@code CANCELLED} ou {@code ARCHIVED}.
     * Utilisé pour les opérations de modification qui restent acceptables
     * pendant les phases autorisées (ex. : désélection, réponse artiste).
     */
    private void validerDateModifiable(ShowDateEntity showDate) {
        if (showDate.getStatus() == ShowDateStatus.STAFFED
                || showDate.getStatus() == ShowDateStatus.CANCELLED
                || showDate.getStatus() == ShowDateStatus.ARCHIVED) {
            throw new ShowDateNotModifiableException();
        }
    }

    /**
     * Vérifie que la date permet l'annulation d'un booking par le gérant.
     * Autorise {@code OPTION}, {@code CONFIRMED} et {@code STAFFED} ;
     * bloque uniquement {@code CANCELLED} et {@code ARCHIVED}.
     */
    private void assertShowDateCancellable(ShowDateEntity showDate) {
        if (showDate.getStatus() == ShowDateStatus.CANCELLED
                || showDate.getStatus() == ShowDateStatus.ARCHIVED) {
            throw new ShowDateNotModifiableException();
        }
    }

    /**
     * Vérifie qu'aucun booking actif n'existe pour la paire (date, artiste) déjà chargée.
     * Un booking en statut terminal ({@code REFUSED}, {@code CANCELLED}) n'est pas bloquant —
     * il sera recyclé par {@link #createBooking}.
     */
    private void assertNotActivelyBooked(Optional<ArtistBookingEntity> existingBooking) {
        existingBooking
                .filter(booking -> isActiveBookingStatus(booking.getStatus()))
                .ifPresent(existing -> {
                    throw new BookingAlreadyExistsException();
                });
    }

    /**
     * Réinitialise un booking terminal pour une nouvelle sélection sur la même paire (date, artiste).
     * L'entité est déjà managée — aucun {@code persist} nécessaire.
     */
    private ArtistBookingEntity resetBookingForReselection(
            ArtistBookingEntity booking,
            ShowDateSkillRequirementEntity skillRequirement) {
        booking.setSkillRequirement(skillRequirement);
        booking.setStatus(BookingStatus.SELECTED);
        booking.setAgreedNetFee(skillRequirement != null ? skillRequirement.getNetFee() : null);
        booking.getTimeline().setRequestedAt(null);
        booking.getTimeline().setRespondedAt(null);
        return booking;
    }

    private boolean isActiveBookingStatus(BookingStatus status) {
        return status == BookingStatus.SELECTED
                || status == BookingStatus.PENDING_CONFIRMATION
                || status == BookingStatus.CONFIRMED;
    }

    private boolean isTerminalBookingStatus(BookingStatus status) {
        return status == BookingStatus.REFUSED || status == BookingStatus.CANCELLED;
    }

    /**
     * Vérifie que l'artiste a déclaré une disponibilité sélectionnable pour cette date.
     *
     * <p>Règle métier V1 :
     * {@code IF_NEEDED} = disponible si besoin, sélection autorisée mais non prioritaire.
     * Les statuts {@code PENDING} et {@code UNAVAILABLE} restent bloquants.
     */
    private void validerDisponibiliteArtiste(Long showDateId, Long artistId) {
        boolean available = artistAvailabilityRepository
                .findByIdOptional(new ArtistAvailabilityId(showDateId, artistId))
                .map(a -> a.getStatus() == AvailabilityStatus.AVAILABLE
                        || a.getStatus() == AvailabilityStatus.IF_NEEDED)
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
