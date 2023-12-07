RSpec.shared_examples 'convict search feature' do
  it 'allows user to search convicts by name or phone number', logged_in_as: 'cpip', js: true do
    create(:convict, last_name: 'Dupneu',
                     first_name: 'Bob',
                     phone: '0612345678', organizations: [@user.organization])
    create(:convict, last_name: 'Rabbit',
                     first_name: 'Roger',
                     phone: '0787654321', organizations: [@user.organization])

    create(:convict, last_name: 'McGregor',
                     first_name: 'Connor',
                     no_phone: true, user: @user, organizations: [@user.organization])
    create(:convict, last_name: 'Champion',
                     first_name: 'Thomas',
                     no_phone: true, user: @user, organizations: [@user.organization])

    visit convicts_path

    page.find('label[for="my_convicts_checkbox"]').click

    expect(page).to have_content('McGregor')
    expect(page).to have_content('Champion')
    expect(page).not_to have_content('Rabbit')
    expect(page).not_to have_content('Dupneu')

    search_input = find('#convicts_search_field')
    search_input.set('Champ')

    expect(page).not_to have_content('McGregor')
    expect(page).to have_content('Champion')

    page.find('label[for="my_convicts_checkbox"]').click

    search_input.set('')
    search_input.set('Bob')

    expect(page).to have_content('Dupneu')
    expect(page).to have_link('Profil')
    expect(page).not_to have_content('Rabbit')

    search_input.set('')
    search_input.set('07876')

    expect(page).to have_content('Rabbit')
    expect(page).to have_link('Profil')
    expect(page).not_to have_content('Dupneu')

    search_input.set('')
    search_input.set('+337876')

    expect(page).to have_content('Rabbit')
    expect(page).to have_link('Profil')
    expect(page).not_to have_content('Dupneu')

    search_input.set('')
    search_input.set('Whatever')
    expect(page).not_to have_content('Dupneu')
    expect(page).not_to have_content('Rabbit')
  end
end
