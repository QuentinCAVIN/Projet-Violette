package io.violette.cabaretcompany.model;

import io.violette.violetteuser.model.VioletteUserEntity;
import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

import java.time.Instant;

/**
 * Représente l'appartenance d'un artiste à une compagnie.
 * Modélisée comme une vraie entité (pas une simple table de jointure anonyme)
 * afin de pouvoir évoluer : date d'adhésion, rôle dans la compagnie, etc.
 *
 * Clé primaire composite (company_id, artist_id) via @EmbeddedId + @MapsId,
 * alignée sur la table SQL company_member (Flyway V1).
 *
 * Un artiste peut appartenir à plusieurs compagnies.
 * Une compagnie peut avoir plusieurs artistes.
 */
@Entity
@Table(name = "company_member")
public class CompanyMemberEntity {

    @EmbeddedId
    private CompanyMemberId id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("companyId")
    @JoinColumn(name = "company_id")
    private CabaretCompanyEntity company;

    /**
     * Artiste membre de la compagnie (FK artist_id → violette_user).
     * Pas de validation de rôle à ce stade — la contrainte métier sera appliquée ultérieurement.
     */
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("artistId")
    @JoinColumn(name = "artist_id")
    private VioletteUserEntity artist;

    @Column(name = "joined_at", nullable = false, updatable = false)
    private Instant joinedAt;

    public CompanyMemberId getId() {
        return id;
    }

    public void setId(CompanyMemberId id) {
        this.id = id;
    }

    public CabaretCompanyEntity getCompany() {
        return company;
    }

    public void setCompany(CabaretCompanyEntity company) {
        this.company = company;
    }

    public VioletteUserEntity getArtist() {
        return artist;
    }

    public void setArtist(VioletteUserEntity artist) {
        this.artist = artist;
    }

    public Instant getJoinedAt() {
        return joinedAt;
    }

    public void setJoinedAt(Instant joinedAt) {
        this.joinedAt = joinedAt;
    }

    @PrePersist
    void onPersist() {
        this.joinedAt = Instant.now();
    }
}
