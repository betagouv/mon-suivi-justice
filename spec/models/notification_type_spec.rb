require 'rails_helper'

RSpec.describe NotificationType, type: :model do
  let!(:organization) { create(:organization) }
  let!(:appointment_type) { create(:appointment_type) }

  it { should belong_to(:appointment_type) }
  it { should belong_to(:organization).optional(true) }

  it { should define_enum_for(:role).with_values(%i[summon reminder cancelation no_show reschedule]) }
  it { should define_enum_for(:reminder_period).with_values(%i[one_day two_days]) }

  context 'validations' do
    it { should validate_presence_of(:template) }

    it 'should accept templates with correct keys' do
      correct_template = 'Super template avec des clés valides {lieu.nom} {lieu.adresse}'
      notification_type = build(:notification_type, organization:, template: correct_template)

      expect(notification_type).to be_valid
    end

    it "shouldn't accept templates with incorrect keys" do
      incorrect_template = 'Mauvais template avec une clé invalide {rdv.heure} {clé_invalide}'
      notification_type = build(:notification_type, organization:, template: incorrect_template)

      expect(notification_type).not_to be_valid

      expected_error =
        "Le format de ce modèle n'est pas valide. Merci d'utiliser uniquement les clés documentées."
      expect(notification_type.errors.messages[:template]).to eq([expected_error])
    end

    it 'validates uniqueness of organization_id with appointment_type_id and role' do
      create(:notification_type, organization_id: organization.id, appointment_type_id: appointment_type.id, role: 0)
      new_notification_type = build(:notification_type, organization_id: organization.id,
                                                        appointment_type_id: appointment_type.id, role: 0)
      expect(new_notification_type).not_to be_valid
    end

    describe '#check_is_default' do
      context 'when organization_id is nil' do
        it 'is invalid if is_default is false' do
          notification_type = build(:notification_type, organization: nil, is_default: false)
          expect(notification_type).not_to be_valid
          expect(notification_type.errors[:is_default]).to include('doit être true si organization_id est nil')
        end

        it 'is valid if is_default is true' do
          notification_type = build(:notification_type, organization: nil, is_default: true)
          expect(notification_type).to be_valid
        end
      end

      context 'when organization_id is not nil' do
        it 'is invalid if is_default is true' do
          notification_type = build(:notification_type, organization:, is_default: true)
          expect(notification_type).not_to be_valid
          expect(notification_type.errors[:is_default]).to include('doit être false si organization_id n\'est pas nil')
        end

        it 'is valid if is_default is false' do
          notification_type = build(:notification_type, organization:, is_default: false)
          expect(notification_type).to be_valid
        end
      end
    end
  end

  # describe 'setup_template' do
  #   it 'translates human readable template into a ruby usable one' do
  #     human_template = 'Convocation le {rdv.date} à {rdv.heure}'
  #     expected = 'Convocation le %<appointment_date>s à %<appointment_hour>s'

  #     result = NotificationFactory.setup_template(human_template)

  #     expect(result).to eq(expected)
  #   end
  # end
end
