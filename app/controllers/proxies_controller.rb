require 'net/http'
require 'digest/md5'

class ProxiesController < ApplicationController
  def show
    raise 'invalid' unless params[:url]

    data = Rails.cache.fetch("proxies#show__#{Digest::MD5.hexdigest params[:url]}", expires_in: 1.hours) do
      url = URI.parse(params[:url])
      resp = Net::HTTP.get_response(url)
      if resp.code =~ /\A2\d+\z/ && resp.size < IMAGE_MAX_SIZE && IMAGE_CONTENT_TYPE.include?(resp.content_type)
        {
            content_type: resp.content_type,
            body: resp.body,
        }
      else
        nil
      end
    end

    if data
      send_data data[:body], type: data[:content_type], disposition: 'inline'
    else
      raise '404'
    end
  end

  IMAGE_MAX_SIZE = 1024

  IMAGE_CONTENT_TYPE = %w[
    image/gif
    image/jpeg
    image/x-png
    image/png
  ]
end
