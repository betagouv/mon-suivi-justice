# Obtenir des infos sur l'utilisation de MSJ avec Ahoy et Papertrail

Le ministère et la CNIL exige une traçabilité des actions des agents sur MSJ. Le référent CNIL du ministère, Thomas Durantet, a définit le besoin en ces termes :

> "Tracer les opérations de modification et consultation de tous les utilisateurs, les opérations doivent être horodatées et on doit pouvoir retrouver les fonctions de la personne qui consulte/modifie les données. Conservation des enregistrements pendant un an et suppression automatique."

Pour plus de détails, voir ce [ticket Trello](https://trello.com/c/4KqRpzET/1225-faire-%C3%A9voluer-la-journalisation-pour-laipd).

On peut répondre à cette demande dans MSJ avec deux librairires : [Ahoy](https://github.com/ankane/ahoy) et [Paperclip](https://github.com/paper-trail-gem/paper_trail).

Les deux README sont très complets et contiennent toutes les commandes nécessaires.

## Exemple

On cherche l'activité d'un agent sur la journée en cours. Avec l'objet events de Ahoy, on peut lister toutes les actions avec la commande suivante :

```
events = Ahoy::Event.where(user_id: 76).where(time: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
```

On peut ensuite explorer ces events, par exemple avec `pp events.pluck(:properties, :time)` pour lister toutes les actions et leurs timestamps.

Ahoy ne donne pas toutes les informations, par exemple on peut voir qu'un agent a modifié les données d'une PPSMJ, mais pour avoir les changements exacts il faut utiliser Papertrail.

```
c = Convict.find(98)
pp c.versions.last(3)
```

Cet exemple sort les trois dernières versions d'une PPSMJ données, avec toutes les modifications et les timestamps.
