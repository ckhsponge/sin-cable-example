# frozen_string_literal: true

require "litecable"
require "anycable"

# Sample chat application
module LiteRouter
  class Connection < LiteCable::Connection::Base # :nodoc:
    # identified_by :user, :sid
    identified_by :connection_id

    def connect
      puts "Connection connect"
      puts "WebSocket URL: #{request.url}"
      puts "Request params: #{request.params.inspect}"
      # self.user = cookies["user"]
      self.connection_id = request.params["connection_id"]
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
      reject unless connection_id
      stream_from broadcast_channel
    end

    def perform(data)
      data = data.with_indifferent_access
      puts "PERFORM #{data}"
      path = data[:path]
      input = (data[:input] || {}).with_indifferent_access
      # connection_id = data[:connection_id]
      LiteCable.broadcast broadcast_channel, { result: 'performed', path: path, input: input, connection_id: connection_id }
      SocketController.handle_path(path, input)
    end

    def subscribe(data)
      data = data.with_indifferent_access
      puts "SUBSCRIBE #{data}"
      path = data[:path]
      # connection_id = data[:connection_id]
      LiteCable.broadcast broadcast_channel, { result: 'subscribed', path: path, connection_id: connection_id }
      WebsocketSubscription.subscribe(path, connection_id)
    end

    def unsubscribe(data)
      data = data.with_indifferent_access
      puts "SUBSCRIBE #{data}"
      path = data[:path]
      # connection_id = data[:connection_id]
      LiteCable.broadcast broadcast_channel, { result: 'unsubscribed', path: path, connection_id: connection_id }
      WebsocketSubscription.unsubscribe(path, connection_id)
    end

    private

    def broadcast_channel
      "lite_router_#{connection_id}"
    end

    def connection_id
      puts "CONNECTION_ID #{params.inspect}"
      params.fetch("connection_id")
    end
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
