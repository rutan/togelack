class UsersController < ApplicationController
  before_action :set_user

  def show
    page = (params[:page] || 1).to_i
    source = @user.summaries.newest.page(page)
    @summaries = SummaryDecorator.decorate_collection(source)
  end

  private

  def set_user
    @user = User.find_by(name: params[:name])
  rescue StandardError => e
    Rails.logger.debug e.backtrace.inspect
    raise e
  end
end
