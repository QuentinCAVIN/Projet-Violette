package io.violette.artistbooking.model;

import io.violette.showdate.model.ShowDateEntity;
import io.violette.showdate.model.ShowDateSkillRequirementEntity;
import io.violette.violetteuser.model.VioletteUserEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Embedded;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.Instant;

/**
 * Aggregate root du domaine artistbooking.
 *
 * <p>Représente un artiste présélectionné ou réservé pour une date de spectacle.
 * Le statut {@link BookingStatus} précise le niveau d'engagement :
 * <ul>
 *   <li>{@code SELECTED} sur date {@code OPTION} → présélection, pas d'engagement ferme.</li>
 *   <li>{@code SELECTED} sur date {@code CONFIRMED} → sélection ferme avant envoi de la demande.</li>
 *   <li>{@code PENDING_CONFIRMATION} → demande ferme envoyée, en attente de réponse artiste.</li>
 *   <li>{@code CONFIRMED} → artiste engagé, présence sur la date acquise.</li>
 * </ul>
 *
 * <p>Source de vérité des artistes retenus ou réservés pour une {@link ShowDateEntity}.
 * Aligne la responsabilité qui appartenait à {@code selectedCount} / {@code artistBookings}
 * dans le modèle Firestore frontend.
 *
 * <p>Alignée sur la table SQL {@code artist_booking} (Flyway V5).
 *
 * <p><b>Contrainte :</b> un artiste ne peut être présélectionné/réservé qu'une seule fois par date
 * ({@code UNIQUE(show_date_id, artist_id)}).
 */
@Entity
@Table(
        name = "artist_booking",
        uniqueConstraints = @UniqueConstraint(
                name = "uk_booking_artist_date",
                columnNames = {"show_date_id", "artist_id"}
        )
)
public class ArtistBookingEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Date de spectacle concernée (FK show_date_id → show_date).
     * Suppression en cascade : si la date est supprimée, les bookings le sont aussi.
     */
    @NotNull
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "show_date_id",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_booking_show_date")
    )
    private ShowDateEntity showDate;

    /**
     * Artiste présélectionné ou réservé (FK artist_id → violette_user).
     * Le niveau d'engagement réel est déterminé par {@link #status}.
     */
    @NotNull
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "artist_id",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_booking_artist")
    )
    private VioletteUserEntity artist;

    /**
     * Besoin artistique couvert par ce booking (FK skill_requirement_id → show_date_skill_requirement).
     * Nullable : le lien vers un besoin spécifique est fortement recommandé mais non obligatoire
     * pour permettre une migration douce. Mis à NULL si le besoin est supprimé (ON DELETE SET NULL).
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "skill_requirement_id",
            foreignKey = @ForeignKey(name = "fk_booking_skill_requirement")
    )
    private ShowDateSkillRequirementEntity skillRequirement;

    /**
     * Statut courant du cycle de réservation.
     * Voir {@link BookingStatus} pour le workflow complet et les transitions autorisées.
     */
    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private BookingStatus status = BookingStatus.SELECTED;

    /**
     * Cachet net capturé au moment de la présélection/sélection (en euros).
     * Copié depuis {@link ShowDateSkillRequirementEntity#getNetFee()} lors de la création.
     * Conservé pour garantir la traçabilité même si le barème est modifié ultérieurement.
     *
     * <p><b>Sémantique selon la phase :</b>
     * <ul>
     *   <li>Date {@code OPTION} → <b>estimation de planification</b> : pas d'engagement contractuel ;
     *       la présélection est non bloquante.</li>
     *   <li>Date {@code CONFIRMED} → <b>montant de référence</b> : le cachet sera engagé lors
     *       de l'envoi de la demande ferme ({@code sendConfirmationRequests}).</li>
     * </ul>
     * Null si aucun besoin artistique n'est associé.
     */
    @Column(name = "agreed_net_fee", precision = 10, scale = 2)
    private BigDecimal agreedNetFee;

    /**
     * Horodatages du cycle de vie du booking.
     * Voir {@link BookingTimeline} pour le détail de chaque champ.
     */
    @Embedded
    private BookingTimeline timeline = new BookingTimeline();

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public ShowDateEntity getShowDate() {
        return showDate;
    }

    public void setShowDate(ShowDateEntity showDate) {
        this.showDate = showDate;
    }

    public VioletteUserEntity getArtist() {
        return artist;
    }

    public void setArtist(VioletteUserEntity artist) {
        this.artist = artist;
    }

    public ShowDateSkillRequirementEntity getSkillRequirement() {
        return skillRequirement;
    }

    public void setSkillRequirement(ShowDateSkillRequirementEntity skillRequirement) {
        this.skillRequirement = skillRequirement;
    }

    public BookingStatus getStatus() {
        return status;
    }

    public void setStatus(BookingStatus status) {
        this.status = status;
    }

    public BigDecimal getAgreedNetFee() {
        return agreedNetFee;
    }

    public void setAgreedNetFee(BigDecimal agreedNetFee) {
        this.agreedNetFee = agreedNetFee;
    }

    public BookingTimeline getTimeline() {
        return timeline;
    }

    public void setTimeline(BookingTimeline timeline) {
        this.timeline = timeline;
    }

    @PrePersist
    void onPersist() {
        Instant now = Instant.now();
        timeline.setCreatedAt(now);
        timeline.setUpdatedAt(now);
    }

    @PreUpdate
    void onUpdate() {
        timeline.setUpdatedAt(Instant.now());
    }
}
