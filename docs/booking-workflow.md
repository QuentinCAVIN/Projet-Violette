# Workflow de réservation artistes — Violette v0.4.0

Ce document décrit le workflow de réservation côté produit. La source de vérité détaillée des statuts et règles métier est [regles-metier.md](regles-metier.md).

---

## Vue d'ensemble

```text
Demande client
  -> OPTION
  -> disponibilités artistes
  -> présélection éventuelle
  -> CONFIRMED
  -> demandes de confirmation
  -> réponses artistes
  -> STAFFED
  -> ARCHIVED
```

Le workflow distingue trois notions :

- **Disponibilité** : l'artiste indique s'il peut venir (`AVAILABLE`, `IF_NEEDED`, `UNAVAILABLE`).
- **Présélection** : le gérant prépare une équipe avec des bookings `SELECTED`, sans engagement ferme.
- **Booking ferme** : le gérant envoie une demande officielle (`PENDING_CONFIRMATION`) et l'artiste accepte ou refuse.

---

## Étapes V1

### 1. Demande client (`INQUIRY`)

La demande client est en qualification. Les informations peuvent être incomplètes : date, lieu, revue, nombre d'artistes ou cachets.

Aucune disponibilité, présélection ou réservation ne doit être créée à ce stade.

### 2. Option posée (`OPTION`)

Le devis est envoyé ou l'option est posée. Le gérant peut commencer à préparer la date.

Actions possibles :

- collecter les disponibilités artistes ;
- présélectionner des artistes en statut `SELECTED` ;
- ajuster les besoins artistiques par compétence.

Il n'y a pas encore d'engagement ferme : l'artiste n'est pas officiellement sollicité.

### 3. Client confirmé (`CONFIRMED`)

Le client valide la prestation. Le gérant peut transformer la sélection en demande ferme.

Actions possibles :

- sélectionner ou retirer des artistes tant que les règles de capacité sont respectées ;
- envoyer les demandes de confirmation ;
- passer les bookings `SELECTED` en `PENDING_CONFIRMATION`.

### 4. Réponse artiste

L'artiste répond à sa demande :

- acceptation : `PENDING_CONFIRMATION` -> `CONFIRMED` ;
- refus : `PENDING_CONFIRMATION` -> `REFUSED`.

Un refus libère la capacité pour un autre artiste.

### 5. Équipe complète (`STAFFED`)

Quand l'équipe nécessaire est complète et sécurisée, la date peut passer en `STAFFED`.

À ce stade, les modifications de composition d'équipe doivent être bloquées ou très encadrées.

### 6. Annulation ou archivage

- `CANCELLED` indique qu'une date est abandonnée ou annulée.
- `ARCHIVED` indique qu'une date passée est conservée dans l'historique.

Les bookings actifs peuvent être annulés quand la date est annulée.

---

## Transitions métier de référence

### `ShowDateStatus`

```text
INQUIRY -> OPTION -> CONFIRMED -> STAFFED -> ARCHIVED
    |         |          |
    v         v          v
CANCELLED CANCELLED  CANCELLED
```

### `AvailabilityStatus`

```text
PENDING -> AVAILABLE | IF_NEEDED | UNAVAILABLE
AVAILABLE <-> IF_NEEDED <-> UNAVAILABLE
```

### `BookingStatus`

```text
SELECTED -> PENDING_CONFIRMATION -> CONFIRMED
                         |
                         v
                      REFUSED
```

Voir [regles-metier.md](regles-metier.md) pour les tableaux détaillés et les conditions d'autorisation.

---

## Vision V2 — workflows configurables

Certaines compagnies pourront fonctionner différemment :

| Variante | Description |
|---|---|
| Appel direct | Le gérant contacte des artistes ciblés sans phase de disponibilité préalable. |
| Remplacement progressif | L'effectif est constitué au fil des refus. |
| Pré-confirmation manuelle | Le gérant valide manuellement une réponse artiste avant engagement définitif. |
| Disponibilités optionnelles | La sélection peut être autorisée même sans déclaration préalable. |

Ces variantes ne sont pas implémentées dans le workflow V1. Elles devront être modélisées explicitement avant d'être ajoutées au backend.
