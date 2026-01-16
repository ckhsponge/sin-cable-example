

class RoomsSocketController

  def handle_path(path, input)
    return unless path =~ /rooms\//

    puts "HANDLE PATH #{path} #{input}"
    Broadcaster.broadcast(path, message: input[:message], user: input[:user])
  end

  def can_subscribe?(path)
    path =~ /rooms\//
  end
end