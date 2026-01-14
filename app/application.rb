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
loader.setup

Dir["#{APP_ROOT}/initializers/*.rb"].sort.each { |file| puts file; require file }

# require 'sinatra/activerecord'

Aws.use_bundled_cert!


puts 'Done application load'
