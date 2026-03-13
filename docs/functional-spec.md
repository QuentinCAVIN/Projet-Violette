# Description fonctionnelle — Violette

## 1. Introduction

**Violette** est une plateforme de gestion destinée aux compagnies de cabaret et aux artistes indépendants. Elle permet de coordonner les dates de spectacle, de collecter les disponibilités des artistes et de gérer les réservations de façon centralisée.

Aujourd'hui, la planification des spectacles repose souvent sur des échanges informels (messages, tableurs, appels téléphoniques), ce qui génère des oublis, des conflits de planning et des inégalités dans la répartition des engagements. Violette centralise ces informations et fiabilise la coordination entre gérants et artistes.

---

## 2. Contexte métier

Une compagnie de cabaret organise régulièrement des spectacles. Pour chaque date, le gérant doit réunir les artistes nécessaires selon les compétences requises (danse, chant, acrobaties, etc.). Les artistes sont souvent indépendants et travaillent pour plusieurs compagnies en parallèle.

La gestion de ces plannings implique plusieurs défis :

- connaître les disponibilités de chaque artiste avant de les contacter,
- éviter les doubles engagements,
- suivre l'état des confirmations pour chaque date,
- répartir les engagements équitablement entre les artistes.

---

## 3. Acteurs du système

### Gérant (Manager)

Le gérant est responsable de la compagnie. Il pilote la planification des spectacles et la constitution des équipes artistiques.

Il peut :
- créer et gérer les dates de spectacle,
- définir les besoins artistiques de chaque date (compétences, nombre d'artistes),
- consulter les disponibilités déclarées par les artistes,
- sélectionner les artistes retenus pour une date,
- envoyer des demandes de confirmation aux artistes sélectionnés,
- suivre l'état des réservations.

### Artiste

L'artiste est membre ou collaborateur d'une compagnie. Il gère ses propres disponibilités et répond aux sollicitations du gérant.

Il peut :
- déclarer sa disponibilité sur les dates à venir,
- consulter les demandes de réservation qui lui sont adressées,
- accepter ou refuser une demande,
- consulter ses engagements confirmés.

---

## 4. Fonctionnalités principales

### Gestion des utilisateurs

- Création d'un compte avec prénom, nom et rôle (gérant ou artiste).
- Connexion sécurisée via Firebase Authentication.
- Un même compte peut avoir plusieurs rôles si nécessaire.

### Gestion des compagnies

- Création d'une compagnie avec ses informations (nom, description).
- Gestion des membres associés à la compagnie.
- Gestion des revues (spectacles rattachés à la compagnie).

### Gestion des dates de spectacle

- Création d'une date avec les informations logistiques : lieu, adresse, heure de rendez-vous, contacts client.
- Définition des compétences artistiques requises et du nombre d'artistes nécessaires par compétence.
- Collecte des disponibilités : chaque artiste indique s'il est disponible, incertain ou indisponible pour la date.

### Réservation des artistes

- Sélection des artistes disponibles pour une date confirmée.
- Envoi groupé des demandes de confirmation aux artistes sélectionnés.
- Réponse de chaque artiste : acceptation ou refus.
- Enregistrement des réservations confirmées, avec le cachet net convenu.

---

## 5. Workflow simplifié de réservation

```
1. Le gérant crée une date de spectacle
         │
         ▼
2. Les artistes déclarent leur disponibilité
         │
         ▼
3. Le gérant consulte les disponibilités et sélectionne les artistes retenus
         │
         ▼
4. Le gérant envoie les demandes de confirmation
         │
         ▼
5. Chaque artiste accepte ou refuse la demande
         │
         ▼
6. Les réservations acceptées sont confirmées et enregistrées
```

Ce workflow constitue le cycle de base de la version 1. Il est conçu pour évoluer selon les besoins des compagnies.

---

## 6. Objectifs de la version 1

La première version de Violette vise à :

- **centraliser** la gestion des disponibilités dans un outil unique,
- **sécuriser** le processus de réservation (validation explicite à chaque étape),
- **éviter les conflits** de planning grâce à la gestion des statuts et des capacités,
- **préparer la traçabilité** des cachets avec l'enregistrement du montant convenu à la réservation.

### Fonctionnalités prévues pour les versions futures

- Notifications automatiques aux artistes (envoi de demandes, rappels),
- Gestion complète des cachets et des paiements,
- Partage de contenus artistiques (vidéos de répétition),
- Workflows de réservation configurables selon la compagnie,
- Messagerie interne entre gérants et artistes.
