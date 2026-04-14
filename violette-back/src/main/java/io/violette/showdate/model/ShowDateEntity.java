package io.violette.showdate.model;

import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.model.CabaretShowEntity;
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
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;

/**
 * Aggregate root du domaine showdate.
 * Représente une date de spectacle (feuille de route) organisée par une compagnie.
 * Alignée sur la table SQL show_date (Flyway V4).
 *
 * <p>Note : "show" est un mot réservé MySQL, mais "show_date" (composé) est accepté
 * car Hibernate quote automatiquement les identifiants avec le dialecte MySQL.
 */
@Entity
@Table(name = "show_date")
public class ShowDateEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Compagnie organisatrice (FK company_id → cabaret_company).
     */
    @NotNull
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "company_id", nullable = false)
    private CabaretCompanyEntity company;

    /**
     * Revue jouée lors de cette date (nullable — peut être définie après création).
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "revue_id")
    private CabaretShowEntity cabaretShow;

    @NotNull
    @Column(name = "event_date", nullable = false)
    private LocalDate eventDate;

    @NotNull
    @Column(name = "meeting_time", nullable = false)
    private LocalTime meetingTime;

    /**
     * Champ libre de localisation (nom de lieu, département, adresse précise, etc.).
     */
    @NotBlank
    @Size(max = 500)
    @Column(nullable = false, length = 500)
    private String location;

    @NotBlank
    @Size(max = 255)
    @Column(name = "client_contact_name", nullable = false, length = 255)
    private String clientContactName;

    @NotBlank
    @Size(max = 50)
    @Column(name = "client_contact_phone", nullable = false, length = 50)
    private String clientContactPhone;

    @Column(name = "show_details", columnDefinition = "TEXT")
    private String showDetails;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ShowDateStatus status = ShowDateStatus.PENDING;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public CabaretCompanyEntity getCompany() {
        return company;
    }

    public void setCompany(CabaretCompanyEntity company) {
        this.company = company;
    }

    public CabaretShowEntity getCabaretShow() {
        return cabaretShow;
    }

    public void setCabaretShow(CabaretShowEntity cabaretShow) {
        this.cabaretShow = cabaretShow;
    }

    public LocalDate getEventDate() {
        return eventDate;
    }

    public void setEventDate(LocalDate eventDate) {
        this.eventDate = eventDate;
    }

    public LocalTime getMeetingTime() {
        return meetingTime;
    }

    public void setMeetingTime(LocalTime meetingTime) {
        this.meetingTime = meetingTime;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getClientContactName() {
        return clientContactName;
    }

    public void setClientContactName(String clientContactName) {
        this.clientContactName = clientContactName;
    }

    public String getClientContactPhone() {
        return clientContactPhone;
    }

    public void setClientContactPhone(String clientContactPhone) {
        this.clientContactPhone = clientContactPhone;
    }

    public String getShowDetails() {
        return showDetails;
    }

    public void setShowDetails(String showDetails) {
        this.showDetails = showDetails;
    }

    public ShowDateStatus getStatus() {
        return status;
    }

    public void setStatus(ShowDateStatus status) {
        this.status = status;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }

    @PrePersist
    void onPersist() {
        Instant now = Instant.now();
        this.createdAt = now;
        this.updatedAt = now;
    }

    @PreUpdate
    void onUpdate() {
        this.updatedAt = Instant.now();
    }
}
