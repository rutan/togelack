class SessionsController < ApplicationController
  skip_before_action :require_login_in_private

  # GET /auth/slack/callback
  def create
    auth = request.env['omniauth.auth']
    unless valid_auth?(auth)
      redirect_to '/'
      return
    end

    user = create_or_update_user(auth)
    session[:user_id] = user.uid
    session[:token] = auth.credentials.token

    redirect_to '/'
  end

  # DELETE /logout
  def destroy
    session[:user_id] = nil
    session[:token] = nil
    redirect_to '/'
  end

  private

  def valid_auth?(auth)
    return false unless auth
    return false unless auth['provider'] == 'slack'
    return false unless auth['info']['team_id'] == ENV['SLACK_TEAM_ID']

    true
  end

  def create_or_update_user(auth)
    user = User.find_or_initialize_by(uid: auth['uid'])
    user.name = auth['info']['nickname']
    user.avatar_url = auth['info']['image']
    user.is_admin = auth.extra.user_info['user']['is_admin']
    user.save!

    user
  end
end
