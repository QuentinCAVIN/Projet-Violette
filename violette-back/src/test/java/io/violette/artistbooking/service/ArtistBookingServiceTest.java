package io.violette.artistbooking.service;

import io.quarkus.test.junit.QuarkusTest;
import io.violette.artistbooking.dto.ArtistBookingDto;
import io.violette.artistbooking.dto.CreateBookingRequestDto;
import io.violette.artistbooking.exception.ArtistBookingNotFoundException;
import io.violette.artistbooking.exception.ArtistNotAvailableException;
import io.violette.artistbooking.exception.BookingAlreadyExistsException;
import io.violette.artistbooking.exception.BookingCapacityExceededException;
import io.violette.artistbooking.exception.InvalidBookingTransitionException;
import io.violette.artistbooking.exception.ShowDateNotModifiableException;
import io.violette.artistbooking.exception.SkillRequirementNotFoundException;
import io.violette.artistbooking.model.ArtistBookingEntity;
import io.violette.artistbooking.model.BookingStatus;
import io.violette.artistbooking.repository.ArtistBookingRepository;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.security.JwtPrincipalInfo;
import io.violette.showdate.model.ArtistAvailabilityEntity;
import io.violette.showdate.model.ArtistAvailabilityId;
import io.violette.showdate.model.AvailabilityStatus;
import io.violette.showdate.model.ShowDateEntity;
import io.violette.showdate.model.ShowDateSkillRequirementEntity;
import io.violette.showdate.model.ShowDateStatus;
import io.violette.showdate.repository.ArtistAvailabilityRepository;
import io.violette.showdate.repository.ShowDateRepository;
import io.violette.showdate.repository.ShowDateSkillRequirementRepository;
import io.violette.violetteuser.model.ArtistSkill;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

@QuarkusTest
class ArtistBookingServiceTest {

    @Inject
    ArtistBookingService artistBookingService;

    @Inject
    ArtistBookingRepository bookingRepository;

    @Inject
    ShowDateRepository showDateRepository;

    @Inject
    ShowDateSkillRequirementRepository skillRequirementRepository;

    @Inject
    ArtistAvailabilityRepository availabilityRepository;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    // ==================================================================
    // createBooking — cas nominal
    // ==================================================================

    @Test
    @Transactional
    @DisplayName("createBooking — nominal : statut SELECTED, snapshot agreedNetFee, timeline renseignée")
    void createBooking_nominal_returnsSelectedBookingWithSnapshot() {
        Context ctx = buildContext("svc-nom-1");

        ArtistBookingDto dto = artistBookingService.createBooking(
                new CreateBookingRequestDto(ctx.showDate.getId(), ctx.artist.getId(), ctx.skillReq.getId())
        );

        assertAll(
                () -> assertNotNull(dto.id()),
                () -> assertEquals(BookingStatus.SELECTED, dto.status()),
                () -> assertEquals(ctx.showDate.getId(), dto.showDateId()),
                () -> assertEquals(ctx.artist.getId(), dto.artistId()),
                () -> assertEquals(ctx.skillReq.getId(), dto.skillRequirementId()),
                () -> assertEquals(new BigDecimal("120.00"), dto.agreedNetFee()),
                () -> assertNotNull(dto.createdAt()),
                () -> assertNotNull(dto.updatedAt()),
                () -> assertNull(dto.requestedAt()),
                () -> assertNull(dto.respondedAt())
        );
    }

    @Test
    @Transactional
    @DisplayName("createBooking — agreedNetFee est un snapshot du netFee de la compétence au moment de la sélection")
    void createBooking_agreedNetFeeIsSnapshotFromSkillRequirement() {
        Context ctx = buildContext("svc-snap-1");

        ArtistBookingDto dto = artistBookingService.createBooking(
                new CreateBookingRequestDto(ctx.showDate.getId(), ctx.artist.getId(), ctx.skillReq.getId())
        );

        assertEquals(ctx.skillReq.getNetFee(), dto.agreedNetFee());
    }

    @Test
    @Transactional
    @DisplayName("createBooking — sans compétence : pas de snapshot de cachet, skillRequirementId null")
    void createBooking_withoutSkillRequirement_noFeeSnapshot() {
        Context ctx = buildContext("svc-nosk-1");

        ArtistBookingDto dto = artistBookingService.createBooking(
                new CreateBookingRequestDto(ctx.showDate.getId(), ctx.artist.getId(), null)
        );

        assertAll(
                () -> assertEquals(BookingStatus.SELECTED, dto.status()),
                () -> assertNull(dto.skillRequirementId()),
                () -> assertNull(dto.agreedNetFee())
        );
    }

    // ==================================================================
    // createBooking — blocages
    // ==================================================================

    @Test
    @Transactional
    @DisplayName("createBooking — échoue si la disponibilité de l'artiste n'est pas AVAILABLE")
    void createBooking_whenArtistNotAvailable_throwsArtistNotAvailableException() {
        Context ctx = buildContext("svc-unavail-1");
        ctx.availability.setStatus(AvailabilityStatus.IF_NEEDED);
        availabilityRepository.flush();

        assertThrows(ArtistNotAvailableException.class, () ->
                artistBookingService.createBooking(
                        new CreateBookingRequestDto(ctx.showDate.getId(), ctx.artist.getId(), ctx.skillReq.getId())
                )
        );
    }

    @Test
    @Transactional
    @DisplayName("createBooking — échoue si aucune disponibilité n'est déclarée pour l'artiste")
    void createBooking_whenNoAvailabilityEntry_throwsArtistNotAvailableException() {
        Context ctx = buildContext("svc-noav-1");
        // Supprime la disponibilité créée par buildContext
        availabilityRepository.delete(ctx.availability);
        availabilityRepository.flush();

        assertThrows(ArtistNotAvailableException.class, () ->
                artistBookingService.createBooking(
                        new CreateBookingRequestDto(ctx.showDate.getId(), ctx.artist.getId(), ctx.skillReq.getId())
                )
        );
    }

    @Test
    @Transactional
    @DisplayName("createBooking — échoue si la capacité est atteinte (requiredCount=1, 1 réservation active)")
    void createBooking_whenCapacityReached_throwsBookingCapacityExceededException() {
        Context ctx = buildContext("svc-cap-1");

        // Première sélection — occupe la seule place disponible (requiredCount = 1)
        artistBookingService.createBooking(
                new CreateBookingRequestDto(ctx.showDate.getId(), ctx.artist.getId(), ctx.skillReq.getId())
        );

        // Deuxième artiste disponible pour la même compétence
        VioletteUserEntity artist2 = buildAndPersistUser("svc-cap-1-b", "svc-cap-1-b@test.com", Set.of(UserRole.ARTIST));
        persistAvailability(ctx.showDate, artist2, AvailabilityStatus.AVAILABLE);
        availabilityRepository.flush();

        assertThrows(BookingCapacityExceededException.class, () ->
                artistBookingService.createBooking(
                        new CreateBookingRequestDto(ctx.showDate.getId(), artist2.getId(), ctx.skillReq.getId())
                )
        );
    }

    @Test
    @Transactional
    @DisplayName("createBooking — échoue si la date est LOCKED")
    void createBooking_whenShowDateLocked_throwsShowDateNotModifiableException() {
        Context ctx = buildContext("svc-locked-1");
        ctx.showDate.setStatus(ShowDateStatus.LOCKED);
        showDateRepository.flush();

        assertThrows(ShowDateNotModifiableException.class, () ->
                artistBookingService.createBooking(
                        new CreateBookingRequestDto(ctx.showDate.getId(), ctx.artist.getId(), ctx.skillReq.getId())
                )
        );
    }

    @Test
    @Transactional
    @DisplayName("createBooking — échoue si la date est CANCELLED")
    void createBooking_whenShowDateCancelled_throwsShowDateNotModifiableException() {
        Context ctx = buildContext("svc-sdcanc-1");
        ctx.showDate.setStatus(ShowDateStatus.CANCELLED);
        showDateRepository.flush();

        assertThrows(ShowDateNotModifiableException.class, () ->
                artistBookingService.createBooking(
                        new CreateBookingRequestDto(ctx.showDate.getId(), ctx.artist.getId(), ctx.skillReq.getId())
                )
        );
    }

    @Test
    @Transactional
    @DisplayName("createBooking — échoue si la date est PENDING (workflow V1 : la sélection nécessite CONFIRMED)")
    void createBooking_whenShowDatePending_throwsShowDateNotModifiableException() {
        Context ctx = buildContext("svc-sdpend-1");
        // Repasse en PENDING pour simuler une date non encore confirmée par le client
        ctx.showDate.setStatus(ShowDateStatus.PENDING);
        showDateRepository.flush();

        assertThrows(ShowDateNotModifiableException.class, () ->
                artistBookingService.createBooking(
                        new CreateBookingRequestDto(ctx.showDate.getId(), ctx.artist.getId(), null)
                )
        );
    }

    @Test
    @Transactional
    @DisplayName("createBooking — échoue si la date est OPTIONAL (workflow V1 : la sélection nécessite CONFIRMED)")
    void createBooking_whenShowDateOptional_throwsShowDateNotModifiableException() {
        Context ctx = buildContext("svc-sdopt-1");
        ctx.showDate.setStatus(ShowDateStatus.OPTIONAL);
        showDateRepository.flush();

        assertThrows(ShowDateNotModifiableException.class, () ->
                artistBookingService.createBooking(
                        new CreateBookingRequestDto(ctx.showDate.getId(), ctx.artist.getId(), null)
                )
        );
    }

    @Test
    @Transactional
    @DisplayName("createBooking — échoue si un booking existe déjà pour cet artiste sur cette date")
    void createBooking_whenBookingAlreadyExists_throwsBookingAlreadyExistsException() {
        Context ctx = buildContext("svc-dup-1");

        // Première sélection
        artistBookingService.createBooking(
                new CreateBookingRequestDto(ctx.showDate.getId(), ctx.artist.getId(), null)
        );

        // Deuxième tentative — même artiste, même date
        assertThrows(BookingAlreadyExistsException.class, () ->
                artistBookingService.createBooking(
                        new CreateBookingRequestDto(ctx.showDate.getId(), ctx.artist.getId(), null)
                )
        );
    }

    @Test
    @Transactional
    @DisplayName("createBooking — échoue si la compétence appartient à une autre date")
    void createBooking_whenSkillRequirementBelongsToOtherDate_throwsSkillRequirementNotFoundException() {
        Context ctx = buildContext("svc-wrongsk-1");

        // Crée une date différente avec son propre besoin
        ShowDateEntity otherDate = buildAndPersistShowDate(ctx.company, LocalDate.of(2026, 12, 31));
        ShowDateSkillRequirementEntity otherReq =
                buildAndPersistSkillRequirement(otherDate, ArtistSkill.SINGING, 1, "80.00");

        // Tente d'associer le besoin de otherDate au booking de ctx.showDate
        assertThrows(SkillRequirementNotFoundException.class, () ->
                artistBookingService.createBooking(
                        new CreateBookingRequestDto(ctx.showDate.getId(), ctx.artist.getId(), otherReq.getId())
                )
        );
    }

    // ==================================================================
    // deleteBooking
    // ==================================================================

    @Test
    @Transactional
    @DisplayName("deleteBooking — autorisé quand le statut est SELECTED")
    void deleteBooking_whenSelected_deletesBooking() {
        Context ctx = buildContext("svc-del-1");
        ArtistBookingDto created = artistBookingService.createBooking(
                new CreateBookingRequestDto(ctx.showDate.getId(), ctx.artist.getId(), null)
        );

        artistBookingService.deleteBooking(created.id());

        assertTrue(bookingRepository.findByIdOptional(created.id()).isEmpty());
    }

    @Test
    @Transactional
    @DisplayName("deleteBooking — échoue si le statut est PENDING_CONFIRMATION")
    void deleteBooking_whenPendingConfirmation_throwsInvalidBookingTransitionException() {
        Context ctx = buildContext("svc-del-2");
        ArtistBookingEntity booking = persistBookingDirectly(ctx, BookingStatus.PENDING_CONFIRMATION);

        assertThrows(InvalidBookingTransitionException.class,
                () -> artistBookingService.deleteBooking(booking.getId()));
    }

    @Test
    @Transactional
    @DisplayName("deleteBooking — échoue si le statut est CONFIRMED")
    void deleteBooking_whenConfirmed_throwsInvalidBookingTransitionException() {
        Context ctx = buildContext("svc-del-3");
        ArtistBookingEntity booking = persistBookingDirectly(ctx, BookingStatus.CONFIRMED);

        assertThrows(InvalidBookingTransitionException.class,
                () -> artistBookingService.deleteBooking(booking.getId()));
    }

    @Test
    @Transactional
    @DisplayName("deleteBooking — échoue si la date est LOCKED")
    void deleteBooking_whenShowDateLocked_throwsShowDateNotModifiableException() {
        Context ctx = buildContext("svc-del-4");
        ArtistBookingEntity booking = persistBookingDirectly(ctx, BookingStatus.SELECTED);
        ctx.showDate.setStatus(ShowDateStatus.LOCKED);
        showDateRepository.flush();

        assertThrows(ShowDateNotModifiableException.class,
                () -> artistBookingService.deleteBooking(booking.getId()));
    }

    @Test
    @Transactional
    @DisplayName("deleteBooking — échoue si le booking n'existe pas")
    void deleteBooking_whenNotFound_throwsArtistBookingNotFoundException() {
        assertThrows(ArtistBookingNotFoundException.class,
                () -> artistBookingService.deleteBooking(99999L));
    }

    // ==================================================================
    // sendConfirmationRequests
    // ==================================================================

    @Test
    @Transactional
    @DisplayName("sendConfirmationRequests — passe SELECTED en PENDING_CONFIRMATION et renseigne requestedAt")
    void sendConfirmationRequests_movesSelectedToPendingAndSetsRequestedAt() {
        Context ctx = buildContext("svc-send-1");
        VioletteUserEntity artist2 = buildAndPersistUser("svc-send-1-b", "svc-send-1-b@test.com", Set.of(UserRole.ARTIST));
        persistAvailability(ctx.showDate, artist2, AvailabilityStatus.AVAILABLE);

        // Sélectionner deux artistes
        artistBookingService.createBooking(
                new CreateBookingRequestDto(ctx.showDate.getId(), ctx.artist.getId(), null)
        );
        // Le skillReq de ctx a requiredCount=1 (déjà atteint par b1), on utilise null pour b2
        ArtistBookingEntity raw2 = new ArtistBookingEntity();
        raw2.setShowDate(ctx.showDate);
        raw2.setArtist(artist2);
        raw2.setStatus(BookingStatus.SELECTED);
        bookingRepository.persistAndFlush(raw2);

        List<ArtistBookingDto> updated = artistBookingService.sendConfirmationRequests(ctx.showDate.getId());

        assertAll(
                () -> assertEquals(2, updated.size()),
                () -> assertTrue(updated.stream().allMatch(b -> b.status() == BookingStatus.PENDING_CONFIRMATION)),
                () -> assertTrue(updated.stream().allMatch(b -> b.requestedAt() != null))
        );
    }

    @Test
    @Transactional
    @DisplayName("sendConfirmationRequests — ne modifie pas les bookings avec un statut autre que SELECTED")
    void sendConfirmationRequests_doesNotModifyNonSelectedBookings() {
        Context ctx = buildContext("svc-send-2");
        VioletteUserEntity artist2 = buildAndPersistUser("svc-send-2-b", "svc-send-2-b@test.com", Set.of(UserRole.ARTIST));

        // Persiste directement un CONFIRMED (non modifiable par sendConfirmationRequests)
        ArtistBookingEntity confirmed = new ArtistBookingEntity();
        confirmed.setShowDate(ctx.showDate);
        confirmed.setArtist(artist2);
        confirmed.setStatus(BookingStatus.CONFIRMED);
        bookingRepository.persistAndFlush(confirmed);

        // Aucun SELECTED → batch vide
        List<ArtistBookingDto> updated = artistBookingService.sendConfirmationRequests(ctx.showDate.getId());

        assertEquals(0, updated.size());

        // Le CONFIRMED n'a pas bougé
        ArtistBookingEntity reloaded = bookingRepository.findById(confirmed.getId());
        assertEquals(BookingStatus.CONFIRMED, reloaded.getStatus());
    }

    @Test
    @Transactional
    @DisplayName("sendConfirmationRequests — échoue si la date est LOCKED")
    void sendConfirmationRequests_whenShowDateLocked_throwsShowDateNotModifiableException() {
        Context ctx = buildContext("svc-send-3");
        ctx.showDate.setStatus(ShowDateStatus.LOCKED);
        showDateRepository.flush();

        assertThrows(ShowDateNotModifiableException.class,
                () -> artistBookingService.sendConfirmationRequests(ctx.showDate.getId()));
    }

    // ==================================================================
    // respondToRequest — acceptation
    // ==================================================================

    @Test
    @Transactional
    @DisplayName("respondToRequest — acceptation : PENDING_CONFIRMATION → CONFIRMED, respondedAt renseigné")
    void respondToRequest_accept_transitionsToConfirmedAndSetsRespondedAt() {
        Context ctx = buildContext("svc-resp-1");
        ArtistBookingEntity booking = persistBookingDirectly(ctx, BookingStatus.PENDING_CONFIRMATION);
        JwtPrincipalInfo principal = new JwtPrincipalInfo(ctx.artist.getFirebaseUid(), ctx.artist.getEmail(), "");

        ArtistBookingDto dto = artistBookingService.respondToRequest(booking.getId(), true, principal);

        assertAll(
                () -> assertEquals(BookingStatus.CONFIRMED, dto.status()),
                () -> assertNotNull(dto.respondedAt())
        );
    }

    @Test
    @Transactional
    @DisplayName("respondToRequest — refus : PENDING_CONFIRMATION → REFUSED, respondedAt renseigné")
    void respondToRequest_refuse_transitionsToRefusedAndSetsRespondedAt() {
        Context ctx = buildContext("svc-resp-2");
        ArtistBookingEntity booking = persistBookingDirectly(ctx, BookingStatus.PENDING_CONFIRMATION);
        JwtPrincipalInfo principal = new JwtPrincipalInfo(ctx.artist.getFirebaseUid(), ctx.artist.getEmail(), "");

        ArtistBookingDto dto = artistBookingService.respondToRequest(booking.getId(), false, principal);

        assertAll(
                () -> assertEquals(BookingStatus.REFUSED, dto.status()),
                () -> assertNotNull(dto.respondedAt())
        );
    }

    // ==================================================================
    // respondToRequest — transitions invalides
    // ==================================================================

    @Test
    @Transactional
    @DisplayName("respondToRequest — échoue si le statut est SELECTED (pas PENDING_CONFIRMATION)")
    void respondToRequest_whenBookingIsSelected_throwsInvalidBookingTransitionException() {
        Context ctx = buildContext("svc-resp-3");
        ArtistBookingEntity booking = persistBookingDirectly(ctx, BookingStatus.SELECTED);
        JwtPrincipalInfo principal = new JwtPrincipalInfo(ctx.artist.getFirebaseUid(), ctx.artist.getEmail(), "");

        assertThrows(InvalidBookingTransitionException.class,
                () -> artistBookingService.respondToRequest(booking.getId(), true, principal));
    }

    @Test
    @Transactional
    @DisplayName("respondToRequest — échoue si le statut est CONFIRMED")
    void respondToRequest_whenBookingIsConfirmed_throwsInvalidBookingTransitionException() {
        Context ctx = buildContext("svc-resp-4");
        ArtistBookingEntity booking = persistBookingDirectly(ctx, BookingStatus.CONFIRMED);
        JwtPrincipalInfo principal = new JwtPrincipalInfo(ctx.artist.getFirebaseUid(), ctx.artist.getEmail(), "");

        assertThrows(InvalidBookingTransitionException.class,
                () -> artistBookingService.respondToRequest(booking.getId(), false, principal));
    }

    @Test
    @Transactional
    @DisplayName("respondToRequest — échoue si la date est CANCELLED")
    void respondToRequest_whenShowDateCancelled_throwsShowDateNotModifiableException() {
        Context ctx = buildContext("svc-resp-sdcanc");
        ArtistBookingEntity booking = persistBookingDirectly(ctx, BookingStatus.PENDING_CONFIRMATION);
        ctx.showDate.setStatus(ShowDateStatus.CANCELLED);
        showDateRepository.flush();
        JwtPrincipalInfo principal = new JwtPrincipalInfo(ctx.artist.getFirebaseUid(), ctx.artist.getEmail(), "");

        assertThrows(ShowDateNotModifiableException.class,
                () -> artistBookingService.respondToRequest(booking.getId(), true, principal));
    }

    @Test
    @Transactional
    @DisplayName("respondToRequest — échoue si la date est LOCKED")
    void respondToRequest_whenShowDateLocked_throwsShowDateNotModifiableException() {
        Context ctx = buildContext("svc-resp-sdlock");
        ArtistBookingEntity booking = persistBookingDirectly(ctx, BookingStatus.PENDING_CONFIRMATION);
        ctx.showDate.setStatus(ShowDateStatus.LOCKED);
        showDateRepository.flush();
        JwtPrincipalInfo principal = new JwtPrincipalInfo(ctx.artist.getFirebaseUid(), ctx.artist.getEmail(), "");

        assertThrows(ShowDateNotModifiableException.class,
                () -> artistBookingService.respondToRequest(booking.getId(), true, principal));
    }

    @Test
    @Transactional
    @DisplayName("respondToRequest — échoue si le demandeur n'est pas le propriétaire du booking")
    void respondToRequest_whenCallerIsNotOwner_throwsInvalidBookingTransitionException() {
        Context ctx = buildContext("svc-resp-5");
        ArtistBookingEntity booking = persistBookingDirectly(ctx, BookingStatus.PENDING_CONFIRMATION);

        // Autre artiste qui tente de répondre à un booking qui ne lui appartient pas
        VioletteUserEntity otherArtist = buildAndPersistUser("svc-resp-5-other", "svc-resp-5-other@test.com", Set.of(UserRole.ARTIST));
        JwtPrincipalInfo wrongPrincipal = new JwtPrincipalInfo(otherArtist.getFirebaseUid(), otherArtist.getEmail(), "");

        assertThrows(InvalidBookingTransitionException.class,
                () -> artistBookingService.respondToRequest(booking.getId(), true, wrongPrincipal));
    }

    // ==================================================================
    // getPendingBookingsForCurrentArtist
    // ==================================================================

    @Test
    @Transactional
    @DisplayName("getPendingBookingsForCurrentArtist — retourne uniquement les bookings PENDING_CONFIRMATION de l'artiste")
    void getPendingBookingsForCurrentArtist_returnsOnlyPendingConfirmationForArtist() {
        Context ctx = buildContext("svc-pending-1");

        // Bookings dans différents statuts pour le même artiste
        persistBookingDirectly(ctx, BookingStatus.PENDING_CONFIRMATION);

        ShowDateEntity date2 = buildAndPersistShowDate(ctx.company, LocalDate.of(2026, 6, 2));
        ArtistBookingEntity confirmed = new ArtistBookingEntity();
        confirmed.setShowDate(date2);
        confirmed.setArtist(ctx.artist);
        confirmed.setStatus(BookingStatus.CONFIRMED);
        bookingRepository.persistAndFlush(confirmed);

        JwtPrincipalInfo principal = new JwtPrincipalInfo(ctx.artist.getFirebaseUid(), ctx.artist.getEmail(), "");

        List<ArtistBookingDto> pending = artistBookingService.getPendingBookingsForCurrentArtist(principal);

        assertEquals(1, pending.size());
        assertEquals(BookingStatus.PENDING_CONFIRMATION, pending.get(0).status());
        assertEquals(ctx.artist.getId(), pending.get(0).artistId());
    }

    @Test
    @Transactional
    @DisplayName("getPendingBookingsForCurrentArtist — ne retourne pas les bookings des autres artistes")
    void getPendingBookingsForCurrentArtist_doesNotReturnOtherArtistsBookings() {
        Context ctx = buildContext("svc-pending-2");

        // Booking PENDING pour un autre artiste sur la même date
        VioletteUserEntity otherArtist = buildAndPersistUser("svc-pend-2-other", "svc-pend-2-other@test.com", Set.of(UserRole.ARTIST));
        ArtistBookingEntity otherBooking = new ArtistBookingEntity();
        otherBooking.setShowDate(ctx.showDate);
        otherBooking.setArtist(otherArtist);
        otherBooking.setStatus(BookingStatus.PENDING_CONFIRMATION);
        bookingRepository.persistAndFlush(otherBooking);

        JwtPrincipalInfo principal = new JwtPrincipalInfo(ctx.artist.getFirebaseUid(), ctx.artist.getEmail(), "");

        List<ArtistBookingDto> pending = artistBookingService.getPendingBookingsForCurrentArtist(principal);

        // ctx.artist n'a aucun booking PENDING — seul otherArtist en a un
        assertTrue(pending.isEmpty());
    }

    // ==================================================================
    // getBookingsForShowDate
    // ==================================================================

    @Test
    @Transactional
    @DisplayName("getBookingsForShowDate — retourne tous les bookings de la date")
    void getBookingsForShowDate_returnsAllBookingsForDate() {
        Context ctx = buildContext("svc-getall-1");
        VioletteUserEntity artist2 = buildAndPersistUser("svc-getall-1b", "svc-getall-1b@test.com", Set.of(UserRole.ARTIST));

        ArtistBookingEntity b1 = new ArtistBookingEntity();
        b1.setShowDate(ctx.showDate);
        b1.setArtist(ctx.artist);
        b1.setStatus(BookingStatus.SELECTED);
        bookingRepository.persist(b1);

        ArtistBookingEntity b2 = new ArtistBookingEntity();
        b2.setShowDate(ctx.showDate);
        b2.setArtist(artist2);
        b2.setStatus(BookingStatus.CONFIRMED);
        bookingRepository.persistAndFlush(b2);

        List<ArtistBookingDto> bookings = artistBookingService.getBookingsForShowDate(ctx.showDate.getId());

        assertEquals(2, bookings.size());
    }

    // ==================================================================
    // Helpers
    // ==================================================================

    /**
     * Contexte de test minimal : manager + artiste + compagnie + showDate (CONFIRMED) +
     * skillRequirement (DANCE, requiredCount=1) + availability (AVAILABLE).
     *
     * <p>La date est créée en statut {@code CONFIRMED} — statut requis par le workflow V1
     * pour la sélection et l'envoi de confirmations. Les tests qui vérifient les blocages
     * sur d'autres statuts (PENDING, OPTIONAL, LOCKED, CANCELLED) modifient ce statut
     * explicitement après construction du contexte.
     */
    private Context buildContext(String seed) {
        VioletteUserEntity manager = buildAndPersistUser("mgr-" + seed, "mgr-" + seed + "@test.com", Set.of(UserRole.MANAGER));
        VioletteUserEntity artist = buildAndPersistUser("art-" + seed, "art-" + seed + "@test.com", Set.of(UserRole.ARTIST));
        CabaretCompanyEntity company = buildAndPersistCompany("Cie-" + seed, manager);
        ShowDateEntity showDate = buildAndPersistShowDate(company, LocalDate.of(2026, 6, 1).plusDays(seed.hashCode() % 300));
        showDate.setStatus(ShowDateStatus.CONFIRMED);
        showDateRepository.flush();
        ShowDateSkillRequirementEntity skillReq = buildAndPersistSkillRequirement(showDate, ArtistSkill.DANCE, 1, "120.00");
        ArtistAvailabilityEntity availability = persistAvailability(showDate, artist, AvailabilityStatus.AVAILABLE);
        return new Context(manager, artist, company, showDate, skillReq, availability);
    }

    /**
     * Persiste directement un booking sans passer par le service (contournement des règles).
     * Utilisé pour tester des transitions à partir de statuts spécifiques.
     */
    private ArtistBookingEntity persistBookingDirectly(Context ctx, BookingStatus status) {
        ArtistBookingEntity booking = new ArtistBookingEntity();
        booking.setShowDate(ctx.showDate);
        booking.setArtist(ctx.artist);
        booking.setStatus(status);
        bookingRepository.persistAndFlush(booking);
        return booking;
    }

    private VioletteUserEntity buildAndPersistUser(String firebaseUid, String email, Set<UserRole> roles) {
        VioletteUserEntity user = new VioletteUserEntity();
        user.setFirebaseUid(firebaseUid);
        user.setEmail(email);
        user.setFirstName("User");
        user.setLastName("Test");
        user.setRoles(roles);
        user.setSkills(Set.of());
        violetteUserRepository.persistAndFlush(user);
        return user;
    }

    private CabaretCompanyEntity buildAndPersistCompany(String name, VioletteUserEntity manager) {
        CabaretCompanyEntity company = new CabaretCompanyEntity();
        company.setName(name);
        company.setManager(manager);
        cabaretCompanyRepository.persistAndFlush(company);
        return company;
    }

    private ShowDateEntity buildAndPersistShowDate(CabaretCompanyEntity company, LocalDate eventDate) {
        ShowDateEntity sd = new ShowDateEntity();
        sd.setCompany(company);
        sd.setEventDate(eventDate);
        sd.setMeetingTime(LocalTime.of(10, 0));
        sd.setLocation("12 rue du Spectacle, 75001 Paris");
        sd.setClientContactName("Client Test");
        sd.setClientContactPhone("0600000000");
        showDateRepository.persistAndFlush(sd);
        return sd;
    }

    private ShowDateSkillRequirementEntity buildAndPersistSkillRequirement(
            ShowDateEntity showDate, ArtistSkill skill, int count, String fee) {
        ShowDateSkillRequirementEntity req = new ShowDateSkillRequirementEntity();
        req.setShowDate(showDate);
        req.setSkill(skill);
        req.setRequiredCount(count);
        req.setNetFee(new BigDecimal(fee));
        skillRequirementRepository.persistAndFlush(req);
        return req;
    }

    private ArtistAvailabilityEntity persistAvailability(
            ShowDateEntity showDate, VioletteUserEntity artist, AvailabilityStatus status) {
        ArtistAvailabilityId key = new ArtistAvailabilityId(showDate.getId(), artist.getId());
        ArtistAvailabilityEntity av = new ArtistAvailabilityEntity();
        av.setId(key);
        av.setShowDate(showDate);
        av.setArtist(artist);
        av.setStatus(status);
        availabilityRepository.persistAndFlush(av);
        return av;
    }

    /**
     * Contexte de test regroupant les entités dépendantes d'un scénario.
     */
    private record Context(
            VioletteUserEntity manager,
            VioletteUserEntity artist,
            CabaretCompanyEntity company,
            ShowDateEntity showDate,
            ShowDateSkillRequirementEntity skillReq,
            ArtistAvailabilityEntity availability
    ) {}
}
