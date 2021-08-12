# INSTALL

## 1. Installer Ruby

MSJ utilise Ruby 2.7.4. L'installation peut être géré avec[RVM](https://rvm.io/): [Installing rubies](https://rvm.io/rubies/installing)

## 2. Installer les bases de données

- PostgreSQL

  Ubuntu : [tutoriel](https://www.digitalocean.com/community/tutorials/how-to-install-postgresql-on-ubuntu-20-04-quickstart)

- Redis

  Ubuntu : [tutoriel](https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-redis-on-ubuntu-20-04)

# 3. Installer les outils de dev

- Yarn : voir https://yarnpkg.com/en/docs/install
- Foreman : voir https://github.com/ddollar/foreman
- graphviz, pour rails-erd : voir https://voormedia.github.io/rails-erd/install.html

## Script d'installation

Une fois les dépendances installées, lancer le script d'installation :

`$ bin/setup`

Pour vérifier que tout fonctionne, lancer le serveur local :

`$ foreman start`

et exécutez la suite de test :

`$ rails db:test:prepare`
`$ rspec`

## Conseil

Ce projet dispose d'un Guardfile, n'hésitez à lancer `$ bundle exec guard` pour voir les tests et le linter s'exécuter automatiquement à chaque sauvegarde de fichier.
