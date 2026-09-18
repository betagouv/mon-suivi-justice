require 'rails_helper'

RSpec.describe 'Session invalidation', type: :request do
  it 'invalidates the session server-side on sign out, so a replayed cookie no longer authenticates' do
    session_key = Rails.application.config.session_options[:key]
    user = create(:user, :in_organization)

    post user_session_path, params: { user: { email: user.email, password: user.password } }
    expect(response).to redirect_to(root_path)

    get convicts_path
    expect(response).to have_http_status(:ok)

    old_session_cookie = cookies[session_key]

    delete destroy_user_session_path

    cookies[session_key] = old_session_cookie

    get convicts_path
    expect(response).to redirect_to(new_user_session_path)
  end
end
