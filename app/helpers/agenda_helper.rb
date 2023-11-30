module AgendaHelper
  def agendas_options_for_select(agendas)
    agendas.map do |agenda|
      label = agenda.discarded_at ? "#{agenda.name} (Archivé)" : agenda.name
      [label, agenda.id]
    end
  end
end
