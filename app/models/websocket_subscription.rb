class WebsocketSubscription < ApplicationRecord
  validates_presence_of :path, :connection_id

  # def self.connect(connection_id)
  #   return unless connection_id.present?
  #
  #   WebsocketConnection.find_or_create_by!(connection_id: connection_id)
  # end

  def self.subscribe(path, connection_id)
    find_or_create_by!(path: path, connection_id: connection_id)
  end

  def self.unsubscribe(path, connection_id)
    where(path: path, connection_id: connection_id).delete_all
  end

  def self.disconnect(connection_id)
    return unless connection_id.present?

    where(connection_id: connection_id).delete_all
  end

  def self.broadcast(path, data)
    puts "WebsocketSubcription broadcast #{path} #{data}"
    where(path: path).each do |subscription|
      puts "WHERE"
      subscription.send_message(path, data)
    end
  end

  def send_message(path, data)
    puts "WebsocketSubcription send_message #{path} #{data}"
    LiteCable.broadcast broadcast_channel, { path: path, data: data }
    puts "WebsocketSubcription send_message DONE"
  end

  def broadcast_channel
    "lite_router_#{connection_id}"
  end

  # def self.send_message(domain, stage, data)
  #
  #   find_each do |connection|
  #     begin
  #     rescue Aws::ApiGatewayManagementApi::Errors::GoneException
  #       connection.destroy
  #     end
  #   end
  # end

  # def send_message(domain, stage, data)
  #   client = Aws::ApiGatewayManagementApi::Client.new(
  #     endpoint: "https://#{domain}/#{stage}"
  #   )
  #
  #   # data = {
  #   #   version: "0.8.2",
  #   #   data: data,
  #   #   type: :text
  #   # }
  #
  #   data = data.to_json if data.is_a?(Hash)
  #
  #   client.post_to_connection(
  #     connection_id: self.connection_id,
  #     data: data.to_json
  #   )
  # end
end
