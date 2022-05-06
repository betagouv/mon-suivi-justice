require 'rails_helper'

describe Users::AppointmentPolicy do
  subject { Users::AppointmentPolicy.new(user, appointment) }

  let(:appointment_type) { create(:appointment_type) }
  let(:slot) { create :slot, :without_validations, appointment_type: appointment_type }
  let!(:appointment) { create(:appointment, slot: slot) }

  users_roles = %w[
    admin
    local_admin
    jap
    bex
    prosecutor
    secretary_court
    dir_greff_bex
    greff_co
    greff_tpe
    greff_crpc
    greff_ca
    dir_greff_sap
    greff_sap
    dpip
    cpip
    secretary_spip
    educator
    psychologist
    overseer
  ]

  users_roles.delete_if { |r| r == 'cpip' }.each do |role|
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
