# Guide de contribution

La meilleure façon de contribuer à Mon Suivi Justice (MSJ), c'est de créer une issue [ici](https://github.com/betagouv/mon-suivi-justice/issues), ou de répondre à une issue existante. L'équipe pose régulièrement dans des issues des problèmes repérés mais non priorisés.

Pour signaler un problème ou proposer quelque chose, vous pouvez aussi nous contacter à [contact@mon-suivi-justice.beta.gouv.fr](mailto:contact@mon-suivi-justice.beta.gouv.fr)

## Soumettre une modification

Pour installer un environnement de dev en local, suivre [cette documentation](INSTALL.md).

Pour soumettre une modification de code :

- Cloner le projet dans votre environnement
- Créer une branche
- Apporter les modifications que vous souhaitez en respectant [le guide de programmation](#Guide-de-programmation)
- Pousser votre code sur Github
- Créer une pull request

N'oubliez pas de vérifier le résultat de la CI sur Github Actions.

## Code existant

Le métier est centré sur la convocation de personnes placées sous main de justice (PPSMJ) par des agents du Ministère de la Justice.

La première phase du projet contient une interface pour les agents, qui peuvent saisir leurs rendez-vous (rdv) et envoyer des SMS de notification au PPSMJ. Le premier objectif, c'est de réduire l'absentéisme, et l'outil principal, ce sont des SMS.

MSJ envoie actuellement trois types de SMS :

- Convocation : envoyé immédiatement après la prise de rdv, regroupe les infos utiles.
- Rappel : envoyé 48h avant le rdv.
- Annulation : envoyé si un agent annule un rdv prévu.

Dans la suite du projet, nous allons nous concentrer sur les PPSMJ, avec un site d'information sur les différentes mesures et une interface dédiée.

### Sens métier des principaux modèles:

- Convict : PPSMJ, personne récemment condamnée, soumise à diverses mesures (bracelet électronique, obligation de soins...) ou sortant de prison.
- User : agent du ministère, peut travailler dans un Spip (Service pénitentiaire d'insertion et de probation) ou un tribunal.
- Place : lieu de rendez-vous. Pour l'expérimentation en cours, les rdv ont lieu au Spip du 92 et au Tribunal judiciaire de Nanterre.
- Appointment : rendez-vous d'un PPSMJ dans un lieu, matérialisé par une convocation.
- Slot : créneau disponible pour un rendez-vous, défini par les agents du lieu de rdv.
- Notification : SMS envoyé au PPSMJ.

### Structure de la base de données

![Graph ERD](/docs/erd.png)

### State machines

Les modèles Appointment et Notification disposent chacun d'une state machine. C'est avec ce système que sont envoyé les SMS.

Appointment :

![Machine à état Appointment](/docs/Appointment_state.png)

Notification :

![Machine à état Notification](/docs/Notification_state.png)

## Guide de programmation

Le code de MSJ respecte les bonnes pratiques de la communauté, en s'inspirant des textes suivants :

- [The Rails Doctrine](https://rubyonrails.org/doctrine/)
- [The rails Style Guide](https://rails.rubystyle.guide)
- [The Twelve-factor app](https://12factor.net/)
- [Sandi Metz' Rules For Developers](https://thoughtbot.com/blog/sandi-metz-rules-for-developers)

Le but est de chercher "the Rails way", la méthode préférée de la communauté Rails pour régler un problème. Convention over configuration.

Pour s'assurer que les standards sont respectés, le linter Rubocop bloque la CI sur Github Actions. Des modifications au fichier `.rubocop.yml` peuvent être acceptables, à discuter en PR.

### Langues

Pour respecter les conventions de l'open-source, le code est en anglais. Les noms de tables, colonnes et variables sont en anglais.
Pour git, les commits / noms de branche sont en anglais. Les messages de commit commencent toujours par un verbe d'action.

Mais la documentation que vous êtes en train de lire est en français. Le projet est financé par l'État français, tous les utilisateurs sont français.

Pour éviter le franglais et que le code reste clair, la séparation doit être très nette. La langue française est présente uniquement dans des fichiers de traduction et la documentation.

Les échanges avec l'équipe, notamment sur Github, sont en français. Les issues et les PR sont en français. Cela peut changer si des contributeurs non-francophones arrivent dans le projet (doubtful).

### Tests

La suite de test a été réalisée avec [Rspec](http://rspec.info/), [Capybara](https://github.com/teamcapybara/capybara), [Webmock](https://github.com/bblimke/webmock), [FactoryBot](https://github.com/thoughtbot/factory_bot) et [Shoulda-matchers](https://github.com/thoughtbot/shoulda-matchers).

- Chaque fonctionnalité est couverte par des tests, de préférence par un test de feature et une série de tests unitaires. Aucune pull request ne sera mergée sans tests.
- Éviter au maximum l'utilisation d'ActiveRecord dans les tests unitaires. Préférer :build à :create pour les objets de test.

### Modèles

- Le code doit si possible être placé dans un service dédié, et non par défaut dans le fichier du modèle.
- Ne pas utiliser de hook ActiveRecord (:before_create, :after_save...). Préférer l'usage de state machines pour la gestion des workflows.

### Vues

- Le texte de l'application n'est pas en dur dans les vues mais dans des fichiers de traduction.

### Style

Le style du projet a été intégré en mobile-first pour la partie site d'information. L'interface agent n'a pas de version mobile, et ce n'est pas prévu (outil de travail utilisé sur des ordinateurs pros).

Le CSS du projet s'inspire du BEM, sans le respecter rigoureusement. Parmi les principes gardés :

- Le style est toujours lié à une classe, pas à un id. Les id sont utilisés pour le Javascript.
- Aucun style n'est lié directement à une balise, mais toujours à une classe.
- Classes à usage unique, avec des noms longs et descriptifs. Il vaut parfois mieux dupliquer que complexifier du CSS.
- Les classes ne sont pas nestées, elles restent à un seul niveau.

Les styles de MSJ sont structurés comme un proto-design système.

- Les couleurs de l'interface et certaines valeurs clés sont regroupés dans le fichier `variables.scss`
- Favoriser le découpage des fichiers SCSS par composant.

## D'autres façons de contribuer

Si vous souhaitez contribuer à notre projet, vous pouvez :
- En parler autour de vous.
- Proposer des améliorations de la documentation, y compris cette page.
- Venir discuter dans les issues et les PR, donner votre avis sur le code proposé.

Merci d'avoir lu ce document, et n'hésitez pas : toutes les contributions seront les bienvenues :)

<!-- - Participer à la [documentation](https://doc.rdv-solidarites.fr/) -->
