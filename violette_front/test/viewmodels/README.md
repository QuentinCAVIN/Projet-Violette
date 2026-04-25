# Tests ViewModels

Ce dossier contient les tests unitaires des ViewModels Flutter.

## Rôle

Les ViewModels orchestrent les repositories, services Stacked et états d'écran. Les tests doivent rester ciblés sur les comportements utiles :

- chargement des données depuis les repositories REST ;
- navigation selon l'état utilisateur ou métier ;
- gestion des erreurs réseau ou des états incohérents ;
- transformation simple d'état UI quand elle n'est pas déjà couverte par un mapper.

## Conventions

- Utiliser `mocktail` pour isoler les repositories et services externes.
- Initialiser le locator Stacked uniquement quand le ViewModel en dépend réellement.
- Garder la logique métier complexe dans les modèles, mappers ou services dédiés afin de pouvoir la tester sans UI.
- Voir `test/TEST_README.md` et `docs/testing-strategy.md` pour la stratégie globale.

Ce fichier n'est pas une justification d'absence de tests : les tests ViewModels existent et doivent être maintenus lorsqu'un flux utilisateur ou REST évolue.
