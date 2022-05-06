require 'rails_helper'

describe Users::AppointmentPolicy do
  subject { Users::AppointmentPolicy.new(user, appointment) }

  let(:appointment_type) { create(:appointment_type) }
  let(:slot) { create :slot, :without_validations, appointment_type: appointment_type }
  let!(:appointment) { create(:appointment, slot: slot) }

  User.roles.keys.delete_if { |r| r == 'cpip' }.each do |role|
    context "a #{role} user" do
      let(:user) { build(:user, role: role) }
      it { is_expected.to forbid_action(:index) }
    end
  end

  context 'a cpip user' do
    let(:user) { build(:user, role: 'cpip') }
    it { is_expected.to permit_action(:index) }
  end
end
