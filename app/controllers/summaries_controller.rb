require 'slack'

class SummariesController < ApplicationController
  before_action :do_check_login, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_summary, only: [:show, :edit, :update, :destroy]

  def index
    page = (params[:page] || 1).to_i
    source = Summary.newest.page(page)
    @summaries = SummaryDecorator.decorate_collection(source)
  end

  def list
    page = (params[:page] || 1).to_i
    source = Summary.newest.page(page).per(25)
    source = source.match_text(params[:keyword]) if params[:keyword]
    @summaries = SummaryDecorator.decorate_collection(source)
  end

  def new
    @summary = SummaryDecorator.decorate(Summary.new)
  end

  def create
    @summary = Summary.new(summary_params)
    if @summary.save
      if ENV['SLACK_CHANNEL']
        EM.defer do
          poster = SlackSupport::Poster.new(Slack::Client.new(token: ENV['SLACK_TOKEN']), ENV['SLACK_CHANNEL'])
          poster.post(@current_user, summary_url(@summary), @summary.title, @summary.description)
        end
      end
      render json: {result: @summary.decorate}, root: nil
    else
      raise 'error'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @summary.update(summary_params)
      render json: {result: @summary.decorate}, root: nil
    else
      raise 'error'
    end
  end

  def destroy
    raise 'permission error' unless @summary.user == @current_user || @current_user.admin?
    @summary.destroy
    redirect_to '/'
  end

  private

  def set_summary
    @summary = Summary.find(params[:id]).decorate
  end

  def summary_params
    n = params.permit(:title, :description, :messages => [])
    n[:user] = @current_user
    n[:messages] = n[:messages].uniq.reject(&:empty?).map { |n| Message.find(n) }
    n
  end
end
