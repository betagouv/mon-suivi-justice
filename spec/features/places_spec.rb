require 'rails_helper'

RSpec.feature 'Places', type: :feature do
  describe 'index', logged_in_as: 'admin' do
    before do
      @place1 = create(:place, name: 'Spip 78', organization: @user.organization)
      @place2 = create(:place, name: 'Spip 83', organization: @user.organization)

      visit places_path
    end

    it 'lists all places' do
      expect(page).to have_content('Spip 78')
      expect(page).to have_content('Spip 83')
    end

    it 'allows to archive a place' do
      first('tbody > tr').click_link('Archiver')
      expect(@place1.reload.discarded?).to eq(true)
    end
  end

  describe 'creation', logged_in_as: 'local_admin' do
    it 'creates a place and its first agenda' do
      create(:appointment_type, name: 'Premier contact Spip')

      visit new_place_path

      fill_in 'Nom', with: 'Spip 72'
      fill_in 'Adresse', with: '93 rue des charmes 72200 La Flèche'
      fill_in 'Téléphone', with: '0606060606'
      fill_in "Lien d'information sur le lieu", with: 'https://mon-suivi-justice.beta.gouv.fr/preparer_spip92'
      within first('.edit-place-appointment-types-container') do
        check 'Premier contact Spip'
      end
      expect { click_button 'Enregistrer' }.to change { Place.count }.by(1)
                                           .and change { Agenda.count }.by(1)
    end
  end

  describe 'update', logged_in_as: 'local_admin_spip', js: true do
    it 'works' do
      place = create(:place, name: 'Spip du 78',
                             preparation_link: 'https://mon-suivi-justice.beta.gouv.fr/preparer_spip92',
                             organization: @user.organization)
      visit places_path

      within first('tbody > tr') { click_link 'Modifier' }
      fill_in :place_name, with: 'Spip du 58'
      fill_in :place_preparation_link, with: 'https://mon-suivi-justice.beta.gouv.fr/preparer_spip58'
      within("#edit_place_#{place.id}") { click_button 'Enregistrer' }
      place.reload
      expect(place.name).to eq('Spip du 58')
      expect(place.preparation_link).to eq('https://mon-suivi-justice.beta.gouv.fr/preparer_spip58')
    end

    it 'creates agenda' do
      place = create(:place, name: 'Spip du 93', organization: @user.organization)
      visit edit_place_path(place)

      within '#new_agenda' do
        fill_in :agenda_name, with: 'Agenda de Jean-Pierre'
        expect { click_button('Ajouter agenda') }.to change { Agenda.count }.by(1)
      end
    end

    it 'updates agenda' do
      place = create :place, name: 'Spip du 93', organization: @user.organization
      agenda = create(:agenda, name: 'test_agenda', place:)
      visit edit_place_path place
      within "#edit_agenda_#{agenda.id}" do
        fill_in :agenda_name, with: 'updated_name'
        click_button 'Enregistrer'
      end
      expect(agenda.reload.name).to eq 'updated_name'
    end

    it 'allows to select appointment_types' do
      apt_type = create(:appointment_type, name: 'Premier contact Spip')
      place = build(:place, name: 'Spip du 91', organization: @user.organization, appointment_types: [])
      place.save(validate: false)
      expect(place.appointment_types).to be_empty

      visit edit_place_path(place)
      within first('.edit-place-appointment-types-container') do
        check apt_type.name
      end

      click_button('Enregistrer')

      place.reload

      expect(place.appointment_types.first).to eq(apt_type)
    end
  end
end
