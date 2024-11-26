require 'rails_helper'

RSpec.describe '/api/v1/convicts/:id', type: :request do
  with_env('HTTP_BASIC_AUTH_USER', 'username')
  with_env('HTTP_BASIC_AUTH_PSWD', 'password')

  let(:do_request) { get(path.to_s, headers:) }

  let(:organization1) { create(:organization, name: 'SPIP 92') }
  let(:agent) do
    create(:user, id: 1, first_name: 'Rémy', last_name: 'MAU', phone: '+33606060610',
                  email: 'remy.mau@justice.fr', organization: organization1, role: 2,
                  share_email_to_convict: false)
  end

  let(:convict) do
    create(:convict, id: 1, first_name: 'Damien', last_name: 'LT', phone: '+33606060606',
                     user: agent)
  end

  let(:appointment_type1) do
    create(:appointment_type, name: 'Convocation DDSE', share_address_to_convict: true)
  end
  let(:agenda1) { create(:agenda, name: 'Cabinet 12 (JAPAT)', place: place1) }
  let(:slot1) do
    create(:slot, date: next_valid_day(day: :tuesday), starting_time: new_time_for(10, 0),
                  duration: 30, appointment_type: appointment_type1, agenda: agenda1)
  end
  let(:place1) do
    create(:place, organization: organization1, name: 'SPIP 92',
                   adress: '94 Boulevard du Général Leclerc, 92000 Nanterre',
                   phone: '+33707070707', contact_email: 'test@test.fr',
                   main_contact_method: 'phone')
  end
  let!(:appointment1) do
    create(:appointment, convict:, slot: slot1, id: 1,
                         state: 'booked', origin_department: 'bex')
  end

  let(:appointment_type2) do
    create(:appointment_type, name: '1ère convocation de suivi SPIP', share_address_to_convict: false)
  end
  let(:agenda2) { create(:agenda, name: 'Cabinet 11 (JAPAT)', place: place2) }
  let(:slot2) do
    create(:slot, date: next_valid_day(day: :monday), starting_time: new_time_for(9, 0),
                  duration: 30, appointment_type: appointment_type2, agenda: agenda2)
  end
  let(:organization2) { create(:organization, name: 'SPIP 93') }
  let(:place2) do
    create(:place, organization: organization2, name: 'SPIP 93',
                   adress: '95 Boulevard du Général Leclerc, 93000 Nanterre',
                   phone: '+33707070708', contact_email: 'test2@test.fr',
                   main_contact_method: 'phone')
  end
  let!(:appointment2) do
    create(:appointment, convict:, slot: slot2, id: 2, state: 'booked',
                         origin_department: 'bex')
  end

  describe 'GET /show' do
    let(:path) { "/api/v1/convicts/#{convict.id}" }

    before do
      do_request
    end

    context 'with the right api_key' do
      let(:headers) do
        { 'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials('username', 'password') }
      end

      context 'basic call' do
        let(:expected_response) do
          { 'id' => 1,
            'first_name' => 'Damien',
            'last_name' => 'LT',
            'phone' => '+33606060606',
            'agent' =>
              { 'id' => 1,
                'first_name' => 'Rémy',
                'last_name' => 'MAU',
                'phone' => '+33606060610',
                'email' => 'remy.mau@justice.fr',
                'organization_name' => 'SPIP 92',
                'share_phone_to_convict' => false,
                'share_email_to_convict' => false,
                'role' => 'CPIP' },
            'appointments' =>
              [{ 'id' => 1,
                 'datetime' => json_datetime_format(appointment1.datetime),
                 'duration' => 30,
                 'state' => 'Planifié',
                 'organization_name' => 'SPIP 92',
                 'origin_department' => 'BEX',
                 'appointment_type_name' => 'Convocation DDSE',
                 'display_address' => true,
                 'place' =>
                   { 'name' => 'SPIP 92',
                     'adress' => '94 Boulevard du Général Leclerc, 92000 Nanterre',
                     'phone' => '+33707070707',
                     'email' => 'test@test.fr',
                     'contact_method' => 'phone' },
                 'agenda_name' => 'Cabinet 12 (JAPAT)' },
               { 'id' => 2,
                 'datetime' => json_datetime_format(appointment2.datetime),
                 'duration' => 30,
                 'state' => 'Planifié',
                 'organization_name' => 'SPIP 93',
                 'origin_department' => 'BEX',
                 'appointment_type_name' => '1ère convocation de suivi SPIP',
                 'display_address' => false,
                 'place' =>
                   { 'name' => 'SPIP 93',
                     'adress' => '95 Boulevard du Général Leclerc, 93000 Nanterre',
                     'phone' => '+33707070708',
                     'email' => 'test2@test.fr',
                     'contact_method' => 'phone' },
                 'agenda_name' => 'Cabinet 11 (JAPAT)' }] }
        end

        it 'renders a successful response' do
          expect(response).to be_successful
        end

        it 'has the right content' do
          parsed_response = JSON.parse(response.body)
          sorted_appointments = parsed_response['appointments'].sort_by { |a| a['id'] }
          sorted_expected_appointments = expected_response['appointments'].sort_by { |a| a['id'] }
          expect(parsed_response.except('appointments')).to eq(expected_response.except('appointments'))
          expect(sorted_appointments).to eq(sorted_expected_appointments)
        end
      end

      context 'for a user who does not exist' do
        let(:path) { '/api/v1/convicts/10' }

        let(:expected_response) do
          { 'error' => 'Not found' }
        end

        it 'renders a successful response' do
          expect(response).to be_not_found
        end

        it 'has the right not found content' do
          expect(JSON.parse(response.body)).to match(expected_response)
        end
      end
    end

    context 'with the wrong api_key' do
      let(:headers) do
        { 'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials('mauvais', 'password') }
      end

      it 'renders a successful response with the wrong api_key' do
        expect(response).to be_unauthorized
      end
    end

    context 'without api_key' do
      let(:headers) { {} }

      it 'renders a successful response without api_key' do
        expect(response).to be_unauthorized
      end
    end
  end
end
