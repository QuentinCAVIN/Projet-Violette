# Règles métier — Violette

Ce document est la source de vérité métier des cycles de vie de l'application. Il est à jour de la version `v0.5.0` (voir le [journal des versions](../CHANGELOG.md) pour l'historique des évolutions).

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
- **L'archivage n'est pas encore déclenché en `v0.5.0`** : le statut `ARCHIVED` est défini et protégé (aucune mutation n'est possible depuis cet état, la garde `assertShowDateCancellable` le refuse au même titre que `CANCELLED`), mais **aucune transition ne l'atteint** dans l'application. La flèche `STAFFED → ARCHIVED` du cycle de vie ci-dessus décrit la cible fonctionnelle, pas un flux exécutable aujourd'hui.

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
- Pour la sélection manager (`SELECTED`) : `AVAILABLE` et `IF_NEEDED` sont sélectionnables ; `UNAVAILABLE` et `PENDING` ne le sont pas dans la version actuelle.
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
- Si un artiste possède un booking `CONFIRMED` sur une date, il ne peut plus modifier sa disponibilité sur cette date dans l'application — verrou également garanti côté backend depuis la `v0.5.0`.
- Pour modifier un engagement confirmé ou se désister, l'artiste doit contacter le gérant ; le désistement autonome est hors périmètre `v0.5.0`.
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

## Écarts terrain identifiés (reportés post-v0.5.0)

Deux comportements ont été identifiés lors de tests avec la compagnie pilote.
Ils sont documentés comme choix assumés pour v0.5.0 et feront l'objet d'une
évolution en v0.6.0 / v0.7.0.

### 1. Découplage disponibilité / présélection (choix assumé)

Un artiste présélectionné (`SELECTED`) qui modifie ensuite sa disponibilité
vers `UNAVAILABLE` conserve sa présélection et continue de compter dans
l'effectif de la date.

Ce comportement est **volontaire** : la présélection est une décision du gérant,
qu'un changement de disponibilité de l'artiste ne doit pas défaire silencieusement.
La contradiction éventuelle (présélectionné mais déclaré indisponible) se résout
par un échange direct entre l'artiste et le gérant, conformément à la règle
« une disponibilité ne réserve pas l'artiste et ne bloque pas d'autre engagement ».

**Évolution envisagée (v0.6.0)** : signaler visuellement au gérant qu'un artiste
présélectionné s'est déclaré indisponible, sans désélection automatique.

### 2. Engagement ferme dès le stade OPTION (report v0.6.0/v0.7.0)

Retour terrain (compagnie pilote) : dans la pratique, les compagnies demandent
aux artistes de s'engager dès que la date est en `OPTION`, sans attendre le
passage en `CONFIRMED`.

Le workflow actuel réserve l'envoi des demandes fermes (`sendConfirmationRequests`,
`SELECTED → PENDING_CONFIRMATION`) aux dates `CONFIRMED`. La règle
« `PENDING_CONFIRMATION` ne doit exister que pour une date `CONFIRMED` » est donc
maintenue en v0.5.0.

**Évolution envisagée** : autoriser l'envoi des demandes fermes dès `OPTION`.
Impact à traiter proprement (hors périmètre gel v0.5.0) : assouplissement de la
garde `assertDateConfirmed` dans `sendConfirmationRequests`, révision de la
sémantique de `PENDING_CONFIRMATION`, mise à jour des tests associés et de la
capacité (comptage de l'effectif sur les bookings confirmés plutôt que
présélectionnés). Reporté en v0.6.0 / v0.7.0.

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
