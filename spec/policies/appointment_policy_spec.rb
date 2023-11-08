require 'rails_helper'

describe AppointmentPolicy do
  subject { AppointmentPolicy.new(user, appointment) }
  let(:organization) { build(:organization, organization_type: 'spip') }
  let(:place) { build(:place, organization:) }
  let(:agenda) { build :agenda, place: }
  let(:appointment_type) { create(:appointment_type) }
  let(:slot) { create :slot, :without_validations, appointment_type: }
  let(:convict) { create :convict, organizations: [slot.place.organization] }
  let!(:appointment) do
    create(:appointment, slot:, state: :booked, creating_organization: slot.place.organization, convict:)
  end

  context 'related to appointment status' do
    let(:user) { build(:user, role: 'admin', organization: slot.place.organization) }

    context 'for a booked appointment' do
      let!(:appointment) { create(:appointment, slot:, state: 'booked') }
      subject { AppointmentPolicy.new(user, appointment) }

      it { is_expected.to permit_action(:cancel) }
    end

    context 'for a canceled appointment' do
      let!(:appointment) { create(:appointment, slot:, state: 'canceled') }
      subject { AppointmentPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:cancel) }
    end

    context 'for a created appointment' do
      let!(:appointment) { create(:appointment, slot:, state: 'created') }
      subject { AppointmentPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:cancel) }
    end

    context 'for a fulfiled appointment' do
      let!(:appointment) { create(:appointment, slot:, state: 'fulfiled') }
      subject { AppointmentPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:cancel) }
    end

    context 'for a no_show appointment' do
      let!(:appointment) { create(:appointment, slot:, state: 'no_show') }
      subject { AppointmentPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:cancel) }
    end

    context 'for a excused appointment' do
      let!(:appointment) { create(:appointment, slot:, state: 'excused') }
      subject { AppointmentPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:cancel) }
    end
  end

  context 'show?' do
    context 'for an appointment within the organization' do
      context 'for an admin' do
        let(:user) { build(:user, role: 'admin', organization: slot.place.organization) }
        it { is_expected.to permit_action(:show) }
      end
      context 'for a cpip' do
        let(:user) { build(:user, role: 'cpip', organization: slot.place.organization) }
        it { is_expected.to permit_action(:show) }
      end
      context 'for a psychologist' do
        let(:user) { build(:user, role: 'psychologist', organization: slot.place.organization) }
        it { is_expected.to permit_action(:show) }
      end
      context 'for an overseer' do
        let(:user) { build(:user, role: 'overseer', organization: slot.place.organization) }
        it { is_expected.to permit_action(:show) }
      end
      context 'for a secretary_spip' do
        let(:user) { build(:user, role: 'secretary_spip', organization: slot.place.organization) }
        it { is_expected.to permit_action(:show) }
      end
      context 'for a dpip' do
        let(:user) { build(:user, role: 'dpip', organization: slot.place.organization) }
        it { is_expected.to permit_action(:show) }
      end
      context 'for an educator' do
        let(:user) { build(:user, role: 'educator', organization: slot.place.organization) }
        it { is_expected.to permit_action(:show) }
      end
      context 'for a local_admin spip' do
        let(:user) { build(:user, role: 'cpip', organization: slot.place.organization) }
        it { is_expected.to permit_action(:show) }
      end

      context 'tj' do
        let(:organization) { build(:organization, organization_type: 'tj') }
        let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

        context 'for a secretary_court' do
          let(:user) { build(:user, role: 'secretary_court', organization: slot.place.organization) }
          it { is_expected.to permit_action(:show) }
        end
        context 'for a jap' do
          let(:user) { build(:user, role: 'jap', organization: slot.place.organization) }
          it { is_expected.to permit_action(:show) }
        end
        context 'for a dir_greff_sap' do
          let(:user) { build(:user, role: 'dir_greff_sap', organization: slot.place.organization) }
          it { is_expected.to permit_action(:show) }
        end
        context 'for a greff_sap' do
          let(:user) { build(:user, role: 'greff_sap', organization: slot.place.organization) }
          it { is_expected.to permit_action(:show) }
        end

        context 'for a local admin tj' do
          let(:user) { build(:user, role: 'local_admin', organization: slot.place.organization) }
          it { is_expected.to permit_action(:show) }
        end

        context 'work at bex' do
          context 'for a prosecutor' do
            let(:user) { build(:user, role: 'prosecutor', organization: slot.place.organization) }
            it { is_expected.to permit_action(:show) }
          end
          context 'for a bex' do
            let(:user) { build(:user, role: 'bex', organization: slot.place.organization) }
            it { is_expected.to permit_action(:show) }
          end
          context 'for a dir_greff_bex' do
            let(:user) { build(:user, role: 'dir_greff_bex', organization: slot.place.organization) }
            it { is_expected.to permit_action(:show) }
          end
          context 'for a greff_co' do
            let(:user) { build(:user, role: 'greff_co', organization: slot.place.organization) }
            it { is_expected.to permit_action(:show) }
          end
          context 'for a greff_tpe' do
            let(:user) { build(:user, role: 'greff_tpe', organization: slot.place.organization) }
            it { is_expected.to permit_action(:show) }
          end
          context 'for a greff_crpc' do
            let(:user) { build(:user, role: 'greff_crpc', organization: slot.place.organization) }
            it { is_expected.to permit_action(:show) }
          end
          context 'for a greff_ca' do
            let(:user) { build(:user, role: 'greff_ca', organization: slot.place.organization) }
            it { is_expected.to permit_action(:show) }
          end
        end
      end
    end

    context 'for an appointment created by the organization' do
      context 'tj' do
        let(:organization2) { build(:organization, organization_type: 'tj') }
        let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }
        let!(:appointment) do
          create(:appointment, slot:, state: :booked, creating_organization: organization2, convict:)
        end
        context 'for a secretary_court' do
          let(:user) { build(:user, role: 'secretary_court', organization: organization2) }
          it { is_expected.to permit_action(:show) }
        end
        context 'for a jap' do
          let(:user) { build(:user, role: 'jap', organization: organization2) }
          it { is_expected.to permit_action(:show) }
        end
        context 'for a dir_greff_sap' do
          let(:user) { build(:user, role: 'dir_greff_sap', organization: organization2) }
          it { is_expected.to permit_action(:show) }
        end
        context 'for a greff_sap' do
          let(:user) { build(:user, role: 'greff_sap', organization: organization2) }
          it { is_expected.to permit_action(:show) }
        end

        context 'for a local admin tj' do
          let(:user) { build(:user, role: 'local_admin', organization: organization2) }
          it { is_expected.to permit_action(:show) }
        end

        context 'work at bex' do
          context 'for a prosecutor' do
            let(:user) { build(:user, role: 'prosecutor', organization: organization2) }
            it { is_expected.to permit_action(:show) }
          end
          context 'for a bex' do
            let(:user) { build(:user, role: 'bex', organization: organization2) }
            it { is_expected.to permit_action(:show) }
          end
          context 'for a dir_greff_bex' do
            let(:user) { build(:user, role: 'dir_greff_bex', organization: organization2) }
            it { is_expected.to permit_action(:show) }
          end
          context 'for a greff_co' do
            let(:user) { build(:user, role: 'greff_co', organization: organization2) }
            it { is_expected.to permit_action(:show) }
          end
          context 'for a greff_tpe' do
            let(:user) { build(:user, role: 'greff_tpe', organization: organization2) }
            it { is_expected.to permit_action(:show) }
          end
          context 'for a greff_crpc' do
            let(:user) { build(:user, role: 'greff_crpc', organization: organization2) }
            it { is_expected.to permit_action(:show) }
          end
          context 'for a greff_ca' do
            let(:user) { build(:user, role: 'greff_ca', organization: organization2) }
            it { is_expected.to permit_action(:show) }
          end
        end
      end
    end

    context 'for an appointment outside of the organization' do
      let(:organization2) { build(:organization, organization_type: 'spip') }
      context 'for an admin' do
        let(:user) { build(:user, role: 'admin', organization: organization2) }
        it { is_expected.to forbid_action(:show) }
      end
      context 'for a cpip' do
        let(:user) { build(:user, role: 'cpip', organization: organization2) }
        it { is_expected.to forbid_action(:show) }
      end
      context 'for a psychologist' do
        let(:user) { build(:user, role: 'psychologist', organization: organization2) }
        it { is_expected.to forbid_action(:show) }
      end
      context 'for an overseer' do
        let(:user) { build(:user, role: 'overseer', organization: organization2) }
        it { is_expected.to forbid_action(:show) }
      end
      context 'for a secretary_spip' do
        let(:user) { build(:user, role: 'secretary_spip', organization: organization2) }
        it { is_expected.to forbid_action(:show) }
      end
      context 'for a dpip' do
        let(:user) { build(:user, role: 'dpip', organization: organization2) }
        it { is_expected.to forbid_action(:show) }
      end
      context 'for an educator' do
        let(:user) { build(:user, role: 'educator', organization: organization2) }
        it { is_expected.to forbid_action(:show) }
      end
      context 'for a local_admin spip' do
        let(:user) { build(:user, role: 'cpip', organization: organization2) }
        it { is_expected.to forbid_action(:show) }
      end

      context 'tj' do
        let(:organization) { build(:organization, organization_type: 'spip') }
        let(:organization2) { build(:organization, organization_type: 'tj') }
        let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

        context 'for a secretary_court' do
          let(:user) { build(:user, role: 'secretary_court', organization: organization2) }
          it { is_expected.to forbid_action(:show) }
        end
        context 'for a jap' do
          let(:user) { build(:user, role: 'jap', organization: organization2) }
          it { is_expected.to forbid_action(:show) }
        end
        context 'for a dir_greff_sap' do
          let(:user) { build(:user, role: 'dir_greff_sap', organization: organization2) }
          it { is_expected.to forbid_action(:show) }
        end
        context 'for a greff_sap' do
          let(:user) { build(:user, role: 'greff_sap', organization: organization2) }
          it { is_expected.to forbid_action(:show) }
        end

        context 'for a local admin tj' do
          let(:user) { build(:user, role: 'local_admin', organization: organization2) }
          it { is_expected.to forbid_action(:show) }
        end

        context 'work at bex' do
          context 'for a prosecutor' do
            let(:user) { build(:user, role: 'prosecutor', organization: organization2) }
            it { is_expected.to forbid_action(:show) }
          end
          context 'for a bex' do
            let(:user) { build(:user, role: 'bex', organization: organization2) }
            it { is_expected.to forbid_action(:show) }
          end
          context 'for a dir_greff_bex' do
            let(:user) { build(:user, role: 'dir_greff_bex', organization: organization2) }
            it { is_expected.to forbid_action(:show) }
          end
          context 'for a greff_co' do
            let(:user) { build(:user, role: 'greff_co', organization: organization2) }
            it { is_expected.to forbid_action(:show) }
          end
          context 'for a greff_tpe' do
            let(:user) { build(:user, role: 'greff_tpe', organization: organization2) }
            it { is_expected.to forbid_action(:show) }
          end
          context 'for a greff_crpc' do
            let(:user) { build(:user, role: 'greff_crpc', organization: organization2) }
            it { is_expected.to forbid_action(:show) }
          end
          context 'for a greff_ca' do
            let(:user) { build(:user, role: 'greff_ca', organization: organization2) }
            it { is_expected.to forbid_action(:show) }
          end
        end
      end
    end

    context 'for an appointment in jurisdiction' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }
      let(:organization2) { build(:organization, organization_type: 'spip', tjs: [slot.place.organization]) }
      context 'for an admin' do
        let(:user) { build(:user, role: 'admin', organization: organization2) }
        it { is_expected.to forbid_action(:show) }
      end
      context 'for a cpip' do
        let(:user) { build(:user, role: 'cpip', organization: organization2) }
        it { is_expected.to forbid_action(:show) }
      end
      context 'for a psychologist' do
        let(:user) { build(:user, role: 'psychologist', organization: organization2) }
        it { is_expected.to forbid_action(:show) }
      end
      context 'for an overseer' do
        let(:user) { build(:user, role: 'overseer', organization: organization2) }
        it { is_expected.to forbid_action(:show) }
      end
      context 'for a secretary_spip' do
        let(:user) { build(:user, role: 'secretary_spip', organization: organization2) }
        it { is_expected.to forbid_action(:show) }
      end
      context 'for a dpip' do
        let(:user) { build(:user, role: 'dpip', organization: organization2) }
        it { is_expected.to forbid_action(:show) }
      end
      context 'for an educator' do
        let(:user) { build(:user, role: 'educator', organization: organization2) }
        it { is_expected.to forbid_action(:show) }
      end
      context 'for a local_admin spip' do
        let(:user) { build(:user, role: 'cpip', organization: organization2) }
        it { is_expected.to forbid_action(:show) }
      end

      context 'tj' do
        let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }
        let(:organization2) { build(:organization, organization_type: 'tj', spips: [slot.place.organization]) }

        context 'for a secretary_court' do
          let(:user) { build(:user, role: 'secretary_court', organization: organization2) }
          it { is_expected.to forbid_action(:show) }
        end
        context 'for a jap' do
          let(:user) { build(:user, role: 'jap', organization: organization2) }
          it { is_expected.to forbid_action(:show) }
        end
        context 'for a dir_greff_sap' do
          let(:user) { build(:user, role: 'dir_greff_sap', organization: organization2) }
          it { is_expected.to forbid_action(:show) }
        end
        context 'for a greff_sap' do
          let(:user) { build(:user, role: 'greff_sap', organization: organization2) }
          it { is_expected.to forbid_action(:show) }
        end

        context 'for a local admin tj' do
          let(:user) { build(:user, role: 'local_admin', organization: organization2) }
          it { is_expected.to permit_action(:show) }
        end

        context 'work at bex' do
          context 'for a prosecutor' do
            let(:user) { build(:user, role: 'prosecutor', organization: organization2) }
            it { is_expected.to permit_action(:show) }
          end
          context 'for a bex' do
            let(:user) { build(:user, role: 'bex', organization: organization2) }
            it { is_expected.to permit_action(:show) }
          end
          context 'for a dir_greff_bex' do
            let(:user) { build(:user, role: 'dir_greff_bex', organization: organization2) }
            it { is_expected.to permit_action(:show) }
          end
          context 'for a greff_co' do
            let(:user) { build(:user, role: 'greff_co', organization: organization2) }
            it { is_expected.to permit_action(:show) }
          end
          context 'for a greff_tpe' do
            let(:user) { build(:user, role: 'greff_tpe', organization: organization2) }
            it { is_expected.to permit_action(:show) }
          end
          context 'for a greff_crpc' do
            let(:user) { build(:user, role: 'greff_crpc', organization: organization2) }
            it { is_expected.to permit_action(:show) }
          end
          context 'for a greff_ca' do
            let(:user) { build(:user, role: 'greff_ca', organization: organization2) }
            it { is_expected.to permit_action(:show) }
          end
        end
      end
    end
  end

  context 'for an admin' do
    let(:user) { build(:user, role: 'admin', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:cancel) }
    it { is_expected.to permit_action(:fulfil) }
    it { is_expected.to permit_action(:miss) }
    it { is_expected.to permit_action(:excuse) }
    it { is_expected.to permit_action(:rebook) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment outside of organization' do
      let(:organization2) { build(:organization, organization_type: 'tj') }
      let(:user2) { build(:user, role: 'admin', organization: organization2) }
      subject { AppointmentPolicy.new(user2, appointment) }

      it { is_expected.to forbid_action(:show) }
    end
  end

  context 'for an local_admin spip' do
    let(:user) { build(:user, :in_organization, type: 'spip', role: 'local_admin') }
    let(:place) { build(:place, organization: user.organization) }
    let(:agenda) { build :agenda, place: }
    let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }
    let(:slot) { create :slot, :without_validations, appointment_type:, agenda: }
    let!(:appointment) { create(:appointment, slot:, state: :booked) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:cancel) }
    it { is_expected.to permit_action(:fulfil) }
    it { is_expected.to permit_action(:miss) }
    it { is_expected.to permit_action(:excuse) }
    it { is_expected.to permit_action(:rebook) }
    it { is_expected.not_to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment outside of organization' do
      let(:organization2) { build(:organization, organization_type: 'spip') }
      let(:user2) { build(:user, role: 'local_admin', organization: organization2) }
      subject { AppointmentPolicy.new(user2, appointment) }

      it { is_expected.to forbid_action(:show) }
    end
  end

  context 'for an local_admin tj' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'local_admin', organization:) }
    let(:place) { build(:place, organization: user.organization) }
    let(:agenda) { build :agenda, place: }
    let(:slot) { create :slot, :without_validations, appointment_type:, agenda: }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:cancel) }
    it { is_expected.to permit_action(:fulfil) }
    it { is_expected.to permit_action(:miss) }
    it { is_expected.to permit_action(:excuse) }
    it { is_expected.to permit_action(:rebook) }
    it { is_expected.not_to permit_action(:agenda_spip) }
    it { is_expected.to permit_action(:agenda_jap) }

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:organization2) { build :organization, organization_type: 'spip' }
      let(:place) { build(:place, organization: organization2) }
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }
      let(:organization) { build(:organization, organization_type: 'tj', spips: [organization2]) }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context 'show?' do
      let(:organization2) { build(:organization, organization_type: 'tj') }
      let(:user2) { build(:user, role: 'local_admin', organization: organization2) }

      context 'for an appointment outside of organization' do
        subject { AppointmentPolicy.new(user2, appointment) }

        it { is_expected.to forbid_action(:show) }
      end

      context 'for an appointment in jurisdiction' do
        let(:organization2) { build(:organization, organization_type: 'tj', spips: [organization]) }
        subject { AppointmentPolicy.new(user2, appointment) }

        it { is_expected.to permit_action(:show) }
      end

      context 'for an appointment created by user organization' do
        let!(:appointment) do
          create(:appointment, slot:, state: :booked, creating_organization: user2.organization, convict:)
        end
        subject { AppointmentPolicy.new(user2, appointment) }

        it { is_expected.to permit_action(:show) }
      end
    end
  end

  context 'for a prosecutor' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'prosecutor', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment outside of organization' do
      let(:organization2) { build(:organization, organization_type: 'tj') }
      let(:user2) { build(:user, role: 'prosecutor', organization: organization2) }
      subject { AppointmentPolicy.new(user2, appointment) }

      it { is_expected.to forbid_action(:show) }
    end

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a jap user' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'jap', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to forbid_action(:agenda_spip) }

    context 'for an appointment outside of organization' do
      let(:organization2) { build(:organization, organization_type: 'tj') }
      let(:user2) { build(:user, role: 'jap', organization: organization2) }
      subject { AppointmentPolicy.new(user2, appointment) }

      it { is_expected.to forbid_action(:show) }
    end

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a court secretary' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'secretary_court', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to forbid_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment outside of organization' do
      let(:organization2) { build(:organization, organization_type: 'tj') }
      let(:user2) { build(:user, role: 'secretary_court', organization: organization2) }
      subject { AppointmentPolicy.new(user2, appointment) }

      it { is_expected.to forbid_action(:show) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a dir_greff_bex user' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'dir_greff_bex', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a bex user' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'bex', organization:) }
    let(:place) { build(:place, organization: user.organization) }
    let(:agenda) { build :agenda, place: }
    let(:slot) { create :slot, :without_validations, appointment_type:, agenda: }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:organization2) { build :organization, organization_type: 'spip' }
      let(:place) { build(:place, organization: organization2) }
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }
      let(:organization) { build(:organization, organization_type: 'tj', spips: [organization2]) }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a greff_co user' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'greff_co', organization:) }
    let(:place) { build(:place, organization: user.organization) }
    let(:agenda) { build :agenda, place: }
    let(:slot) { create :slot, :without_validations, appointment_type:, agenda: }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:organization2) { build :organization, organization_type: 'spip' }
      let(:place) { build(:place, organization: organization2) }
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }
      let(:organization) { build(:organization, organization_type: 'tj', spips: [organization2]) }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a greff_tpe user' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'greff_tpe', organization:) }
    let(:place) { build(:place, organization: user.organization) }
    let(:agenda) { build :agenda, place: }
    let(:slot) { create :slot, :without_validations, appointment_type:, agenda: }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:organization2) { build :organization, organization_type: 'spip' }
      let(:place) { build(:place, organization: organization2) }
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }
      let(:organization) { build(:organization, organization_type: 'tj', spips: [organization2]) }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a greff_crpc user' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'greff_crpc', organization:) }
    let(:place) { build(:place, organization: user.organization) }
    let(:agenda) { build :agenda, place: }
    let(:slot) { create :slot, :without_validations, appointment_type:, agenda: }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:organization2) { build :organization, organization_type: 'spip' }
      let(:place) { build(:place, organization: organization2) }
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }
      let(:organization) { build(:organization, organization_type: 'tj', spips: [organization2]) }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a greff_ca user' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'greff_ca', organization:) }
    let(:place) { build(:place, organization: user.organization) }
    let(:agenda) { build :agenda, place: }
    let(:slot) { create :slot, :without_validations, appointment_type:, agenda: }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:organization2) { build :organization, organization_type: 'spip' }
      let(:place) { build(:place, organization: organization2) }
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }
      let(:organization) { build(:organization, organization_type: 'tj', spips: [organization2]) }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a dir_greff_sap user' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'dir_greff_sap', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to forbid_action(:agenda_spip) }

    context 'for an appointment outside of organization' do
      let(:organization2) { build(:organization, organization_type: 'tj') }
      let(:user2) { build(:user, role: 'dir_greff_sap', organization: organization2) }
      subject { AppointmentPolicy.new(user2, appointment) }

      it { is_expected.to forbid_action(:show) }
    end

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a greff_sap user' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'greff_sap', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to forbid_action(:agenda_spip) }

    context 'for an appointment outside of organization' do
      let(:organization2) { build(:organization, organization_type: 'tj') }
      let(:user2) { build(:user, role: 'greff_sap', organization: organization2) }
      subject { AppointmentPolicy.new(user2, appointment) }

      it { is_expected.to forbid_action(:show) }
    end

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a cpip user' do
    let(:organization) { build(:organization, organization_type: 'spip') }
    let(:user) { build(:user, role: 'cpip', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment outside of organization' do
      let(:organization2) { build(:organization, organization_type: 'spip') }
      let(:user2) { build(:user, role: 'cpip', organization: organization2) }
      subject { AppointmentPolicy.new(user2, appointment) }

      it { is_expected.to forbid_action(:show) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP from another service' do
      let(:organization) { create(:organization) }
      let(:user) { build(:user, role: 'cpip', organization:) }
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to forbid_action(:fulfil) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a educator user' do
    let(:organization) { build(:organization, organization_type: 'spip') }
    let(:user) { build(:user, role: 'educator', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment outside of organization' do
      let(:organization2) { build(:organization, organization_type: 'spip') }
      let(:user2) { build(:user, role: 'educator', organization: organization2) }
      subject { AppointmentPolicy.new(user2, appointment) }

      it { is_expected.to forbid_action(:show) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a psychologist user' do
    let(:organization) { build(:organization, organization_type: 'spip') }
    let(:user) { build(:user, role: 'psychologist', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment outside of organization' do
      let(:organization2) { build(:organization, organization_type: 'spip') }
      let(:user2) { build(:user, role: 'psychologist', organization: organization2) }
      subject { AppointmentPolicy.new(user2, appointment) }

      it { is_expected.to forbid_action(:show) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a overseer user' do
    let(:organization) { build(:organization, organization_type: 'spip') }
    let(:user) { build(:user, role: 'overseer', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment outside of organization' do
      let(:organization2) { build(:organization, organization_type: 'spip') }
      let(:user2) { build(:user, role: 'overseer', organization: organization2) }
      subject { AppointmentPolicy.new(user2, appointment) }

      it { is_expected.to forbid_action(:show) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a dpip user' do
    let(:organization) { build(:organization, organization_type: 'spip') }
    let(:user) { build(:user, role: 'dpip', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment outside of organization' do
      let(:organization2) { build(:organization, organization_type: 'spip') }
      let(:user2) { build(:user, role: 'dpip', organization: organization2) }
      subject { AppointmentPolicy.new(user2, appointment) }

      it { is_expected.to forbid_action(:show) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a secretary_spip user' do
    let(:organization) { build(:organization, organization_type: 'spip') }
    let(:user) { build(:user, role: 'secretary_spip', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment outside of organization' do
      let(:organization2) { build(:organization, organization_type: 'spip') }
      let(:user2) { build(:user, role: 'secretary_spip', organization: organization2) }
      subject { AppointmentPolicy.new(user2, appointment) }

      it { is_expected.to forbid_action(:show) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end
end
