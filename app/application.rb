Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# require 'bundler/setup'
# require 'rack'
# require 'rack/contrib'
# require 'rack/contrib/post_body_content_type_parser'
#
# require 'sinatra/base' # use /base for modular app
# require 'sinatra/json'
# require 'dotenv' if Sinatra::Base.development? || Sinatra::Base.test?
require 'json'
require 'zeitwerk'

def development?
  ENV['RACK_ENV'] != 'production'
end

if development?
  require 'byebug'
  require 'dotenv'
  Dotenv.load('../.env')

  # LiteCable.config.log_level = Logger::DEBUG
end

APP_ROOT = File.dirname(__FILE__)

# def development?
#   Sinatra::Base.development?
# end

# Dotenv.load('../.env') if development?
# require 'bundler/setup'
# require 'rack'
# require 'rack/contrib'
# require 'rack/contrib/post_body_content_type_parser'
#
# require 'sinatra/base' # use /base for modular app
# require 'sinatra/json'

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/models")
loader.push_dir("#{__dir__}/controllers")
loader.setup

Dir["#{APP_ROOT}/initializers/*.rb"].sort.each { |file| puts file; require file }
Aws.use_bundled_cert!

require 'sinatra/activerecord' if development? # so migrations can run

puts 'Done application load'
