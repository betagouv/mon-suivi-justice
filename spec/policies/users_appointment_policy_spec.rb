require 'rails_helper'

describe Users::AppointmentPolicy do
  subject { Users::AppointmentPolicy.new(user, appointment) }

  let(:appointment_type) { create(:appointment_type) }
  let(:slot) { create :slot, :without_validations, appointment_type: appointment_type }
  let!(:appointment) { create(:appointment, slot: slot) }

  User.roles.keys.delete_if { |r| %[cpip psychologist overseer ].include? r }.each do |role|
    context "for a #{role} user" do
      let(:user) { build(:user, role: role) }
      let(:scope) { Pundit.policy_scope!(user, Users::AppointmentPolicy) } 

      it 'should raise a '

      it { is_expected.to forbid_action(:index) }
    end
  end

  # Replace this test with https://stackoverflow.com/questions/54330559/how-to-test-pundit-scopes-in-rspec
  context 'a cpip user' do
    let(:user) { build(:user, role: 'cpip') }
    it { is_expected.to permit_action(:index) }
  end


  describe "Scope" do
    context 'user is not cpip / psychologist / overseer' do
      it 'should raise an error' do
        expect(scope.to_a).to match_array([account2_report])
      end 
    end
    context 'admin user' do
      let(:user) { User.new(role: 'admin') }
      it 'allows access to all the reports' do
        expect(scope.to_a).to match_array([account1_report, account2_report])
      end
    end
  end



end
