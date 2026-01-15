# frozen_string_literal: true

require "litecable"
require "anycable"

# Sample chat application
module LiteRouter
  class Connection < LiteCable::Connection::Base # :nodoc:
    # identified_by :user, :sid
    identified_by :sid

    def connect
      puts "Connection connect"
      puts "WebSocket URL: #{request.url}"
      puts "Request params: #{request.params.inspect}"
      # self.user = cookies["user"]
      self.sid = request.params["sid"]
      # reject_unauthorized_connection unless user
      # $stdout.puts "#{user} connected"
      $stdout.puts "connected"
    end

    def disconnect
      # $stdout.puts "#{user} disconnected"
      $stdout.puts "disconnected"
    end
  end

  class Channel < LiteCable::Channel::Base # :nodoc:
    identifier :lite_router

    def subscribed
      # reject unless chat_id
      stream_from "lite_router"
    end

    def speak(data)
      LiteCable.broadcast "lite_router", { message: data["message"], sid: sid }
    end

    private

    # def chat_id
    #   puts "CHAT_ID #{params.inspect}"
    #   params.fetch("id")
    # end
  end
end

# LiteCable::Connection::Subscriptions
#
# module LiteCable
#   module Connection
#     # Manage the connection channels and route messages
#     class Subscriptions
#       def find(identifier)
#         s = subscriptions[identifier]
#         puts "SUBSCRIPTIONS #{identifier} #{subscriptions}"
#         s
#       end
#     end
#   end
# end
