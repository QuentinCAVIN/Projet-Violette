# Choix et justification du référentiel d'accessibilité

> Projet Violette — Bloc 2 (conception et développement)
> Statut : décision de cadrage. L'implémentation des critères est un chantier identifié (voir § Périmètre et trajectoire).

## 1. Décision

Le référentiel retenu pour Violette est **WCAG 2.2, niveau de conformité AA**.

- **WCAG** (Web Content Accessibility Guidelines) est le standard international d'accessibilité numérique publié par le W3C. Il définit l'accessibilité à travers quatre principes — contenu **P**erceptible, **U**tilisable, **C**ompréhensible, **R**obuste — déclinés en critères de succès vérifiables, sur trois niveaux : A (minimal), **AA** (standard de l'industrie), AAA (exigeant).
- La version **2.2** est la version courante du standard (W3C Recommendation depuis octobre 2023, et norme ISO/IEC 40500:2025). Elle est rétrocompatible : satisfaire WCAG 2.2 AA revient à satisfaire aussi 2.1 AA et 2.0 AA.
- Le niveau **AA** est la cible visée : c'est le niveau de référence dans l'industrie et le droit (le RGAA français et l'EN 301 549 européen s'alignent sur WCAG niveau AA). Le niveau AAA n'est pas universellement atteignable et n'est pas retenu comme objectif global.

## 2. Justification du choix

Trois référentiels étaient candidats. Le choix de WCAG 2.2 AA résulte d'une analyse de leur adéquation à la **technologie** et au **public** de Violette, et non d'une préférence par familiarité.

### Contexte technique déterminant

Violette est une application **Flutter native**, livrée d'abord sous forme d'**APK Android** (la version web est prévue en fin de lot 1). Ce point conditionne le choix :

- **WCAG** est **agnostique de la technologie** : ses critères de succès sont rédigés comme des énoncés testables indépendants d'une technologie particulière, et s'appliquent à tout type de support, y compris mobile. Surtout, Flutter fournit nativement les briques qui se mappent directement sur les critères WCAG : le widget `Semantics` (exposition aux lecteurs d'écran TalkBack/VoiceOver), le respect du facteur d'échelle de texte du système, la gestion du focus et de l'ordre de navigation, les contrastes. WCAG est donc **directement applicable** à l'app actuelle.

- Le **RGAA** (Référentiel Général d'Amélioration de l'Accessibilité) est l'adaptation française de WCAG AA, opposable juridiquement au secteur public. Sa **méthodologie de test est conçue pour le web** (structure HTML, attributs ARIA, DOM). Pour une application Flutter native — qui ne produit pas de HTML — le RGAA est mal ajusté techniquement. De plus, Violette n'est pas un acteur public soumis à une obligation RGAA opposable.

- **Opquast** est un référentiel de **qualité web** (240 bonnes pratiques couvrant accessibilité, mais aussi SEO, performance, éco-conception, expérience utilisateur). L'accessibilité n'y est qu'un sous-ensemble, et l'ensemble est orienté web. Opquast est **complémentaire** de WCAG (qualité globale vs norme d'accessibilité), non substituable, et ne s'applique pas à une app mobile native dans son état actuel.

### Synthèse comparative

| Référentiel | Nature | Adéquation Flutter natif (aujourd'hui) | Statut pour Violette |
|---|---|---|---|
| **WCAG 2.2 AA** | Norme d'accessibilité internationale, agnostique techno | Directe (API d'accessibilité Flutter) | **Retenu** |
| RGAA | Adaptation FR de WCAG AA, orientée web, opposable secteur public | Faible (méthode de test web) | Écarté aujourd'hui, pertinent si front web + obligation légale |
| Opquast | Référentiel de qualité web global (accessibilité = sous-ensemble) | Faible (orienté web) | Réintégré en trajectoire web (déjà maîtrisé) |

## 3. Périmètre visé et trajectoire

### Aujourd'hui — application mobile native (lot courant)

Référentiel : **WCAG 2.2 AA**, appliqué via les API d'accessibilité de Flutter. Les familles de critères réalistes et prioritaires pour Violette :

- **Perceptible** : contrastes de couleur suffisants (texte/fond), respect du redimensionnement de texte défini par le système, alternatives textuelles (`Semantics` labels) pour les éléments non textuels.
- **Utilisable** : cibles tactiles d'au moins 44×44 px, ordre de focus cohérent, navigation au lecteur d'écran (TalkBack/VoiceOver), pas de dépendance à un seul sens (couleur).
- **Compréhensible** : libellés de formulaires explicites, messages d'erreur clairs (cohérent avec les retours d'erreur déjà structurés côté backend), langue de l'interface déclarée.
- **Robuste** : exposition correcte des rôles/états des composants à la couche d'accessibilité du système.

> **État d'implémentation** : à ce stade, le référentiel est choisi et justifié ; l'implémentation et l'audit des critères constituent un chantier identifié (axe d'amélioration documenté). Le présent livrable répond à l'attendu « choix et justification du référentiel ».

### Demain — front web (fin lot 1)

Lorsque la version web Flutter sera déployée :

- **Opquast** pourra être réintroduit pour la qualité web globale (compétence déjà maîtrisée au sein de l'équipe), au-delà de la seule accessibilité.
- Le **RGAA** deviendra pertinent si une obligation légale s'applique, ou comme cadre de test web structuré.
- La **cohérence est garantie** : les trois référentiels partagent le socle WCAG, donc viser WCAG 2.2 AA aujourd'hui pose les fondations réutilisables pour Opquast et RGAA demain, sans retravail du socle.

## 4. Références

- W3C — Web Content Accessibility Guidelines (WCAG) 2.2 : https://www.w3.org/TR/WCAG22/
- W3C WAI — Nouveautés de WCAG 2.2 : https://www.w3.org/WAI/standards-guidelines/wcag/new-in-22/
- Flutter — Accessibilité : https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility
