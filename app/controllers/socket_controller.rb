class SocketController

  SUBCLASSES = [RoomsSocketController]

  def self.handle_path(path, input)
    SUBCLASSES.each do |klass|
      klass.new.handle_path(path, input)
    end
  end

  def self.can_subscribe?(path)
    SUBCLASSES.any? do |klass|
      klass.new.can_subscribe?(path)
    end
  end

  def broadcast(path, data)

  end
end
