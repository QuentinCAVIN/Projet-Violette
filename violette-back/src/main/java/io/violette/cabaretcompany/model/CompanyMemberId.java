package io.violette.cabaretcompany.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

import java.io.Serializable;
import java.util.Objects;

/**
 * Clé primaire composite de CompanyMemberEntity.
 * Représente l'unicité de la relation (company_id, artist_id).
 * Doit implémenter Serializable et redéfinir equals/hashCode (contrat JPA).
 */
@Embeddable
public class CompanyMemberId implements Serializable {

    @Column(name = "company_id")
    private Long companyId;

    @Column(name = "artist_id")
    private Long artistId;

    public CompanyMemberId() {
    }

    public CompanyMemberId(Long companyId, Long artistId) {
        this.companyId = companyId;
        this.artistId = artistId;
    }

    public Long getCompanyId() {
        return companyId;
    }

    public void setCompanyId(Long companyId) {
        this.companyId = companyId;
    }

    public Long getArtistId() {
        return artistId;
    }

    public void setArtistId(Long artistId) {
        this.artistId = artistId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof CompanyMemberId that)) return false;
        return Objects.equals(companyId, that.companyId) &&
                Objects.equals(artistId, that.artistId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(companyId, artistId);
    }
}
