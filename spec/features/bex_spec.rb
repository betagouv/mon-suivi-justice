require 'rails_helper'

RSpec.feature 'Bex', type: :feature do
  before do
    @department = create :department
    @organization = create :organization
    create :areas_organizations_mapping, organization: @organization, area: @department
    bex_user = create(:user, role: :bex, organization: @organization)
    logout_current_user
    login_user(bex_user)
  end

  describe 'JAP appointments index', js: true do
    it "lists appointments of type Sortie d'audience SAP" do
      convict1 = create(:convict, first_name: 'James',
                                  last_name: 'Moriarty',
                                  prosecutor_number: '203204')

      convict2 = create(:convict, first_name: 'Lex',
                                  last_name: 'Luthor',
                                  prosecutor_number: '205206')

      convict3 = create(:convict, first_name: 'Pat',
                                  last_name: 'Hibulaire',
                                  prosecutor_number: '205806')

      convict4 = create(:convict, first_name: 'Darth',
                                  last_name: 'Vador',
                                  prosecutor_number: '205896')

      create :areas_convicts_mapping, convict: convict1, area: @department
      create :areas_convicts_mapping, convict: convict2, area: @department

      apt_type = create(:appointment_type, name: "Sortie d'audience SAP")
      apt_type2 = create(:appointment_type, name: 'RDV de suivi SAP')

      place = create(:place, name: 'Tribunal de Nanterre', organization: @organization)

      agenda1 = create(:agenda, place: place, name: 'Cabinet Bleu')
      agenda2 = create(:agenda, place: place, name: 'Cabinet Rouge')

      slot1 = create(:slot, agenda: agenda1,
                            appointment_type: apt_type,
                            date: Date.today.next_occurring(:friday),
                            starting_time: '10h')

      slot2 = create(:slot, agenda: agenda2,
                            appointment_type: apt_type,
                            date: Date.today.next_occurring(:friday),
                            starting_time: '17h',
                            capacity: 2)

      slot3 = create(:slot, agenda: agenda2,
                            appointment_type: apt_type2,
                            date: Date.today.next_occurring(:friday),
                            starting_time: '12h',
                            capacity: 2)

      current_date = slot1.date.strftime('%d/%m/%Y')

      create(:appointment, slot: slot1, convict: convict1)
      create(:appointment, slot: slot2, convict: convict2)
      create(:appointment, slot: slot2, convict: convict3)
      create(:appointment, slot: slot3, convict: convict4)

      visit agenda_jap_path
      select current_date, from: :date
      page.execute_script("$('#jap-appointments-date-select').trigger('change')")

      expect(page).to have_current_path(agenda_jap_path(date: current_date))

      agenda_containers = page.all('.bex-agenda-container', minimum: 2)

      expect(agenda_containers[0]).to have_content('Cabinet Bleu')
      expect(agenda_containers[0]).to have_content('James')
      expect(agenda_containers[0]).to have_content('MORIARTY')
      expect(agenda_containers[0]).to have_content('203204')

      expect(agenda_containers[1]).to have_content('Cabinet Rouge')
      expect(agenda_containers[1]).to have_content('Lex')
      expect(agenda_containers[1]).to have_content('LUTHOR')
      expect(agenda_containers[1]).to have_content('205206')

      expect(agenda_containers[1]).to have_content('Pat')
      expect(agenda_containers[1]).to have_content('HIBULAIRE')
      expect(agenda_containers[1]).to have_content('205806')

      expect(page).not_to have_content('Darth')
      expect(page).not_to have_content('Vador')
    end
  end

  describe 'Spip appointment index' do
    let(:frozen_time) { Time.zone.parse('2021-08-01 10:00:00').to_date }

    it "lists all Spip appointments of type Sortie d'audience SPIP", js: true do
      allow(Date).to receive(:today).and_return frozen_time
      convict1 = create(:convict, first_name: 'Julius',
                                  last_name: 'Erving',
                                  prosecutor_number: '203205')

      convict2 = create(:convict, first_name: 'Moses',
                                  last_name: 'Malone',
                                  prosecutor_number: '205201')

      convict3 = create(:convict, first_name: 'Darius',
                                  last_name: 'Garland',
                                  prosecutor_number: '205202')

      convict4 = create(:convict, first_name: 'Magic',
                                  last_name: 'Johnson',
                                  prosecutor_number: '205282')

      create :areas_convicts_mapping, convict: convict1, area: @department
      create :areas_convicts_mapping, convict: convict2, area: @department

      apt_type = create(:appointment_type, name: "Sortie d'audience SPIP")
      apt_type2 = create(:appointment_type, name: 'RDV de suivi SPIP')

      place = create(:place, name: 'SPIP 91', organization: @organization)

      agenda = create(:agenda, place: place, name: 'Agenda SPIP 91')

      slot1 = create(:slot, agenda: agenda,
                            appointment_type: apt_type,
                            date: Date.today.next_occurring(:tuesday),
                            starting_time: '8h',
                            capacity: 2)

      slot2 = create(:slot, agenda: agenda,
                            appointment_type: apt_type,
                            date: Date.today.next_occurring(:friday) + 1.month,
                            starting_time: '15h')

      slot3 = create(:slot, agenda: agenda,
                            appointment_type: apt_type2,
                            date: Date.today.next_occurring(:tuesday),
                            starting_time: '15h')

      current_month_label = (I18n.l slot1.date, format: '%B %Y').capitalize
      next_month_label = (I18n.l slot2.date, format: '%B %Y').capitalize

      create(:appointment, slot: slot1, convict: convict1)
      create(:appointment, slot: slot2, convict: convict2)
      create(:appointment, slot: slot1, convict: convict3)
      create(:appointment, slot: slot3, convict: convict4)

      visit agenda_spip_path
      select current_month_label, from: :date
      page.execute_script("$('#spip-appointments-month-select').trigger('change')")

      expect(page).to have_content('Julius')
      expect(page).to have_content('ERVING')
      expect(page).to have_content('203205')

      expect(page).to have_content('Darius')
      expect(page).to have_content('GARLAND')
      expect(page).to have_content('205202')

      expect(page).not_to have_content('Magic')
      expect(page).not_to have_content('Johnson')
      expect(page).not_to have_content('205282')

      select next_month_label, from: :date
      page.execute_script("$('#spip-appointments-month-select').trigger('change')")

      expect(page).not_to have_content('Julius')
      expect(page).not_to have_content('ERVING')
      expect(page).not_to have_content('203205')

      expect(page).to have_content('Moses')
      expect(page).to have_content('MALONE')
      expect(page).to have_content('205201')

      expect(page).not_to have_content('Magic')
      expect(page).not_to have_content('Johnson')
      expect(page).not_to have_content('205282')
    end
  end
end
