# Workflow Git/GitHub – site4night

Procédure à suivre pour **chaque** tâche du projet (fonctionnalité, correction,
documentation). Durée totale hors développement : environ 10 minutes.

> [!IMPORTANT]
>
> Les commandes `git push` et `git pull` se lancent dans le **Terminal macOS**,
> pas dans le terminal de VS Code ouvert dans le conteneur (la clé SSH n'y est
> pas disponible).

## Vue d'ensemble

```text
Issue → Branche → Développement → Commit(s) → Push → Pull request → Fusion → Mise à jour locale
```

## Les étapes

### 1. Partir d'un `main` à jour (20 s)

```bash
git switch main
git pull
```

### 2. Créer une issue sur GitHub (1 min)

1. Dépôt GitHub → onglet _Issues_ → _New issue_.
2. Titre court à l'infinitif : « Ajouter la page de connexion ».
3. Description : ce qui doit être fait, en quelques points.
4. Noter le numéro de l'issue (ex. `#5`).

### 3. Créer une branche (10 s)

```bash
git switch -c <type>/<description-courte>
```

| Type       | Usage                             | Exemple                       |
| ---------- | --------------------------------- | ----------------------------- |
| `feature/` | Nouvelle fonctionnalité           | `feature/connexion`           |
| `fix/`     | Correction de bug                 | `fix/validation-coordonnees`  |
| `docs/`    | Documentation, cahier des charges | `docs/maquette`               |
| `db/`      | Schéma ou script SQL              | `db/schema-initial`           |

### 4. Développer

- Enregistrer avec ⌘S : Prettier et Intelephense formatent automatiquement.
- Vérifier régulièrement ce qui a changé :

  ```bash
  git status
  git diff
  ```

- Annuler une modification non voulue sur un fichier :

  ```bash
  git restore <fichier>
  ```

### 5. Faire un ou plusieurs commits (30 s chacun)

```bash
git add <fichier1> <fichier2>
git commit -m "<type>: <description>"
```

- Ajouter les fichiers **un par un** plutôt que `git add .` pour éviter
  d'envoyer des fichiers modifiés par erreur.
- Types de message : `feat`, `fix`, `docs`, `refactor`, `style`, `chore`.
- Exemple : `feat: ajout du formulaire de connexion`.
- Un commit = une modification cohérente. Plusieurs petits commits valent mieux
  qu'un gros.

### 6. Envoyer la branche sur GitHub (10 s) – Terminal macOS

```bash
git push -u origin <nom-de-la-branche>
```

Pour les push suivants sur la même branche : `git push`.

### 7. Ouvrir la pull request (2 min)

1. GitHub → bandeau jaune _Compare & pull request_.
2. Vérifier : base `main` ← branche de travail.
3. Titre clair.
4. Description :
   - ce qui a été fait ;
   - comment tester ;
   - aide externe ou IA utilisée (outil, quoi, pourquoi), à reporter aussi
     dans la section IA du cahier des charges ;
   - `Closes #<numéro>` pour fermer l'issue automatiquement.
5. _Create pull request_.

### 8. Relire et fusionner (1 min)

1. Onglet _Files changed_ : relire chaque modification.
2. _Merge pull request_ → _Confirm merge_.
3. _Delete branch_.

### 9. Mettre à jour le Mac (20 s) – Terminal macOS

```bash
git switch main
git pull
git fetch --prune
git branch -d <nom-de-la-branche>
```

## En cas de conflit

Un conflit apparaît quand `main` a changé sur les mêmes lignes que la branche.

1. Mettre la branche à jour avec `main` :

   ```bash
   git switch main
   git pull
   git switch <nom-de-la-branche>
   git merge main
   ```

2. Ouvrir les fichiers signalés dans VS Code et choisir, pour chaque bloc
   `<<<<<<<` / `>>>>>>>`, la version à garder (_Accept Current_, _Accept
   Incoming_ ou _Accept Both_).
3. Terminer :

   ```bash
   git add <fichier-résolu>
   git commit
   git push
   ```

## Commandes utiles

| Commande                    | Effet                                          |
| --------------------------- | ---------------------------------------------- |
| `git status`                | État des fichiers et de la branche             |
| `git log --oneline -10`     | 10 derniers commits                            |
| `git diff`                  | Modifications non encore ajoutées              |
| `git branch -a`             | Branches locales et distantes                  |
| `git restore <fichier>`     | Annule les modifications d'un fichier          |
| `git restore --staged <f>`  | Retire un fichier du prochain commit           |
| `git commit --amend`        | Corrige le dernier commit (avant le push)      |

## Livrables attendus par séance

Chaque livrable correspond à au moins une PR fusionnée.

| Séance | Livrable                                     | Branche suggérée          | Statut |
| ------ | -------------------------------------------- | ------------------------- | ------ |
| 2      | Cahier des charges initial                   | `docs/cahier-des-charges` | ✅     |
| 3      | Maquette de l'interface                      | `docs/maquette`           | ⏳     |
| 4      | MCD, MLD, MPD                                | `db/schema`               | ⏳     |
| 5      | Déploiement Infomaniak + BDD                 | `feature/deploiement`     | ⏳     |
| 6      | Programmation orientée objet                 | `feature/poo`             | ⏳     |
| 7      | Sécurité (SQL, XSS, CSRF)                    | `feature/securite`        | ⏳     |
| 8      | Multilingue (i18n)                           | `feature/i18n`            | ⏳     |
| 9      | Sessions, authentification, autorisation     | `feature/authentification`| ⏳     |
| 10     | Envoi d'e-mails                              | `feature/emails`          | ⏳     |

## Pièges déjà rencontrés

- `git push` refusé dans le terminal de VS Code (conteneur) → utiliser le
  Terminal macOS.
- Fichier modifié par erreur (ex. `README.md`) → vérifier `git status` avant
  chaque commit, puis `git restore <fichier>`.
- Prettier absent hors conteneur → installer l'extension
  _Prettier – Code formatter_ dans VS Code.
