# frozen_string_literal: true

require_relative "application"

# app = Rack::Builder.new do
#   map "/" do
#     run App
#   end
# end

unless ENV["ANYCABLE"]
  # Start built-in rack hijack middleware to serve websockets
  require "lite_cable"
  require "lite_cable/server"
  require_relative "dev/lite_router"
  require_relative "dev/broadcaster/lite"

  map "/cable" do
    use LiteCable::Server::Middleware, connection_class: LiteRouter::Connection
    run(proc { |_| [200, {"Content-Type" => "text/plain"}, ["OK"]] })
  end
end

# run app
