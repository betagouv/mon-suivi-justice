# Créer les comptes des agents d'un nouveau service

Lors du déploiement de MSJ dans un nouveau service, il faut créer les comptes des agents de tout le service, en général la veille du déploiement.

Les données nécessaires arrivent sous la forme d'un fichier excel, qu'il faut enregistrer en format CSV pour le script.

Le format attendu du fichier CSV est le suivant :

```
LAST_NAME,FIRST_NAME,ROLE,PHONE,ORGANIZATION,EMAIL
Dupont,Jean-Louis,local_admin,,SPIP 49,jeanlouis.dupont@justice.fr
Leblanc,Marc,dpip,,SPIP 49,marc.leblanc@justice.fr
Duflot,Celine,cpip,04 00 00 00 00,SPIP 49,celine.duflot@justice.fr
```

La colonne PHONE est optionnelle. Les roles doivent etre représentés par les clés de l'enum roles du modèles agent (ex: "local_admin" et pas "administrateur local").

Une fois le CSV récupéré et formatté, on peut l'utiliser dans un conteneur one-off de Scalingo de la façon suivante :  

```
$ scalingo --app mon-suivi-justice-prod --region osc-secnum-fr1 run -f ./agents_SPIP93.csv bash
```

La commande précédente lance un shell bash dans un conteneur one-off, et charge le CSV dans le dossier `tmp/uploads`. On peut donc l'utiliser pour la tache rake `invite_agents` :

```
$ rake 'invite_agents[/tmp/uploads/agents_SPIP93.csv]'
```

Cette tache rake crée les comptes des agents et leur envoie un mail d'invitation, qui leur permet de choisir leur mot de passe.

Si jamais le mail n'arrive pas, les chargés de déploiement peuvent retrouver le lien d'activation sur la page de profil de l'agent crée.
