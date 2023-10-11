require 'rails_helper'

describe AppointmentsReschedulesPolicy do
  context 'for spip related appointment_type' do
    let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }
    let(:slot) { create :slot, :without_validations, appointment_type: }
    let(:appointment) { create(:appointment, slot:) }

    User.spip_roles.each do |role|
      context "for a #{role} user which belongs to the same organization as the appointment's" do
        let(:user) { build(:user, organization: slot.agenda.place.organization, role:) }
        subject { AppointmentsReschedulesPolicy.new(user, appointment) }

        it { is_expected.to permit_action(:new) }
        it { is_expected.to permit_action(:create) }
      end

      context "for a #{role} user which does not belong to the same organization as the appointment's" do
        let(:user) { build(:user, :in_organization, role:) }
        subject { AppointmentsReschedulesPolicy.new(user, appointment) }

        it { is_expected.not_to permit_action(:new) }
        it { is_expected.not_to permit_action(:create) }
      end

      context 'for a canceled appointment' do
        let(:user) { build(:user, organization: slot.agenda.place.organization, role:) }
        let(:appointment) { create(:appointment, slot:, state: :canceled) }
        subject { AppointmentsReschedulesPolicy.new(user, appointment) }

        it { is_expected.not_to permit_action(:new) }
        it { is_expected.not_to permit_action(:create) }
      end
    end
  end

  context 'for tj related appointment_type' do
    let(:appointment_type) { create(:appointment_type, name: 'Sortie d\'audience SAP') }
    let(:slot) { create :slot, :without_validations, appointment_type: }
    let(:appointment) { create(:appointment, slot:) }

    User.tj_roles.each do |role|
      context "for a #{role} user which belongs to the same organization as the appointment's" do
        let(:user) { build(:user, organization: slot.agenda.place.organization, role:) }
        subject { AppointmentsReschedulesPolicy.new(user, appointment) }

        it { is_expected.to permit_action(:new) }
        it { is_expected.to permit_action(:create) }
      end

      context "for a #{role} user which does not belong to the same organization as the appointment's" do
        let(:user) { build(:user, :in_organization, role:) }
        subject { AppointmentsReschedulesPolicy.new(user, appointment) }

        it { is_expected.not_to permit_action(:new) }
        it { is_expected.not_to permit_action(:create) }
      end

      context 'for a canceled appointment' do
        let(:user) { build(:user, organization: slot.agenda.place.organization, role:) }
        let(:appointment) { create(:appointment, slot:, state: :canceled) }
        subject { AppointmentsReschedulesPolicy.new(user, appointment) }

        it { is_expected.not_to permit_action(:new) }
        it { is_expected.not_to permit_action(:create) }
      end
    end
  end
end
