# Fusionner des agendas

Tout se fait via la console rails
`./cli console_prod`

```ruby
to_delete = Agenda.find(id_de_lagenda_a_supprimer)
to_keep = Agenda.find(id_de_lagenda_a_garder)

# on récupère les créneaux futurs
slots_to_move = to_delete.slots.where(date: Date.tomorrow..)

# on met a jour l'agenda associé
slots_to_move.update_all(agenda_id: to_keep.id)

# on vérifie également les créneaux récurents si besoin (a voir avec le support)
slot_types_to_move = to_delete.slot_types

slot_types_to_move.update_all(agenda_id: to_keep.id)

# on archive l'agenda obsolete
to_delete.discard
```