# Règles métier — Violette v0.4.0

Ce document est la source de vérité métier pour les cycles de vie stabilisés avant la release `v0.4.0`.

Le backend Quarkus porte les règles métier principales. Le frontend Flutter consomme ces règles via l'API REST et les mappe vers ses modèles d'affichage.

---

## Principes

- Firebase Auth fournit l'identité et le JWT.
- Le backend Quarkus est la source métier principale pour les utilisateurs, dates de spectacle, disponibilités et bookings.
- Firestore n'est plus utilisé par le code métier frontend des domaines migrés.
- Une disponibilité n'est pas un engagement.
- Une présélection n'est pas un booking ferme.
- Un booking ferme commence quand une demande de confirmation est envoyée à l'artiste.

---

## Cycle de vie d'une date (`ShowDateStatus`)

```text
INQUIRY -> OPTION -> CONFIRMED -> STAFFED -> ARCHIVED
    |         |          |
    v         v          v
CANCELLED CANCELLED  CANCELLED
```

| Statut | Sens métier | Disponibilités | Présélection | Booking ferme |
|---|---|---:|---:|---:|
| `INQUIRY` | Demande client à qualifier. Les informations peuvent être incomplètes. | Non | Non | Non |
| `OPTION` | Devis envoyé ou option posée. Le besoin est assez clair pour préparer l'équipe. | Oui | Oui | Non |
| `CONFIRMED` | Client confirmé. Les sollicitations fermes peuvent être envoyées. | Oui | Oui | Oui |
| `STAFFED` | Équipe complète et sécurisée. | Lecture seule | Non | Non |
| `CANCELLED` | Date abandonnée ou annulée. | Non | Non | Non |
| `ARCHIVED` | Date historisée après prestation. | Non | Non | Non |

### Règles associées

- En `INQUIRY`, aucune sollicitation artiste ne doit être créée.
- En `OPTION`, le gérant peut préparer l'équipe avec des disponibilités et des présélections, sans engagement ferme.
- En `CONFIRMED`, le gérant peut envoyer des demandes de confirmation aux artistes.
- En `STAFFED`, l'équipe est considérée complète.
- `CANCELLED` et `ARCHIVED` sont des états de sortie : les mutations métier doivent être bloquées ou très encadrées.

---

## Disponibilité artiste (`AvailabilityStatus`)

| Statut | Sens métier |
|---|---|
| `PENDING` | L'artiste n'a pas encore répondu. |
| `AVAILABLE` | L'artiste est disponible. |
| `IF_NEEDED` | L'artiste est disponible si besoin, mais non prioritaire. |
| `UNAVAILABLE` | L'artiste est indisponible. |

### Règles associées

- `PENDING` est l'état initial.
- Après une réponse, le retour à `PENDING` n'est pas une transition normale.
- `IF_NEEDED` remplace l'ancien vocabulaire `CONDITIONAL`.
- Une disponibilité ne réserve pas l'artiste et ne bloque pas d'autre engagement.
- Pour la sélection manager (`SELECTED`) : `AVAILABLE` et `IF_NEEDED` sont sélectionnables ; `UNAVAILABLE` et `PENDING` ne le sont pas en v0.4.0.
- `IF_NEEDED` signifie "disponible si besoin" : sélection autorisée, mais priorité métier inférieure à `AVAILABLE`.

---

## Booking artiste (`BookingStatus`)

```text
SELECTED -> PENDING_CONFIRMATION -> CONFIRMED
                         |
                         v
                      REFUSED

SELECTED | PENDING_CONFIRMATION | CONFIRMED -> CANCELLED
```

| Statut backend | Libellé Flutter | Sens métier | Déclencheur |
|---|---|---|---|
| `SELECTED` | `preselected` | Artiste présélectionné ou sélectionné par le gérant. Pas encore de demande ferme. | Gérant |
| `PENDING_CONFIRMATION` | `pendingConfirmation` | Demande de confirmation envoyée, en attente de réponse. | Gérant |
| `CONFIRMED` | `confirmed` | Artiste engagé après acceptation. | Artiste |
| `REFUSED` | `refused` | Artiste a refusé la demande. | Artiste |
| `CANCELLED` | `cancelled` | Booking annulé, par exemple après annulation de la date. | Système ou action métier |

### Règles associées

- `SELECTED` peut exister en `OPTION` pour préparer une équipe sans engagement.
- `PENDING_CONFIRMATION` ne doit exister que pour une date `CONFIRMED`.
- `CONFIRMED` signifie que l'artiste a accepté la demande.
- Si un artiste possède un booking `CONFIRMED` sur une date, il ne peut plus modifier sa disponibilité sur cette date dans l'application `v0.4.0`.
- Pour modifier un engagement confirmé ou se désister, l'artiste doit contacter le gérant ; le désistement autonome est hors périmètre `v0.4.0`.
- `REFUSED` libère la place dans la capacité métier.
- `CANCELLED` sert à neutraliser un booking devenu inactif.

---

## Présélection vs booking ferme

| Étape | Date | Statut booking | Engagement artiste | Notification / demande |
|---|---|---|---|---|
| Disponibilité | `OPTION` ou `CONFIRMED` | Aucun booking requis | Non | Non |
| Présélection | `OPTION` | `SELECTED` | Non | Non |
| Sélection avant envoi | `CONFIRMED` | `SELECTED` | Non | Pas encore |
| Demande ferme | `CONFIRMED` | `PENDING_CONFIRMATION` | En attente | Oui |
| Acceptation | `CONFIRMED` ou `STAFFED` | `CONFIRMED` | Oui | Réponse artiste |

La différence principale est l'engagement : une présélection aide le gérant à composer une équipe, tandis qu'un booking ferme sollicite officiellement l'artiste.

---

## Capacité et cachet

- La capacité se calcule par besoin artistique (`ShowDateSkillRequirement.requiredCount`).
- Les bookings `SELECTED`, `PENDING_CONFIRMATION` et `CONFIRMED` comptent dans la capacité.
- Les bookings `REFUSED` et `CANCELLED` ne comptent pas.
- Le cachet d'un booking (`agreedNetFee`) est un snapshot au moment de la sélection, basé sur `ShowDateSkillRequirement.netFee`.
- Il n'existe pas de `fee` global fiable au niveau `ShowDate` : les montants sont portés par les besoins artistiques et les bookings.

---

## Identifiants

- Le backend utilise ses identifiants SQL (`id`) comme identifiants métier principaux.
- `firebaseUid` identifie l'utilisateur Firebase et sert à relier le JWT au profil backend.
- Pendant les transitions historiques, certains mappers peuvent encore défendre des cas où une donnée legacy contient un `firebaseUid`; cette compatibilité doit disparaître quand les données legacy ne sont plus utiles.

---

### À traiter en v0.5.0
- Clarifier l’affichage de la présélection côté manager et côté artiste.
- Distinguer visuellement les artistes disponibles, présélectionnés et confirmés.
- Déterminer si la présélection en OPTION doit être visible par l’artiste ou rester interne au gérant.
