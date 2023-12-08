# Ajout des informations du SRJ dans l'application Mon Suivi Justice

## Introduction

L'insertion des informations du SRJ dans l'application Mon Suivi Justice se fait en trois étapes :

- La génération d'un .csv contenant les informations du SRJ avec les colonnes suivantes "id","postal_code","names","insee_code","ascii_name","name","type". Séparateur : "," et encodage UTF-8. L'objectif est que chaque commune doit être associée à un unique spip et un unique tj.
 
- L'insertion des données de ce .csv dans la base de données de l'application Mon Suivi Justice via la fonctionnalité d'import disponible dans l'interface d'administration.

- La création d'un lien entre les services créés au sens SRJ (qui sont des instances des modèles `SrjTj` et `SrjSpip`) et les services au sens Mon Suivi Justice (qui sont des instances du modèle `Organization`) puis éventuellemnt l'activation de l'inter-ressort au niveau de l'`Organization` (champ `use_inter_ressort` à `true`).

## 1/ Génération du .csv

Pour générer le .csv, il faut disposer des tables `monsuivijustice_structure`, `monsuivijustice_communes`, et `monsuivijustice_communes_structures`. Vous pouvez vous rapprocher d'un membre de l'équipe Mon Suivi Justice pour obtenir ces tables.

### On récupère les communes dont les informations sont correctes : 

On récupère les informations pour les communes qui sont correctement associées à un spip et un tj grâce à la requête suivante (ici un exemple avec Paris, modifiez le code postal au besoin) :

```sql
SELECT c.id, c.postal_code, c.names, c.insee_code, c.ascii_name, s.name, s.type FROM public.monsuivijustice_commune c
INNER JOIN public.monsuivijustice_relation_commune_structure rcs ON rcs.commune_id = c.id
INNER JOIN public.monsuivijustice_structure s ON s.id = rcs.structure_id
WHERE (c.postal_code LIKE '75%') and (s.name LIKE '%Service%' OR s.name LIKE '%Tribunal%')
GROUP BY c.id, s.name, s.type
HAVING count(*) = 1
ORDER BY count(*) DESC
```

On exporte ces informations dans un .csv avec les en-têtes "id","postal_code","names","insee_code","ascii_name","name","type", un séparateur "," et un encodage UTF-8 (avec un logiciel de gestion de base de données par exemple).

### On récupère les commmunes qui sont associés à de trop nombreux spips :

On récupère ensuite les informations pour les communes qui possèdent un nombre anormalement élevé de spips grâce à la requête suivante (On fait un count > 2 car une commune peut avoir un spip et une antenne de spip dans le référentiel, ce qui est normal). Il n'y a pas de requête pour les tj car chaque commune est bien associée à un unique tj quand elle est en possède un.

```sql
SELECT c.id, c.postal_code, c.insee_code, c.ascii_name, string_agg(s.name || '--' || s.id, '|') AS spips_and_alips, count(*) FROM public.monsuivijustice_commune c
INNER JOIN public.monsuivijustice_relation_commune_structure rcs ON rcs.commune_id = c.id
INNER JOIN public.monsuivijustice_structure s ON s.id = rcs.structure_id
WHERE (c.postal_code LIKE '75%' OR c.postal_code LIKE '77%'  OR c.postal_code LIKE '89%' OR c.postal_code LIKE '91%' OR c.postal_code LIKE '93%' OR c.postal_code LIKE '94%') and s.name LIKE '%Service%'
GROUP BY c.id
HAVING count(*) > 2
ORDER BY count(*) DESC
```

On récupère également les informations sur les communes qui ne possèdent pas de services associés grâce à la requête suivante :

```sql
SELECT * FROM monsuivijustice_commune c
LEFT JOIN monsuivijustice_relation_commune_structure rcs ON rcs.commune_id = c.id
WHERE rcs.commune_id IS null AND (c.postal_code LIKE '75%')
```

Les communes listées par ces deux requêtes, si il y en a, doivent être corrigées/complétées par un membre de l'équipe Mon Suivi Justice et donner lieu à la génération d'un .csv ou chaque commune possède un seul spip et un seul tj tel que décrit dans l'introduction.

### On combine les deux .csv générés précédemment :
On combine les informations des deux .csv générés précédemment en un seul .csv contenant toutes les informations du SRJ grâce.

## 2/ Insertion des données du .csv dans la base de données de l'application

Cette étape est réalisée via l'interface d'administration de l'application. Pour cela, il faut se rendre sur la page d'administration des communes du srj (Interface d'aministration > Import Srjs). Il faut ensuite sélectionner le .csv généré précédemment et cliquer sur "Importer". Les données sont alors importées dans la base de données de l'application. Un message d'erreur indique si l'import a échoué ou si certaines communes n'ont pas pu être importées.

Un rapport est envoyé par mail à l'adresse de l'utilisateur qui a effectué l'import.

## 3/ Création des liens entre les services du SRJ et les services de l'application

Pour que l'inter-ressort fonctionne dans l'application. Il faut lier chaque `SrjTj` et chaque `SrjSpip` avec l'`Organization` qui lui correspond. Pour cela on peut se rendre dans l'interface d'administration, dans les listings des `SrjSpips` et des `SrjTjs` et ensuite éditer chacun d'entre eux pour leur associer l'`Organization` qui lui correspond.

Une fois que ceci est fait, il faut activer l'inter-ressort au niveau de l'`Organization` en passant le champ `use_inter_ressort` à `true`.




