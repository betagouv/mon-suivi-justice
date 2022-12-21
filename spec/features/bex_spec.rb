require 'rails_helper'

RSpec.feature 'Bex', type: :feature do
  before do
    @department = create :department
    @organization = create :organization, organization_type: 'tj'
    create :areas_organizations_mapping, organization: @organization, area: @department, area_type: 'Department'
    @bex_user = create(:user, role: :bex, organization: @organization)
    logout_current_user
    login_user(@bex_user)
  end

  describe 'JAP appointments index', js: true do
    it "lists appointments of type Sortie d'audience SAP" do
      convict1 = create(:convict, first_name: 'James', last_name: 'Moriarty')
      convict2 = create(:convict, first_name: 'Lex', last_name: 'Luthor')
      convict3 = create(:convict, first_name: 'Pat', last_name: 'Hibulaire')
      convict4 = create(:convict, first_name: 'Darth', last_name: 'Vador')

      create :areas_convicts_mapping, convict: convict1, area: @department
      create :areas_convicts_mapping, convict: convict2, area: @department
      create :areas_convicts_mapping, convict: convict3, area: @department
      create :areas_convicts_mapping, convict: convict4, area: @department

      apt_type = create(:appointment_type, name: "Sortie d'audience SAP")
      apt_type2 = create(:appointment_type, name: 'RDV de suivi JAP')

      place = create(:place, name: 'Tribunal de Nanterre', organization: @organization)

      create(:place_appointment_type, place: place, appointment_type: apt_type)
      create(:place_appointment_type, place: place, appointment_type: apt_type2)

      agenda1 = create(:agenda, place: place, name: 'Cabinet Bleu')
      agenda2 = create(:agenda, place: place, name: 'Cabinet Rouge')
      agenda3 = create(:agenda, place: place, name: 'Cabinet Jaune')

      slot1 = create(:slot, :without_validations, agenda: agenda1,
                                                  appointment_type: apt_type,
                                                  date: Date.today.next_occurring(:friday),
                                                  starting_time: '10h')

      slot2 = create(:slot, :without_validations, agenda: agenda2,
                                                  appointment_type: apt_type,
                                                  date: Date.today.next_occurring(:friday),
                                                  starting_time: '17h',
                                                  capacity: 2)

      slot3 = create(:slot, :without_validations, agenda: agenda2,
                                                  appointment_type: apt_type2,
                                                  date: Date.today.next_occurring(:friday),
                                                  starting_time: '12h',
                                                  capacity: 2)

      slot4 = create(:slot, :without_validations, agenda: agenda3,
                                                  appointment_type: apt_type2,
                                                  date: Date.today.next_occurring(:friday),
                                                  starting_time: '12h',
                                                  capacity: 2)


      current_date = (I18n.l slot1.date, format: '%A %d').capitalize

      create(:appointment, slot: slot1, convict: convict1, prosecutor_number: '203204', inviter_user_id: @bex_user.id)
      create(:appointment, slot: slot2, convict: convict2, prosecutor_number: '205206', inviter_user_id: @bex_user.id)
      create(:appointment, slot: slot2, convict: convict3, prosecutor_number: '205806', inviter_user_id: @bex_user.id)
      create(:appointment, slot: slot3, convict: convict4, prosecutor_number: '205896', inviter_user_id: @bex_user.id)
      create(:appointment, slot: slot4, convict: convict2, prosecutor_number: '205206', inviter_user_id: @bex_user.id)

      visit agenda_jap_path

      select current_date, from: :date

      expect(page).to have_current_path(agenda_jap_path())

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
      expect(page).not_to have_content('Cabinet Jaune')
    end

    it 'allows user to mark a case as prepared', js: true do
      convict = create(:convict, first_name: 'Julius', last_name: 'Erving')
      create :areas_convicts_mapping, convict: convict, area: @department
      apt_type = create(:appointment_type, name: "Sortie d'audience SAP")
      place = create(:place, name: 'SPIP 91', organization: @organization)
      agenda = create(:agenda, place: place, name: 'Agenda SPIP 91')

      slot = create(:slot, :without_validations, agenda: agenda,
                                                 appointment_type: apt_type,
                                                 date: Date.today.next_occurring(:tuesday))

      appointment = create(:appointment, slot: slot, convict: convict, inviter_user_id: @bex_user.id)
      current_date = slot.date.strftime('%d/%m/%Y')

      visit agenda_jap_path

      select current_date, from: :date
      page.execute_script("$('#jap-appointments-date-select').trigger('change')")

      expect(appointment.case_prepared).to eq(false)

      check "case-prepared-#{appointment.id}"

      visit home_path
      appointment.reload

      expect(appointment.case_prepared).to eq(true)
    end
  end

  describe 'Spip appointment index' do
    let!(:frozen_time) { Time.zone.parse('2021-08-01 10:00:00').to_date }

    before do
      zone = ActiveSupport::TimeZone.new('Paris')
      allow(zone).to receive(:today).and_return(frozen_time)
      allow(Time).to receive(:zone).and_return(zone)
    end

    it "lists all Spip appointments of type Sortie d'audience SPIP", js: true do
      convict1 = create(:convict, first_name: 'Julius', last_name: 'Erving')
      convict2 = create(:convict, first_name: 'Moses', last_name: 'Malone')
      convict3 = create(:convict, first_name: 'Darius', last_name: 'Garland')
      convict4 = create(:convict, first_name: 'Magic', last_name: 'Johnson')

      create :areas_convicts_mapping, convict: convict1, area: @department
      create :areas_convicts_mapping, convict: convict2, area: @department

      apt_type = create(:appointment_type, name: "Sortie d'audience SPIP")
      apt_type2 = create(:appointment_type, name: 'RDV de suivi SPIP')

      place = create(:place, name: 'SPIP 91', organization: @organization)

      create(:place_appointment_type, place: place, appointment_type: apt_type)

      agenda = create(:agenda, place: place, name: 'Agenda SPIP 91')

      slot1 = create(:slot, :without_validations, agenda: agenda,
                                                  appointment_type: apt_type,
                                                  date: Time.zone.today.next_occurring(:tuesday),
                                                  starting_time: '8h',
                                                  capacity: 2)

      slot2 = create(:slot, :without_validations, agenda: agenda,
                                                  appointment_type: apt_type,
                                                  date: Time.zone.today.next_occurring(:friday) + 1.month,
                                                  starting_time: '15h')

      slot3 = create(:slot, :without_validations, agenda: agenda,
                                                  appointment_type: apt_type2,
                                                  date: Time.zone.today.next_occurring(:tuesday),
                                                  starting_time: '15h')

      current_month_label = (I18n.l slot1.date, format: '%B %Y').capitalize
      next_month_label = (I18n.l slot2.date, format: '%B %Y').capitalize

      create(:appointment, slot: slot1, convict: convict1, prosecutor_number: '203205')
      create(:appointment, slot: slot2, convict: convict2, prosecutor_number: '205201')
      create(:appointment, slot: slot1, convict: convict3, prosecutor_number: '205202')
      create(:appointment, slot: slot3, convict: convict4, prosecutor_number: '205282')

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

  describe 'SAP DDSE appointments index', js: true do
    it 'lists appointments of type SAP DDSE' do
      @organization.update(organization_type: 'spip')
      convict1 = create(:convict, first_name: 'James', last_name: 'Moriarty')
      convict2 = create(:convict, first_name: 'Lex', last_name: 'Luthor')
      convict3 = create(:convict, first_name: 'Pat', last_name: 'Hibulaire')

      create :areas_convicts_mapping, convict: convict1, area: @department
      create :areas_convicts_mapping, convict: convict2, area: @department
      create :areas_convicts_mapping, convict: convict3, area: @department

      apt_type = create(:appointment_type, name: 'SAP DDSE')
      apt_type2 = create(:appointment_type, name: 'RDV de suivi JAP')

      place = create(:place, name: 'Tribunal de Nanterre', organization: @organization)

      agenda1 = create(:agenda, place: place, name: 'Cabinet Bleu')
      agenda2 = create(:agenda, place: place, name: 'Cabinet Rouge')
      agenda3 = create(:agenda, place: place, name: 'Cabinet Jaune')

      slot1 = create(:slot, :without_validations, agenda: agenda1,
                                                  appointment_type: apt_type,
                                                  date: Date.today.next_occurring(:friday),
                                                  starting_time: '10h')

      slot2 = create(:slot, :without_validations, agenda: agenda2,
                                                  appointment_type: apt_type,
                                                  date: Date.today.next_occurring(:friday),
                                                  starting_time: '17h',
                                                  capacity: 2)

      slot3 = create(:slot, :without_validations, agenda: agenda3,
                                                  appointment_type: apt_type2,
                                                  date: Date.today.next_occurring(:friday),
                                                  starting_time: '12h',
                                                  capacity: 2)

      current_date = slot1.date.strftime('%d/%m/%Y')

      create(:appointment, slot: slot1, convict: convict1, prosecutor_number: '203204', inviter_user_id: @bex_user.id)
      create(:appointment, slot: slot2, convict: convict2, prosecutor_number: '205206', inviter_user_id: @bex_user.id)
      create(:appointment, slot: slot3, convict: convict3, prosecutor_number: '205806', inviter_user_id: @bex_user.id)

      visit agenda_sap_ddse_path
      select current_date, from: :date
      page.execute_script("$('#jap-appointments-date-select').trigger('change')")

      expect(page).to have_current_path(agenda_sap_ddse_path(date: current_date))

      agenda_containers = page.all('.bex-agenda-container', minimum: 2)

      expect(agenda_containers[0]).to have_content('Cabinet Bleu')
      expect(agenda_containers[0]).to have_content('James')
      expect(agenda_containers[0]).to have_content('MORIARTY')
      expect(agenda_containers[0]).to have_content('203204')

      expect(agenda_containers[1]).to have_content('Cabinet Rouge')
      expect(agenda_containers[1]).to have_content('Lex')
      expect(agenda_containers[1]).to have_content('LUTHOR')
      expect(agenda_containers[1]).to have_content('205206')

      expect(page).not_to have_content('Pat')
      expect(page).not_to have_content('HIBULAIRE')
      expect(page).not_to have_content('Cabinet Jaune')
    end
  end
end
