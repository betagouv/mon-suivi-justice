# Déployer un nouveau service

Process à suivre pour déployer Mon Suivi Justice dans un nouveau service. Lors du déploiement dans un nouveau département, il faut suivre cette procédure pour chaque service, pour le SPIP et pour le SAP par exemple.

## 1. Créer le service

-> Onglet Services, cliquer sur Nouveau service.

À cette étape, il suffit de choisir le nom.

Il faut ensuite relier ce service à un département.

-> Onglet services, choisir le bon service, cliquer sur modifier

En bas de la page, dans la section "Département(s) rattaché(s)", choisir le bon département et cliquer sur Ajouter.

Il faut également relier le service à une juridiction. Suivre le meme fonctionnement que pour les départements.

## 2. Créer les comptes des agents

Données nécessaires pour chaque agent :

- Nom, Prénom
- Email professionnel
- Niveau d'habilitation
- Service

Le niveau d'habilitation est à choisir dans la liste suivante :

- Administrateur central
- Administrateur local
- Magistrat du parquet
- JAP
- Secrétariat commun
- Secrétariat SPIP
- Directeur de greffe BEX
- Agent BEX
- Greffe correctionnel
- Directeur de greffe SAP
- Greffe SAP
- DPIP
- CPIP
- Educateur
- Psychologue
- Surveillant

Pour ajouter de nouveaux agents il existe deux options :

### Créer le profil dans l'interface

-> Onglet agents, cliquer sur nouvel agent.

Il faut alors choisir le service et le niveau d'habilitation dans les menus déroulants.

### Créer les profils en masse

Pour ça il faut transmettre un fichier excel aux développeurs avec les bonnes données. Voir avec eux pour le format du fichier.

Dans les deux cas, les agents reçevront un mail qui les invitera à choisir un mot de passe.

## 3. Création des lieux

Cela correspond aux différents lieux de convocation, ils sont donc différents des services. Par exemple, une permanence délocalisée dans le 92 est un lieu de convocation spécifique, rattaché au service SPIP 92. Il est important de bien comprendre qu'il y a deux objets "SPIP 92", un service "SPIP 92" et un lieu de convocation "SPIP 92". Pour déployer MSJ dans un nouveau SPIP, il faut bien créer les deux.

-> Onglet lieux, cliquer sur nouveau lieu.

Données nécessaires :

- Nom du lieu de convocation
- Adresse
- Numéro de téléphone. Numéro de l'accueil, ou numéro à contacter en cas de pb.
- Service
- Types de convocations possibles (à cocher dans une liste)

Note : Si le service pratique des convocations de type "RDV téléphonique" ou "Visite à domicile", il faut créer un lieu de convocation "Domicile du probationnaire" pour faire fonctionner ces types de convocation. Voir sur la production pour des exemples, le SPIP 92 dipose d'un lieu "Domicile du probationnaire".

La création du lieu de convocation entraine la création d'un premier agenda standard. Si le fonctionnement du service exige de multiples agendas (comme le SAP de Nanterre et sa gestion par cabinets), il faut aller créer ces agendas sur la page du lieu.

-> Onglet lieux, choisir le bon lieu, cliquer sur modifier, colonne agendas, saisir le nom, cliquer sur ajouter agenda

## 4. Création des créneaux récurrents

Dans MSJ, il y a deux principes différents mais faciles à confondre : les créneaux et les créneaux récurrents.

- Créneau : Un emplacement disponible dans un agenda pour convoquer. Exemple : Le mardi 4 juin 2022 à 11h dans l'agenda du cabinet 1 du SAP de Nanterre.
- Créneau récurrent : Un emplacement qui est disponible toutes les semaines. Exemple : Le mardi à 11h dans l'agenda du cabinet 1 du SAP de Nanterre.

Dans MSJ, des créneaux sont créés automatiquement à partir des créneaux récurrents. Tout ce fonctionnement n'est utilisé que pour les convocations sortie d'audience (SPIP ou SAP). Il est également possible de créer des créneaux directement, si il ne sont pas récurrents.

Lors de la création d'un nouveau service, si il accueille des convocations de sortie d'audience, il faut donc définir sur quels créneaux ces convocations sont possibles.

-> Onglet lieux, choisir le bon lieu, cliquer sur modifier, colonne agendas, cliquer sur créneaux récurrents

Sur cette page on peut ajouter des créneaux récurrents, soit un par un, en cliquant sur Ajouter dans l'encadré de la bonne journée, soit en masse, en utilisant l'outil en haut de la page.

L'ajout de nouveaux créneaux récurrents sur cette page entraine la création de créneaux pour 6 mois, et le script est lancé chaque nuit à minuit. Les nouveaux créneaux sont donc disponibles le matin suivant la création des créneaux récurrents.

Quand un créneau récurrent est supprimé, les créneaux liés sont supprimés immédiatement.

## 5. Tester le nouveau service

Une fois toute la procédure executée, on peut se connecter avec un compte de test au nouveau service, puis créer des probationnaires et créer des convocations pour vérifier que tout fonctionne.
