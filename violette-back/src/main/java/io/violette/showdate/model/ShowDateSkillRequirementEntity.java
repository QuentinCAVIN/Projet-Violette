package io.violette.showdate.model;

import io.violette.violetteuser.model.ArtistSkill;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

/**
 * Modélise un besoin artistique par compétence pour une date de spectacle.
 * Exemple : 2 danseurs à 120 € net, 1 chanteur à 150 € net.
 *
 * <p>Alignée sur la table SQL show_date_skill_requirement (Flyway V4).
 * Contrainte d'unicité sur (show_date_id, skill) — une seule ligne par compétence et par date.
 */
@Entity
@Table(name = "show_date_skill_requirement")
public class ShowDateSkillRequirementEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Date de spectacle concernée (FK show_date_id → show_date).
     */
    @NotNull
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "show_date_id", nullable = false)
    private ShowDateEntity showDate;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ArtistSkill skill;

    /** Nombre d'artistes nécessaires pour cette compétence (≥ 1). */
    @Min(1)
    @Column(name = "required_count", nullable = false)
    private int requiredCount;

    /** Cachet net par artiste pour cette compétence (en euros, ≥ 0). */
    @NotNull
    @Column(name = "net_fee", nullable = false, precision = 10, scale = 2)
    private BigDecimal netFee;

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

    public ArtistSkill getSkill() {
        return skill;
    }

    public void setSkill(ArtistSkill skill) {
        this.skill = skill;
    }

    public int getRequiredCount() {
        return requiredCount;
    }

    public void setRequiredCount(int requiredCount) {
        this.requiredCount = requiredCount;
    }

    public BigDecimal getNetFee() {
        return netFee;
    }

    public void setNetFee(BigDecimal netFee) {
        this.netFee = netFee;
    }
}
