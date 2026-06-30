package io.violette.showdate.service;

import io.violette.artistbooking.model.BookingStatus;
import io.violette.artistbooking.repository.ArtistBookingRepository;
import io.violette.security.ManagerCompanyResolver;
import io.violette.security.exception.ForbiddenCompanyAccessException;
import io.violette.security.JwtPrincipalInfo;
import io.violette.showdate.dto.ArtistAvailabilityDto;
import io.violette.showdate.exception.AvailabilityLockedByConfirmedBookingException;
import io.violette.showdate.exception.InvalidAvailabilityStatusException;
import io.violette.showdate.exception.ShowDateNotFoundException;
import io.violette.showdate.mapper.ArtistAvailabilityMapper;
import io.violette.showdate.model.ArtistAvailabilityEntity;
import io.violette.showdate.model.ArtistAvailabilityId;
import io.violette.showdate.model.AvailabilityStatus;
import io.violette.showdate.model.ShowDateEntity;
import io.violette.showdate.repository.ArtistAvailabilityRepository;
import io.violette.showdate.repository.ShowDateRepository;
import io.violette.violetteuser.exception.UserNotFoundException;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

/**
 * Service du domaine showdate pour la lecture et la mise à jour des disponibilités artistes par date.
 */
@ApplicationScoped
public class ArtistAvailabilityService {

    private static final Logger LOG = LoggerFactory.getLogger(ArtistAvailabilityService.class);

    @Inject
    ShowDateRepository showDateRepository;

    @Inject
    ArtistAvailabilityRepository artistAvailabilityRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Inject
    ArtistAvailabilityMapper artistAvailabilityMapper;

    @Inject
    ManagerCompanyResolver managerCompanyResolver;

    @Inject
    ArtistBookingRepository artistBookingRepository;

    /**
     * Liste les disponibilités déclarées pour une date de spectacle (usage manager).
     * Vérifie que la date appartient à la compagnie du manager authentifié (OWASP A01).
     *
     * @return liste vide si aucune disponibilité n'a encore été enregistrée
     * @throws ShowDateNotFoundException        si la date n'existe pas
     * @throws ForbiddenCompanyAccessException  si la date n'appartient pas à la compagnie du manager courant
     */
    @Transactional
    public List<ArtistAvailabilityDto> getAvailabilitiesForShowDate(Long showDateId) {
        LOG.debug("Liste des disponibilités pour showDateId={}", showDateId);
        assertManagerOwnsShowDate(showDateId);
        return artistAvailabilityRepository.findByShowDateId(showDateId).stream()
                .map(artistAvailabilityMapper::toDto)
                .toList();
    }

    /**
     * Crée ou met à jour la disponibilité de l'artiste authentifié pour une date.
     *
     * @throws ShowDateNotFoundException si la date n'existe pas
     * @throws UserNotFoundException                 si aucun utilisateur backend ne correspond au JWT
     * @throws InvalidAvailabilityStatusException    si {@code status} est {@link AvailabilityStatus#PENDING}
     * @throws AvailabilityLockedByConfirmedBookingException si l'artiste possède un booking CONFIRMED sur cette date
     */
    @Transactional
    public ArtistAvailabilityDto upsertMyAvailability(Long showDateId, JwtPrincipalInfo principal, AvailabilityStatus status) {
        if (status == AvailabilityStatus.PENDING) {
            throw new InvalidAvailabilityStatusException(
                    "Le statut PENDING est réservé à l'initialisation automatique et ne peut pas être envoyé explicitement."
            );
        }

        ShowDateEntity showDate = showDateRepository.findByIdOptional(showDateId)
                .orElseThrow(ShowDateNotFoundException::new);

        VioletteUserEntity artist = violetteUserRepository.findByFirebaseUid(principal.firebaseUid())
                .orElseThrow(UserNotFoundException::new);

        // Contrainte d'unicité (show_date_id, artist_id) : au plus un booking par paire.
        // findByShowDateIdAndArtistId suffit — pas besoin d'une méthode dédiée findByShowDateIdAndArtistIdAndStatus.
        artistBookingRepository.findByShowDateIdAndArtistId(showDateId, artist.getId())
                .filter(booking -> booking.getStatus() == BookingStatus.CONFIRMED)
                .ifPresent(booking -> {
                    LOG.info("Modification de disponibilité refusée pour showDateId={} artistId={} — booking CONFIRMED id={}",
                            showDateId, artist.getId(), booking.getId());
                    throw new AvailabilityLockedByConfirmedBookingException();
                });

        ArtistAvailabilityId key = new ArtistAvailabilityId(showDateId, artist.getId());
        var existing = artistAvailabilityRepository.findByIdOptional(key);

        if (existing.isPresent()) {
            ArtistAvailabilityEntity entity = existing.get();
            entity.setStatus(status);
            artistAvailabilityRepository.flush();
            LOG.info("Disponibilité mise à jour pour showDateId={} artistId={} status={}", showDateId, artist.getId(), status);
            return artistAvailabilityMapper.toDto(entity);
        }

        ArtistAvailabilityEntity entity = new ArtistAvailabilityEntity();
        entity.setId(key);
        entity.setShowDate(showDate);
        entity.setArtist(artist);
        entity.setStatus(status);
        artistAvailabilityRepository.persistAndFlush(entity);
        LOG.info("Disponibilité créée pour showDateId={} artistId={} status={}", showDateId, artist.getId(), status);
        return artistAvailabilityMapper.toDto(entity);
    }

    /**
     * Retourne uniquement la disponibilité de l'artiste courant pour une date.
     * Si aucune ligne n'existe encore, renvoie un DTO logique en PENDING.
     */
    @Transactional
    public ArtistAvailabilityDto getMyAvailability(Long showDateId, JwtPrincipalInfo principal) {
        showDateRepository.findByIdOptional(showDateId)
                .orElseThrow(ShowDateNotFoundException::new);

        VioletteUserEntity artist = violetteUserRepository.findByFirebaseUid(principal.firebaseUid())
                .orElseThrow(UserNotFoundException::new);

        ArtistAvailabilityId key = new ArtistAvailabilityId(showDateId, artist.getId());
        return artistAvailabilityRepository.findByIdOptional(key)
                .map(artistAvailabilityMapper::toDto)
                .orElseGet(() -> new ArtistAvailabilityDto(
                        showDateId,
                        artist.getId(),
                        artist.getFirebaseUid(),
                        artist.getFirstName(),
                        artist.getLastName(),
                        AvailabilityStatus.PENDING,
                        null
                ));
    }

    /**
     * Vérifie qu'une date existe et appartient à la compagnie du manager courant.
     * Ordre impératif : existence (404) avant ownership (403).
     * Méthode locale à ce service (logique équivalente à {@link ShowDateService#loadOwnedShowDate(Long)}).
     */
    private void assertManagerOwnsShowDate(Long showDateId) {
        ShowDateEntity entity = showDateRepository.findByIdOptional(showDateId)
                .orElseThrow(ShowDateNotFoundException::new);
        managerCompanyResolver.assertCurrentManagerOwnsCompany(entity.getCompany().getId());
    }
}
