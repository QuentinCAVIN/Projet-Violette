package io.violette.showdate.service;

import io.violette.artistbooking.repository.ArtistBookingRepository;
import io.violette.cabaretcompany.repository.CompanyMemberRepository;
import io.violette.cabaretcompany.exception.CabaretCompanyNotFoundException;
import io.violette.cabaretcompany.exception.CabaretShowNotFoundException;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.model.CabaretShowEntity;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.cabaretcompany.repository.CabaretShowRepository;
import io.violette.showdate.dto.CreateShowDateRequestDto;
import io.violette.showdate.dto.CreateSkillRequirementRequestDto;
import io.violette.showdate.dto.ShowDateDto;
import io.violette.showdate.dto.ShowDateSkillRequirementDto;
import io.violette.showdate.dto.UpdateShowDateRequestDto;
import io.violette.showdate.exception.ShowDateNotFoundException;
import io.violette.showdate.mapper.ShowDateMapper;
import io.violette.showdate.mapper.ShowDateSkillRequirementMapper;
import io.violette.showdate.model.ShowDateEntity;
import io.violette.showdate.model.ShowDateSkillRequirementEntity;
import io.violette.showdate.model.ShowDateStatus;
import io.violette.showdate.repository.ShowDateRepository;
import io.violette.showdate.repository.ShowDateSkillRequirementRepository;
import io.violette.security.JwtPrincipalInfo;
import io.violette.violetteuser.exception.UserNotFoundException;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.BadRequestException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;

/**
 * Service du domaine showdate.
 * Orchestre la création et la lecture des dates de spectacle et de leurs besoins artistiques.
 */
@ApplicationScoped
public class ShowDateService {

    private static final Logger LOG = LoggerFactory.getLogger(ShowDateService.class);

    private static final DateTimeFormatter DISPLAY_TITLE_DATE_FORMAT =
            DateTimeFormatter.ofPattern("d MMMM yyyy", Locale.FRENCH);
    private static final List<ShowDateStatus> ARTIST_VISIBLE_STATUSES = Arrays.asList(
            ShowDateStatus.OPTION,
            ShowDateStatus.CONFIRMED,
            ShowDateStatus.STAFFED
    );
    private static final List<ShowDateStatus> V040_ALLOWED_MANAGER_STATUS_TARGETS = Arrays.asList(
            ShowDateStatus.OPTION,
            ShowDateStatus.CONFIRMED,
            ShowDateStatus.STAFFED
    );

    @Inject
    ShowDateRepository showDateRepository;

    @Inject
    ShowDateSkillRequirementRepository skillRequirementRepository;

    @Inject
    ArtistBookingRepository artistBookingRepository;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    CabaretShowRepository cabaretShowRepository;

    @Inject
    ShowDateMapper showDateMapper;

    @Inject
    ShowDateSkillRequirementMapper skillRequirementMapper;

    @Inject
    CompanyMemberRepository companyMemberRepository;

    @Inject
    io.violette.violetteuser.repository.VioletteUserRepository violetteUserRepository;

    /**
     * Crée une nouvelle date de spectacle.
     *
     * @throws CabaretCompanyNotFoundException si la compagnie n'existe pas
     * @throws CabaretShowNotFoundException    si la revue est fournie mais introuvable
     */
    @Transactional
    public ShowDateDto createShowDate(CreateShowDateRequestDto request) {
        LOG.info("Création d'une date de spectacle pour companyId={}", request.companyId());

        CabaretCompanyEntity company = cabaretCompanyRepository
                .findByIdOptional(request.companyId())
                .orElseThrow(CabaretCompanyNotFoundException::new);

        CabaretShowEntity cabaretShow = null;
        if (request.cabaretShowId() != null) {
            cabaretShow = cabaretShowRepository
                    .findByIdOptional(request.cabaretShowId())
                    .orElseThrow(CabaretShowNotFoundException::new);
        }

        ShowDateEntity entity = new ShowDateEntity();
        entity.setCompany(company);
        entity.setCabaretShow(cabaretShow);
        entity.setEventDate(request.eventDate());
        entity.setMeetingTime(request.meetingTime());
        entity.setLocation(request.location());
        entity.setClientContactName(request.clientContactName());
        entity.setClientContactPhone(request.clientContactPhone());
        entity.setShowDetails(request.showDetails());
        entity.setStatus(ShowDateStatus.INQUIRY);

        showDateRepository.persistAndFlush(entity);

        LOG.info("Date de spectacle créée id={} pour companyId={}", entity.getId(), request.companyId());
        return mapToDto(entity);
    }

    /**
     * Récupère une date de spectacle par son id.
     *
     * @throws ShowDateNotFoundException si la date n'existe pas
     */
    public ShowDateDto getById(Long id) {
        LOG.debug("Récupération de la date de spectacle id={}", id);
        return showDateRepository.findByIdOptional(id)
                .map(this::mapToDto)
                .orElseThrow(ShowDateNotFoundException::new);
    }

    /**
     * Retourne toutes les dates de spectacle, triées par date croissante.
     */
    public List<ShowDateDto> getAll() {
        LOG.debug("Récupération de toutes les dates de spectacle");
        return showDateRepository.findAllOrderByEventDateAsc().stream()
                .map(this::mapToDto)
                .toList();
    }

    /**
     * Règle temporaire v0.4.0 :
     * liste les dates visibles pour l'artiste courant en limitant les statuts exposés
     * (OPTION, CONFIRMED, STAFFED) et aux compagnies dont il est membre.
     */
    public List<ShowDateDto> getVisibleForArtist(JwtPrincipalInfo principal) {
        var artist = violetteUserRepository.findByFirebaseUid(principal.firebaseUid())
                .orElseThrow(UserNotFoundException::new);
        var companyIds = companyMemberRepository.findByArtistId(artist.getId()).stream()
                .map(membership -> membership.getId().getCompanyId())
                .distinct()
                .toList();

        if (companyIds.isEmpty()) {
            return List.of();
        }

        return showDateRepository.findByCompanyIdsAndStatuses(companyIds, ARTIST_VISIBLE_STATUSES).stream()
                .map(this::mapToDto)
                .toList();
    }

    /**
     * Retourne toutes les dates de spectacle d'une compagnie.
     *
     * @throws CabaretCompanyNotFoundException si la compagnie n'existe pas
     */
    public List<ShowDateDto> getByCompanyId(Long companyId) {
        LOG.debug("Récupération des dates de spectacle pour companyId={}", companyId);
        cabaretCompanyRepository.findByIdOptional(companyId)
                .orElseThrow(CabaretCompanyNotFoundException::new);
        return showDateRepository.findByCompanyId(companyId).stream()
                .map(this::mapToDto)
                .toList();
    }

    /**
     * Supprime une date de spectacle.
     *
     * <p>Les entités liées ({@code artist_availability}, {@code artist_booking},
     * {@code show_date_skill_requirement}) sont supprimées automatiquement
     * par les contraintes SQL ON DELETE CASCADE.
     *
     * @throws ShowDateNotFoundException si la date n'existe pas
     */
    @Transactional
    public void deleteShowDate(Long id) {
        LOG.info("Suppression de la date de spectacle id={}", id);
        ShowDateEntity entity = showDateRepository.findByIdOptional(id)
                .orElseThrow(ShowDateNotFoundException::new);
        showDateRepository.delete(entity);
    }

    /**
     * Met à jour partiellement une date de spectacle.
     * Les champs {@code null} dans le DTO sont ignorés (pas de modification).
     *
     * @throws ShowDateNotFoundException si la date n'existe pas
     */
    @Transactional
    public ShowDateDto updateShowDate(Long id, UpdateShowDateRequestDto request) {
        LOG.info("Mise à jour partielle de la date de spectacle id={}", id);
        ShowDateEntity entity = showDateRepository.findByIdOptional(id)
                .orElseThrow(ShowDateNotFoundException::new);

        if (request.eventDate() != null) {
            entity.setEventDate(request.eventDate());
        }
        if (request.meetingTime() != null) {
            entity.setMeetingTime(request.meetingTime());
        }
        if (request.location() != null) {
            entity.setLocation(request.location());
        }
        if (request.clientContactName() != null) {
            entity.setClientContactName(request.clientContactName());
        }
        if (request.clientContactPhone() != null) {
            entity.setClientContactPhone(request.clientContactPhone());
        }
        if (request.showDetails() != null) {
            entity.setShowDetails(request.showDetails());
        }
        if (request.status() != null) {
            applyV040StatusTransition(entity, request.status());
        }

        showDateRepository.flush();
        return mapToDto(entity);
    }

    /**
     * Règle transitoire v0.4.0 :
     * autorise uniquement les transitions nécessaires au test E2E.
     */
    private void applyV040StatusTransition(ShowDateEntity entity, ShowDateStatus targetStatus) {
        ShowDateStatus currentStatus = entity.getStatus();
        boolean isAllowed =
                (currentStatus == ShowDateStatus.INQUIRY && targetStatus == ShowDateStatus.OPTION)
                        || (currentStatus == ShowDateStatus.OPTION && targetStatus == ShowDateStatus.CONFIRMED)
                        || (currentStatus == ShowDateStatus.CONFIRMED && targetStatus == ShowDateStatus.STAFFED);

        if (!isAllowed || !V040_ALLOWED_MANAGER_STATUS_TARGETS.contains(targetStatus)) {
            throw new BadRequestException(
                    "Transition de statut non autorisée en v0.4.0 : " + currentStatus + " -> " + targetStatus
            );
        }
        entity.setStatus(targetStatus);
    }

    /**
     * Construit le DTO avec titre affiché et agrégats calculés (non persistés).
     */
    private ShowDateDto mapToDto(ShowDateEntity entity) {
        Long id = entity.getId();
        String displayTitle = computeDisplayTitle(entity);
        int totalRequiredArtists = skillRequirementRepository.sumRequiredCountByShowDateId(id);
        int selectedCount = (int) artistBookingRepository.countActiveBookingsByShowDateId(id);
        return showDateMapper.toDto(entity, displayTitle, totalRequiredArtists, selectedCount);
    }

    /**
     * Titre affiché : revue (si liée et titre non vide) + lieu + date, en français.
     */
    private String computeDisplayTitle(ShowDateEntity entity) {
        String datePart = DISPLAY_TITLE_DATE_FORMAT.format(entity.getEventDate());
        String location = entity.getLocation();
        CabaretShowEntity show = entity.getCabaretShow();
        if (show != null) {
            String title = show.getTitle();
            if (title != null && !title.isBlank()) {
                return title + " — " + location + " — " + datePart;
            }
        }
        return location + " — " + datePart;
    }

    /**
     * Ajoute un besoin artistique par compétence à une date de spectacle.
     *
     * @throws ShowDateNotFoundException si la date n'existe pas
     */
    @Transactional
    public ShowDateSkillRequirementDto addSkillRequirement(Long showDateId, CreateSkillRequirementRequestDto request) {
        LOG.info("Ajout d'un besoin {} pour showDateId={}", request.skill(), showDateId);

        ShowDateEntity showDate = showDateRepository.findByIdOptional(showDateId)
                .orElseThrow(ShowDateNotFoundException::new);

        ShowDateSkillRequirementEntity entity = new ShowDateSkillRequirementEntity();
        entity.setShowDate(showDate);
        entity.setSkill(request.skill());
        entity.setRequiredCount(request.requiredCount());
        entity.setNetFee(request.netFee());

        skillRequirementRepository.persist(entity);

        LOG.info("Besoin {} ajouté (id={}) pour showDateId={}", request.skill(), entity.getId(), showDateId);
        return skillRequirementMapper.toDto(entity);
    }

    /**
     * Retourne tous les besoins artistiques d'une date de spectacle.
     *
     * @throws ShowDateNotFoundException si la date n'existe pas
     */
    public List<ShowDateSkillRequirementDto> getSkillRequirements(Long showDateId) {
        LOG.debug("Récupération des besoins artistiques pour showDateId={}", showDateId);
        showDateRepository.findByIdOptional(showDateId)
                .orElseThrow(ShowDateNotFoundException::new);
        return skillRequirementRepository.findByShowDateId(showDateId).stream()
                .map(skillRequirementMapper::toDto)
                .toList();
    }
}
