require 'rails_helper'

Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'invite_convicts_to_interface.rake' do
  let!(:convict1) { create(:convict) }
  let!(:slot1) { create(:slot, date: Date.new(2021, 2, 2)) }
  let!(:convict2) { create(:convict, invitation_to_convict_interface_count: 1) }
  let!(:slot2) { create(:slot, date: Date.new(2021, 2, 2)) }
  let!(:convict3) { create(:convict, phone: nil, no_phone: true) }
  let!(:slot3) { create(:slot, date: Date.new(2021, 2, 2)) }
  let!(:convict4) { create(:convict) }
  let!(:slot4) { create(:slot, date: Date.new(2027, 2, 2)) }

  before do
    appointment1 = build(:appointment, slot: slot1, convict: convict1)
    appointment1.save(validate: false)
    appointment2 = build(:appointment, slot: slot2, convict: convict2)
    appointment2.save(validate: false)
    appointment3 = build(:appointment, slot: slot3, convict: convict3)
    appointment3.save(validate: false)
    appointment4 = build(:appointment, slot: slot4, convict: convict4)
    appointment4.save(validate: false)
  end

  pending 'invites the right convicts' do
    expect do
      Rake::Task['invite_convicts_to_interface'].invoke
    end.to have_enqueued_job(InviteConvictJob).once.with(convict1.id)
  end
end
