require 'active_record'
require 'activerecord-dsql-adapter'

puts "Active Record connecting to: #{ENV['DATABASE_HOST']}"

ActiveRecord::Base.logger = ENV['SQL_LOGGING'] == 'false' ? nil : Logger.new(STDOUT)

ActiveRecord::Base.establish_connection(
  adapter:  'dsql',
  host:     ENV['DATABASE_HOST'],
  # username: 'admin',
  # database: 'postgres'
)
