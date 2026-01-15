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

    WebsocketConnection.find_each do |connection|
      begin
      rescue Aws::ApiGatewayManagementApi::Errors::GoneException
        connection.destroy
      end
    end
  end

  def send_message(domain, stage, data)
    client = Aws::ApiGatewayManagementApi::Client.new(
      endpoint: "https://#{domain}/#{stage}"
    )

    # data = {
    #   version: "0.8.2",
    #   data: data,
    #   type: :text
    # }

    data = data.to_json if data.is_a?(Hash)

    client.post_to_connection(
      connection_id: self.connection_id,
      data: data.to_json
    )
  end
end
