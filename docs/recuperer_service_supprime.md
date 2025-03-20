# Récupérer un service supprimé

## Étape 1 : Récupérer un dump de production

Accéder au dump de production via le dashboard Scalingo :
- URL : https://dashboard.scalingo.com/apps/osc-secnum-fr1/mon-suivi-justice-prod
- Aller dans la section "addon postgresql"

## Étape 2 : Créer une nouvelle base de données

Créer une nouvelle base de données locale (via TablePlus ou un autre outil de gestion de base de données).

## Étape 3 : Créer le rôle correspondant

Créer le rôle correspondant à la base de données de production dans PostgreSQL :

1. Se connecter à PostgreSQL :
   ```
   psql
   ```

2. Créer le rôle avec les privilèges nécessaires :
   ```
   CREATE ROLE new_superuser_role WITH SUPERUSER LOGIN PASSWORD 'new_password';
   ```

3. Vérifier la bonne création du rôle :
   ```
   \du
   ```

![Capture d'écran des rôles PostgreSQL](https://prod-files-secure.s3.us-west-2.amazonaws.com/295c7149-5809-465e-bc72-63513bc588e8/5d961945-69e4-44e6-9029-5f5adc4975c1/Untitled.png)

## Étape 4 : Décompresser l'archive du dump

Décompresser l'archive du dump téléchargée pour obtenir un fichier au format .pgsql :

## Étape 5 : Charger le dump en local

Utiliser la commande `pg_restore` pour charger le dump dans la base de données locale :
`pg_restore -e -d backup 20240301133704_mon_suivi_j_9909.pgsql`

`-d` correspond au nom de la db créée precedemment

`-e` permet au script de s’arreter en cas d’erreur, ce qui aide au debug

## Étape 6 : Récupérer les données souhaitées au format CSV

Exécuter les commandes suivantes pour extraire les données du service supprimé (remplacer l'ID 207 par l'ID du service concerné) :

```jsx
psql -d backup -c "COPY (SELECT * FROM organizations WHERE id = 207) TO '/Users/matthieufaugere/backup/organizations.csv' WITH CSV HEADER;"
psql -d backup -c "COPY (SELECT * FROM places WHERE organization_id = 207) TO '/Users/matthieufaugere/backup/places.csv' WITH CSV HEADER;"
psql -d backup -c "COPY (SELECT * FROM agendas WHERE place_id IN (SELECT id FROM places WHERE organization_id = 207)) TO '/Users/matthieufaugere/backup/agendas.csv' WITH CSV HEADER;"
psql -d backup -c "COPY (SELECT * FROM slots WHERE agenda_id IN (SELECT id FROM agendas WHERE place_id IN (SELECT id FROM places WHERE organization_id = 207))) TO '/Users/matthieufaugere/backup/slots.csv' WITH CSV HEADER;"
psql -d backup -c "COPY (SELECT * FROM appointments WHERE slot_id IN (SELECT id FROM slots WHERE agenda_id IN (SELECT id FROM agendas WHERE place_id IN (SELECT id FROM places WHERE organization_id = 207)))) TO '/Users/matthieufaugere/backup/appointments.csv' WITH CSV HEADER;"
psql -d backup -c "COPY (SELECT * FROM users WHERE organization_id = 207) TO '/Users/matthieufaugere/backup/users.csv' WITH CSV HEADER;"
psql -d backup -c "COPY (SELECT pat.* FROM place_appointment_types pat JOIN places p ON pat.place_id = p.id WHERE p.organization_id = 207) TO '/Users/matthieufaugere/backup/place_appointment_types.csv' WITH CSV HEADER;"
psql -d backup -c "COPY (SELECT st.* FROM slot_types st JOIN agendas ag ON st.agenda_id = ag.id JOIN places p ON ag.place_id = p.id WHERE p.organization_id = 207) TO '/Users/matthieufaugere/backup/slot_types.csv' WITH CSV HEADER;"
psql -d backup -c "COPY (SELECT * FROM convicts_organizations_mappings WHERE organization_id = 207) TO '/Users/matthieufaugere/backup/convict_organization_mapping.csv' WITH CSV HEADER;"
psql -d backup -c "COPY (SELECT * FROM notification_types WHERE organization_id = 207) TO '/Users/matthieufaugere/backup/notification_types.csv' WITH CSV HEADER;"
psql -d backup -c "COPY (SELECT hi.* FROM history_items hi JOIN appointments a ON hi.appointment_id = a.id JOIN slots s ON a.slot_id = s.id JOIN agendas ag ON s.agenda_id = ag.id JOIN places p ON ag.place_id = p.id WHERE p.organization_id = 207) TO '/Users/matthieufaugere/backup/history_items.csv' WITH CSV HEADER;"
psql -d backup -c "COPY (SELECT n.* FROM notifications n JOIN appointments a ON n.appointment_id = a.id JOIN slots s ON a.slot_id = s.id JOIN agendas ag ON s.agenda_id = ag.id JOIN places p ON ag.place_id = p.id WHERE p.organization_id = 207) TO '/Users/matthieufaugere/backup/notifications.csv' WITH CSV HEADER;"
```

## Étape 7 : Importer les données CSV dans les tables associées

Utiliser un outil comme TablePlus ou un autre outil de gestion de base de données pour importer les fichiers CSV dans les tables correspondantes de votre base de données.

![Interface d'importation TablePlus](https://prod-files-secure.s3.us-west-2.amazonaws.com/295c7149-5809-465e-bc72-63513bc588e8/4debbbfe-68fc-463d-a552-36c2cfb9f0f7/Untitled.png)

## Bonus : Récupérer des informations sur les rendez-vous via PaperTrail::Version

Pour obtenir des informations supplémentaires sur les rendez-vous créés dans le service supprimé, vous pouvez utiliser PaperTrail::Version avec la requête SQL suivante (qui prend longtemps à tourner) :

```jsx
SELECT
	versions.*
FROM
	versions
WHERE
	versions.item_type = 'Appointment'
	AND versions.event = 'create'
	AND(object_changes -> 'creating_organization_id' @> '[207]')
	AND(created_at > '2024-03-01 14:00:00')
```