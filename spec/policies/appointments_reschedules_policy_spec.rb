require 'rails_helper'

describe AppointmentsReschedulesPolicy do
  User.roles.keys.delete_if { |r| %(cpip psychologist overseer local_admin).include? r }.each do |role|
    context "for a #{role} user" do
      org_type = %w[educator dpip secretary_spip].include?(role) ? 'spip' : 'tj'

      let(:user) { build(:user, :in_organization, type: org_type, role: role) }
      let(:scope) { Users::AppointmentPolicy::Scope.new(user, Appointment).resolve }

      it 'Policy scope should raise an error' do
        expect { scope }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context 'for a tj local_admin user' do
      let(:user) { build(:user, :in_organization, type: 'tj', role: 'local_admin') }
      let(:scope) { Users::AppointmentPolicy::Scope.new(user, Appointment).resolve }

      it 'Policy scope should raise an error' do
        expect { scope }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context 'for a spip local_admin user' do
      let(:user) { build(:user, :in_organization, type: 'spip', role: 'local_admin') }
      let(:scope) { Users::AppointmentPolicy::Scope.new(user, Appointment).resolve }

      it 'Policy scope should raise an error' do
        expect { scope }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  %w[cpip psychologist overseer].each do |role|
    context "for a #{role} user" do
      let(:user) { create(:user_with_appointments, :in_organization, role: role) }
      let(:scope) { Users::AppointmentPolicy::Scope.new(user, Appointment).resolve }

      it 'Policy scope should return proper appointments' do
        expect(scope.to_a).to match_array(user.appointments)
      end
    end
  end
end
