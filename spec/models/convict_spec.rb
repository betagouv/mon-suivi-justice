require 'rails_helper'
require 'models/shared_normalized_phone'

RSpec.describe Convict, type: :model do
  it { should belong_to(:user).optional }
  it { should have_many(:appointments) }

  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:invitation_to_convict_interface_count) }
  it { should validate_uniqueness_of(:appi_uuid) }

  describe 'uniqueness' do
    context 'when appi_uuid is present' do
      let(:organization) { Organization.create(name: 'Organization') }
      let(:appi_uuid) { "2024#{Faker::Number.number(digits: 8)}" }
      let(:first_name) { Faker::Name.first_name }
      let(:last_name) { Faker::Name.last_name }
      let(:phone) { Faker::Base.numerify('+3361#######') }
      let(:date_of_birth) { Faker::Date.birthday(min_age: 18, max_age: 65) }
      let!(:existing_convict) do
        create(:convict, organizations: [organization], appi_uuid:, first_name:, last_name:, date_of_birth:, phone:)
      end

      it 'should not allow to create a convict with the same appi_uuid' do
        new_convict = build(:convict, organizations: [organization], appi_uuid:)

        expect(new_convict.valid?).to eq(false)
        expect(new_convict.errors[:appi_uuid]).to include("est déjà enregistré avec ce numéro APPI")
      end

      it 'should allow to create a convict with same first_name, last_name and dob but different appi_number' do
        appi_uuid2 = "2024#{Faker::Number.number(digits: 8)}"
        new_convict = build(:convict, organizations: [organization], appi_uuid: appi_uuid2, first_name:, last_name:,
                                      date_of_birth:)

        expect(new_convict.valid?).to eq(true)
      end

      it 'should allow to create a convict with same first_name, last_name and dob but without appi_number' do
        new_convict = build(:convict, organizations: [organization], first_name:, last_name:,
                                      date_of_birth:)

        expect(new_convict.valid?).to eq(true)
      end

      it 'should not allow to create a convict with same phone_number' do
        appi_uuid2 = "2024#{Faker::Number.number(digits: 8)}"
        new_convict = build(:convict, organizations: [organization], appi_uuid: appi_uuid2, first_name:, last_name:,
                                      date_of_birth:, phone:)
        expect(new_convict.valid?).to eq(false)
        error_message = 'Un probationnaire est déjà enregistré avec ce numéro de téléphone'
        expect(new_convict.errors[:phone].first).to include(error_message)
      end
    end
    context 'when appi_uuid is not present' do
      let(:organization) { Organization.create(name: 'Organization') }
      let(:first_name) { Faker::Name.first_name }
      let(:last_name) { Faker::Name.last_name }
      let(:phone) { Faker::Base.numerify('+3361#######') }
      let(:date_of_birth) { Faker::Date.birthday(min_age: 18, max_age: 65) }
      let!(:existing_convict) do
        create(:convict, organizations: [organization], first_name:, last_name:, date_of_birth:, phone:, appi_uuid: nil)
      end

      it 'should NOT allow to create a convict with same first_name, last_name and dob and no appi_uuid' do
        new_convict = build(:convict, organizations: [organization], first_name:, last_name:,
                                      date_of_birth:, appi_uuid: nil)

        expect(new_convict.valid?).to eq(false)
        error_message = 'Un probationnaire avec les mêmes prénom, nom et date de naissance existe déjà'
        expect(new_convict.errors[:date_of_birth]).to include(error_message)
      end

      it 'should allow to create a convict with same first_name, last_name and dob but with appi_number' do
        appi_uuid = "2024#{Faker::Number.number(digits: 8)}"
        new_convict = build(:convict, organizations: [organization], appi_uuid:, first_name:, last_name:,
                                      date_of_birth:)

        expect(new_convict.valid?).to eq(true)
      end

      it 'should allow to change the phone number (or any attributes that are not first_name, last_name and
          date_of_birth) of a convict without appi_uuid' do
        existing_convict.phone = Faker::Base.numerify('+3361#######')

        expect(existing_convict.valid?).to eq(true)
      end

      it 'should not allow to create a convict with same phone_number' do
        first_name2 = Faker::Name.first_name
        last_name2 = Faker::Name.last_name
        date_of_birth2 = Faker::Date.birthday(min_age: 18, max_age: 65)
        new_convict = build(:convict, organizations: [organization], first_name: first_name2, last_name: last_name2,
                                      date_of_birth: date_of_birth2, phone:)
        expect(new_convict.valid?).to eq(false)
        error_message = 'Un probationnaire est déjà enregistré avec ce numéro de téléphone'
        expect(new_convict.errors[:phone].first).to include(error_message)
      end
    end
  end

  it_behaves_like 'normalized_phone'

  describe 'Normalization' do
    it 'normalizes first_name' do
      convict = create(:convict, first_name: '  jean  ')
      expect(convict.first_name).to eq('Jean')
    end

    it 'normalizes hyphen first_name' do
      convict = create(:convict, first_name: '  jean-pierre  ')
      expect(convict.first_name).to eq('Jean-Pierre')
    end

    it 'normalizes spaces in first_name' do
      convict = create(:convict, first_name: '  jean pierre  ')
      expect(convict.first_name).to eq('Jean Pierre')
    end

    it 'normalizes last_name' do
      convict = create(:convict, last_name: '  martin  ')
      expect(convict.last_name).to eq('MARTIN')
    end

    it 'normalizes appi_uuid' do
      appi_uuid = "2024#{Faker::Number.unique.number(digits: 8)}"
      convict = create(:convict, appi_uuid: " #{appi_uuid}  ")
      expect(convict.appi_uuid).to eq(appi_uuid)
    end
  end

  describe 'Validations' do
    it 'requires a phone' do
      expect(build(:convict, phone: nil)).not_to be_valid
    end
    it 'denies a blank phone' do
      expect(build(:convict, phone: '')).not_to be_valid
    end
    it 'accepts a blank phone with no_phone option' do
      expect(build(:convict, phone: nil, no_phone: true)).to be_valid
    end
    it 'accepts a blank phone with refused_phone option' do
      expect(build(:convict, phone: nil, refused_phone: true)).to be_valid
    end
    it 'accepts a 06 mobile phone' do
      expect(build(:convict, phone: '0612458745')).to be_valid
    end
    it 'accepts a 07 mobile phone' do
      expect(build(:convict, phone: '0781007498')).to be_valid
    end
    it 'denies a non-mobile phone' do
      expect(build(:convict, phone: '0561083731')).not_to be_valid
    end
    it 'accepts multiples user with no-data for appi uuid' do
      create(:convict, appi_uuid: nil)
      expect(build(:convict, appi_uuid: nil)).to be_valid
    end

    describe '#unique_organizations' do
      let(:organization1) { Organization.create(name: 'Organization 1') }
      let(:organization2) { Organization.create(name: 'Organization 2') }
      let(:convict) { build(:convict, organizations: []) }
      context 'when convict has unique organizations' do
        it 'is valid' do
          convict.organizations << organization1
          convict.organizations << organization2
          expect(convict).to be_valid
        end
      end

      context 'when convict has duplicate organizations' do
        it 'is invalid' do
          convict.organizations << organization1
          convict.organizations << organization1
          expect(convict).to be_invalid
          expect(convict.errors[:organizations]).not_to be_empty
        end
      end
    end

    it 'denies a convict under 16' do
      expect(build(:convict, date_of_birth: 15.years.ago, no_phone: true)).not_to be_valid
      expect(build(:convict, date_of_birth: 17.years.ago, no_phone: true)).to be_valid
    end

    describe 'appi_uuid' do
      context 'no appi uuid' do
        let(:convict) { build(:convict, appi_uuid: nil) }
        it 'should be valid' do
          expect(convict).to be_valid
        end
      end

      context 'right format' do
        let(:convict) { build(:convict, appi_uuid: nil) }
        it 'start with 199 and have 12 characters' do
          convict.appi_uuid = "199#{Faker::Number.unique.number(digits: 5)}"
          expect(convict).to be_valid
        end
        it 'start with 200 and have 12 characters' do
          convict.appi_uuid = "200#{Faker::Number.unique.number(digits: 9)}"
          expect(convict).to be_valid
        end
        it 'start with 201 and have 12 characters' do
          convict.appi_uuid = "201#{Faker::Number.unique.number(digits: 9)}"
          expect(convict).to be_valid
        end
        it 'start with 202 and have 12 characters' do
          convict.appi_uuid = "202#{Faker::Number.unique.number(digits: 9)}"
          expect(convict).to be_valid
        end
      end
      context 'wrong format' do
        let(:convict) { build(:convict, appi_uuid: nil) }
        it 'does not start with the the right digits' do
          convict.appi_uuid = "18#{Faker::Number.unique.number(digits: 10)}"
          expect(convict).not_to be_valid
        end
        it 'does not have the right amount of digits for an appi uuid starting with 201' do
          convict.appi_uuid = "201#{Faker::Number.unique.number(digits: 5)}"
          expect(convict).not_to be_valid
        end
        it 'does not have the right amount of digits for an appi uuid starting with 199' do
          convict.appi_uuid = "199#{Faker::Number.unique.number(digits: 9)}"
          expect(convict).not_to be_valid
        end
        it 'contains letters' do
          convict.appi_uuid = "201#{Faker::Number.unique.number(digits: 8)}a"
          expect(convict).not_to be_valid
        end
      end
    end
  end

  describe 'phone_uniqueness' do
    it 'denies a phone already existing' do
      create(:convict, phone: '0612458744')

      expect(build(:convict, phone: '0612458744')).not_to be_valid
    end
  end

  describe 'either_city_homeless_lives_abroad_present' do
    it('is valid when the user is not using inter-ressort') do
      expect(build(:convict, city: nil, homeless: false, lives_abroad: false)).to be_valid
    end
    it('is valid when the user is using inter-ressort but is not bex') do
      organization = create(:organization, use_inter_ressort: true)
      current_user = create(:user, organization:, role: 'greff_sap')
      convict = build(:convict, city: nil, homeless: false, lives_abroad: false, creating_organization: organization,
                                current_user:)
      expect(convict).to be_valid
    end
    context 'when the user is using inter-ressort' do
      let(:organization) { create(:organization, use_inter_ressort: true) }
      let(:current_user) { create(:user, organization:, role: 'bex') }
      it('is invalid when has no city, dont live abroad and is not homeless') do
        convict = build(:convict, city: nil, homeless: false, lives_abroad: false, creating_organization: organization,
                                  current_user:)
        expect(convict.valid?).to be false
      end
      it('is valid when has a city, dont live abroad and is not homeless') do
        convict = build(:convict, city_id: '12', homeless: false, lives_abroad: false,
                                  creating_organization: organization, current_user:)
        expect(convict.valid?).to be true
      end
      it('is valid when has no city, lives abroad and is not homeless') do
        convict = build(:convict, city: nil, homeless: false, lives_abroad: true, creating_organization: organization,
                                  current_user:)
        expect(convict.valid?).to be true
      end
      it('is valid when has a city, dont live abroad and is homeless') do
        convict = build(:convict, city: nil, homeless: true, lives_abroad: false, creating_organization: organization,
                                  current_user:)
        expect(convict.valid?).to be true
      end
    end
  end

  describe 'update_organizations' do
    before do
      srj_tj_organization = create(:organization, organization_type: 'tj')
      @srj_tj = create(:srj_tj, name: 'srj tj', organization: srj_tj_organization)

      srj_spip_organization = create(:organization, organization_type: 'spip')
      @srj_spip = create(:srj_spip, organization: srj_spip_organization)

      @city = create(:city, srj_tj: @srj_tj, srj_spip: @srj_spip)

      @tj_paris = Organization.find_or_create_by(name: 'TJ Paris', organization_type: 'tj')

      current_user_organization = create(:organization)
      @current_user = build(:user, organization: current_user_organization)
    end
    it('contains city organization if city is present') do
      convict = build(:convict, city: @city, organizations: [])

      convict.update_organizations(@current_user)

      expect(convict.organizations).to eq(@city.organizations)
    end

    it('contains current user organization if city is not present') do
      convict = build(:convict, city: nil, organizations: [])
      convict.update_organizations(@current_user)

      expect(convict.organizations).to eq([@current_user.organization])
    end

    it('contains TJ Paris if convict is japat') do
      convict = build(:convict, city: @city, japat: true, organizations: [])

      convict.update_organizations(@current_user)

      expect(convict.organizations).to match_array([@srj_spip.organization, @tj_paris])
    end

    it('add new organization and not remove the previous ones') do
      convict = build(:convict, city: nil, organizations: [])
      convict.update_organizations(@current_user)

      expect(convict.organizations).to eq([@current_user.organization])

      convict.update(city: @city)
      convict.update_organizations(@current_user)

      expect(convict.organizations).to match_array([@city.organizations, @current_user.organization].flatten)
    end

    it('should not add organization if it is already present') do
      convict = build(:convict, city: nil, organizations: [])
      convict.update_organizations(@current_user)

      expect(convict.organizations).to eq([@current_user.organization])

      convict.update_organizations(@current_user)
      expect(convict.organizations.pluck(:id)).to match_array([@current_user.organization.id])
    end
  end

  describe '#toggle_japat_orgs' do
    let(:tj_paris) { create(:organization, organization_type: :tj, name: 'TJ Paris') }
    let(:spip_paris) { create(:organization, organization_type: :spip, name: 'SPIP 75') }
    context 'when in Paris jurisdiction' do
      let(:convict) { build(:convict, organizations: [tj_paris, spip_paris]) }
      it 'does not change organizations' do
        allow(convict).to receive(:in_paris_jurisdiction?).and_return(true)
        expect(convict).not_to receive(:save)

        convict.toggle_japat_orgs

        expect(convict.organizations).to include(tj_paris)
      end
    end

    context 'when not in Paris jurisdiction' do
      let(:tj_bordeaux) { create(:organization, organization_type: :tj, name: 'TJ Bordeaux') }
      let(:spip_bordeaux) { create(:organization, organization_type: :spip, name: 'SPIP 33') }

      context 'and japat? is true' do
        let(:convict) { create(:convict, organizations: [tj_bordeaux, spip_bordeaux], japat: true) }

        it 'adds TJ Paris to organizations if not already included' do
          allow(convict).to receive(:japat?).and_return(true)

          expect { convict.toggle_japat_orgs }.to change {
                                                    convict.organizations.include?(tj_paris)
                                                  }.from(false).to(true)
        end

        it 'does not add TJ Paris if already included' do
          convict = create(:convict, organizations: [tj_bordeaux, spip_bordeaux, tj_paris], japat: true)

          expect { convict.toggle_japat_orgs }.not_to(change { convict.organizations.count })
        end
      end

      context 'and japat? is false' do
        let(:convict) { create(:convict, organizations: [tj_bordeaux, spip_bordeaux], japat: false) }

        it 'removes TJ Paris from organizations if included' do
          convict = create(:convict, organizations: [tj_bordeaux, spip_bordeaux, tj_paris], japat: false)

          expect { convict.toggle_japat_orgs }.to change {
                                                    convict.organizations.include?(tj_paris)
                                                  }.from(true).to(false)
        end

        it 'does nothing if TJ Paris is not included' do
          expect { convict.toggle_japat_orgs }.not_to(change { convict.organizations.count })
        end
      end
    end
  end
  describe 'first_name, last_name and dob validations with and without appi_uuid' do
    let(:first_name) { 'Jane' }
    let(:last_name) { 'Doe' }
    let(:date_of_birth) { '1990-01-01' }
    let!(:existing_convict) { create(:convict, first_name:, last_name:, date_of_birth:, appi_uuid: nil) }

    context 'when validating date_of_birth uniqueness' do
      it 'is invalid with a duplicate date_of_birth, first_name, and last_name without appi_uuid' do
        new_convict = build(:convict, first_name:, last_name:, date_of_birth:, appi_uuid: nil)
        expect(new_convict).not_to be_valid
        expect(new_convict.errors[:date_of_birth]).to include(Convict::DOB_UNIQUENESS_MESSAGE)
      end

      it 'is valid with a unique combination of date_of_birth, first_name, and last_name' do
        unique_convict = build(:convict, first_name:, last_name: 'Smith', date_of_birth:, appi_uuid: nil)
        expect(unique_convict).to be_valid
      end

      it 'is valid with a duplicate date_of_birth, first_name, and last_name but with appi_uuid' do
        convict_with_appi_uuid = build(:convict, first_name:, last_name:, date_of_birth:)
        expect(convict_with_appi_uuid).to be_valid
      end
    end
  end

  describe '#update_organizations_for_bex_user' do
    let(:bex_user) { create(:user, :in_organization, role: 'bex') }
    let(:convict) { create(:convict) }

    context 'when the convict is not valid' do
      let(:convict) do
        c = build(:convict, appi_uuid: 'abc')
        c.save(validate: false)
        c
      end

      it 'does not update the convict\'s organizations' do
        orgas = [*convict.organizations]
        convict.update_organizations_for_bex_user(bex_user)
        expect(convict.organizations).to match_array(orgas)
      end
    end

    context 'when the user works at BEX' do
      before { allow(bex_user).to receive(:work_at_bex?).and_return(true) }

      it 'adds the user\'s organizations to the convict' do
        expect { convict.update_organizations_for_bex_user(bex_user) }
          .to change { convict.organizations.count }.by(bex_user.organizations.count)
      end
    end

    context 'when the user does not work at BEX' do
      let(:non_bex_user) { create(:user, :in_organization, role: 'cpip') }

      it 'does not change the convict’s organizations' do
        expect { convict.update_organizations_for_bex_user(non_bex_user) }
          .not_to(change { convict.organizations.count })
      end
    end
  end

  describe '.find_duplicates' do
    let(:convict) { build(:convict) }

    context 'when there are no duplicates' do
      it 'returns an empty array' do
        convict.validate
        expect(convict.find_duplicates).to be_empty
      end
    end

    context 'when there is a duplicate by appi_uuid' do
      let!(:duplicate_convict) { create(:convict, appi_uuid: convict.appi_uuid) }

      it 'returns an array with the duplicate convict' do
        convict.validate
        convict.errors.add(:appi_uuid, :taken)
        expect(convict.find_duplicates).to include(duplicate_convict)
      end
    end

    context 'when there is a duplicate by phone' do
      let!(:duplicate_convict) { create(:convict, phone: convict.phone) }

      it 'returns an array with the duplicate convict' do
        convict.validate
        expect(convict.find_duplicates).to include(duplicate_convict)
      end
    end

    context 'when there is a duplicate by date_of_birth and name' do
      let(:convict) { build(:convict, appi_uuid: nil) }
      let!(:duplicate_convict) do
        create(:convict, first_name: convict.first_name,
                         last_name: convict.last_name,
                         date_of_birth: convict.date_of_birth,
                         appi_uuid: nil)
      end

      it 'returns an array with the duplicate convict' do
        convict.validate
        expect(convict.find_duplicates).to include(duplicate_convict)
      end
    end

    context 'when there are multiple duplicates' do
      let!(:duplicate_by_appi_uuid) { create(:convict, appi_uuid: convict.appi_uuid) }
      let!(:duplicate_by_phone) { create(:convict, phone: convict.phone) }
      let!(:duplicate_by_date_of_birth) do
        create(:convict, first_name: convict.first_name,
                         last_name: convict.last_name,
                         date_of_birth: convict.date_of_birth,
                         appi_uuid: nil)
      end
      context 'convict with appi uuid' do
        it 'returns an array with all duplicate convicts' do
          # no dob validation when appi_uuid is present
          convict.validate
          duplicates = convict.find_duplicates
          expect(duplicates).to match_array([duplicate_by_appi_uuid, duplicate_by_phone])
        end
      end
      context 'convict without appi uuid' do
        let(:convict) { build(:convict, appi_uuid: nil) }
        it 'returns an array with all duplicate convicts' do
          convict.validate
          duplicates = convict.find_duplicates
          expect(duplicates).to match_array([duplicate_by_date_of_birth, duplicate_by_phone])
        end
      end
    end

    context 'when another convict match multiple criteria' do
      let(:convict) { build(:convict, appi_uuid: nil) }
      let!(:dup) do
        create(:convict, phone: convict.phone, first_name: convict.first_name, last_name: convict.last_name,
                         date_of_birth: convict.date_of_birth, appi_uuid: nil)
      end

      it 'returns the dup only once' do
        convict.validate
        duplicates = convict.find_duplicates

        expect(duplicates).to match_array([dup])
      end
    end
  end
end
