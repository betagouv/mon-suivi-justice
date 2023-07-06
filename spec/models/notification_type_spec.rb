require 'rails_helper'

RSpec.describe NotificationType, type: :model do
  it { should belong_to(:appointment_type) }
  it { should belong_to(:organization).optional(true) }

  it { should define_enum_for(:role).with_values(%i[summon reminder cancelation no_show reschedule]) }
  it { should define_enum_for(:reminder_period).with_values(%i[one_day two_days]) }

  context 'validations' do
    it { should validate_presence_of(:template) }

    it 'should accept templates with correct keys' do
      correct_template = 'Super template avec des clés valides {lieu.nom} {lieu.adresse}'
      notification_type = build(:notification_type, template: correct_template)

      expect(notification_type).to be_valid
    end

    it "shouldn't accept templates with incorrect keys" do
      incorrect_template = 'Mauvais template avec une clé invalide {convocation.heure} {clé_invalide}'
      notification_type = build(:notification_type, template: incorrect_template)

      expect(notification_type).not_to be_valid

      expected_error =
        "Le format de ce modèle n'est pas valide. Merci d'utiliser uniquement les clés documentées."
      expect(notification_type.errors.messages[:template]).to eq([expected_error])
    end
  end
end
