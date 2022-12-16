class UpdateConvictPhoneJob < ApplicationJob
  sidekiq_options retry: 5
  queue_as :default

  def perform(convict_id)
    @convict = Convict.find(convict_id)
    return unless @convict.phone.present?

    params = { phone: @convict.phone, msj_id: @convict.id }

    MonSuiviJusticePublicApi::Convict.update_phone(params)
  end
end
