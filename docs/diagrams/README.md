# Diagrammes — Sources et génération des PNG

Les quatre diagrammes C4 sont versionnés sous deux formes : le **PNG** (affiché par la documentation) et sa **source PlantUML** (`.puml`), qui documente son origine et permet de le régénérer.

## Fichiers sources

| Fichier source | PNG généré | Contenu |
|----------------|------------|---------|
| `c4-context.puml` | `c4-context.png` | Niveau 1 — Contexte système : acteurs (gérant, artiste, client), Violette, Firebase Authentication. |
| `c4-container.puml` | `c4-container.png` | Niveau 2 — Conteneurs : application mobile Flutter, backend Quarkus, base de données, Firebase. |
| `c4-component-backend.puml` | `c4-component-backend.png` | Niveau 3 — Composants du backend : sécurité (JWT, `ManagerCompanyResolver`, `GlobalExceptionMapper`), domaines métier, événements CDI, mappers. |
| `c4-component-artistbooking.puml` | `c4-component-artistbooking.png` | Niveau 4 — Zoom sur le domaine **artistbooking** : Controller, Service, Repository, Entity, Event, observers, Mapper. |

Le dossier contient aussi deux diagrammes de **vision produit** issus de l'avant-projet, sans source PlantUML : `ddd-bounded-contexts.png` et `domain-storytelling.png` (leur statut est expliqué dans [../architecture-c4.md](../architecture-c4.md)).

## Régénérer un PNG à partir de sa source

Les commandes ci-dessous valent pour n'importe lequel des quatre fichiers : remplacer `<nom>` par `c4-context`, `c4-container`, `c4-component-backend` ou `c4-component-artistbooking`.

### Option 1 — Docker (recommandé)

Sans rien installer localement (sauf Docker) :

```bash
# Depuis la racine du projet
docker run --rm -v "${PWD}/docs/diagrams:/data" plantuml/plantuml:latest -tpng /data/<nom>.puml -o .
```

Le fichier `<nom>.png` est créé dans `docs/diagrams/`.

### Option 2 — PlantUML en ligne de commande

Si PlantUML est installé (voir [plantuml.com](https://plantuml.com/fr/)) :

```bash
cd docs/diagrams
plantuml -tpng <nom>.puml
```

### Option 3 — En ligne

1. Ouvrir [PlantUML Online Server](https://www.plantuml.com/plantuml/uml/).
2. Copier le contenu du fichier `.puml` (y compris la ligne `!include https://...`).
3. Générer puis télécharger le PNG et le placer dans `docs/diagrams/` sous le même nom que la source.

### Option 4 — Extension VS Code

Avec l'extension **PlantUML** (jebbs.plantuml), ouvrir le `.puml` et utiliser « Export Current Diagram » (Alt+D) pour générer le PNG.

---

Après génération, chaque PNG doit porter **le même nom que sa source** et rester dans ce dossier : c'est sous ces noms qu'il est référencé par le README racine et `docs/architecture-c4.md`.
