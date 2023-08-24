require 'rails_helper'

RSpec.describe AgendaHelper, type: :helper do
  describe '#agendas_options_for_select' do
    let(:organization) { create(:organization) }
    let(:place) { create(:place, organization:) }
    let(:user) { create(:user, organization:) }

    before do
      @active_agenda = create(:agenda, place:, name: 'Active Agenda', discarded_at: nil)
      @archived_agenda = create(:agenda, place:, name: 'Archived Agenda', discarded_at: Time.now)
    end

    it 'returns formatted options for select' do
      options = helper.agendas_options_for_select(user)

      expect(options).to include(['Active Agenda', @active_agenda.id])
      expect(options).to include(['Archived Agenda (Archivé)', @archived_agenda.id])
    end
  end
end
