require 'rails_helper'

describe AppointmentPolicy do
  subject { AppointmentPolicy.new(user, appointment) }
  let(:organization) { build(:organization, organization_type: 'spip') }
  let(:place) { build(:place, organization:) }
  let(:agenda) { build :agenda, place: }
  let(:appointment_type) { create(:appointment_type) }
  let(:slot) { create :slot, :without_validations, appointment_type:, agenda:, date: Date.yesterday }
  let(:convict) { create :convict, organizations: [slot.place.organization] }
  let!(:appointment) do
    create(:appointment, :skip_validate, slot:, state: :booked, creating_organization: slot.place.organization,
                                         convict:)
  end

  context 'appointment date' do
    let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }
    let(:user) do
      build(:user, role: 'local_admin', organization: slot.place.organization,
                   security_charter_accepted_at: Time.zone.yesterday)
    end
    let!(:appointment) do
      create(:appointment, :skip_validate, slot:, state: :booked, creating_organization: slot.place.organization,
                                           convict:)
    end
    context 'in the past' do
      let(:slot) { create :slot, :without_validations, appointment_type:, agenda:, date: 2.day.ago }
      it { is_expected.to forbid_action(:cancel) }
    end
    context 'in the future' do
      let(:slot) { create :slot, :without_validations, appointment_type:, agenda:, date: 2.day.from_now }
      it { is_expected.to permit_action(:cancel) }
    end
  end

  context 'for a user who has not accepted the security charter' do
    let(:user) { build(:user, role: 'admin', organization: slot.place.organization, security_charter_accepted_at: nil) }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to forbid_action(:agenda_sap_ddse) }
    it { is_expected.to forbid_action(:agenda_spip) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:cancel) }
    it { is_expected.to forbid_action(:fulfil) }
    it { is_expected.to forbid_action(:miss) }
    it { is_expected.to forbid_action(:excuse) }
    it { is_expected.to forbid_action(:rebook) }
    it { is_expected.to forbid_action(:prepare) }
    it { is_expected.to forbid_action(:fulfil_old) }
    it { is_expected.to forbid_action(:excuse_old) }
    it { is_expected.to forbid_action(:rebook_old) }
  end

  context 'scope' do
    let(:spip1) { build(:organization, organization_type: 'spip') }
    let(:tj_with_spip1) { build(:organization, organization_type: 'tj', spips: [spip1]) }
    let(:spip2) { build(:organization, organization_type: 'spip') }
    let(:sortie_audience_spip) { create(:appointment_type, name: "Sortie d'audience SPIP") }
    let(:suivi_spip) { create(:appointment_type, name: 'Convocation de suivi SPIP') }
    let(:ddse) { create(:appointment_type, name: 'SAP DDSE') }
    let(:sap_debat) { create(:appointment_type, name: 'SAP débat contradictoire') }
    let(:place_spip1) { build(:place, organization: spip1) }
    let(:place_tj_with_spip1) { build(:place, organization: tj_with_spip1) }
    let(:place_spip2) { build(:place, organization: spip2) }
    let(:agenda1) { build :agenda, place: place_spip1 }
    let(:agenda2) { build :agenda, place: place_tj_with_spip1 }
    let(:agenda3) { build :agenda, place: place_spip2 }
    let(:convict1) { create :convict, organizations: [spip1, tj_with_spip1] }
    let(:convict2) { create :convict, organizations: [tj_with_spip1, spip1] }
    let(:convict3) { create :convict, organizations: [spip2] }
    let(:slot1) { create :slot, :without_validations, appointment_type: sortie_audience_spip, agenda: agenda1 }
    let(:slot2) { create :slot, :without_validations, appointment_type: suivi_spip, agenda: agenda1 }
    let(:slot3) { create :slot, :without_validations, appointment_type: ddse, agenda: agenda1 }
    let(:slot4) { create :slot, :without_validations, appointment_type: sap_debat, agenda: agenda1 }
    let(:slot5) { create :slot, :without_validations, appointment_type: sortie_audience_spip, agenda: agenda2 }
    let(:slot6) { create :slot, :without_validations, appointment_type: suivi_spip, agenda: agenda2 }
    let(:slot7) { create :slot, :without_validations, appointment_type: ddse, agenda: agenda2 }
    let(:slot8) { create :slot, :without_validations, appointment_type: sap_debat, agenda: agenda2 }
    let(:slot9) { create :slot, :without_validations, appointment_type: sortie_audience_spip, agenda: agenda3 }
    let(:slot10) { create :slot, :without_validations, appointment_type: suivi_spip, agenda: agenda3 }
    let(:slot11) { create :slot, :without_validations, appointment_type: ddse, agenda: agenda3 }
    let(:slot12) { create :slot, :without_validations, appointment_type: sap_debat, agenda: agenda3 }
    let!(:appointment1) do
      create(:appointment, slot: slot1, state: :booked, creating_organization: slot1.place.organization,
                           convict: convict1)
    end
    let!(:appointment2) do
      create(:appointment, slot: slot2, state: :booked, creating_organization: slot2.place.organization,
                           convict: convict1)
    end
    let!(:appointment3) do
      create(:appointment, slot: slot3, state: :booked, creating_organization: slot3.place.organization,
                           convict: convict1)
    end
    let!(:appointment4) do
      create(:appointment, slot: slot4, state: :booked, creating_organization: slot4.place.organization,
                           convict: convict1)
    end
    let!(:appointment5) do
      create(:appointment, slot: slot5, state: :booked, creating_organization: slot5.place.organization,
                           convict: convict2)
    end
    let!(:appointment6) do
      create(:appointment, slot: slot6, state: :booked, creating_organization: slot6.place.organization,
                           convict: convict2)
    end
    let!(:appointment7) do
      create(:appointment, slot: slot7, state: :booked, creating_organization: slot7.place.organization,
                           convict: convict2)
    end
    let!(:appointment8) do
      create(:appointment, slot: slot8, state: :booked, creating_organization: slot8.place.organization,
                           convict: convict2)
    end
    let!(:appointment9) do
      create(:appointment, slot: slot9, state: :booked, creating_organization: slot9.place.organization,
                           convict: convict3)
    end
    let!(:appointment10) do
      create(:appointment, slot: slot10, state: :booked, creating_organization: slot10.place.organization,
                           convict: convict3)
    end
    let!(:appointment11) do
      create(:appointment, slot: slot11, state: :booked, creating_organization: slot11.place.organization,
                           convict: convict3)
    end
    let!(:appointment12) do
      create(:appointment, slot: slot12, state: :booked, creating_organization: slot12.place.organization,
                           convict: convict3)
    end
    let!(:appointment13) do
      create(:appointment, slot: slot11, state: :booked, creating_organization: tj_with_spip1,
                           convict: convict3)
    end
    let!(:appointment14) do
      create(:appointment, slot: slot9, state: :booked, creating_organization: tj_with_spip1,
                           convict: convict3)
    end

    context 'for an bex user' do
      let(:user) { build(:user, role: 'bex', organization: tj_with_spip1) }

      it 'returns the appointments of the organization,
         created by the organization and the ones used at bex in the juridiction' do
        expect(described_class::Scope.new(user,
                                          Appointment).resolve).to match_array([appointment1, appointment5,
                                                                                appointment6, appointment7,
                                                                                appointment8, appointment13,
                                                                                appointment14])
      end
    end
    context 'for an admin_local_tj user' do
      let(:user) { build(:user, role: 'local_admin', organization: tj_with_spip1) }

      it 'returns the appointments of the organization,
         created by the organization and the ones used by local admin tj in the juridiction' do
        expect(described_class::Scope.new(user,
                                          Appointment).resolve).to match_array([appointment1, appointment3,
                                                                                appointment4, appointment5,
                                                                                appointment6, appointment7,
                                                                                appointment8, appointment13,
                                                                                appointment14])
      end
    end
    context 'for an sap user' do
      let(:user) { build(:user, role: 'jap', organization: tj_with_spip1) }

      it 'returns the appointments of the organization and the DDSE appointments created by the organization' do
        expected = [appointment1, appointment3, appointment4, appointment5, appointment7, appointment8, appointment13,
                    appointment14]
        actual = described_class::Scope.new(user, Appointment).resolve

        expect(actual).to match_array(expected)
      end
    end
    context 'for a CPIP' do
      let(:user) { build(:user, role: 'cpip', organization: spip1) }

      it 'returns the appointments of the organization' do
        expect(described_class::Scope.new(user,
                                          Appointment).resolve).to match_array([appointment1, appointment2,
                                                                                appointment3, appointment4])
      end
    end
  end

  context 'related to appointment status' do
    let(:user) { build(:user, role: 'admin', organization: slot.place.organization) }

    context 'for a booked appointment' do
      let(:slot) { create(:slot, appointment_type:, agenda:) }
      let!(:appointment) { create(:appointment, :skip_validate, slot:, state: 'booked') }
      subject { AppointmentPolicy.new(user, appointment) }

      it { is_expected.to permit_action(:cancel) }
    end

    context 'for a canceled appointment' do
      let!(:appointment) { create(:appointment, :skip_validate, slot:, state: 'canceled') }
      subject { AppointmentPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:cancel) }
    end

    context 'for a created appointment' do
      let!(:appointment) { create(:appointment, :skip_validate, slot:, state: 'created') }
      subject { AppointmentPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:cancel) }
    end

    context 'for a fulfiled appointment' do
      let!(:appointment) { create(:appointment, :skip_validate, slot:, state: 'fulfiled') }
      subject { AppointmentPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:cancel) }
    end

    context 'for a no_show appointment' do
      let!(:appointment) { create(:appointment, :skip_validate, slot:, state: 'no_show') }
      subject { AppointmentPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:cancel) }
    end

    context 'for a excused appointment' do
      let!(:appointment) { create(:appointment, :skip_validate, slot:, state: 'excused') }
      subject { AppointmentPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:cancel) }
    end
  end

  context 'show?' do
    context 'for an appointment within the organization' do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }

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
        let(:appointment_type) { create(:appointment_type, name: 'SAP DDSE') }
        let!(:appointment) do
          create(:appointment, :skip_validate, slot:, state: :booked, creating_organization: organization2, convict:)
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
          let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }

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
        let(:organization2) { build(:organization, organization_type: 'tj', spips: [slot.place.organization]) }

        context 'Sortie d\'audience SPIP' do
          let(:appointment_type) { create(:appointment_type, name: 'Sortie d\'audience SPIP') }

          context 'for a local admin tj' do
            let(:user) { build(:user, role: 'local_admin', organization: organization2) }
            it { is_expected.to permit_action(:show) }
          end

          context 'for a local admin tj and a SPIP a' do
            let(:user) { build(:user, role: 'local_admin', organization: organization2) }
            it { is_expected.to permit_action(:show) }
          end

          context 'work_at_sap' do
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

            context 'appointment_type is SAP DDSE' do
              let!(:appointment) do
                create(:appointment, :skip_validate, slot:, state: :booked, creating_organization: user.organization,
                                                     convict:)
              end
              let(:appointment_type) { create(:appointment_type, name: 'SAP DDSE') }

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
            end
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
        context 'Convocation de suivi SPIP' do
          let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }

          context 'for a local admin tj' do
            let(:user) { build(:user, role: 'local_admin', organization: organization2) }
            it { is_expected.to forbid_action(:show) }
          end

          context 'for a local admin tj and a SPIP a' do
            let(:user) { build(:user, role: 'local_admin', organization: organization2) }
            it { is_expected.to forbid_action(:show) }
          end

          context 'work_at_sap' do
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
    end
  end

  context 'create?' do
    context 'work at bex' do
      let(:tj) { build(:organization, organization_type: 'tj', spips: [organization]) }
      let(:user) { build(:user, role: 'bex', organization: tj) }
      context 'appointment in organization' do
        let(:place) { build(:place, organization: tj) }
        it { is_expected.to permit_action(:create) }
      end
      context 'appointment in jurisdiction and appointment_type bex' do
        let(:appointment_type) { create(:appointment_type, name: 'Sortie d\'audience SPIP') }
        it { is_expected.to permit_action(:create) }
      end
      context 'appointment in jurisdiction' do
        it { is_expected.to forbid_action(:create) }
      end
      context 'inter ressort' do
        let(:tj) { build(:organization, organization_type: 'tj', use_inter_ressort: true) }
        it { is_expected.to permit_action(:create) }
      end
      context 'outside of organization' do
        let(:tj) { build(:organization, organization_type: 'tj') }
        it { is_expected.to forbid_action(:create) }
      end
    end
    context 'work at sap' do
      let(:tj) { build(:organization, organization_type: 'tj', spips: [organization]) }
      let(:user) { build(:user, role: 'jap', organization: tj) }
      context 'appointment in organization' do
        let(:place) { build(:place, organization: tj) }
        it { is_expected.to permit_action(:create) }
      end
      context 'appointment in jurisdiction' do
        it { is_expected.to forbid_action(:create) }
      end
      context 'inter ressort' do
        let(:tj) { build(:organization, organization_type: 'tj', use_inter_ressort: true) }
        it { is_expected.to forbid_action(:create) }
      end
      context 'outside of organization' do
        let(:tj) { build(:organization, organization_type: 'tj') }
        it { is_expected.to forbid_action(:create) }
      end
    end
    context 'work at spip' do
      let(:tj) { build(:organization, organization_type: 'tj', spips: [organization]) }
      let(:user) { build(:user, role: 'cpip', organization: tj) }
      context 'appointment in organization' do
        let(:place) { build(:place, organization: tj) }
        it { is_expected.to permit_action(:create) }
      end
      context 'appointment in jurisdiction' do
        it { is_expected.to forbid_action(:create) }
      end
      context 'inter ressort' do
        let(:tj) { build(:organization, organization_type: 'tj', use_inter_ressort: true) }
        it { is_expected.to forbid_action(:create) }
      end
      context 'outside of organization' do
        let(:tj) { build(:organization, organization_type: 'tj') }
        it { is_expected.to forbid_action(:create) }
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
    it { is_expected.to permit_action(:fulfil) }
    it { is_expected.to permit_action(:miss) }
    it { is_expected.to permit_action(:excuse) }
    it { is_expected.to permit_action(:rebook) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'can cancel an appointment' do
      let(:slot) { build(:slot, appointment_type:, agenda:) }
      it { is_expected.to permit_action(:cancel) }
    end

    context 'show for an appointment outside of organization' do
      let(:organization2) { build(:organization, organization_type: 'tj') }
      let(:user2) { build(:user, role: 'admin', organization: organization2) }
      subject { AppointmentPolicy.new(user2, appointment) }

      it { is_expected.to forbid_action(:show) }
    end

    context 'create for an appointment in jurisdiction' do
      let(:organization2) { build(:organization, organization_type: 'tj', spips: [slot.place.organization]) }
      let(:user2) { build(:user, role: 'admin', organization: organization2) }
      subject { AppointmentPolicy.new(user2, appointment) }

      it { is_expected.to permit_action(:create) }
    end

    context 'create for an appointment outside of jurisdiction' do
      let(:organization2) { build(:organization, organization_type: 'tj') }
      let(:user2) { build(:user, role: 'admin', organization: organization2) }
      subject { AppointmentPolicy.new(user2, appointment) }

      it { is_expected.to forbid_action(:create) }
    end
  end

  context 'for an local_admin spip' do
    let(:user) { build(:user, :in_organization, type: 'spip', role: 'local_admin') }
    let(:place) { build(:place, organization: user.organization) }
    let(:agenda) { build :agenda, place: }
    let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }
    let(:slot) { create :slot, :without_validations, appointment_type:, agenda:, date: Date.yesterday }
    let!(:appointment) { create(:appointment, :skip_validate, slot:, state: :booked) }

    context 'can cancel an appointment' do
      let(:slot) { build(:slot, appointment_type:, agenda:) }
      it { is_expected.to permit_action(:cancel) }
    end

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:fulfil) }
    it { is_expected.to permit_action(:miss) }
    it { is_expected.to permit_action(:excuse) }
    it { is_expected.to permit_action(:rebook) }
    it { is_expected.not_to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }
  end

  context 'for an local_admin tj' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'local_admin', organization:) }
    let(:place) { build(:place, organization: user.organization) }
    let(:agenda) { build :agenda, place: }
    let(:slot) { create :slot, :without_validations, appointment_type:, agenda:, date: Date.yesterday }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:fulfil) }
    it { is_expected.to permit_action(:miss) }
    it { is_expected.to permit_action(:excuse) }
    it { is_expected.to permit_action(:rebook) }
    it { is_expected.to permit_action(:agenda_spip) }
    it { is_expected.to permit_action(:agenda_jap) }

    context 'can cancel an appointment' do
      let(:slot) { build(:slot, appointment_type:, agenda:) }
      it { is_expected.to permit_action(:cancel) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:organization2) { build :organization, organization_type: 'spip' }
      let(:place) { build(:place, organization: organization2) }
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }
      let(:organization) { build(:organization, organization_type: 'tj', spips: [organization2]) }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi SPIP' do
      let(:organization2) { build :organization, organization_type: 'spip' }
      let(:place) { build(:place, organization: organization2) }
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }
      let(:organization) { build(:organization, organization_type: 'tj', spips: [organization2]) }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:create) }
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

  context 'for a prosecutor' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'prosecutor', organization: slot.place.organization) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a jap user' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'jap', organization: slot.place.organization) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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

  context 'for a dir_greff_bex user' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'dir_greff_bex', organization: slot.place.organization) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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
    let(:slot) { create :slot, :without_validations, appointment_type:, agenda:, date: Date.yesterday }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a dir_greff_sap user' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'dir_greff_sap', organization: slot.place.organization) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to forbid_action(:show) }
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

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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

    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP from another service' do
      let(:spip2) { create(:organization, organization_type: 'spip') }
      let(:user) { build(:user, role: 'cpip', organization: spip2) }
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to forbid_action(:fulfil) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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

    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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

    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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

    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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

    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }

      context 'can cancel an appointment' do
        let(:slot) { build(:slot, appointment_type:, agenda:) }
        it { is_expected.to permit_action(:cancel) }
      end

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
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

  describe 'state change' do
    let(:user) { build(:user, :in_organization, type: 'spip', role: 'local_admin') }
    let(:place) { build(:place, organization: user.organization) }
    let(:agenda) { build :agenda, place: }
    let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }
    let(:slot) { create :slot, :without_validations, appointment_type:, agenda: }
    let!(:appointment) { create(:appointment, slot:, state: :booked) }

    context 'past appointment' do
      before do
        allow(appointment).to receive(:in_the_past?).and_return(true)
      end
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
    end

    context 'future appointment' do
      before do
        allow(appointment).to receive(:in_the_past?).and_return(false)
      end
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
    end
  end
end
