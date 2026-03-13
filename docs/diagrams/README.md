# Diagrammes — Génération des PNG

Les diagrammes C4 niveau 1 à 3 sont des PNG présents dans ce dossier. Le **zoom niveau 4** (domaine artistbooking) est défini en source PlantUML et doit être généré pour obtenir le PNG.

## Fichier source niveau 4

| Fichier | Description |
|---------|-------------|
| `c4-component-artistbooking.puml` | Zoom sur le domaine **artistbooking** : Controller, Service, Repository, Entity, Event, Observer, Mapper. |

## Générer le PNG à partir du .puml

### Option 1 — Docker (recommandé)

Sans rien installer localement (sauf Docker) :

```bash
# Depuis la racine du projet
docker run --rm -v "${PWD}/docs/diagrams:/data" plantuml/plantuml:latest -tpng /data/c4-component-artistbooking.puml -o .
```

Le fichier `c4-component-artistbooking.png` est créé dans `docs/diagrams/`.

### Option 2 — PlantUML en ligne de commande

Si PlantUML est installé (voir [plantuml.com](https://plantuml.com/fr/)) :

```bash
cd docs/diagrams
plantuml -tpng c4-component-artistbooking.puml
```

### Option 3 — En ligne

1. Ouvrir [PlantUML Online Server](https://www.plantuml.com/plantuml/uml/).
2. Copier le contenu de `c4-component-artistbooking.puml` (y compris la ligne `!include https://...`).
3. Générer puis télécharger le PNG et le placer dans `docs/diagrams/c4-component-artistbooking.png`.

### Option 4 — Extension VS Code

Avec l’extension **PlantUML** (jebbs.plantuml), ouvrir le `.puml` et utiliser « Export Current Diagram » (Alt+D) pour générer le PNG.

---

Après génération, le PNG doit être nommé **`c4-component-artistbooking.png`** et placé dans ce dossier pour être référencé par le README et `docs/architecture-c4.md`.
