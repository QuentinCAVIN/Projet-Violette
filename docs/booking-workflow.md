# Workflow de réservation artistes — Violette V1

## Table des matières

1. [Rôle des domaines](#rôle-des-domaines)
2. [Statuts d'une date de spectacle](#statuts-dune-date-de-spectacle)
3. [Statuts d'un booking artiste](#statuts-dun-booking-artiste)
4. [Workflow V1 — étape par étape](#workflow-v1--étape-par-étape)
5. [Règles importantes](#règles-importantes)
6. [Transitions autorisées — récapitulatif](#transitions-autorisées--récapitulatif)
7. [Vision V2 — workflows configurables](#vision-v2--workflows-configurables)

---

## Rôle des domaines

### `showdate` — feuille de route logistique

Le domaine `showdate` gère les informations logistiques d'une date de spectacle :
lieu, heure de rendez-vous, contacts client, revue optionnelle, statut de la date.

Il porte également :
- les **besoins artistiques par compétence** (`ShowDateSkillRequirement`) : compétence requise, nombre de places, cachet net prévu
- les **disponibilités déclarées par les artistes** (`ArtistAvailability`) : statut PENDING / AVAILABLE / CONDITIONAL / UNAVAILABLE

Le domaine `showdate` **ne gère pas les artistes effectivement retenus**. Il est responsable de la préparation et du pilotage de la date, pas de la composition de l'équipe.

### `artistbooking` — réservations artistes

Le domaine `artistbooking` est la **source de vérité des artistes présents sur une date**. Il gère :
- la sélection d'un artiste par le gérant
- l'envoi de la demande de confirmation à l'artiste
- la réponse de l'artiste (acceptation / refus)
- la confirmation finale de présence

Un `ArtistBooking` représente **un artiste retenu pour une date afin de couvrir un besoin artistique spécifique** (`ShowDateSkillRequirement`). Le lien vers le besoin artistique est optionnel — un booking peut exister sans être rattaché à une compétence précise.

---

## Statuts d'une date de spectacle

```
PENDING ──→ OPTIONAL ──→ CONFIRMED ──→ LOCKED
                │               │         │
                └───────────────┴─────────┘
                                ↓
                            CANCELLED
```

| Statut      | Signification | Actions de booking autorisées |
|-------------|---------------|-------------------------------|
| `PENDING`   | Date créée, devis non encore envoyé | Aucune |
| `OPTIONAL`  | Devis envoyé, collecte des disponibilités artistes | Déclarations de disponibilité uniquement |
| `CONFIRMED` | Client a confirmé la date | Sélection, désélection, envoi de confirmations |
| `LOCKED`    | Effectif complet et confirmé | Aucune (lecture seule) |
| `CANCELLED` | Date annulée | Aucune (lecture seule) |

> **Règle V1** : la sélection d'artistes et l'envoi de confirmations ne sont autorisés
> que lorsque la date est en statut **`CONFIRMED`**.

---

## Statuts d'un booking artiste

```
SELECTED ──→ PENDING_CONFIRMATION ──→ CONFIRMED
                     │
                     └──────────────→ REFUSED

(tout statut actif) ──→ CANCELLED   (annulation de la date — V1 partiel)
```

| Statut                 | Qui déclenche | Signification |
|------------------------|---------------|---------------|
| `SELECTED`             | Gérant        | Artiste sélectionné, demande non encore envoyée |
| `PENDING_CONFIRMATION` | Gérant        | Demande de confirmation envoyée à l'artiste |
| `CONFIRMED`            | Artiste       | Artiste a accepté — présence confirmée |
| `REFUSED`              | Artiste       | Artiste a refusé |
| `CANCELLED`            | Système       | Date annulée — booking inactif (voir [Vision V2](#vision-v2--workflows-configurables)) |

**Statuts terminaux** (aucune transition possible) : `REFUSED`, `CANCELLED`

**Statuts modifiables** : `SELECTED` (peut être supprimé), `PENDING_CONFIRMATION` (en attente de réponse artiste)

---

## Workflow V1 — étape par étape

### Étape 1 — Date en option (`OPTIONAL`)

La date a été soumise au client. Le gérant collecte les disponibilités de ses artistes.

- Le gérant notifie les artistes de la date envisagée
- Chaque artiste déclare sa disponibilité : `AVAILABLE`, `CONDITIONAL`, ou `UNAVAILABLE`
- **Aucun booking n'est encore créé à ce stade**

### Étape 2 — Date confirmée (`CONFIRMED`)

Le client confirme la date. Le gérant peut désormais constituer l'équipe artistique.

- Le gérant sélectionne les artistes disponibles (`AVAILABLE`)
  - Un booking `SELECTED` est créé pour chaque artiste retenu
  - Le cachet net (`agreedNetFee`) est figé au moment de la sélection, à partir du `ShowDateSkillRequirement.netFee`
  - La capacité par compétence est vérifiée (`SELECTED + PENDING_CONFIRMATION + CONFIRMED ≤ requiredCount`)
- Le gérant peut désélectionner un artiste (suppression du booking `SELECTED`)
- Une fois satisfait de la sélection, le gérant envoie les demandes de confirmation
  - Tous les bookings `SELECTED` passent en `PENDING_CONFIRMATION`
  - Le timestamp `requestedAt` est renseigné

### Étape 3 — Réponse des artistes

Chaque artiste répond à la demande qui lui a été envoyée.

- **Acceptation** : `PENDING_CONFIRMATION` → `CONFIRMED` — `respondedAt` renseigné
- **Refus** : `PENDING_CONFIRMATION` → `REFUSED` — `respondedAt` renseigné

Un artiste ne peut répondre qu'à son propre booking. Un booking `REFUSED` bloque la re-sélection du même artiste sur la même date — une suppression préalable est nécessaire.

### Étape 4 — Verrouillage (`LOCKED`)

Quand l'effectif artistique est complet et stabilisé, le gérant verrouille la date.

- La date passe en `LOCKED`
- **Aucune modification de booking n'est plus possible** (création, suppression, envoi de confirmations)

### Étape 5 — Annulation (`CANCELLED`)

Si la date est annulée à n'importe quel moment après `OPTIONAL` :

- La date passe en `CANCELLED`
- Toute mutation des bookings existants est bloquée
- Les bookings actifs (`SELECTED`, `PENDING_CONFIRMATION`, `CONFIRMED`) **devraient** passer en `CANCELLED`
  - Le statut `CANCELLED` est présent dans le modèle et prêt à être utilisé
  - La propagation automatique et les notifications artistes sont prévues en V1 mais pas encore implémentées
  - `respondedAt` n'est pas renseigné lors d'un passage en `CANCELLED` (c'est une décision externe, pas une réponse de l'artiste)

---

## Règles importantes

### Quand un gérant peut réserver

| Condition | Autorisé ? |
|-----------|------------|
| Date `CONFIRMED` | ✅ Oui |
| Date `PENDING` | ❌ Non — phase préparatoire |
| Date `OPTIONAL` | ❌ Non — collecte de disponibilités uniquement |
| Date `LOCKED` | ❌ Non — effectif figé |
| Date `CANCELLED` | ❌ Non — date annulée |

### Quand un gérant peut envoyer les confirmations

Même règle que pour la réservation : uniquement si la date est `CONFIRMED`.

### Quand un gérant peut désélectionner un artiste

Un booking `SELECTED` peut être supprimé tant que la date n'est pas `LOCKED` ou `CANCELLED`.

### Quand un artiste peut répondre à une demande

Un artiste peut répondre (`PENDING_CONFIRMATION → CONFIRMED | REFUSED`) tant que la date n'est pas `LOCKED` ou `CANCELLED`. Dans le workflow V1, les réponses interviennent pendant la phase `CONFIRMED`, avant le verrouillage de la date.

### Calcul de la capacité

La capacité est calculée par `ShowDateSkillRequirement`. Les statuts comptant dans la capacité :
- `SELECTED`
- `PENDING_CONFIRMATION`
- `CONFIRMED`

Les statuts `REFUSED` et `CANCELLED` **ne comptent pas** — un artiste qui refuse libère la place pour un autre.

### Snapshot du cachet

Le cachet (`agreedNetFee`) est figé au moment de la sélection à partir de `ShowDateSkillRequirement.netFee`. Une modification ultérieure du barème n'affecte pas les bookings existants.

---

## Transitions autorisées — récapitulatif

### Transitions de date (`ShowDateStatus`)

| De → Vers   | OPTIONAL | CONFIRMED | LOCKED | CANCELLED |
|-------------|----------|-----------|--------|-----------|
| `PENDING`   | ✅       | —         | —      | —         |
| `OPTIONAL`  | —        | ✅        | —      | ✅        |
| `CONFIRMED` | —        | —         | ✅     | ✅        |
| `LOCKED`    | —        | —         | —      | ✅        |

> **Note** : les transitions de statut de date (`PATCH /show-dates/{id}/status`) ne sont pas encore implémentées dans le backend V1. La date est pour l'instant créée en `PENDING` et son statut doit être mis à jour manuellement en base.

### Transitions de booking (`BookingStatus`)

| De → Vers              | PENDING_CONFIRMATION | CONFIRMED | REFUSED | CANCELLED |
|------------------------|----------------------|-----------|---------|-----------|
| `SELECTED`             | ✅ (gérant)          | —         | —       | ✅ (système) |
| `PENDING_CONFIRMATION` | —                    | ✅ (artiste, date non LOCKED/CANCELLED) | ✅ (artiste, date non LOCKED/CANCELLED) | ✅ (système) |
| `CONFIRMED`            | —                    | —         | —       | ✅ (système) |
| `REFUSED`              | —                    | —         | —       | — (terminal) |
| `CANCELLED`            | —                    | —         | —       | — (terminal) |

---

## Vision V2 — workflows configurables

Le workflow V1 décrit dans ce document est le **workflow classique** :

> Disponibilités → Confirmation client → Sélection → Demandes → Réponses artistes → Verrouillage

Dans la réalité, certaines compagnies de cabaret opèrent différemment. Ces variantes sont hors périmètre V1 mais pourront être adressées en V2 sous la forme de **workflows configurables par compagnie** :

| Variante | Description |
|----------|-------------|
| **Appel direct** | Le gérant contacte des artistes ciblés sans phase de disponibilité préalable |
| **Remplacement progressif** | L'effectif est constitué au fil des refus, sans batch de confirmations |
| **Pré-confirmation manuelle** | La confirmation artiste est validée par le gérant avant d'être effective |
| **Disponibilités optionnelles** | La sélection est autorisée même sans déclaration de disponibilité préalable |

Ces variantes nécessiteront probablement :
- Un champ `bookingWorkflow` sur `CabaretCompanyEntity`
- Des stratégies de validation interchangeables dans `ArtistBookingService`
- Des transitions de statut adaptées selon le workflow de la compagnie

**Aucun de ces workflows n'est implémenté en V1.** Le backend applique strictement le workflow classique décrit dans ce document.
