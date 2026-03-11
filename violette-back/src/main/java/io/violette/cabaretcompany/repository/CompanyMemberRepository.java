package io.violette.cabaretcompany.repository;

import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import io.violette.cabaretcompany.model.CompanyMemberEntity;
import io.violette.cabaretcompany.model.CompanyMemberId;
import jakarta.enterprise.context.ApplicationScoped;

import java.util.List;

/**
 * Repository Panache pour CompanyMemberEntity.
 * Utilise PanacheRepositoryBase avec la clé composite CompanyMemberId.
 * Seule couche d'accès BDD pour les appartenances artiste ↔ compagnie.
 */
@ApplicationScoped
public class CompanyMemberRepository implements PanacheRepositoryBase<CompanyMemberEntity, CompanyMemberId> {

    /**
     * Retourne tous les membres d'une compagnie donnée.
     */
    public List<CompanyMemberEntity> findByCompanyId(Long companyId) {
        return find("id.companyId", companyId).list();
    }

    /**
     * Retourne toutes les compagnies auxquelles appartient un artiste donné.
     */
    public List<CompanyMemberEntity> findByArtistId(Long artistId) {
        return find("id.artistId", artistId).list();
    }
}
