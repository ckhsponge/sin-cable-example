class WebsocketConnection < ApplicationRecord

  def self.connect(connection_id)
    return unless connection_id.present?

    WebsocketConnection.find_or_create_by!(connection_id: connection_id)
  end

  def self.disconnect(connection_id)
    return unless connection_id.present?

    WebsocketConnection.where(connection_id: connection_id).delete_all
  end

  def self.send_message(domain, stage, data)
    client = Aws::ApiGatewayManagementApi::Client.new(
      endpoint: "https://#{domain}/#{stage}"
    )

    WebsocketConnection.find_each do |connection|
      begin
        client.post_to_connection(
          connection_id: connection.connection_id,
          data: data
        )
      rescue Aws::ApiGatewayManagementApi::Errors::GoneException
        connection.destroy
      end
    end
  end
end
