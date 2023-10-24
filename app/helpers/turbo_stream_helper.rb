module TurboStreamHelper
  def stream_error_messages(object)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('turbostream_error_messages',
                                                  partial: 'shared/standard_error',
                                                  locals: { message: object })
      end
    end
  end
end
