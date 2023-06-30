require 'rails_helper'

RSpec.feature 'Bex', type: :feature do
  # before do
  #   @department = create :department
  #   @organization = create :organization, organization_type: 'tj'
  #   create :areas_organizations_mapping, organization: @organization, area: @department, area_type: 'Department'
  #   @local_admin = create(:user, role: :local_admin, organization: @organization)
  #   logout_current_user
  #   login_user(@local_admin)
  # end

  describe 'JAP appointments index', logged_in_as: 'local_admin', js: true do
    it "lists appointments of type Sortie d'audience SAP" do
      convict1 = create(:convict, first_name: 'James', last_name: 'Moriarty', organizations: [@user.organization])
      convict2 = create(:convict, first_name: 'Lex', last_name: 'Luthor', organizations: [@user.organization])
      convict3 = create(:convict, first_name: 'Pat', last_name: 'Hibulaire', organizations: [@user.organization])
      convict4 = create(:convict, first_name: 'Darth', last_name: 'Vador', organizations: [@user.organization])

      apt_type = create(:appointment_type, name: "Sortie d'audience SAP")
      apt_type2 = create(:appointment_type, name: 'Convocation de suivi JAP')

      place = create(:place, name: 'Tribunal de Nanterre', organization: @user.organization)

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

      month = (I18n.l slot1.date, format: '%B %Y').capitalize
      current_date = (I18n.l slot1.date, format: '%A %d').capitalize

      create(:appointment, slot: slot1, convict: convict1, prosecutor_number: '203204',
                           inviter_user_id: @user.id)
      create(:appointment, slot: slot2, convict: convict2, prosecutor_number: '205206',
                           inviter_user_id: @user.id)
      create(:appointment, slot: slot2, convict: convict3, prosecutor_number: '205806',
                           inviter_user_id: @user.id)
      create(:appointment, slot: slot3, convict: convict4, prosecutor_number: '205896',
                           inviter_user_id: @user.id)
      create(:appointment, slot: slot4, convict: convict2, prosecutor_number: '205206',
                           inviter_user_id: @user.id)

      visit agenda_jap_path

      select month, from: :month
      select current_date, from: :date

      expect(page).to have_current_path(agenda_jap_path)

      agenda_containers = page.all('.fr-table', minimum: 2)

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
  end

  describe 'Spip appointment index', logged_in_as: 'local_admin' do
    let!(:frozen_time) { Time.zone.parse('2021-08-01 10:00:00').to_date }

    before do
      zone = ActiveSupport::TimeZone.new('Paris')
      allow(zone).to receive(:today).and_return(frozen_time)
      allow(Time).to receive(:zone).and_return(zone)
    end

    it "lists all Spip appointments of type Sortie d'audience SPIP", js: true do
      convict1 = create(:convict, first_name: 'Julius', last_name: 'Erving', organizations: [@user.organization])
      convict2 = create(:convict, first_name: 'Moses', last_name: 'Malone', organizations: [@user.organization])
      convict3 = create(:convict, first_name: 'Darius', last_name: 'Garland', organizations: [@user.organization])
      convict4 = create(:convict, first_name: 'Magic', last_name: 'Johnson', organizations: [@user.organization])

      apt_type = create(:appointment_type, name: "Sortie d'audience SPIP")
      apt_type2 = create(:appointment_type, name: 'Convocation de suivi SPIP')

      place = create(:place, name: 'SPIP 91', organization: @user.organization)

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

  describe 'SAP DDSE appointments index', logged_in_as: 'local_admin', js: true do
    it 'lists appointments of type SAP DDSE' do
      @user.organization.update(organization_type: 'spip')
      convict1 = create(:convict, first_name: 'James', last_name: 'Moriarty', organizations: [@user.organization])
      convict2 = create(:convict, first_name: 'Lex', last_name: 'Luthor', organizations: [@user.organization])
      convict3 = create(:convict, first_name: 'Pat', last_name: 'Hibulaire', organizations: [@user.organization])

      apt_type = create(:appointment_type, name: 'SAP DDSE')
      apt_type2 = create(:appointment_type, name: 'Convocation de suivi JAP')

      place = create(:place, name: 'Tribunal de Nanterre', organization: @user.organization)

      create(:place_appointment_type, place: place, appointment_type: apt_type)

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

      current_month_label = (I18n.l slot1.date, format: '%B %Y').capitalize

      create(:appointment, slot: slot1, convict: convict1, prosecutor_number: '203204',
                           inviter_user_id: @user.id)
      create(:appointment, slot: slot2, convict: convict2, prosecutor_number: '205206',
                           inviter_user_id: @user.id)
      create(:appointment, slot: slot3, convict: convict3, prosecutor_number: '205806',
                           inviter_user_id: @user.id)

      visit agenda_sap_ddse_path
      select current_month_label, from: :date

      agenda_containers = page.all('.agenda-jap-table', minimum: 1)

      expect(agenda_containers[0]).to have_content('James')
      expect(agenda_containers[0]).to have_content('MORIARTY')
      expect(agenda_containers[0]).to have_content('203204')

      expect(page).not_to have_content('Lex')
      expect(page).not_to have_content('LUTHOR')
      expect(page).not_to have_content('205206')

      expect(page).not_to have_content('Pat')
      expect(page).not_to have_content('HIBULAIRE')
      expect(page).not_to have_content('Cabinet Jaune')

      select agenda2.name, from: :agenda_id

      agenda_containers = page.all('.agenda-jap-table', minimum: 1)

      expect(agenda_containers[0]).to have_content('Lex')
      expect(agenda_containers[0]).to have_content('LUTHOR')
      expect(agenda_containers[0]).to have_content('205206')

      expect(page).not_to have_content('Pat')
      expect(page).not_to have_content('HIBULAIRE')
    end
  end
end
