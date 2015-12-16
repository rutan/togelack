require 'slack'

module API
  class HistoriesController < ApplicationController
    before_action :do_check_login

    # 暫定
    # GET /api/histories.json?url=http://〜
    def index
      client = Slack::Client.new(token: session[:token])
      chs = Services::CacheHistoryService.new(client)
      messages = chs.cache(params[:url])

      render json: {result: MessageDecorator.decorate_collection(messages)}, root: nil
    end
  end
end
