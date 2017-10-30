require 'line/bot'

module Api
  module V1
    module Line
      class BaseController < ApplicationController
        protect_from_forgery with: :null_session

        def client
          @client ||= ::Line::Bot::Client.new do |config|
            config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
            config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
          end
        end
      end
    end
  end
end
