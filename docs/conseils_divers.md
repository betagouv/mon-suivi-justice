# Conseils divers

## Gestion des templates de sms

- Ne pas rajouter de point après la balise `{lieu.lien_info}` car certains téléphones l'intègrent dans le lien.

## Lancer de longues modifications de données sur Scalingo

Pour s'assurer que le conteneur dispose d'assez de mémoire pour lancer des taches lourdes, on peut augmenter la taille du conteneur au moment de lancer la commande.

```
$ scalingo -a [APP_NAME] run --size L [COMMAND]
```

Cet exemple utilise un conteneur de taille L pour lancer la commande.

## Lancer les tests en automatique

[Guard](https://github.com/guard/guard) est installé dans le repo, et permet de lancer les tests et rubocop à chaque modification de fichier. Très utile pour le TDD.

Il suffit de lancer `bundle exec guard` à la racine du repo. La configuration est dans le fichier `Guardfile`, à la racine du projet.

## Re-générer les graphs des states machines

Les deux graphs présents dans le dossier `docs` peuvent etre mis à jour si besoin avec cette tache rake :

```
$ rake state_machines:draw TARGET='docs' ORIENTATION=landscape CLASS=Notification,Appointment
```
