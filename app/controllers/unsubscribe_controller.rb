class UnsubscribeController < ApplicationController
  def stop_sms
    @token = params[:token]
    # Recherche du Convict correspondant au token
    @convict = Convict.find_by_token_for(:stop_sms, @token)

    return if @convict

    @error_message = 'Token invalide ou expiré.'
  end

  def refuse_phone
    @token = params[:token]
    @convict = Convict.find_by_token_for(:stop_sms, @token)

    if @convict
      if @convict.refuse_phone
        render turbo_stream: turbo_stream.replace('unsubscribe', partial: 'unsubscribe/stop_sms_success')
      else
        @error_message = 'Une erreur s\'est produite, veuillez contacter votre agent référent.'
        render turbo_stream: turbo_stream.replace('unsubscribe', partial: 'unsubscribe/stop_sms_error')
      end
    else
      @error_message = 'Token invalide ou expiré.'
      render turbo_stream: turbo_stream.replace('unsubscribe', partial: 'unsubscribe/stop_sms_error')
    end
  end

  def skip_pundit?
    true
  end
end
