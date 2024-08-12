require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create(:user, :in_organization) }

  it { should belong_to(:organization) }

  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }

    describe '#correct_role_for_organization_type' do
      let(:error_message) { I18n.t('activerecord.errors.models.user.attributes.role.correct_for_organization') }

      context 'when user is an admin' do
        let(:user) { build(:user, :admin) }

        it 'is valid with SPIP organization' do
          user.organization = build(:organization, :spip)
          expect(user).to be_valid
        end

        it 'is valid with TJ organization' do
          user.organization = build(:organization, :tj)
          expect(user).to be_valid
        end
      end

      context 'when user is not an admin' do
        let(:user) { build(:user) }

        context 'when organization is SPIP' do
          before do
            user.organization = build(:organization, :spip)
          end

          it 'is valid if user works at SPIP' do
            allow(user).to receive(:work_at_spip?).and_return(true)
            expect(user).to be_valid
          end

          it 'is invalid if user does not work at SPIP' do
            allow(user).to receive(:work_at_spip?).and_return(false)
            expect(user).not_to be_valid
            expect(user.errors[:role]).to include(error_message)
          end
        end

        context 'when organization is TJ' do
          before do
            user.organization = build(:organization, :tj)
          end

          it 'is valid if user works at TJ' do
            allow(user).to receive(:work_at_tj?).and_return(true)
            expect(user).to be_valid
          end

          it 'is invalid if user does not work at TJ' do
            allow(user).to receive(:work_at_tj?).and_return(false)
            expect(user).not_to be_valid
            expect(user.errors[:role]).to include(error_message)
          end
        end
      end
    end
  end

  it {
    should define_enum_for(:role).with_values(
      {
        admin: 0,
        bex: 1,
        cpip: 2,
        local_admin: 4,
        prosecutor: 5,
        jap: 6,
        secretary_court: 7,
        dir_greff_bex: 8,
        greff_co: 9,
        dir_greff_sap: 10,
        greff_sap: 11,
        educator: 12,
        psychologist: 13,
        overseer: 14,
        dpip: 15,
        secretary_spip: 16,
        greff_tpe: 17,
        greff_crpc: 18,
        greff_ca: 19
      }
    )
  }

  describe '#set_default_role' do
    let(:organization) { create(:organization, organization_type: 'tj') }

    it 'sets the default role if role is blank' do
      user = User.new(organization:, email: 'admin@example.com', password: '1mot2passeSecurise!',
                      password_confirmation: '1mot2passeSecurise!', first_name: 'Kevin', last_name: 'McCallister')
      expect(user).to be_valid
      expect(user.role).to eq('greff_sap')
    end

    it 'does not change the role if role is already present' do
      user = User.new(organization:, email: 'admin@example.com', password: '1mot2passeSecurise!',
                      password_confirmation: '1mot2passeSecurise!', role: :admin,
                      first_name: 'Kevin', last_name: 'McCallister')
      expect(user).to be_valid
      expect(user.role).to eq('admin')
    end

    it 'raises a database error when role is null' do
      user = User.new(organization:, email: 'admin@example.com',
                      password: '1mot2passeSecurise!', password_confirmation: '1mot2passeSecurise!',
                      first_name: 'Kevin', last_name: 'McCallister')

      expect { user.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
    end
  end

  context 'brevo sync' do
    before do
      allow_any_instance_of(BrevoAdapter).to receive(:real_production?).and_return(true)

      stub_request(:post, 'https://api.sendinblue.com/v3/contacts').to_return(status: 200)
      stub_request(:put, 'https://api.sendinblue.com/v3/contacts').to_return(status: 200)
      stub_request(:delete, 'https://api.sendinblue.com/v3/contacts').to_return(status: 200)
    end

    describe 'after_create callback' do
      it 'enqueues the CreateContactInBrevoJob' do
        user = create(:user, :in_organization, email: 'test@example.com', first_name: 'Test', last_name: 'User',
                                               role: 'admin')
        user.invite!
        user.accept_invitation!
        perform_enqueued_jobs
        expect(WebMock).to have_requested(:post, 'https://api.sendinblue.com/v3/contacts')
      end
    end

    describe 'after_update callback' do
      it 'enqueues the UpdateContactInBrevoJob' do
        user = create(:user, :in_organization, email: 'test@example.com', first_name: 'Test',
                                               last_name: 'User', role: 'admin')
        perform_enqueued_jobs
        user.update(first_name: 'Updated')
        perform_enqueued_jobs
        expect(WebMock).to have_requested(:put, 'https://api.sendinblue.com/v3/contacts/test@example.com')
      end
    end

    describe 'after_destroy callback' do
      it 'enqueues the DeleteContactInBrevoJob' do
        user = create(:user, :in_organization, email: 'test@example.com', first_name: 'Test',
                                               last_name: 'User', role: 'admin')
        user.destroy
        perform_enqueued_jobs
        expect(WebMock).to have_requested(:delete, 'https://api.sendinblue.com/v3/contacts/test@example.com')
      end
    end
  end
end
