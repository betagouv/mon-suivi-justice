require 'rails_helper'

describe AppointmentsReschedulesPolicy do
  context 'reschedule related to appointment status' do
    let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }
    let(:slot) { create :slot, :without_validations, appointment_type: }
    let(:user) { build(:user, organization: slot.agenda.place.organization, role: :cpip) }

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

      User.spip_roles.each do |role|
        context "for a #{role} user which belongs to the same organization as the appointment's" do
          let(:user) { build(:user, organization: slot.agenda.place.organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.to permit_action(:new) }
        end

        context "for a #{role} user which does not belong to the same organization as the appointment's" do
          let(:user) { build(:user, :in_organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.not_to permit_action(:new) }
        end
      end

      User.tj_roles.each do |role|
        context "for a #{role} user which belongs to the same organization as the appointment's" do
          let(:user) { build(:user, organization: slot.agenda.place.organization, role:) }
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

      User.spip_roles.each do |role|
        context "for a #{role} user which belongs to the same organization as the appointment's" do
          let(:user) { build(:user, organization: slot.agenda.place.organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.to permit_action(:create) }
        end

        context "for a #{role} user which does not belong to the same organization as the appointment's" do
          let(:user) { build(:user, :in_organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.not_to permit_action(:create) }
        end
      end

      User.tj_roles.each do |role|
        context "for a #{role} user which belongs to the same organization as the appointment's" do
          let(:user) { build(:user, organization: slot.agenda.place.organization, role:) }
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
      User.tj_roles.each do |role|
        context "for a #{role} user which belongs to the same organization as the appointment's" do
          let(:user) { build(:user, organization: slot.agenda.place.organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.to permit_action(:new) }
        end

        context "for a #{role} user which does not belong to the same organization as the appointment's" do
          let(:user) { build(:user, :in_organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.not_to permit_action(:new) }
        end
      end

      User.spip_roles.each do |role|
        context "for a #{role} user which belongs to the same organization as the appointment's" do
          let(:user) { build(:user, organization: slot.agenda.place.organization, role:) }
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
      User.tj_roles.each do |role|
        context "for a #{role} user which belongs to the same organization as the appointment's" do
          let(:user) { build(:user, organization: slot.agenda.place.organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.to permit_action(:create) }
        end

        context "for a #{role} user which does not belong to the same organization as the appointment's" do
          let(:user) { build(:user, :in_organization, role:) }
          subject { AppointmentsReschedulesPolicy.new(user, appointment) }

          it { is_expected.not_to permit_action(:create) }
        end
      end

      User.spip_roles.each do |role|
        context "for a #{role} user which belongs to the same organization as the appointment's" do
          let(:user) { build(:user, organization: slot.agenda.place.organization, role:) }
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
