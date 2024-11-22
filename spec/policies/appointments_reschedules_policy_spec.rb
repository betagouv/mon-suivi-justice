require 'rails_helper'

describe AppointmentsReschedulesPolicy do
  context 'for a user who has not accepted the security charter' do
    let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }
    let(:slot) { create :slot, :without_validations, appointment_type: }
    let(:user) do
      build(:user, organization: slot.organization, role: :cpip, security_charter_accepted_at: nil)
    end
    let(:appointment) { create(:appointment, slot:, state: :booked) }

    subject { AppointmentsReschedulesPolicy.new(user, appointment) }

    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'previous appointment date is' do
    let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }
    let(:user) do
      build(:user, organization: slot.organization, role: :cpip,
                   security_charter_accepted_at: Time.zone.now)
    end
    let(:appointment) { create(:appointment, :skip_validate, slot:, state: :booked) }
    context 'in the past' do
      let(:slot) { create :slot, :without_validations, appointment_type:, date: 2.day.ago }

      subject { AppointmentsReschedulesPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:new) }
    end
    context 'in the future' do
      let(:slot) { create :slot, :without_validations, appointment_type:, date: 2.day.from_now }

      let(:appointment) { create(:appointment, :skip_validate, slot:, state: :booked) }

      subject { AppointmentsReschedulesPolicy.new(user, appointment) }

      it { is_expected.to permit_action(:new) }
    end
  end

  context 'reschedule related to appointment status' do
    let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }
    let(:slot) { create :slot, :without_validations, appointment_type: }
    let(:user) { build(:user, organization: slot.organization, role: :cpip) }

    context 'for a booked appointment' do
      let(:appointment) { create(:appointment, slot:, state: :booked) }
      subject { AppointmentsReschedulesPolicy.new(user, appointment) }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:create) }
    end

    context 'for a created appointment' do
      let(:appointment) { create(:appointment, slot:, state: :created) }
      subject { AppointmentsReschedulesPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:new) }
      it { is_expected.to permit_action(:create) }
    end

    context 'for a canceled appointment' do
      let(:appointment) { create(:appointment, slot:, state: :canceled) }
      subject { AppointmentsReschedulesPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:new) }
      it { is_expected.to forbid_action(:create) }
    end

    context 'for a fulfiled appointment' do
      let(:appointment) { create(:appointment, slot:, state: :fulfiled) }
      subject { AppointmentsReschedulesPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:new) }
      it { is_expected.to forbid_action(:create) }
    end

    context 'for a excused appointment' do
      let(:appointment) { create(:appointment, slot:, state: :excused) }
      subject { AppointmentsReschedulesPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:new) }
      it { is_expected.to forbid_action(:create) }
    end

    context 'for a no_show appointment' do
      let(:appointment) { create(:appointment, slot:, state: :no_show) }
      subject { AppointmentsReschedulesPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:new) }
      it { is_expected.to forbid_action(:create) }
    end
  end
  context 'for spip related appointment_type' do
    let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }
    let(:slot) { create :slot, :without_validations, appointment_type: }

    context 'for a booked appointment' do
      let(:appointment) { create(:appointment, slot:, state: :booked) }

      User::SPIP_ROLES.each do |role|
        context "for a #{role} user which belongs to the same organization as the appointment's" do
          let(:user) { build(:user, organization: slot.organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.to permit_action(:new) }
        end

        context "for a #{role} user which does not belong to the same organization as the appointment's" do
          let(:user) { build(:user, :in_organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.not_to permit_action(:new) }
        end
      end

      User::TJ_ROLES.each do |role|
        context "for a #{role} user which belongs to the same organization as the appointment's" do
          let(:user) { build(:user, organization: slot.organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.to forbid_action(:new) }
        end

        context "for a #{role} user which does not belong to the same organization as the appointment's" do
          let(:user) { build(:user, :in_organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.not_to permit_action(:new) }
        end
      end
    end
    context 'for a created appointment' do
      let(:appointment) { create(:appointment, slot:, state: :created) }

      User::SPIP_ROLES.each do |role|
        context "for a #{role} user which belongs to the same organization as the appointment's" do
          let(:user) { build(:user, organization: slot.organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.to permit_action(:create) }
        end

        context "for a #{role} user which does not belong to the same organization as the appointment's" do
          let(:user) { build(:user, :in_organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.not_to permit_action(:create) }
        end
      end

      User::TJ_ROLES.each do |role|
        context "for a #{role} user which belongs to the same organization as the appointment's" do
          let(:user) { build(:user, organization: slot.organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.to forbid_action(:create) }
        end

        context "for a #{role} user which does not belong to the same organization as the appointment's" do
          let(:user) { build(:user, :in_organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.not_to permit_action(:create) }
        end
      end
    end
  end

  context 'for tj related appointment_type' do
    let(:appointment_type) { create(:appointment_type, name: 'Sortie d\'audience SAP') }
    let(:slot) { create :slot, :without_validations, appointment_type: }

    context 'for a booked appointment' do
      let(:appointment) { create(:appointment, slot:, state: :booked) }
      User::TJ_ROLES.each do |role|
        context "for a #{role} user which belongs to the same organization as the appointment's" do
          let(:user) { build(:user, organization: slot.organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.to permit_action(:new) }
        end

        context "for a #{role} user which does not belong to the same organization as the appointment's" do
          let(:user) { build(:user, :in_organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.not_to permit_action(:new) }
        end
      end

      User::SPIP_ROLES.each do |role|
        context "for a #{role} user which belongs to the same organization as the appointment's" do
          let(:user) { build(:user, organization: slot.organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.to forbid_action(:new) }
        end

        context "for a #{role} user which does not belong to the same organization as the appointment's" do
          let(:user) { build(:user, :in_organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.not_to permit_action(:new) }
        end
      end
    end

    context 'for a created appointment' do
      let(:appointment) { create(:appointment, slot:, state: :created) }
      User::TJ_ROLES.each do |role|
        context "for a #{role} user which belongs to the same organization as the appointment's" do
          let(:user) { build(:user, organization: slot.organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.to permit_action(:create) }
        end

        context "for a #{role} user which does not belong to the same organization as the appointment's" do
          let(:user) { build(:user, :in_organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.not_to permit_action(:create) }
        end
      end

      User::SPIP_ROLES.each do |role|
        context "for a #{role} user which belongs to the same organization as the appointment's" do
          let(:user) { build(:user, organization: slot.organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.to forbid_action(:create) }
        end

        context "for a #{role} user which does not belong to the same organization as the appointment's" do
          let(:user) { build(:user, :in_organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.not_to permit_action(:create) }
        end
      end
    end
  end
end
