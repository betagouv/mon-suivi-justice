require 'rails_helper'

describe Users::AppointmentPolicy do
  User.roles.keys.delete_if { |r| %(cpip psychologist overseer).include? r }.each do |role|
    context "for a #{role} user" do
      let(:user) { create(:user, role: role) }
      let(:scope) { Users::AppointmentPolicy::Scope.new(user, Appointment).resolve }

      it 'Policy scope should raise an error' do
        expect { scope }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  %w[cpip psychologist overseer].each do |role|
    context "for a #{role} user" do
      let(:appointments) { create(:user_with_appointments, role: role).appointments }

      let(:scope) { Users::AppointmentPolicy::Scope.new(appointments.last.user, Appointment).resolve }

      it 'Policy scope should return proper appointments' do
        expect(scope.to_a).to match_array(appointments)
      end
    end
  end
end
