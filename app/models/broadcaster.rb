class Broadcaster

  def self.instance
    ENV['BROADCASTER_PROVIDER'] == 'lite' ? "Broadcaster::Lite".constantize.new : Broadcaster::ApiGateway.new
  end

  def self.broadcast(path, data)
    instance.broadcast(path, data)
  end

  def broadcast(path, data)
    WebsocketSubscription.where(path: path).each do |subscription|
      send_message(subscription.connection_id, path, data)
    end
  end

  def send_message(connection_id, path, data)
    raise "override me"
  end
end
